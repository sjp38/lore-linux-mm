Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE4F6C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:29:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DEF320645
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:29:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DEF320645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 188558E000B; Mon, 25 Feb 2019 13:29:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15E628E0009; Mon, 25 Feb 2019 13:29:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 026B98E000B; Mon, 25 Feb 2019 13:29:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B16648E0009
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:29:06 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e2so7843661pln.12
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:29:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=LNxtI99y9H8G2t75wMxrsYF3meRZl87Y06BYQuTKiWk=;
        b=riviw4iG9m5V/9bbLAp7btcpoPeitqvJtndasW+Y396tsnB4jKHmrv5JQdKGsaURnx
         nhR45OkXbaHV4ZZePRP9ct0dmp8NAau+m3RWn4C/Ux23kEBKNFj//V3ASgnupdTtaq4o
         iBX9QmkJ1Z24hY7hLM2X3tKlemyYsNxWwC8Vs9vnjyglcL7SLp2kLV+z3g9WkplPvw0K
         X5vysHrQkeQJ0Q2vOKXdiEXYvRrV/xXX+lna2AJglVlNgdaP/xgo+b+JNBe106RhYoTT
         SkLVQMHJ8BW+9nWHz0K6dImceA001UuZMoNP3HQrXGSXKyvPK7NSX+9vzm1vA7QSXyrR
         taCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaiYJ+Colo/iMiShYv6WV8ED9ZFQIAPCihvDrzssTHwEFdpa3Z3
	FTHLzk+//w7V1EUJkdLjll1Gs03xMEX+lCT52q4YoZNulXrLuzUzyXyQTBpxwzHPwj3Q44miCMm
	JMmsoiAJDCOg19dOKcd/5PsUyxaHCbnOcbPUtWpT/WqxqxJn8JQ0A0wPibyaEodJQTQ==
X-Received: by 2002:a17:902:9683:: with SMTP id n3mr21993391plp.333.1551119346378;
        Mon, 25 Feb 2019 10:29:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib6wiaSLr/mrBViTq6hlnHILwbbRm9dqG6RXuZFst08sY7KEMbwOBUIW9FSifA1o2Qiits1
X-Received: by 2002:a17:902:9683:: with SMTP id n3mr21993319plp.333.1551119345187;
        Mon, 25 Feb 2019 10:29:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551119345; cv=none;
        d=google.com; s=arc-20160816;
        b=uFURDncSvpyGYhYprUpNuZZ7ioHrycGoWnt6ergVqL0MKqOG+lzWHn9lZFlqLC/q9E
         wM1WjjwL/2aEfaGa1TOQZatOxQuD8D3H8lFYg4Va8TXBvWG8SRu5HIeavNKgj/ynh1CG
         2LB4Vha9OTSZBXVbUByntOoKECO3XT//Ek/WglygGs1qL5RXg36/8pTk4/9vML3VO63c
         oQ1w0/QzY3PEa707Ze6AyIb593WzMuIGVgH6JvoB8rZxdsCEXg6zvCmr2QMF1i844R7K
         RfZAloCcOU+hSTFABO6rZyhNKk8rihoqDf9oH8/uaiVFxa+9Jn2nUuXnhD0vNufS4Ji0
         3FGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=LNxtI99y9H8G2t75wMxrsYF3meRZl87Y06BYQuTKiWk=;
        b=IgcYZ8zxsqKpVvjaHsGa6sd5lMN3eCz0f0XwTsTAwfuk3pFTRXfos7Jx/7Mwq1ymz3
         6O3FKnj8Xe97C1U40cP+dJ04NVX9Q/9orY1c7/e2ySxeCBengj49b06jn5mfx5Go3JOh
         yYdTDHWI2J9nfRWnTMEseR7SWWKbmlTl2maYQztCJEPhmUc3C2FtsxLyASX2z6sf3B9s
         tEQEgQ0/XQOFA8dkG2KvDI01ZndhbcfqnzBf3zrfRL38R5Nin5guJb83L5KB69r4L9xt
         h2xELK0mkIyjzTZ5jrRW4OGWtXIMWJCQG3tWDdwm/5M0wYyy7ZdfWVvlKnaOh4PgD6vS
         fA6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s64si2581943pfb.67.2019.02.25.10.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 10:29:05 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PIMDUJ112644
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:29:02 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvmf93uwt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:29:02 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 18:28:59 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 18:28:53 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PISr8a51314846
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 25 Feb 2019 18:28:53 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E363652059;
	Mon, 25 Feb 2019 18:28:52 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.26])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id ECC2E52051;
	Mon, 25 Feb 2019 18:28:44 +0000 (GMT)
