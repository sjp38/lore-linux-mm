Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 165D8C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:12:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B261420879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:12:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Cfb3WEoU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B261420879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 517346B0006; Tue, 14 May 2019 09:12:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C7146B0007; Tue, 14 May 2019 09:12:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38E9F6B0008; Tue, 14 May 2019 09:12:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F3BEE6B0006
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:12:37 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n4so11498447pgm.19
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:12:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CKs3W/HZ8xcgUNVlG7cUVSbVqrQ3vHb9Xsah+xFkjqg=;
        b=iuaIfwizGK7HG5kPyF0fq/uzi2CTb3fZgz5cGsu/0x4NeZRbBxBOZLLha3eOd0WAA4
         9GMkF2zY67dj8lWgMwwnrQxmaSLO3/OOnhHmLkKtx7/gwz3fOodyWdfvAwa/rdSMcO3p
         LbHqTB//LKpnJqub5sXIyO6qZiF4UcC0U2MfAvmooi/hyqOBr1S6t5rJY7F8e3wtbqiI
         W+MTIdzvgAjG4ru7cWu6ro2dDCX9PSzXrRHuqe6yN4ZYFfGtWiE6mF8qpU3FUgXH5+fp
         66yrpcgf1cyiUfOF8T9K60JxN19Qm6WP+VtJ+9yV7gjdPcA2l2ln3PeRJ3PsKXpyqJ2Q
         aHEg==
X-Gm-Message-State: APjAAAVz7LIaDrvhc3dyBMGnHvTXpJUkyGX2XybaKBVcXNMDtvIfrYOu
	TrqwrXFF7HoC1kX1DIIC2ZSzN4inkP4zlWCkownJwRI9atFFZ7K18DR6PJBKMouYVbOQU5qN66C
	RJ8gWekTN0b4VtNSlIL+l0P6IlEskryb8J8pg7atfBWs3GYb9hByRejST0QKo5uOhFw==
X-Received: by 2002:a63:231c:: with SMTP id j28mr37928769pgj.430.1557839557627;
        Tue, 14 May 2019 06:12:37 -0700 (PDT)
X-Received: by 2002:a63:231c:: with SMTP id j28mr37928690pgj.430.1557839556663;
        Tue, 14 May 2019 06:12:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557839556; cv=none;
        d=google.com; s=arc-20160816;
        b=Au50RoC6cP/Lw0PRhmGb2h9L2gehitDOk4eFMALYd/yHIxixEy8oXqYHzP76eGCrmq
         uEmAoSs6TFDItWs0RlkrRYqitYtqFm8RoOX2c1ltd8YV4hB4U9A7tooO4hms/TthJpXk
         n1nx2vBqXLWp0H2AmOKVobVk9HPBAV4pDuoSPjUZoxhBUyEF2xH2SRLX64uUTYCJNLmI
         /GB4Gv5diSMS+y0MxajEXr0ZYmLiuJTv7O4fqxBc46lfV6EWcMnv/qUgu9P33zllI0Q4
         v4DraNTFNtgD0nuE3crTWUefoH4JfJoULYoI6ckoHGCXqbL6+KnW1uoPZzqY9epjoC3e
         pT7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CKs3W/HZ8xcgUNVlG7cUVSbVqrQ3vHb9Xsah+xFkjqg=;
        b=ERbXJnRWBhNU6Okga4GjTRu49DocorVgIJGMCrf5BduKfeQSSHxdLA6UF0XNQ2vw8D
         h3gP9dNrASXyrAfkSSbUPZayiA0gbUfbwLP/dFytzZUeYP+7NdyB8fz3jCZQRZQoHVQi
         HG5bU6TwfH+Y6Gw2vBiEOBB0brGPYgl0xcsEYc7E4L5swvjIh2ZJiEUab7VdqW0f7G+5
         GOC/qiGJ5FWpMqydjiWPAehCXx4CGzrZZRsjVYuAgo27oNtphkwvqy3SeLNnE9rN/w9F
         2IOuM86r2KrUlKuCE4jzFR5dtqlvo73WwObOJ+bOhDHpXmvvCWTL9kTPsFT03R+ynYCF
         2O8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Cfb3WEoU;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e34sor17955378pge.36.2019.05.14.06.12.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:12:36 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Cfb3WEoU;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CKs3W/HZ8xcgUNVlG7cUVSbVqrQ3vHb9Xsah+xFkjqg=;
        b=Cfb3WEoUyL5NQ+DE834BvxUzhPCmLMsbTj1O/U/QtmKFizrRAYaJCoPBk+/kN1k/A4
         3cyKrQqVs7Z+N6KO2ge+Z6fE9CdVUumVVW2Bg2Nvpn9a1Ck9FvxrkSaRC783P50bN89s
         k9tIqsRhKij6O0irbE6zXbfA3YGTh2BQteQhvJBKDRWip9wUBJyNlyahVNfearGF1R56
         sQre7LpJkbA7u7r3yxkEdVaDXOca5HnVkqYTU1ieLCwKoP3pL8h527NmgbiiKMwau8vv
         XL4TKS0IrFqkqGMDKd5hSR2lVsD8uWysp8cp07cDTsnLdkbveNk4qTjv0yyK8pqOpDpT
         NwYQ==
