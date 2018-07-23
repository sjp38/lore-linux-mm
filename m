Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03F816B0005
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 15:14:52 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x20-v6so1025730pln.13
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 12:14:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37-v6sor2949723plc.101.2018.07.23.12.14.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 12:14:50 -0700 (PDT)
Date: Mon, 23 Jul 2018 12:14:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
In-Reply-To: <20180723140150.GA31843@bombadil.infradead.org>
Message-ID: <alpine.LSU.2.11.1807231111310.1698@eggly.anvils>
References: <000000000000d624c605705e9010@google.com> <20180709143610.GD2662@bombadil.infradead.org> <alpine.LSU.2.11.1807221856350.5536@eggly.anvils> <20180723140150.GA31843@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Mon, 23 Jul 2018, Matthew Wilcox wrote:
> On Sun, Jul 22, 2018 at 07:28:01PM -0700, Hugh Dickins wrote:
> > Whether or not that fixed syzbot's kernel BUG at mm/shmem.c:815!
> > I don't know, but I'm afraid it has not fixed linux-next breakage of
> > huge tmpfs: I get a similar page_to_pgoff BUG at mm/filemap.c:1466!
> > 
> > Please try something like
> > mount -o remount,huge=always /dev/shm
> > cp /dev/zero /dev/shm
> > 
> > Writing soon crashes in find_lock_entry(), looking up offset 0x201
> > but getting the page for offset 0x3c1 instead.
> 
> Hmm.  I don't see a crash while running that command,

Thanks for looking.

It is the VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page)
in find_lock_entry(). Perhaps you didn't have CONFIG_DEBUG_VM=y
on this occasion? Or you don't think of an oops as a kernel crash,
and didn't notice it in dmesg? I see now that I've arranged for oops
to crash, since I don't like to miss them myself; but it is a very
clean oops, no locks held, so can just kill the process and continue.

I recommend CONFIG_DEBUG_VM=y (for developers, not for distros), but
if you'd prefer to avoid it for now, just edit that VM_BUG_ON_PAGE()
in find_lock_entry() to a BUG_ON().

Or is there something more mysterious stopping it from showing up for
you? It's repeatable for me. When not crashing, that "cp" should fill
up about half of RAM before it hits the implicit tmpfs volume limit;
but I am assuming a not entirely fragmented machine - it does need
to allocate two 2MB pages before hitting the VM_BUG_ON_PAGE().

If you still can't see the crash, look to see how long /dev/shm/zero
is after the "cp": mine crashes a page or two over 2MB (I'm being
vague because I'm typing from the laptop I'd prefer not to reproduce
it on at the moment: I think it would be 1 page over, i_size not yet
updated for the page of index 0x201). But the xarray should by that
stage have been populated for two 2MB pages (by your "goto next" loop
in shmem_add_to_page_cache()).

> but I do see an RCU
> stall in find_get_entries() called from shmem_undo_range() when running
> 'cp' the second time -- ie while truncating the /dev/shm/zero file.

When I stopped oops crashing, I did indeed hang on that second attempt:
no "RCU stall" seen, but I've probably missed the relevant config option.

I wouldn't like to predict what happens if find_get_entry() returns the
wrong page when that VM_BUG_ON_PAGE() is compiled out, very confusing.
If it's compiled in, but just killed the process and dmesg was missed,
then there's an unlocked page lock which will indeed hang a subsequent
truncate (if the xarray yields the same wrong page again), though I
don't know if that would amount to an RCU stall.

> Maybe I'm seeing the same bug as you, and maybe I'm seeing a different
> one.  Do we have a shmem test suite somewhere?

Not as such. xfstests works on tmpfs, huge or not, but I'd have to write
up a few instructions, note one or two "-g auto" tests to patch out since
they take forever on tmpfs, and the few failures expected; and update my
snapshot of the tree to check that over first (I pulled it last mid-May).

I'd rather not get into that at present: a working "cp" will be a great
step forward, then I can easily run xfstests on the fixed kernel.

> 
> > I've spent a while on it, but better turn over to you, Matthew:
> > my guess is that xas_create_range() does not create the layout
> > you expect from it.
> 
> I've dumped the XArray tree on my machine and it actually looks fine
> *except* that the pages pointed to are free!  That indicates to me I
> screwed up somebody's reference count somewhere.

I don't actually know what a good xarray for two 2MB pages should look
like, since the best I can find seems to be a bad one!

Are you sure that those pages are free, rather than most of them tails
of one of the two compound pages involved? I think it's the same in your
rewrite of struct page, the compound_head field (lru.next), with its low
bit set, were how to recognize a tail page.

Hugh
