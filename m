Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2983A6B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 18:12:24 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so6379774pab.28
        for <linux-mm@kvack.org>; Mon, 19 May 2014 15:12:23 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id zs2si3687133pbb.482.2014.05.19.15.12.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 15:12:23 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so6403272pab.10
        for <linux-mm@kvack.org>; Mon, 19 May 2014 15:12:22 -0700 (PDT)
Date: Mon, 19 May 2014 15:11:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 0/3] File Sealing & memfd_create()
In-Reply-To: <20140519160942.GD3427@quack.suse.cz>
Message-ID: <alpine.LSU.2.11.1405191403280.969@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com> <alpine.LSU.2.11.1405132118330.4401@eggly.anvils> <537396A2.9090609@cybernetics.com> <alpine.LSU.2.11.1405141456420.2268@eggly.anvils> <CANq1E4QgSbD9G70H7W4QeXbZ77_Kn1wV7edwzN4k4NjQJS=36A@mail.gmail.com>
 <20140519160942.GD3427@quack.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: David Herrmann <dh.herrmann@gmail.com>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Al Viro <viro@zeniv.linux.org.uk>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

On Mon, 19 May 2014, Jan Kara wrote:
> On Mon 19-05-14 13:44:25, David Herrmann wrote:
> > On Thu, May 15, 2014 at 12:35 AM, Hugh Dickins <hughd@google.com> wrote:
> > > The aspect which really worries me is this: the maintenance burden.
> > > This approach would add some peculiar new code, introducing a rare
> > > special case: which we might get right today, but will very easily
> > > forget tomorrow when making some other changes to mm.  If we compile
> > > a list of danger areas in mm, this would surely belong on that list.
> > 
> > I tried doing the page-replacement in the last 4 days, but honestly,
> > it's far more complex than I thought. So if no-one more experienced

To be honest, I'm quite glad to hear that: it is still a solution worth
considering, but I'd rather continue the search for a better solution.

> > with mm/ comes up with a simple implementation, I'll have to delay
> > this for some more weeks.
> > 
> > However, I still wonder why we try to fix this as part of this
> > patchset. Using FUSE, a DIRECT-IO call can be delayed for an arbitrary
> > amount of time. Same is true for network block-devices, NFS, iscsi,
> > maybe loop-devices, ... This means, _any_ once mapped page can be
> > written to after an arbitrary delay. This can break any feature that
> > makes FS objects read-only (remounting read-only, setting S_IMMUTABLE,
> > sealing, ..).

We need to fix it together with your sealing patchset, because your
patchset is all about introducing a new kind of guarantee: a guarantee
which this async i/o issue makes impossible to give, as things stand.

Exasperating for you, I understand; but that's how it is.
A new feature may make new demands on the infrastructure.

I can imagine existing problems, but (I may be out of touch) I have
not heard of them as problems in practice.  Certainly they would not
be recent regressions: mm-page versus fs-file has worked in this way
for as long as I've known them (pages released independently of
unmapping the file, with the understanding that i/o might still
be in progress, so care taken not to free the pages too soon).

> > 
> > Shouldn't we try to fix the _cause_ of this?

Nobody is against fixing the cause: we are all looking for the
simplest way of doing so,

> > 
> > Isn't there a simple way to lock/mark/.. affected vmas in
> > get_user_pages(_fast)() and release them once done? We could increase
> > i_mmap_writable on all affected address_space and decrease it on
> > release. This would at least prevent sealing and could be check on
> > other operations, too (like setting S_IMMUTABLE).
> > This should be as easy as checking page_mapping(page) != NULL and then
> > adjusting ->i_mmap_writable in
> > get_writable_user_pages/put_writable_user_pages, right?
>   Doing this would be quite a bit of work. Currently references returned by
> get_user_pages() are page references like any other and thus are released
> by put_page() or similar. Now you would make them special and they need
> special releasing and there are lots of places in kernel where
> get_user_pages() is used that would need changing.

Lots of places that would need changing, yes; but we have often
wondered in the past whether there should be a put_user_pages().
Though I'm not sure that it would actually solve anything...

> 
> Another aspect is that it could have performance implications - if there
> are several processes using get_user_pages[_fast]() on a file, they would
> start contending on modifying i_mmap_writeable.

Doing extra vma work in get_user_pages() wouldn't be so bad.  But doing
any vma work in get_user_pages_fast() would upset almost all its users:
get_user_pages_fast() is a fast-path which expressly avoids the vmas,
and hates additional cachelines being added to its machinations.

If sealing had appeared before get_user_pages_fast(), maybe we wouldn't
have let get_user_pages_fast() in; but now it's the other way around.

I would be more interested in attacking from the get_user_pages() and
get_user_pages_fast() end, if I could convince myself that they do
actually delimit the problem; maybe they do, but I'm not yet convinced.

> 
> One somewhat crazy idea I have is that maybe we could delay unmapping of a
> page if this was last VMA referencing it until all extra page references of
> pages in there are dropped. That would make i_mmap_writeable reliable for
> you and it would also close those races with remount. Hugh, do you think
> this might be viable?

It is definitely worth pursuing further, but I'm not very hopeful on it.
In a world of free page flags and free struct page fields, maybe.  (And
I don't see sealing as a feature sensibly restricted to 64-bit only.)

I think we would have to set a page flag, maybe bump a count, for every
leftover page that raises i_mmap_writable; and lower it (potentially from
interrupt context) at put_page() time.  Easy to make i_mmap_writable an
atomic rather than guarded by i_mmap_mutex, but we still need to
synchronize on it falling to 0.

And how would we recognize the relevant, decrementing, put_page()?
page_count divided into "read_"count and write_count?  Ugh!

I also have a strong instinct against adding delays into munmap+exit;
though that mainly comes from the urge to free memory, and here we are
only delaying until a page becomes freeable, so maybe I should abandon
that bias in this case.

I did start thinking in this direction last week, but stuck somewhere
and retreated, I forget on what issue.  At this moment I'm not really
in that zone, but anxious to complete my promised responses to David's
patches, which I almost but not quite completed last night.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