X-Google-Smtp-Source: APXvYqyBTKVZgA/2uINyNWML6uUpGy2LUKuyahxZqyVFYkid+7uLwhB3MtrdUKXDmZWQqeifBIMCng==
X-Received: by 2002:a63:1048:: with SMTP id 8mr37778917pgq.70.1557839556085;
        Tue, 14 May 2019 06:12:36 -0700 (PDT)
Received: from box.localdomain ([192.55.54.45])
        by smtp.gmail.com with ESMTPSA id x17sm8534536pgh.47.2019.05.14.06.12.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 06:12:35 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 02BF5100C35; Tue, 14 May 2019 16:01:47 +0300 (+03)
Date: Tue, 14 May 2019 16:01:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Larry Bassel <larry.bassel@oracle.com>
Cc: mike.kravetz@oracle.com, willy@infradead.org, dan.j.williams@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: Re: [PATCH, RFC 2/2] Implement sharing/unsharing of PMDs for FS/DAX
Message-ID: <20190514130147.2pk2xx32aiomm57b@box>
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
 <1557417933-15701-3-git-send-email-larry.bassel@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557417933-15701-3-git-send-email-larry.bassel@oracle.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 09:05:33AM -0700, Larry Bassel wrote:
> This is based on (but somewhat different from) what hugetlbfs
> does to share/unshare page tables.
> 
> Signed-off-by: Larry Bassel <larry.bassel@oracle.com>
> ---
>  include/linux/hugetlb.h |   4 ++
>  mm/huge_memory.c        |  32 ++++++++++++++
>  mm/hugetlb.c            |  21 ++++++++--
>  mm/memory.c             | 108 +++++++++++++++++++++++++++++++++++++++++++++++-
>  4 files changed, 160 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 11943b6..9ed9542 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -142,6 +142,10 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>  int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
>  void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
>  				unsigned long *start, unsigned long *end);
> +unsigned long page_table_shareable(struct vm_area_struct *svma,
> +				   struct vm_area_struct *vma,
> +				   unsigned long addr, pgoff_t idx);
> +bool vma_shareable(struct vm_area_struct *vma, unsigned long addr);
>  struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
>  			      int write);
>  struct page *follow_huge_pd(struct vm_area_struct *vma,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index b6a34b3..e1627c3 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1747,6 +1747,33 @@ static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
>  	mm_dec_nr_ptes(mm);
>  }
>  
> +#ifdef CONFIG_MAY_SHARE_FSDAX_PMD
> +static int unshare_huge_pmd(struct mm_struct *mm, unsigned long addr,
> +			    pmd_t *pmdp)
> +{
> +	pgd_t *pgd = pgd_offset(mm, addr);
> +	p4d_t *p4d = p4d_offset(pgd, addr);
> +	pud_t *pud = pud_offset(p4d, addr);
> +
> +	WARN_ON(page_count(virt_to_page(pmdp)) == 0);
> +	if (page_count(virt_to_page(pmdp)) == 1)
> +		return 0;
> +
> +	pud_clear(pud);

You don't have proper locking in place to do this.

> +	put_page(virt_to_page(pmdp));
> +	mm_dec_nr_pmds(mm);
> +	return 1;
> +}
> +
> +#else
> +static int unshare_huge_pmd(struct mm_struct *mm, unsigned long addr,
> +			    pmd_t *pmdp)
> +{
> +	return 0;
> +}
> +
> +#endif
> +
>  int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		 pmd_t *pmd, unsigned long addr)
>  {
> @@ -1764,6 +1791,11 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	 * pgtable_trans_huge_withdraw after finishing pmdp related
>  	 * operations.
>  	 */
> +	if (unshare_huge_pmd(vma->vm_mm, addr, pmd)) {
> +		spin_unlock(ptl);
> +		return 1;
> +	}
> +
>  	orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
>  			tlb->fullmm);
>  	tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 641cedf..919a290 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4594,9 +4594,9 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
>  }
>  
>  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
> -static unsigned long page_table_shareable(struct vm_area_struct *svma,
> -				struct vm_area_struct *vma,
> -				unsigned long addr, pgoff_t idx)
> +unsigned long page_table_shareable(struct vm_area_struct *svma,
> +				   struct vm_area_struct *vma,
> +				   unsigned long addr, pgoff_t idx)
>  {
>  	unsigned long saddr = ((idx - svma->vm_pgoff) << PAGE_SHIFT) +
>  				svma->vm_start;
> @@ -4619,7 +4619,7 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
>  	return saddr;
>  }
>  
> -static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> +bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
>  {
>  	unsigned long base = addr & PUD_MASK;
>  	unsigned long end = base + PUD_SIZE;
> @@ -4763,6 +4763,19 @@ void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
>  				unsigned long *start, unsigned long *end)
>  {
>  }
> +
> +unsigned long page_table_shareable(struct vm_area_struct *svma,
> +				   struct vm_area_struct *vma,
> +				   unsigned long addr, pgoff_t idx)
> +{
> +	return 0;
> +}
> +
> +bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> +{
> +	return false;
> +}
> +
>  #define want_pmd_share()	(0)
>  #endif /* CONFIG_ARCH_WANT_HUGE_PMD_SHARE */
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index f7d962d..4c1814c 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3845,6 +3845,109 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_MAY_SHARE_FSDAX_PMD
> +static pmd_t *huge_pmd_offset(struct mm_struct *mm,
> +			      unsigned long addr, unsigned long sz)

