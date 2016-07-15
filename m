Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72C326B0261
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 15:00:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so234085204pfx.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 12:00:45 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id fd8si10468360pad.61.2016.07.15.12.00.44
        for <linux-mm@kvack.org>;
        Fri, 15 Jul 2016 12:00:44 -0700 (PDT)
Date: Fri, 15 Jul 2016 13:00:40 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] radix-tree: fix radix_tree_iter_retry() for tagged
 iterators.
Message-ID: <20160715190040.GA7195@linux.intel.com>
References: <CACT4Y+a99OW7TYeLsuEic19uY2j45DGXL=LowUMq3TywWS3f2Q@mail.gmail.com>
 <1468495196-10604-1-git-send-email-aryabinin@virtuozzo.com>
 <20160714222527.GA26136@linux.intel.com>
 <5788A46A.70106@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5788A46A.70106@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, stable@vger.kernel.org

On Fri, Jul 15, 2016 at 11:52:58AM +0300, Andrey Ryabinin wrote:
> On 07/15/2016 01:25 AM, Ross Zwisler wrote:
> > On Thu, Jul 14, 2016 at 02:19:56PM +0300, Andrey Ryabinin wrote:
> >> radix_tree_iter_retry() resets slot to NULL, but it doesn't reset tags.
> >> Then NULL slot and non-zero iter.tags passed to radix_tree_next_slot()
> >> leading to crash:
> >>
> >> RIP: [<     inline     >] radix_tree_next_slot include/linux/radix-tree.h:473
> >>   [<ffffffff816951a4>] find_get_pages_tag+0x334/0x930 mm/filemap.c:1452
> >> ....
> >> Call Trace:
> >>  [<ffffffff816cd91a>] pagevec_lookup_tag+0x3a/0x80 mm/swap.c:960
> >>  [<ffffffff81ab4231>] mpage_prepare_extent_to_map+0x321/0xa90 fs/ext4/inode.c:2516
> >>  [<ffffffff81ac883e>] ext4_writepages+0x10be/0x2b20 fs/ext4/inode.c:2736
> >>  [<ffffffff816c99c7>] do_writepages+0x97/0x100 mm/page-writeback.c:2364
> >>  [<ffffffff8169bee8>] __filemap_fdatawrite_range+0x248/0x2e0 mm/filemap.c:300
> >>  [<ffffffff8169c371>] filemap_write_and_wait_range+0x121/0x1b0 mm/filemap.c:490
> >>  [<ffffffff81aa584d>] ext4_sync_file+0x34d/0xdb0 fs/ext4/fsync.c:115
> >>  [<ffffffff818b667a>] vfs_fsync_range+0x10a/0x250 fs/sync.c:195
> >>  [<     inline     >] vfs_fsync fs/sync.c:209
> >>  [<ffffffff818b6832>] do_fsync+0x42/0x70 fs/sync.c:219
> >>  [<     inline     >] SYSC_fdatasync fs/sync.c:232
> >>  [<ffffffff818b6f89>] SyS_fdatasync+0x19/0x20 fs/sync.c:230
> >>  [<ffffffff86a94e00>] entry_SYSCALL_64_fastpath+0x23/0xc1 arch/x86/entry/entry_64.S:207
> >>
> >> We must reset iterator's tags to bail out from radix_tree_next_slot() and
> >> go to the slow-path in radix_tree_next_chunk().
> > 
> > This analysis doesn't make sense to me.  In find_get_pages_tag(), when we call
> > radix_tree_iter_retry(), this sets the local 'slot' variable to NULL, then
> > does a 'continue'.  This will hop to the next iteration of the
> > radix_tree_for_each_tagged() loop, which will very check the exit condition of
> > the for() loop:
> > 
> > #define radix_tree_for_each_tagged(slot, root, iter, start, tag)	\
> > 	for (slot = radix_tree_iter_init(iter, start) ;			\
> > 	     slot || (slot = radix_tree_next_chunk(root, iter,		\
> > 			      RADIX_TREE_ITER_TAGGED | tag)) ;		\
> > 	     slot = radix_tree_next_slot(slot, iter,			\
> > 				RADIX_TREE_ITER_TAGGED))
> > 
> > So, we'll run the 
> > 	     slot || (slot = radix_tree_next_chunk(root, iter,		\
> > 			      RADIX_TREE_ITER_TAGGED | tag)) ;		\
> > 
> > bit first.  
> 
> This is not the way how the for() loop works. slot = radix_tree_next_slot() executed first
> and only after that goes the condition statement.

Right...*sigh*...  Thanks for the sanity check. :)

> > 'slot' is NULL, so we'll set it via radix_tree_next_chunk().  At
> > this point radix_tree_next_slot() hasn't been called.
> > 
> > radix_tree_next_chunk() will set up the iter->index, iter->next_index and
> > iter->tags before it returns.  The next iteration of the loop in
> > find_get_pages_tag() will use the non-NULL slot provided by
> > radix_tree_next_chunk(), and only after that iteration will we call
> > radix_tree_next_slot() again.  By then iter->tags should be up to date.
> > 
> > Do you have a test setup that reliably fails without this code but passes when
> > you zero out iter->tags?
> > 
> 
> 
> Yup, I run Dmitry's reproducer in a parallel loop:
> 	$ while true; do ./a.out & done
> 
> Usually it takes just couple minutes maximum.

Cool - I was able to get this to work on my system as well by upping the
thread count.

In looking at this more, I agree that your patch fixes this particular bug,
but I think that ultimately we might want something more general.

IIUC, the real issue is that we shouldn't be running through
radix_tree_next_slot() with a NULL 'slot' parameter.  In the end I think it's
fine to zero out iter->tags in radix_tree_iter_retry(), but really we want to
guarantee that we just bail out of radix_tree_next_slot() if we have a NULL
'slot'.

I've run this patch in my test setup, and it fixes the reproducer provided by
Dmitry.  I've also run xfstests against it with out any failures.

--- 8< ---
