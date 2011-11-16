Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 50A1C6B0069
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 20:19:52 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F3DF33EE0C2
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 10:19:47 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D403E45DE68
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 10:19:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BA9DE45DE4D
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 10:19:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AE8621DB803C
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 10:19:47 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 69D4E1DB802C
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 10:19:47 +0900 (JST)
Date: Wed, 16 Nov 2011 10:18:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch] tmpfs: add fallocate support
Message-Id: <20111116101846.5b017d1e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1321346525-10187-1-git-send-email-amwang@redhat.com>
References: <1321346525-10187-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Tue, 15 Nov 2011 16:42:05 +0800
Amerigo Wang <amwang@redhat.com> wrote:

> This patch adds fallocate support to tmpfs. I tested this patch
> with the following test case,
> 
> 	% sudo mount -t tmpfs -o size=100 tmpfs /mnt
> 	% touch /mnt/foobar
> 	% echo hi > /mnt/foobar
> 	% fallocate -o 3 -l 5000 /mnt/foobar          
> 	fallocate: /mnt/foobar: fallocate failed: No space left on device
> 	% fallocate -o 3 -l 3000 /mnt/foobar
> 	% ls -l /mnt/foobar
> 	-rw-rw-r-- 1 wangcong wangcong 3003 Nov 15 16:10 /mnt/foobar
> 	% dd if=/dev/zero of=/mnt/foobar seek=3 bs=1 count=3000
> 	3000+0 records in
> 	3000+0 records out
> 	3000 bytes (3.0 kB) copied, 0.0153224 s, 196 kB/s
> 	% hexdump -C /mnt/foobar                                   
> 	00000000  68 69 0a 00 00 00 00 00  00 00 00 00 00 00 00 00  |hi..............|
> 	00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
> 	*
> 	00000bb0  00 00 00 00 00 00 00 00  00 00 00                 |...........|
> 	00000bbb
> 	% cat /mnt/foobar
> 	hi
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> 
> ---
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d672250..438b7b8 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -30,6 +30,7 @@
>  #include <linux/mm.h>
>  #include <linux/export.h>
>  #include <linux/swap.h>
> +#include <linux/falloc.h>
>  
>  static struct vfsmount *shm_mnt;
>  
> @@ -1431,6 +1432,102 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
>  	return error;
>  }
>  
> +static long shmem_fallocate(struct file *file, int mode,
> +			    loff_t offset, loff_t len)
> +{
> +	struct inode *inode = file->f_path.dentry->d_inode;
> +	struct address_space *mapping = inode->i_mapping;
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
> +	pgoff_t start = DIV_ROUND_UP(offset, PAGE_CACHE_SIZE);
> +	pgoff_t end = DIV_ROUND_UP((offset + len), PAGE_CACHE_SIZE);
> +	pgoff_t index = start;
> +	gfp_t gfp = mapping_gfp_mask(mapping);
> +	loff_t i_size = i_size_read(inode);
> +	struct page *page = NULL;
> +	int ret;
> +
> +	if ((offset + len) <= i_size)
> +		return 0;
> +
> +	if (!(mode & FALLOC_FL_KEEP_SIZE)) {
> +		ret = inode_newsize_ok(inode, (offset + len));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	if (start == end) {
> +		if (!(mode & FALLOC_FL_KEEP_SIZE))
> +			i_size_write(inode, offset + len);
> +		return 0;
> +	}
> +
> +	if (shmem_acct_block(info->flags))
> +		return -ENOSPC;
> +
> +	if (sbinfo->max_blocks) {
> +		unsigned long blocks = (end - index) * BLOCKS_PER_PAGE;
> +		if (blocks + percpu_counter_sum(&sbinfo->used_blocks)
> +				>= sbinfo->max_blocks) {
> +			ret = -ENOSPC;
> +			goto unacct;
> +		}
> +	}
> +
> +	while (index < end) {
> +		if (sbinfo->max_blocks)
> +			percpu_counter_add(&sbinfo->used_blocks, BLOCKS_PER_PAGE);
> +
> +		page = shmem_alloc_page(gfp, info, index);
> +		if (!page) {
> +			ret = -ENOMEM;
> +			goto decused;
> +		}
> +
> +		SetPageSwapBacked(page);
> +		__set_page_locked(page);
> +		ret = mem_cgroup_cache_charge(page, current->mm,
> +						gfp & GFP_RECLAIM_MASK);
> +		if (!ret)
> +			ret = shmem_add_to_page_cache(page, mapping, index,
> +						gfp, NULL);
> +		if (ret)
> +			goto unlock;

The charges for memcg seems leaked here.
Please cancel 'charge' in error path. as

		if (ret) {
			mem_cgroup_uncharge_cache_page(page);
			goto unlock;
		}
> +		lru_cache_add_anon(page);
> +
> +		spin_lock(&info->lock);
> +		info->alloced++;
> +		inode->i_blocks += BLOCKS_PER_PAGE;
> +		inode->i_ctime = inode->i_mtime = CURRENT_TIME;
> +		shmem_recalc_inode(inode);
> +		spin_unlock(&info->lock);
> +
> +		clear_highpage(page);
> +		flush_dcache_page(page);
> +		SetPageUptodate(page);
> +		unlock_page(page);
> +		page_cache_release(page);
> +		cond_resched();
> +		index++;
> +		if (!(mode & FALLOC_FL_KEEP_SIZE))
> +			i_size_write(inode, index << PAGE_CACHE_SHIFT);
> +	}
> +

Hmm.. Doesn't this duplicate shmem_getpage_gfp() ? Can't you split/share codes ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
