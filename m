Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1247C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:07:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66EEB20675
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:07:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="0K1kaoIJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66EEB20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 013196B0005; Fri, 24 May 2019 12:07:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F05546B0006; Fri, 24 May 2019 12:07:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF5076B000C; Fri, 24 May 2019 12:07:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A30F86B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 12:07:34 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b5so6151602plr.16
        for <linux-mm@kvack.org>; Fri, 24 May 2019 09:07:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ay/DwGiyThRnxFLIMwYoesNU6qWFJoBXMPmoYj218ks=;
        b=SgsKirYLnU3EXPHg0wbvhzB1RcYDbO/naHy9tJ5IUD2PMFdoUzW3A6ofOgmWO3kvIW
         XSYfTEyDy+UWaORjiixfksg0RdgmZJ2ovyhYK52R44MuX6A4Q04JqJ5oT8vl5b1p6+yT
         MLUPOmhheES/csd1Y6c8hHRQjOdslndZ+30hZu6UxJUMHwqAYi8idIxeYKMKJLjOr5wc
         ikISB5b0LIWskJkmRvcoHvyHiwSBjgLC7Wpsz5sC9HCFbwga9pzZv/GJ+6Syz+WOHNVb
         MLHfw9sZbLohrPKfbLoTW8kxUWhDrzN95qKbnppqCanhdPcalHssLwsYMnNRC1rlmuZg
         PuzA==
X-Gm-Message-State: APjAAAU2Glft1IRrwE2TeucJpD4i1cLtgu39m5w6VMt/SFAXbrRPopeU
	WkPrjOf0u8ps9iE2JjtRUp4bLy+tcmcGx8TGQDa6SXqKT0bCmka0omqJ+loW4BawyqlFozuzwqz
	rsBuevuIjX3miCX8Zg6Lnq8pX3pExqmuuSVICR6U4b+P+KTHc1ZoKdmrCIHc3t6NQLg==
X-Received: by 2002:aa7:860a:: with SMTP id p10mr97226420pfn.214.1558714054199;
        Fri, 24 May 2019 09:07:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwR5+/7Al6PhciyD+7ta0WWWUH2Tce3/75N3rdNNwWKkc2qu2QDcgk0CnHH4xlJKuIYBetx
X-Received: by 2002:aa7:860a:: with SMTP id p10mr97226300pfn.214.1558714053036;
        Fri, 24 May 2019 09:07:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558714053; cv=none;
        d=google.com; s=arc-20160816;
        b=bDrWaysDDwGI4VCpr0cKuR3iaRGXWCuAXmsV//2yX6BBITbJcOCSDzJQEBmHOwy+qM
         IsAiwDQF3ieiVdSEjiUcwO6k3SQ8DiTEETQayRi4fktXH8QEyC70LpvZJWV9aDQ8Vnwz
         i3j3m3KpNxd69YeWlWlojbCmsRHsBgvWW2jvtrW7dXljiAX+ctkAFoK2clmkyR/zFDeC
         vtO/LK7e+vfigvIG+qkPtlUJgTQYP52sy2aec+OQ9sINJ0AIC3wtggy1lXNLoz6mfnrg
         p630IPsBfXS1Dfvl/ULrN/e59EGCy3XoLe3+Cx3bL9RoEpRA2z1FHVpGVtCKV8e5Mpyq
         /d6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ay/DwGiyThRnxFLIMwYoesNU6qWFJoBXMPmoYj218ks=;
        b=UWBiVEcWPE4WxPBYF8RZ3T/+XyUF9WbgIsjf9ldOLZwp/L44X0DZiAqF972YkXj+lZ
         ivkYntlj+4TIaDp+wxqqOXSHktShcwIpupYAnxz9r52dEcX2DFdsyWh90+7svO8iTbhF
         OjQpD+6BRtqRIvw6uGvvNQjOpVrfZ9NpQaMlXkWfkud4dVx6xGItdYptCMaU+Ux9a1cJ
         Lc2APAN4nrN5XsIAqzL7fle5RTXbJZNeI0mvixYBqn57Zigyo71ySgUzEU88iwRMzRCa
         xtpP8/N6JeKv85ePmjynCYWtP2uONT+VlMl/ZyMOgxjasj4tql4jVmxKhBk4RS995VbY
         QDBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=0K1kaoIJ;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 3si4962812plo.300.2019.05.24.09.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 09:07:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=0K1kaoIJ;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4OFrnEK057227;
	Fri, 24 May 2019 16:07:17 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=ay/DwGiyThRnxFLIMwYoesNU6qWFJoBXMPmoYj218ks=;
 b=0K1kaoIJJD0WrsMOICPB1J5sB8EZJeaN3coOFPEdJ6hC+qlr7DG/iqEzKTH+vh7sCOxb
 QLpueclTMRcD+ABk404aDMP8A79vfLL1HcVkwOYjjS1SKj/7MUdONx6bWKXD702DWbLF
 pOO2LYRcaEK0uNCj84sSO56SMNcHoZbbyOzQq6zIgnv7IrdRwT+2fFKGnXeiSEAYtjwV
 0kfk3OfISidJn3RipCUWZhi4GSRhqA5a4Vc9OqwGQc5OLx/sukmdPZWM6ZECiVnzAFBT
 SYhO5dIztYOEDwsE89OIdoLw2hgNfxNxUdp09y3xPyZKROEwItmSrYuVuvuBelbm97F6 tA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2smsk5t2mx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 24 May 2019 16:07:17 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4OG5dHJ081046;
	Fri, 24 May 2019 16:07:16 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2smsgtydwj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 24 May 2019 16:07:16 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4OG7ERm010855;
	Fri, 24 May 2019 16:07:14 GMT
