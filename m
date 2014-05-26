Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2596B0035
	for <linux-mm@kvack.org>; Mon, 26 May 2014 07:44:14 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id uy17so3146451igb.5
        for <linux-mm@kvack.org>; Mon, 26 May 2014 04:44:14 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id n5si19942573icc.105.2014.05.26.04.44.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 May 2014 04:44:13 -0700 (PDT)
Received: by mail-ie0-f173.google.com with SMTP id lx4so7582335iec.32
        for <linux-mm@kvack.org>; Mon, 26 May 2014 04:44:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1405191403280.969@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
	<alpine.LSU.2.11.1405132118330.4401@eggly.anvils>
	<537396A2.9090609@cybernetics.com>
	<alpine.LSU.2.11.1405141456420.2268@eggly.anvils>
	<CANq1E4QgSbD9G70H7W4QeXbZ77_Kn1wV7edwzN4k4NjQJS=36A@mail.gmail.com>
	<20140519160942.GD3427@quack.suse.cz>
	<alpine.LSU.2.11.1405191403280.969@eggly.anvils>
Date: Mon, 26 May 2014 13:44:13 +0200
Message-ID: <CANq1E4TDDzG+HtBz261_nid3kVRG_jwcWHizzkdZCZZE3BaLgQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Kara <jack@suse.cz>, Tony Battersby <tonyb@cybernetics.com>, Al Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mgorman@suse.de>

Hi

(CC migrate.c committers)

On Tue, May 20, 2014 at 12:11 AM, Hugh Dickins <hughd@google.com> wrote:
> On Mon, 19 May 2014, Jan Kara wrote:
>> On Mon 19-05-14 13:44:25, David Herrmann wrote:
>> > On Thu, May 15, 2014 at 12:35 AM, Hugh Dickins <hughd@google.com> wrote:
>> > > The aspect which really worries me is this: the maintenance burden.
>> > > This approach would add some peculiar new code, introducing a rare
>> > > special case: which we might get right today, but will very easily
>> > > forget tomorrow when making some other changes to mm.  If we compile
>> > > a list of danger areas in mm, this would surely belong on that list.
>> >
>> > I tried doing the page-replacement in the last 4 days, but honestly,
>> > it's far more complex than I thought. So if no-one more experienced
>
> To be honest, I'm quite glad to hear that: it is still a solution worth
> considering, but I'd rather continue the search for a better solution.

What if we set VM_IO for memory-mappings if a file supports sealing?
That might be a hack and quite restrictive, but we could also add a
VM_DONTPIN flag that just prevents any page-pinning like GUP (which is
also a side-effect of VM_IO). This is basically what we do to protect
PCI BARs from that race during hotplug (well, VM_PFNMAP ist what
protects those, but the code is the same). If we mention in the
man-page that memfd-objects don't support direct-IO, we'd be fine, I
think. Not sure if that hack is better than the page-replacement,
though. It'd be definitely much simpler.

Regarding page-replacement, I tried using migrate_page(), however,
this obviously fails in page_freeze_refs() due to the elevated
ref-count and we cannot account for those, as they might vanish
asynchronously. Now I wonder whether we could just add a new mode
MIGRATE_PHASE_OUT that avoids freezing the page and forces the copy.
Existing refs would still operate on the old page, but any new access
gets the new page. This way, we could collect pages with elevated
ref-counts in shmem similar to do_move_page_to_node_array() and then
call migrate_pages(). Now migrate_pages() takes good care to prevent
any new refs during migration. try_to_unmap(TTU_MIGRATION) marks PTEs
as 'in-migration', so accesses are delayed. Page-faults wait on the
page-lock and retry due to mapping==NULL. lru is disabled beforehand.
Therefore, there cannot be any racing page-lookups as they all stall
on the migration. Moreover, page_freeze_refs() fails only if the page
is pinned by independent users (usually some form of I/O).
Question is what those additional ref-counts might be. Given that
shmem 'owns' its pages, none of these external references should pass
those refs around. All they use it for is I/O. Therefore, we shouldn't
even need an additional try_to_unmap() _after_ MIGRATE_PHASE_OUT as we
expect those external refs to never pass page-refs around. If that's a
valid assumption (and I haven't found any offenders so far), we should
be good with migrate_pages(MIGRATE_PHASE_OUT) as I described.

Comments?

While skimming over migrate.c I noticed two odd behaviors:
1) migration_entry_wait() is used to wait on a migration to finish,
before accessing PTE entries. However, we call get_page() there, which
increases the ref-count of the old page and causes page_freeze_refs()
to fail. There's no way we can know how many tasks wait on a migration
entry when calling page_freeze_refs(). I have no idea how that's
supposed to work? Why don't we store the new page in the migration-swp
entry so any lookups stall on the new page? We don't care for
ref-counts on that page and if the migration fails, new->mapping is
set to NULL and any lookup is retried. remove_migration_pte() can
restore the old page correctly.
2) remove_migration_pte() calls get_page(new) before writing the PTE.
But who releases the ref of the old page?

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
