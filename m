Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 670556B0005
	for <linux-mm@kvack.org>; Tue,  1 May 2018 02:32:53 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id g67-v6so8431617otb.10
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 23:32:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p42-v6sor4285189ote.82.2018.04.30.23.32.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 23:32:51 -0700 (PDT)
Date: Mon, 30 Apr 2018 23:32:42 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC v5 PATCH] mm: shmem: make stat.st_blksize return huge page
 size if THP is on
In-Reply-To: <1524665633-83806-1-git-send-email-yang.shi@linux.alibaba.com>
Message-ID: <alpine.LSU.2.11.1804302217530.5864@eggly.anvils>
References: <1524665633-83806-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, mhocko@kernel.org, hch@infradead.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 25 Apr 2018, Yang Shi wrote:

> Since tmpfs THP was supported in 4.8, hugetlbfs is not the only
> filesystem with huge page support anymore. tmpfs can use huge page via
> THP when mounting by "huge=" mount option.
> 
> When applications use huge page on hugetlbfs, it just need check the
> filesystem magic number, but it is not enough for tmpfs. Make
> stat.st_blksize return huge page size if it is mounted by appropriate
> "huge=" option to give applications a hint to optimize the behavior with
> THP.
> 
> Some applications may not do wisely with THP. For example, QEMU may mmap
> file on non huge page aligned hint address with MAP_FIXED, which results
> in no pages are PMD mapped even though THP is used. Some applications
> may mmap file with non huge page aligned offset. Both behaviors make THP
> pointless.
> 
> statfs.f_bsize still returns 4KB for tmpfs since THP could be split, and it
> also may fallback to 4KB page silently if there is not enough huge page.
> Furthermore, different f_bsize makes max_blocks and free_blocks
> calculation harder but without too much benefit. Returning huge page
> size via stat.st_blksize sounds good enough.
> 
> Since PUD size huge page for THP has not been supported, now it just
> returns HPAGE_PMD_SIZE.
> 
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>

Sorry, I have no enthusiasm for this patch; but do I feel strongly
enough to override you and everyone else to NAK it? No, I don't
feel that strongly, maybe st_blksize isn't worth arguing over.

We did look at struct stat when designing huge tmpfs, to see if there
were any fields that should be adjusted for it; but concluded none.
Yes, it would sometimes be nice to have a quickly accessible indicator
for when tmpfs has been mounted huge (scanning /proc/mounts for options
can be tiresome, agreed); but since tmpfs tries to supply huge (or not)
pages transparently, no difference seemed right.

So, because st_blksize is a not very useful field of struct stat,
with "size" in the name, we're going to put HPAGE_PMD_SIZE in there
instead of PAGE_SIZE, if the tmpfs was mounted with one of the huge
"huge" options (force or always, okay; within_size or advise, not so
much). Though HPAGE_PMD_SIZE is no more its "preferred I/O size" or
"blocksize for file system I/O" than PAGE_SIZE was.

Which we can expect to speed up some applications and disadvantage
others, depending on how they interpret st_blksize: just like if
we changed it in the same way on non-huge tmpfs.  (Did I actually
try changing st_blksize early on, and find it broke something? If
so, I've now forgotten what, and a search through commit messages
didn't find it; but I guess we'll find out soon enough.)

If there were an mstat() syscall, returning a field "preferred
alignment", then we could certainly agree to put HPAGE_PMD_SIZE in
there; but in stat()'s st_blksize? And what happens when (in future)
mm maps this or that hard-disk filesystem's blocks with a pmd mapping
- should that filesystem then advertise a bigger st_blksize, despite
the same disk layout as before? What happens with DAX?

And this change is not going to help the QEMU suboptimality that
brought you here (or does QEMU align mmaps according to st_blksize?).
QEMU ought to work well with kernels without this change, and kernels
with this change; and I hope it can easily deal with both by avoiding
that use of MAP_FIXED which prevented the kernel's intended alignment.

Hugh

> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> ---
> v4 --> v5:
> * Adopted suggestion from Kirill to use IS_ENABLED and check 'force' and
>   'deny'. Extracted the condition into an inline helper.
> v3 --> v4:
> * Rework the commit log per the education from Michal and Kirill
> * Fix build error if CONFIG_TRANSPARENT_HUGEPAGE is disabled
> v2 --> v3:
> * Use shmem_sb_info.huge instead of global variable per Michal's comment
> v2 --> v1:
> * Adopted the suggestion from hch to return huge page size via st_blksize
>   instead of creating a new flag.
> 
>  mm/shmem.c | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index b859192..e9e888b 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -571,6 +571,16 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGE_PAGECACHE */
>  
> +static inline bool is_huge_enabled(struct shmem_sb_info *sbinfo)
> +{
> +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
> +	    (shmem_huge == SHMEM_HUGE_FORCE || sbinfo->huge) &&
> +	    shmem_huge != SHMEM_HUGE_DENY)
> +		return true;
> +	else
> +		return false;
> +}
> +
>  /*
>   * Like add_to_page_cache_locked, but error if expected item has gone.
>   */
> @@ -988,6 +998,7 @@ static int shmem_getattr(const struct path *path, struct kstat *stat,
>  {
>  	struct inode *inode = path->dentry->d_inode;
>  	struct shmem_inode_info *info = SHMEM_I(inode);
> +	struct shmem_sb_info *sb_info = SHMEM_SB(inode->i_sb);
>  
>  	if (info->alloced - info->swapped != inode->i_mapping->nrpages) {
>  		spin_lock_irq(&info->lock);
> @@ -995,6 +1006,10 @@ static int shmem_getattr(const struct path *path, struct kstat *stat,
>  		spin_unlock_irq(&info->lock);
>  	}
>  	generic_fillattr(inode, stat);
> +
> +	if (is_huge_enabled(sb_info))
> +		stat->blksize = HPAGE_PMD_SIZE;
> +
>  	return 0;
>  }
>  
> -- 
> 1.8.3.1
> 
> 