Date: Mon, 25 Feb 2019 20:28:40 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Marty McFadden <mcfadden8@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 17/26] userfaultfd: wp: support swap and page migration
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-18-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-18-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022518-0028-0000-0000-0000034CDB0D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022518-0029-0000-0000-0000240B2B53
Message-Id: <20190225182832.GI24917@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=998 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250134
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:23AM +0800, Peter Xu wrote:
> For either swap and page migration, we all use the bit 2 of the entry to
> identify whether this entry is uffd write-protected.  It plays a similar
> role as the existing soft dirty bit in swap entries but only for keeping
> the uffd-wp tracking for a specific PTE/PMD.
> 
> Something special here is that when we want to recover the uffd-wp bit
> from a swap/migration entry to the PTE bit we'll also need to take care
> of the _PAGE_RW bit and make sure it's cleared, otherwise even with the
> _PAGE_UFFD_WP bit we can't trap it at all.
> 
> Note that this patch removed two lines from "userfaultfd: wp: hook
> userfault handler to write protection fault" where we try to remove the
> VM_FAULT_WRITE from vmf->flags when uffd-wp is set for the VMA.  This
> patch will still keep the write flag there.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  include/linux/swapops.h | 2 ++
>  mm/huge_memory.c        | 3 +++
>  mm/memory.c             | 8 ++++++--
>  mm/migrate.c            | 7 +++++++
>  mm/mprotect.c           | 2 ++
>  mm/rmap.c               | 6 ++++++
>  6 files changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 4d961668e5fc..0c2923b1cdb7 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -68,6 +68,8 @@ static inline swp_entry_t pte_to_swp_entry(pte_t pte)
> 
>  	if (pte_swp_soft_dirty(pte))
>  		pte = pte_swp_clear_soft_dirty(pte);
> +	if (pte_swp_uffd_wp(pte))
> +		pte = pte_swp_clear_uffd_wp(pte);
>  	arch_entry = __pte_to_swp_entry(pte);
>  	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
>  }
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index fb2234cb595a..75de07141801 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2175,6 +2175,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  		write = is_write_migration_entry(entry);
>  		young = false;
>  		soft_dirty = pmd_swp_soft_dirty(old_pmd);
> +		uffd_wp = pmd_swp_uffd_wp(old_pmd);
>  	} else {
>  		page = pmd_page(old_pmd);
>  		if (pmd_dirty(old_pmd))
> @@ -2207,6 +2208,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  			entry = swp_entry_to_pte(swp_entry);
>  			if (soft_dirty)
>  				entry = pte_swp_mksoft_dirty(entry);
> +			if (uffd_wp)
> +				entry = pte_swp_mkuffd_wp(entry);
>  		} else {
>  			entry = mk_pte(page + i, READ_ONCE(vma->vm_page_prot));
>  			entry = maybe_mkwrite(entry, vma);
> diff --git a/mm/memory.c b/mm/memory.c
> index c2035539e9fd..7cee990d67cf 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -736,6 +736,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  				pte = swp_entry_to_pte(entry);
>  				if (pte_swp_soft_dirty(*src_pte))
>  					pte = pte_swp_mksoft_dirty(pte);
> +				if (pte_swp_uffd_wp(*src_pte))
> +					pte = pte_swp_mkuffd_wp(pte);
>  				set_pte_at(src_mm, addr, src_pte, pte);
>  			}
>  		} else if (is_device_private_entry(entry)) {
> @@ -2815,8 +2817,6 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>  	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
>  	pte = mk_pte(page, vma->vm_page_prot);
> -	if (userfaultfd_wp(vma))
> -		vmf->flags &= ~FAULT_FLAG_WRITE;
>  	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
>  		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
>  		vmf->flags &= ~FAULT_FLAG_WRITE;
> @@ -2826,6 +2826,10 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  	flush_icache_page(vma, page);
>  	if (pte_swp_soft_dirty(vmf->orig_pte))
>  		pte = pte_mksoft_dirty(pte);
> +	if (pte_swp_uffd_wp(vmf->orig_pte)) {
> +		pte = pte_mkuffd_wp(pte);
> +		pte = pte_wrprotect(pte);
> +	}
>  	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
>  	arch_do_swap_page(vma->vm_mm, vma, vmf->address, pte, vmf->orig_pte);
>  	vmf->orig_pte = pte;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index d4fd680be3b0..605ccd1f5c64 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -242,6 +242,11 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
>  		if (is_write_migration_entry(entry))
>  			pte = maybe_mkwrite(pte, vma);
> 
> +		if (pte_swp_uffd_wp(*pvmw.pte)) {
> +			pte = pte_mkuffd_wp(pte);
> +			pte = pte_wrprotect(pte);
> +		}
> +
>  		if (unlikely(is_zone_device_page(new))) {
>  			if (is_device_private_page(new)) {
>  				entry = make_device_private_entry(new, pte_write(pte));
> @@ -2290,6 +2295,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  			swp_pte = swp_entry_to_pte(entry);
>  			if (pte_soft_dirty(pte))
>  				swp_pte = pte_swp_mksoft_dirty(swp_pte);
> +			if (pte_uffd_wp(pte))
> +				swp_pte = pte_swp_mkuffd_wp(swp_pte);
>  			set_pte_at(mm, addr, ptep, swp_pte);
> 
>  			/*
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index ae93721f3795..73a65f07fe41 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -187,6 +187,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  				newpte = swp_entry_to_pte(entry);
>  				if (pte_swp_soft_dirty(oldpte))
>  					newpte = pte_swp_mksoft_dirty(newpte);
> +				if (pte_swp_uffd_wp(oldpte))
> +					newpte = pte_swp_mkuffd_wp(newpte);
>  				set_pte_at(mm, addr, pte, newpte);
> 
>  				pages++;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 0454ecc29537..3750d5a5283c 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1469,6 +1469,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			swp_pte = swp_entry_to_pte(entry);
>  			if (pte_soft_dirty(pteval))
>  				swp_pte = pte_swp_mksoft_dirty(swp_pte);
> +			if (pte_uffd_wp(pteval))
> +				swp_pte = pte_swp_mkuffd_wp(swp_pte);
>  			set_pte_at(mm, pvmw.address, pvmw.pte, swp_pte);
>  			/*
>  			 * No need to invalidate here it will synchronize on
> @@ -1561,6 +1563,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			swp_pte = swp_entry_to_pte(entry);
>  			if (pte_soft_dirty(pteval))
>  				swp_pte = pte_swp_mksoft_dirty(swp_pte);
> +			if (pte_uffd_wp(pteval))
> +				swp_pte = pte_swp_mkuffd_wp(swp_pte);
>  			set_pte_at(mm, address, pvmw.pte, swp_pte);
>  			/*
>  			 * No need to invalidate here it will synchronize on
> @@ -1627,6 +1631,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			swp_pte = swp_entry_to_pte(entry);
>  			if (pte_soft_dirty(pteval))
>  				swp_pte = pte_swp_mksoft_dirty(swp_pte);
> +			if (pte_uffd_wp(pteval))
> +				swp_pte = pte_swp_mkuffd_wp(swp_pte);
>  			set_pte_at(mm, address, pvmw.pte, swp_pte);
>  			/* Invalidate as we cleared the pte */
>  			mmu_notifier_invalidate_range(mm, address,
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