Received: from ubuette (/75.80.107.76)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 24 May 2019 16:07:13 +0000
Date: Fri, 24 May 2019 09:07:11 -0700
From: Larry Bassel <larry.bassel@oracle.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Larry Bassel <larry.bassel@oracle.com>, mike.kravetz@oracle.com,
        willy@infradead.org, dan.j.williams@intel.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH, RFC 2/2] Implement sharing/unsharing of PMDs for FS/DAX
Message-ID: <20190524160711.GF19025@ubuette>
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
 <1557417933-15701-3-git-send-email-larry.bassel@oracle.com>
 <20190514130147.2pk2xx32aiomm57b@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514130147.2pk2xx32aiomm57b@box>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9267 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905240105
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9267 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905240105
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14 May 19 16:01, Kirill A. Shutemov wrote:
> On Thu, May 09, 2019 at 09:05:33AM -0700, Larry Bassel wrote:
[trim]
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1747,6 +1747,33 @@ static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
> >  	mm_dec_nr_ptes(mm);
> >  }
> >  
> > +#ifdef CONFIG_MAY_SHARE_FSDAX_PMD
> > +static int unshare_huge_pmd(struct mm_struct *mm, unsigned long addr,
> > +			    pmd_t *pmdp)
> > +{
> > +	pgd_t *pgd = pgd_offset(mm, addr);
> > +	p4d_t *p4d = p4d_offset(pgd, addr);
> > +	pud_t *pud = pud_offset(p4d, addr);
> > +
> > +	WARN_ON(page_count(virt_to_page(pmdp)) == 0);
> > +	if (page_count(virt_to_page(pmdp)) == 1)
> > +		return 0;
> > +
> > +	pud_clear(pud);
> 
> You don't have proper locking in place to do this.

This code is based on and very similar to the code in
mm/hugetlb.c (huge_pmd_unshare()).

I asked Mike Kravetz why the locking in huge_pmd_share() and
huge_pmd_unshare() is correct. The issue (as you point out later
in your email) is whether in both of those cases it is OK to
take the PMD table lock and then modify the PUD table.

He responded with the following analysis:

---------------------------------------------------------------------------------
I went back and looked at the locking in the hugetlb code.  Here is
most of the code for huge_pmd_share().

	i_mmap_lock_write(mapping);
	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
		if (svma == vma)
			continue;

		saddr = page_table_shareable(svma, vma, addr, idx);
		if (saddr) {
			spte = huge_pte_offset(svma->vm_mm, saddr,
					       vma_mmu_pagesize(svma));
			if (spte) {
				get_page(virt_to_page(spte));
				break;
			}
		}
	}

	if (!spte)
		goto out;

	ptl = huge_pte_lock(hstate_vma(vma), mm, spte);
