Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3BF6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 05:37:31 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g14so503860984ioj.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 02:37:31 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id m200si1944347itm.45.2016.08.04.02.37.29
        for <linux-mm@kvack.org>;
        Thu, 04 Aug 2016 02:37:30 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <004301d1ee32$fc583630$f508a290$@alibaba-inc.com>
In-Reply-To: <004301d1ee32$fc583630$f508a290$@alibaba-inc.com>
Subject: Re: [PATCH 2/7] userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support
Date: Thu, 04 Aug 2016 17:37:16 +0800
Message-ID: <004401d1ee33$c9b748f0$5d25dad0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Rapoport' <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

> 
> +int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
> +			   pmd_t *dst_pmd,
> +			   struct vm_area_struct *dst_vma,
> +			   unsigned long dst_addr,
> +			   unsigned long src_addr,
> +			   struct page **pagep)
> +{
> +	struct inode *inode = file_inode(dst_vma->vm_file);
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
> +	struct address_space *mapping = inode->i_mapping;
> +	gfp_t gfp = mapping_gfp_mask(mapping);
> +	pgoff_t pgoff = linear_page_index(dst_vma, dst_addr);
> +	struct mem_cgroup *memcg;
> +	spinlock_t *ptl;
> +	void *page_kaddr;
> +	struct page *page;
> +	pte_t _dst_pte, *dst_pte;
> +	int ret;
> +
> +	if (!*pagep) {
> +		ret = -ENOMEM;
> +		if (shmem_acct_block(info->flags))
> +			goto out;
> +		if (sbinfo->max_blocks) {
> +			if (percpu_counter_compare(&sbinfo->used_blocks,
> +						   sbinfo->max_blocks) >= 0)
> +				goto out_unacct_blocks;
> +			percpu_counter_inc(&sbinfo->used_blocks);
> +		}
> +
> +		page = shmem_alloc_page(gfp, info, pgoff);
> +		if (!page)
> +			goto out_dec_used_blocks;
> +
> +		page_kaddr = kmap_atomic(page);
> +		ret = copy_from_user(page_kaddr, (const void __user *)src_addr,
> +				     PAGE_SIZE);
> +		kunmap_atomic(page_kaddr);
> +
> +		/* fallback to copy_from_user outside mmap_sem */
> +		if (unlikely(ret)) {
> +			*pagep = page;
> +			/* don't free the page */
> +			return -EFAULT;
> +		}
> +	} else {
> +		page = *pagep;
> +		*pagep = NULL;
> +	}
> +
> +	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
> +	if (dst_vma->vm_flags & VM_WRITE)
> +		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
> +
> +	ret = -EEXIST;
> +	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
> +	if (!pte_none(*dst_pte))
> +		goto out_release_uncharge_unlock;
> +
> +	__SetPageUptodate(page);
> +
> +	ret = mem_cgroup_try_charge(page, dst_mm, gfp, &memcg,
> +				    false);
> +	if (ret)
> +		goto out_release_uncharge_unlock;
> +	ret = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);

You have to load radix tree without &ptl held.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