Could you explain what this function suppose to do?

As far as I can see vma_mmu_pagesize() is always PAGE_SIZE of DAX
filesystem. So we have 'sz' == PAGE_SIZE here.

So this function can pointer to PMD of PUD page table entry casted to
pmd_t*.

Why?

> +{
> +	pgd_t *pgd;
> +	p4d_t *p4d;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +
> +	pgd = pgd_offset(mm, addr);
> +	if (!pgd_present(*pgd))
> +		return NULL;
> +	p4d = p4d_offset(pgd, addr);
> +	if (!p4d_present(*p4d))
> +		return NULL;
> +
> +	pud = pud_offset(p4d, addr);
> +	if (sz != PUD_SIZE && pud_none(*pud))
> +		return NULL;
> +	/* hugepage or swap? */
> +	if (pud_huge(*pud) || !pud_present(*pud))
> +		return (pmd_t *)pud;
> +
> +	pmd = pmd_offset(pud, addr);
> +	if (sz != PMD_SIZE && pmd_none(*pmd))
> +		return NULL;
> +	/* hugepage or swap? */
> +	if (pmd_huge(*pmd) || !pmd_present(*pmd))
> +		return pmd;
> +
> +	return NULL;
> +}
> +
> +static pmd_t *pmd_share(struct mm_struct *mm, pud_t *pud, unsigned long addr)
> +{
> +	struct vm_area_struct *vma = find_vma(mm, addr);

Why? Caller has vma on hands.

> +	struct address_space *mapping = vma->vm_file->f_mapping;
> +	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
> +			vma->vm_pgoff;

linear_page_index()?

> +	struct vm_area_struct *svma;
> +	unsigned long saddr;
> +	pmd_t *spmd = NULL;
> +	pmd_t *pmd;
> +	spinlock_t *ptl;
> +
> +	if (!vma_shareable(vma, addr))
> +		return pmd_alloc(mm, pud, addr);
> +
> +	i_mmap_lock_write(mapping);
> +
> +	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
> +		if (svma == vma)
> +			continue;
> +
> +		saddr = page_table_shareable(svma, vma, addr, idx);
> +		if (saddr) {
> +			spmd = huge_pmd_offset(svma->vm_mm, saddr,
> +					       vma_mmu_pagesize(svma));
> +			if (spmd) {
> +				get_page(virt_to_page(spmd));

So, here we get a pin on a page table page. And we don't know if it's PMD
or PUD page table.

And we only checked one entry in the page table.

What if the page table mixes huge-PMD/PUD entries with pointers to page
table.

> +				break;
> +			}
> +		}
> +	}
> +
> +	if (!spmd)
> +		goto out;
> +
> +	ptl = pmd_lockptr(mm, spmd);
> +	spin_lock(ptl);

You take lock on PMD page table...

> +
> +	if (pud_none(*pud)) {
> +		pud_populate(mm, pud,
> +			    (pmd_t *)((unsigned long)spmd & PAGE_MASK));

... and modify PUD page table.

> +		mm_inc_nr_pmds(mm);
> +	} else {
> +		put_page(virt_to_page(spmd));
> +	}
> +	spin_unlock(ptl);
> +out:
> +	pmd = pmd_alloc(mm, pud, addr);
> +	i_mmap_unlock_write(mapping);
> +	return pmd;
> +}
> +
> +static bool may_share_pmd(struct vm_area_struct *vma)
> +{
> +	if (vma_is_fsdax(vma))
> +		return true;
> +	return false;
> +}
> +#else
> +static pmd_t *pmd_share(struct mm_struct *mm, pud_t *pud, unsigned long addr)
> +{
> +	return pmd_alloc(mm, pud, addr);
> +}
> +
> +static bool may_share_pmd(struct vm_area_struct *vma)
> +{
> +	return false;
> +}
> +#endif
> +
>  /*
>   * By the time we get here, we already hold the mm semaphore
>   *
> @@ -3898,7 +4001,10 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
>  		}
>  	}
>  
> -	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
> +	if (unlikely(may_share_pmd(vma)))
> +		vmf.pmd = pmd_share(mm, vmf.pud, address);
> +	else
> +		vmf.pmd = pmd_alloc(mm, vmf.pud, address);
>  	if (!vmf.pmd)
>  		return VM_FAULT_OOM;
>  	if (pmd_none(*vmf.pmd) && __transparent_hugepage_enabled(vma)) {
> -- 
> 1.8.3.1
> 