>>>
The primary reason the page table lock is taken here is for the purpose of
checking and possibly updating the PUD (pointer to PMD page).  Note that by
the time we get here we already have found a PMD page to share.  Also note
that the lock taken is the one associated with the PMD page.

The synchronization question to ask is:  Can anyone else modify the PUD value
while I am holding the PMD lock?  In general, the answer is Yes.  However,
we can infer something subtle about the shared PMD case.  Suppose someone
else wanted to set the PUD value.  The only value they could set it to is the
PMD page we found in this routine.  They also would need to go through this
routine to set the value.  They also would need to get the lock on the same
shared PMD.  Actually, they would hit the mapping->i_mmap_rwsem first.  But,
the bottom line is that nobody else can set it.  What about clearing?  In the
hugetlb case, the only places where PUD gets cleared are final page table
tear down and huge_pmd_unshare().  The final page table tear down case is not
interesting as the process is exiting.  All callers if huge_pmd_unshare must
hold the (PMD) page table lock.  This is a requirement.  Therefore, within
a single process this synchronizes two threads:  one calling huge_pmd_share
and another huge_pmd_unshare.
---------------------------------------------------------------------------------

I assert that the same analysis applies to pmd_share() and unshare_huge_pmd()
which are added in this patch.

> 
> > +	put_page(virt_to_page(pmdp));
> > +	mm_dec_nr_pmds(mm);
> > +	return 1;
> > +}
> > +
> > +#else
> > +static int unshare_huge_pmd(struct mm_struct *mm, unsigned long addr,
> > +			    pmd_t *pmdp)
> > +{
> > +	return 0;
> > +}
> > +
> > +#endif
> > +
> >  int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  		 pmd_t *pmd, unsigned long addr)
> >  {
> > @@ -1764,6 +1791,11 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  	 * pgtable_trans_huge_withdraw after finishing pmdp related
> >  	 * operations.
> >  	 */
> > +	if (unshare_huge_pmd(vma->vm_mm, addr, pmd)) {
> > +		spin_unlock(ptl);
> > +		return 1;
> > +	}
> > +
> >  	orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
> >  			tlb->fullmm);
> >  	tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 641cedf..919a290 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -4594,9 +4594,9 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
> >  }
> >  
> >  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
> > -static unsigned long page_table_shareable(struct vm_area_struct *svma,
> > -				struct vm_area_struct *vma,
> > -				unsigned long addr, pgoff_t idx)
> > +unsigned long page_table_shareable(struct vm_area_struct *svma,
> > +				   struct vm_area_struct *vma,
> > +				   unsigned long addr, pgoff_t idx)
> >  {
> >  	unsigned long saddr = ((idx - svma->vm_pgoff) << PAGE_SHIFT) +
> >  				svma->vm_start;
> > @@ -4619,7 +4619,7 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
> >  	return saddr;
> >  }
> >  
> > -static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> > +bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> >  {
> >  	unsigned long base = addr & PUD_MASK;
> >  	unsigned long end = base + PUD_SIZE;
> > @@ -4763,6 +4763,19 @@ void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
> >  				unsigned long *start, unsigned long *end)
> >  {
> >  }
> > +
> > +unsigned long page_table_shareable(struct vm_area_struct *svma,
> > +				   struct vm_area_struct *vma,
> > +				   unsigned long addr, pgoff_t idx)
> > +{
> > +	return 0;
> > +}
> > +
> > +bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> > +{
> > +	return false;
> > +}
> > +
> >  #define want_pmd_share()	(0)
> >  #endif /* CONFIG_ARCH_WANT_HUGE_PMD_SHARE */
> >  
> > diff --git a/mm/memory.c b/mm/memory.c
> > index f7d962d..4c1814c 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3845,6 +3845,109 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
> >  	return 0;
> >  }
> >  
> > +#ifdef CONFIG_MAY_SHARE_FSDAX_PMD
> > +static pmd_t *huge_pmd_offset(struct mm_struct *mm,
> > +			      unsigned long addr, unsigned long sz)
> 
> Could you explain what this function suppose to do?
> 
> As far as I can see vma_mmu_pagesize() is always PAGE_SIZE of DAX
> filesystem. So we have 'sz' == PAGE_SIZE here.

I thought so too, but in my testing I found that vma_mmu_pagesize() returns
4KiB, which differs from the DAX filesystem's 2MiB pagesize.

