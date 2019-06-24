Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C65BC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:19:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3211720820
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:19:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="pAzALn6C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3211720820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D39148E0007; Mon, 24 Jun 2019 09:19:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE7C48E0002; Mon, 24 Jun 2019 09:19:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB0068E0007; Mon, 24 Jun 2019 09:19:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B89B8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:19:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so20473568eda.3
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:19:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rl49ZjQOWKHc6PSmuS0py6dY6eFBF2erKrnaVhI/v1M=;
        b=K8Vc612+0sXA4r8TqNaSmGfLZ+tThhQ86Uj9mrHPS5n5VFsKH8eXWSOpixZfo8afXT
         Bzu9muNVo+Y5X770gIWoqFCgCPh1KrnE2oUrM2Cw1149xKg1pUCJqLIoDqRm6WTlPEq0
         1yMzzHjQsboFfeRFyNAi0Ib2TwXTii8ZTIkpxL51NmR4yTTPyqw1K7pzP6LfFTrTEgda
         u30Xz/GDtmLmDR5L00+JsCX0MTF0ur6oh82CRWYUme7YQCjkoxLubYe39OEES/rHkxdM
         5SKamAIL5+QB0nDfHh/xqwKV+UpNsLUxPT+QZHZSFuV9DiWeZd9zCySlRJndr+Qd7WbX
         YSiw==
X-Gm-Message-State: APjAAAVd0Wx9KitxIOl9cBLRxbbOq5XL0UpUG0lhfk8hV/By33xDxxiR
	BEVIiuDaL7ApVesv05ITxMpW6/ffjEseaBaKrvvafmzQ4KcnSGD/D3pPwaFUNAuOr6geo796tUR
	44bJSgQdDJ5lN7xA8WGu/L7CkpCrFqVni67m9mI+f7ZSCPg3vCS892+hPF29eSLu4VQ==
X-Received: by 2002:a50:94a2:: with SMTP id s31mr125377193eda.290.1561382371983;
        Mon, 24 Jun 2019 06:19:31 -0700 (PDT)
X-Received: by 2002:a50:94a2:: with SMTP id s31mr125377049eda.290.1561382370857;
        Mon, 24 Jun 2019 06:19:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561382370; cv=none;
        d=google.com; s=arc-20160816;
        b=O4s3MXGBm2rsHykjRVvbuFf7un4fd156jGVMWAUm5lJ5XE3GoZCQ2dSzagEqE2+ZUD
         ZN4KfCiaUVquiZJtBdBPZ4+cTCgzKBGnKq9vp8wHso/eY+q7p6uRk6VvIU/TAgNg77HZ
         XFTSlm1VR9Tjxk5bazhH8ZF2SgW6JJUhlo7LbWBIT1SYtn3E3twfqqq2axQ38snZo5cf
         2Nuc4sVpZOTOYqhBiituo4o2Vb2AVLmZj9W0YSn6uJTADo3i2+LTmQb1mJhjrGBtiqjj
         448HkLOw+qHVTfwXObPZ84qI13a3rEgLmNsQ6d/Lhq9Ge/5MhIAn1+3Lo2WsBRoWLAsM
         GOUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rl49ZjQOWKHc6PSmuS0py6dY6eFBF2erKrnaVhI/v1M=;
        b=cx6Fxeoyn6H1fJFxxVfW+3y4BD85CrtvhWPDBsdjio4v+2fkI0m8FKCHWeV1THqSwu
         teYs4ne7koJDqI8j/mZMC91AX1NX5kYJtD/EkCcgJsf+bg41JPbvIFYRO/EqpJ9e8wct
         GW5FCyP99tJVx2ZpGoKNGPfJddo91kdPAtWtQuL0UQDyFFbl9PdrrAMrnRWx2iY5D1g3
         IkOwNE+fa+Hof4FMBfkmkZltkAfVWHx1k7eWCrTYJvf0AldPI0U/KshMcPg7psdnq6Os
         NoqB3iN5ZHXdBl2bcFx83lTa9CcWzDqHZ6YGn3Ik3amnB1JFrfdiZYlrcxDB4L/l01Xt
         0TEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=pAzALn6C;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor9433891edg.10.2019.06.24.06.19.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 06:19:30 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=pAzALn6C;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=rl49ZjQOWKHc6PSmuS0py6dY6eFBF2erKrnaVhI/v1M=;
        b=pAzALn6CQwLJtoYs5SQYVCa9v/b1tWSbSzL07o0W4Tc8FYNtib0147hiNS+18LrYH2
         nmExBiqLml5FZngdyJgAC0sd+q4qbUZABFxRl5dLBjq/kb/zSLnK7Pdp+Wu8ZqCEgkIV
         3JmoycRRxo845zITP2NlIcRCLq6RKDDz/uy5LB/5icV3e+/NCE+N3Qxf98/blAH62/6C
         N4BMClgLCH0BkSltmgoS3ewLXEJ5oRiPALlR9mkT+0dlb+FYKWNCKYqXV1jVG4Y24SIC
         QWTP0jrmgtg660GAjAYSe3/G5b5Nt97K4HTgv4D59v/P+WnIUjS8R8y8SyzWnDR5Yv5M
         UoeA==
