Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id A79BE828E2
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 18:25:29 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so60284092pab.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 15:25:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id xg7si5121267pab.222.2016.07.14.15.25.28
        for <linux-mm@kvack.org>;
        Thu, 14 Jul 2016 15:25:28 -0700 (PDT)
Date: Thu, 14 Jul 2016 16:25:27 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] radix-tree: fix radix_tree_iter_retry() for tagged
 iterators.
Message-ID: <20160714222527.GA26136@linux.intel.com>
References: <CACT4Y+a99OW7TYeLsuEic19uY2j45DGXL=LowUMq3TywWS3f2Q@mail.gmail.com>
 <1468495196-10604-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468495196-10604-1-git-send-email-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, stable@vger.kernel.org

On Thu, Jul 14, 2016 at 02:19:56PM +0300, Andrey Ryabinin wrote:
> radix_tree_iter_retry() resets slot to NULL, but it doesn't reset tags.
> Then NULL slot and non-zero iter.tags passed to radix_tree_next_slot()
> leading to crash:
> 
> RIP: [<     inline     >] radix_tree_next_slot include/linux/radix-tree.h:473
>   [<ffffffff816951a4>] find_get_pages_tag+0x334/0x930 mm/filemap.c:1452
> ....
> Call Trace:
>  [<ffffffff816cd91a>] pagevec_lookup_tag+0x3a/0x80 mm/swap.c:960
>  [<ffffffff81ab4231>] mpage_prepare_extent_to_map+0x321/0xa90 fs/ext4/inode.c:2516
>  [<ffffffff81ac883e>] ext4_writepages+0x10be/0x2b20 fs/ext4/inode.c:2736
>  [<ffffffff816c99c7>] do_writepages+0x97/0x100 mm/page-writeback.c:2364
>  [<ffffffff8169bee8>] __filemap_fdatawrite_range+0x248/0x2e0 mm/filemap.c:300
>  [<ffffffff8169c371>] filemap_write_and_wait_range+0x121/0x1b0 mm/filemap.c:490
>  [<ffffffff81aa584d>] ext4_sync_file+0x34d/0xdb0 fs/ext4/fsync.c:115
>  [<ffffffff818b667a>] vfs_fsync_range+0x10a/0x250 fs/sync.c:195
>  [<     inline     >] vfs_fsync fs/sync.c:209
>  [<ffffffff818b6832>] do_fsync+0x42/0x70 fs/sync.c:219
>  [<     inline     >] SYSC_fdatasync fs/sync.c:232
>  [<ffffffff818b6f89>] SyS_fdatasync+0x19/0x20 fs/sync.c:230
>  [<ffffffff86a94e00>] entry_SYSCALL_64_fastpath+0x23/0xc1 arch/x86/entry/entry_64.S:207
> 
> We must reset iterator's tags to bail out from radix_tree_next_slot() and
> go to the slow-path in radix_tree_next_chunk().

This analysis doesn't make sense to me.  In find_get_pages_tag(), when we call
radix_tree_iter_retry(), this sets the local 'slot' variable to NULL, then
does a 'continue'.  This will hop to the next iteration of the
radix_tree_for_each_tagged() loop, which will very check the exit condition of
the for() loop:

#define radix_tree_for_each_tagged(slot, root, iter, start, tag)	\
	for (slot = radix_tree_iter_init(iter, start) ;			\
	     slot || (slot = radix_tree_next_chunk(root, iter,		\
			      RADIX_TREE_ITER_TAGGED | tag)) ;		\
	     slot = radix_tree_next_slot(slot, iter,			\
				RADIX_TREE_ITER_TAGGED))

So, we'll run the 
	     slot || (slot = radix_tree_next_chunk(root, iter,		\
			      RADIX_TREE_ITER_TAGGED | tag)) ;		\

bit first.  'slot' is NULL, so we'll set it via radix_tree_next_chunk().  At
this point radix_tree_next_slot() hasn't been called.

radix_tree_next_chunk() will set up the iter->index, iter->next_index and
iter->tags before it returns.  The next iteration of the loop in
find_get_pages_tag() will use the non-NULL slot provided by
radix_tree_next_chunk(), and only after that iteration will we call
radix_tree_next_slot() again.  By then iter->tags should be up to date.

Do you have a test setup that reliably fails without this code but passes when
you zero out iter->tags?

I've been looking at this as well, but haven't been able to get a reliable
reproducer in my test setup.

> Fixes: 46437f9a554f ("radix-tree: fix race in gang lookup")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Matthew Wilcox <willy@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: <stable@vger.kernel.org>
> ---
>  include/linux/radix-tree.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index cb4b7e8..eca6f62 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -407,6 +407,7 @@ static inline __must_check
>  void **radix_tree_iter_retry(struct radix_tree_iter *iter)
>  {
>  	iter->next_index = iter->index;
> +	iter->tags = 0;
>  	return NULL;
>  }
>  
> -- 
> 2.7.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
