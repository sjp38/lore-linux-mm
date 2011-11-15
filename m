Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 528B16B0072
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 12:49:39 -0500 (EST)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 15 Nov 2011 12:49:35 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAFHiNst1622264
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 12:44:24 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAFHiLJs022009
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 12:44:23 -0500
Subject: Re: [Patch] tmpfs: add fallocate support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4EC23DB0.3020306@redhat.com>
References: <1321346525-10187-1-git-send-email-amwang@redhat.com>
	 <4EC23DB0.3020306@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Nov 2011 09:43:59 -0800
Message-ID: <1321379039.12374.11.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, 2011-11-15 at 18:23 +0800, Cong Wang wrote:
> > +static long shmem_fallocate(struct file *file, int mode,
> > +			    loff_t offset, loff_t len)
> > +{
> > +	struct inode *inode = file->f_path.dentry->d_inode;
> > +	struct address_space *mapping = inode->i_mapping;
> > +	struct shmem_inode_info *info = SHMEM_I(inode);
> > +	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
> > +	pgoff_t start = DIV_ROUND_UP(offset, PAGE_CACHE_SIZE);
> > +	pgoff_t end = DIV_ROUND_UP((offset + len), PAGE_CACHE_SIZE);
> > +	pgoff_t index = start;
> > +	gfp_t gfp = mapping_gfp_mask(mapping);
> > +	loff_t i_size = i_size_read(inode);
> > +	struct page *page = NULL;
> > +	int ret;
> > +
> > +	if ((offset + len)<= i_size)
> > +		return 0;

This seems to say that if the fallocate() call ends before the end of
the file we should ignore the call.  In other words, this can only be
used to extend the file, but could not be used to fill in the holes of a
sparse file.  

Is there a reason it was done that way?

> > +	if (!(mode&  FALLOC_FL_KEEP_SIZE)) {
> > +		ret = inode_newsize_ok(inode, (offset + len));
> > +		if (ret)
> > +			return ret;
> > +	}

inode_newsize_ok()'s comments say:

 * inode_newsize_ok must be called with i_mutex held.

But I don't see any trace of it.

> > +	if (start == end) {
> > +		if (!(mode&  FALLOC_FL_KEEP_SIZE))
> > +			i_size_write(inode, offset + len);
> > +		return 0;
> > +	}

There's a whitespace borkage like that 'mode&' all over this patch.
Probably needs a little love.

> +       if (shmem_acct_block(info->flags))
> +               return -ENOSPC;
> +
> +       if (sbinfo->max_blocks) {
> +               unsigned long blocks = (end - index) * BLOCKS_PER_PAGE;
> +               if (blocks + percpu_counter_sum(&sbinfo->used_blocks)
> +                               >= sbinfo->max_blocks) {
> +                       ret = -ENOSPC;
> +                       goto unacct;
> +               }
> +       }
...
> > +	while (index<  end) {
> > +		if (sbinfo->max_blocks)
> > +			percpu_counter_add(&sbinfo->used_blocks, BLOCKS_PER_PAGE);
> > +
> > +		page = shmem_alloc_page(gfp, info, index);
> > +		if (!page) {
> > +			ret = -ENOMEM;
> > +			goto decused;
> > +		}
> > +
> > +		SetPageSwapBacked(page);
> > +		__set_page_locked(page);
> > +		ret = mem_cgroup_cache_charge(page, current->mm,
> > +						gfp&  GFP_RECLAIM_MASK);
> > +		if (!ret)
> > +			ret = shmem_add_to_page_cache(page, mapping, index,
> > +						gfp, NULL);
> > +		if (ret)
> > +			goto unlock;
> > +		lru_cache_add_anon(page);
> > +
> > +		spin_lock(&info->lock);
> > +		info->alloced++;
> > +		inode->i_blocks += BLOCKS_PER_PAGE;
> > +		inode->i_ctime = inode->i_mtime = CURRENT_TIME;
> > +		shmem_recalc_inode(inode);
> > +		spin_unlock(&info->lock);
> > +
> > +		clear_highpage(page);
> > +		flush_dcache_page(page);
> > +		SetPageUptodate(page);
> > +		unlock_page(page);
> > +		page_cache_release(page);
> > +		cond_resched();
> > +		index++;
> > +		if (!(mode&  FALLOC_FL_KEEP_SIZE))
> > +			i_size_write(inode, index<<  PAGE_CACHE_SHIFT);
> > +	

This seems to have borrowed quite generously from shmem_getpage_gfp().
Seems like some code consolidation is in order before this level of
copy-n-paste.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
