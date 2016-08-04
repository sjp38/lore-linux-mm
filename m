Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B13546B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:19:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so146719943wmp.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 06:19:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ly3si13618670wjb.68.2016.08.04.06.19.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 06:19:11 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u74DJApG143086
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 09:19:10 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kkajbpqq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 09:19:09 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 14:19:01 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id CF400219004D
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 14:18:24 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u74DIxpi22413334
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 13:18:59 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u74DIw0r029884
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 07:18:58 -0600
Date: Thu, 4 Aug 2016 16:18:55 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/7] userfaultfd: shmem: add shmem_mcopy_atomic_pte for
 userfaultfd support
References: <004301d1ee32$fc583630$f508a290$@alibaba-inc.com>
 <004401d1ee33$c9b748f0$5d25dad0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <004401d1ee33$c9b748f0$5d25dad0$@alibaba-inc.com>
Message-Id: <20160804131855.GC21679@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org

On Thu, Aug 04, 2016 at 05:37:16PM +0800, Hillf Danton wrote:
> > 
> > +int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
> > +			   pmd_t *dst_pmd,
> > +			   struct vm_area_struct *dst_vma,
> > +			   unsigned long dst_addr,
> > +			   unsigned long src_addr,
> > +			   struct page **pagep)
> > +{
> > +	struct inode *inode = file_inode(dst_vma->vm_file);
> > +	struct shmem_inode_info *info = SHMEM_I(inode);
> > +	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
> > +	struct address_space *mapping = inode->i_mapping;
> > +	gfp_t gfp = mapping_gfp_mask(mapping);
> > +	pgoff_t pgoff = linear_page_index(dst_vma, dst_addr);
> > +	struct mem_cgroup *memcg;
> > +	spinlock_t *ptl;
> > +	void *page_kaddr;
> > +	struct page *page;
> > +	pte_t _dst_pte, *dst_pte;
> > +	int ret;
> > +
> > +	if (!*pagep) {
> > +		ret = -ENOMEM;
> > +		if (shmem_acct_block(info->flags))
> > +			goto out;
> > +		if (sbinfo->max_blocks) {
> > +			if (percpu_counter_compare(&sbinfo->used_blocks,
> > +						   sbinfo->max_blocks) >= 0)
> > +				goto out_unacct_blocks;
> > +			percpu_counter_inc(&sbinfo->used_blocks);
> > +		}
> > +
> > +		page = shmem_alloc_page(gfp, info, pgoff);
> > +		if (!page)
> > +			goto out_dec_used_blocks;
> > +
> > +		page_kaddr = kmap_atomic(page);
> > +		ret = copy_from_user(page_kaddr, (const void __user *)src_addr,
> > +				     PAGE_SIZE);
> > +		kunmap_atomic(page_kaddr);
> > +
> > +		/* fallback to copy_from_user outside mmap_sem */
> > +		if (unlikely(ret)) {
> > +			*pagep = page;
> > +			/* don't free the page */
> > +			return -EFAULT;
> > +		}
> > +	} else {
> > +		page = *pagep;
> > +		*pagep = NULL;
> > +	}
> > +
> > +	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
> > +	if (dst_vma->vm_flags & VM_WRITE)
> > +		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
> > +
> > +	ret = -EEXIST;
> > +	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
> > +	if (!pte_none(*dst_pte))
> > +		goto out_release_uncharge_unlock;
> > +
> > +	__SetPageUptodate(page);
> > +
> > +	ret = mem_cgroup_try_charge(page, dst_mm, gfp, &memcg,
> > +				    false);
> > +	if (ret)
> > +		goto out_release_uncharge_unlock;
> > +	ret = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
> 
> You have to load radix tree without &ptl held.

Thanks, will fix.
 
> Hillf
> 

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
