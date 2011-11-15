Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0CEA36B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 05:23:55 -0500 (EST)
Message-ID: <4EC23DB0.3020306@redhat.com>
Date: Tue, 15 Nov 2011 18:23:44 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] tmpfs: add fallocate support
References: <1321346525-10187-1-git-send-email-amwang@redhat.com>
In-Reply-To: <1321346525-10187-1-git-send-email-amwang@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

CC: Lennart Poettering <lennart@poettering.net>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On 2011/11/15 16:42, Amerigo Wang wrote:
> This patch adds fallocate support to tmpfs. I tested this patch
> with the following test case,
>
> 	% sudo mount -t tmpfs -o size=100 tmpfs /mnt
> 	% touch /mnt/foobar
> 	% echo hi>  /mnt/foobar
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
> Signed-off-by: WANG Cong<amwang@redhat.com>
>
> ---
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d672250..438b7b8 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -30,6 +30,7 @@
>   #include<linux/mm.h>
>   #include<linux/export.h>
>   #include<linux/swap.h>
> +#include<linux/falloc.h>
>
>   static struct vfsmount *shm_mnt;
>
> @@ -1431,6 +1432,102 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
>   	return error;
>   }
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
> +	if ((offset + len)<= i_size)
> +		return 0;
> +
> +	if (!(mode&  FALLOC_FL_KEEP_SIZE)) {
> +		ret = inode_newsize_ok(inode, (offset + len));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	if (start == end) {
> +		if (!(mode&  FALLOC_FL_KEEP_SIZE))
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
> +	while (index<  end) {
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
> +						gfp&  GFP_RECLAIM_MASK);
> +		if (!ret)
> +			ret = shmem_add_to_page_cache(page, mapping, index,
> +						gfp, NULL);
> +		if (ret)
> +			goto unlock;
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
> +		if (!(mode&  FALLOC_FL_KEEP_SIZE))
> +			i_size_write(inode, index<<  PAGE_CACHE_SHIFT);
> +	}
> +
> +	goto unacct;
> +
> +unlock:
> +	if (page) {
> +		unlock_page(page);
> +		page_cache_release(page);
> +	}
> +decused:
> +	if (sbinfo->max_blocks)
> +		percpu_counter_sub(&sbinfo->used_blocks, BLOCKS_PER_PAGE);
> +unacct:
> +	shmem_unacct_blocks(info->flags, 1);
> +	return ret;
> +}
> +
>   static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
>   {
>   	struct shmem_sb_info *sbinfo = SHMEM_SB(dentry->d_sb);
> @@ -2286,6 +2383,7 @@ static const struct file_operations shmem_file_operations = {
>   	.fsync		= noop_fsync,
>   	.splice_read	= shmem_file_splice_read,
>   	.splice_write	= generic_file_splice_write,
> +	.fallocate	= shmem_fallocate,
>   #endif
>   };
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