X-Google-Smtp-Source: APXvYqyZNea8ZmAmw4kwbTJhQNzzT9FXr6ZmOFVXnlPgc6amqpUX/uB8MqbkXlYNn4zJzAr37l2Jtg==
X-Received: by 2002:aa7:c692:: with SMTP id n18mr110966818edq.220.1561382370462;
        Mon, 24 Jun 2019 06:19:30 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id g16sm3795300edc.76.2019.06.24.06.19.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 06:19:29 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id E99EC10439E; Mon, 24 Jun 2019 16:19:34 +0300 (+03)
Date: Mon, 24 Jun 2019 16:19:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	matthew.wilcox@oracle.com, kirill.shutemov@linux.intel.com,
	peterz@infradead.org, oleg@redhat.com, rostedt@goodmis.org,
	kernel-team@fb.com, william.kucharski@oracle.com
Subject: Re: [PATCH v6 5/6] khugepaged: enable collapse pmd for pte-mapped THP
Message-ID: <20190624131934.m6gbktixyykw65ws@box>
References: <20190623054829.4018117-1-songliubraving@fb.com>
 <20190623054829.4018117-6-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190623054829.4018117-6-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 22, 2019 at 10:48:28PM -0700, Song Liu wrote:
> khugepaged needs exclusive mmap_sem to access page table. When it fails
> to lock mmap_sem, the page will fault in as pte-mapped THP. As the page
> is already a THP, khugepaged will not handle this pmd again.
> 
> This patch enables the khugepaged to retry retract_page_tables().
> 
> A new flag AS_COLLAPSE_PMD is introduced to show the address_space may
> contain pte-mapped THPs. When khugepaged fails to trylock the mmap_sem,
> it sets AS_COLLAPSE_PMD. Then, at a later time, khugepaged will retry
> compound pages in this address_space.
> 
> Since collapse may happen at an later time, some pages may already fault
> in. To handle these pages properly, it is necessary to prepare the pmd
> before collapsing. prepare_pmd_for_collapse() is introduced to prepare
> the pmd by removing rmap, adjusting refcount and mm_counter.
> 
> prepare_pmd_for_collapse() also double checks whether all ptes in this
> pmd are mapping to the same THP. This is necessary because some subpage
> of the THP may be replaced, for example by uprobe. In such cases, it
> is not possible to collapse the pmd, so we fall back.
> 
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  include/linux/pagemap.h |  1 +
>  mm/khugepaged.c         | 69 +++++++++++++++++++++++++++++++++++------
>  2 files changed, 60 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 9ec3544baee2..eac881de2a46 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -29,6 +29,7 @@ enum mapping_flags {
>  	AS_EXITING	= 4, 	/* final truncate in progress */
>  	/* writeback related tags are not used */
>  	AS_NO_WRITEBACK_TAGS = 5,
> +	AS_COLLAPSE_PMD = 6,	/* try collapse pmd for THP */
>  };
>  
>  /**
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index a4f90a1b06f5..9b980327fd9b 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1254,7 +1254,47 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
>  }
>  
>  #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
> -static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
> +
> +/* return whether the pmd is ready for collapse */
> +bool prepare_pmd_for_collapse(struct vm_area_struct *vma, pgoff_t pgoff,
> +			      struct page *hpage, pmd_t *pmd)
> +{
> +	unsigned long haddr = page_address_in_vma(hpage, vma);
> +	unsigned long addr;
> +	int i, count = 0;
> +
> +	/* step 1: check all mapped PTEs are to this huge page */
> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> +		pte_t *pte = pte_offset_map(pmd, addr);
> +
> +		if (pte_none(*pte))
> +			continue;
> +
> +		if (hpage + i != vm_normal_page(vma, addr, *pte))
> +			return false;
> +		count++;
> +	}
> +
> +	/* step 2: adjust rmap */
> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> +		pte_t *pte = pte_offset_map(pmd, addr);
> +		struct page *page;
> +
> +		if (pte_none(*pte))
> +			continue;
> +		page = vm_normal_page(vma, addr, *pte);
> +		page_remove_rmap(page, false);
> +	}
> +
> +	/* step 3: set proper refcount and mm_counters. */
> +	page_ref_sub(hpage, count);
> +	add_mm_counter(vma->vm_mm, mm_counter_file(hpage), -count);
> +	return true;
> +}
> +
> +extern pid_t sysctl_dump_pt_pid;
> +static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff,
> +				struct page *hpage)
>  {
>  	struct vm_area_struct *vma;
>  	unsigned long addr;
> @@ -1273,21 +1313,21 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
>  		pmd = mm_find_pmd(vma->vm_mm, addr);
>  		if (!pmd)
>  			continue;
> -		/*
> -		 * We need exclusive mmap_sem to retract page table.
> -		 * If trylock fails we would end up with pte-mapped THP after
> -		 * re-fault. Not ideal, but it's more important to not disturb
> -		 * the system too much.
> -		 */
>  		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
>  			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
> -			/* assume page table is clear */
> +
> +			if (!prepare_pmd_for_collapse(vma, pgoff, hpage, pmd)) {
> +				spin_unlock(ptl);
> +				up_write(&vma->vm_mm->mmap_sem);
> +				continue;
> +			}
>  			_pmd = pmdp_collapse_flush(vma, addr, pmd);
>  			spin_unlock(ptl);
>  			up_write(&vma->vm_mm->mmap_sem);
>  			mm_dec_nr_ptes(vma->vm_mm);
>  			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
> -		}
> +		} else
> +			set_bit(AS_COLLAPSE_PMD, &mapping->flags);
>  	}
>  	i_mmap_unlock_write(mapping);
>  }
> @@ -1561,7 +1601,7 @@ static void collapse_file(struct mm_struct *mm,
>  		/*
>  		 * Remove pte page tables, so we can re-fault the page as huge.
>  		 */
> -		retract_page_tables(mapping, start);
> +		retract_page_tables(mapping, start, new_page);
>  		*hpage = NULL;
>  
>  		khugepaged_pages_collapsed++;
> @@ -1622,6 +1662,7 @@ static void khugepaged_scan_file(struct mm_struct *mm,
>  	int present, swap;
>  	int node = NUMA_NO_NODE;
>  	int result = SCAN_SUCCEED;
> +	bool collapse_pmd = false;
>  
>  	present = 0;
>  	swap = 0;
> @@ -1640,6 +1681,14 @@ static void khugepaged_scan_file(struct mm_struct *mm,
>  		}
>  
>  		if (PageTransCompound(page)) {
> +			if (collapse_pmd ||
> +			    test_and_clear_bit(AS_COLLAPSE_PMD,
> +					       &mapping->flags)) {

Who said it's the only PMD range that's subject to collapse? The bit has
to be per-PMD, not per-mapping.

I beleive we can store the bit in struct page of PTE page table, clearing
it if we've mapped anyting that doesn't belong to there from fault path.

And in general this calls for more substantial re-design for khugepaged:
we might want to split if into two different kernel threads. One works on
collapsing small pages into compound and the other changes virtual address
space to map the page as PMD.

Even if only the first step is successful, it's still useful: the new
mapping of the file will get huge page, even if the old is sill
PTE-mapped.

-- 
 Kirill A. Shutemov