> 
> So this function can pointer to PMD of PUD page table entry casted to
> pmd_t*.
> 
> Why?

I don't understand your question here.

> 
> > +{
> > +	pgd_t *pgd;
> > +	p4d_t *p4d;
> > +	pud_t *pud;
> > +	pmd_t *pmd;
> > +
> > +	pgd = pgd_offset(mm, addr);
> > +	if (!pgd_present(*pgd))
> > +		return NULL;
> > +	p4d = p4d_offset(pgd, addr);
> > +	if (!p4d_present(*p4d))
> > +		return NULL;
> > +
> > +	pud = pud_offset(p4d, addr);
> > +	if (sz != PUD_SIZE && pud_none(*pud))
> > +		return NULL;
> > +	/* hugepage or swap? */
> > +	if (pud_huge(*pud) || !pud_present(*pud))
> > +		return (pmd_t *)pud;
> > +
> > +	pmd = pmd_offset(pud, addr);
> > +	if (sz != PMD_SIZE && pmd_none(*pmd))
> > +		return NULL;
> > +	/* hugepage or swap? */
> > +	if (pmd_huge(*pmd) || !pmd_present(*pmd))
> > +		return pmd;
> > +
> > +	return NULL;
> > +}
> > +
> > +static pmd_t *pmd_share(struct mm_struct *mm, pud_t *pud, unsigned long addr)
> > +{
> > +	struct vm_area_struct *vma = find_vma(mm, addr);
> 
> Why? Caller has vma on hands.

This was taken from huge_pmd_share() in mm/hugetlb.c which does
things that way. Are you suggesting that I just pass vma as
an argument to pmd_share()?

> 
> > +	struct address_space *mapping = vma->vm_file->f_mapping;
> > +	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
> > +			vma->vm_pgoff;
> 
> linear_page_index()?

Again this came from huge_pmd_share(). I was trying to keep
the differences between both functions as small as possible.

> 
> > +	struct vm_area_struct *svma;
> > +	unsigned long saddr;
> > +	pmd_t *spmd = NULL;
> > +	pmd_t *pmd;
> > +	spinlock_t *ptl;
> > +
> > +	if (!vma_shareable(vma, addr))
> > +		return pmd_alloc(mm, pud, addr);
> > +
> > +	i_mmap_lock_write(mapping);
> > +
> > +	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
> > +		if (svma == vma)
> > +			continue;
> > +
> > +		saddr = page_table_shareable(svma, vma, addr, idx);
> > +		if (saddr) {
> > +			spmd = huge_pmd_offset(svma->vm_mm, saddr,
> > +					       vma_mmu_pagesize(svma));
> > +			if (spmd) {
> > +				get_page(virt_to_page(spmd));
> 
> So, here we get a pin on a page table page. And we don't know if it's PMD
> or PUD page table.

DAX only does 4 KiB and 2 MiB pagesizes, not 1 GiB. The checks for sharing
prevent any 4 KiB DAX from entering this code.

> 
> And we only checked one entry in the page table.
> 
> What if the page table mixes huge-PMD/PUD entries with pointers to page
> table.

Again, I don't think this can happen in DAX. The only sharing allowed
is for FS/DAX/2MiB pagesize.

> 
> > +				break;
> > +			}
> > +		}
> > +	}
> > +
> > +	if (!spmd)
> > +		goto out;
> > +
> > +	ptl = pmd_lockptr(mm, spmd);
> > +	spin_lock(ptl);
> 
> You take lock on PMD page table...
> 
> > +
> > +	if (pud_none(*pud)) {
> > +		pud_populate(mm, pud,
> > +			    (pmd_t *)((unsigned long)spmd & PAGE_MASK));
> 
> ... and modify PUD page table.

Please see my comments about this issue above.

> 
> > +		mm_inc_nr_pmds(mm);
> > +	} else {
> > +		put_page(virt_to_page(spmd));
> > +	}
> > +	spin_unlock(ptl);
> > +out:
> > +	pmd = pmd_alloc(mm, pud, addr);
> > +	i_mmap_unlock_write(mapping);
> > +	return pmd;
> > +}

[trim]

Thanks for the review. My apologies for not getting
back to you sooner.

Larry

