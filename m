Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAA8DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:02:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94F112084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:02:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94F112084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D3A98E000E; Mon, 25 Feb 2019 13:02:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 282A58E000D; Mon, 25 Feb 2019 13:02:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 173DC8E000E; Mon, 25 Feb 2019 13:02:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id D40BC8E000D
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:01:59 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id q65so6241477vkd.4
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:01:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=S0bVXpwyi1F6jSqVincTOMCcxOyV3ffmnkfaGP/JGFA=;
        b=aQVTgBlrWP2OGVbNrTXbhIQATCqzdt0MV/q66v0HI9suQCxAEWXUpnarI3qMRetfg+
         Y+TP5hlMlGtfMyiVSRZ41m1xN9GghDyyRb+MBXdx9yyxrI5Ry89ygXYxSpX9w8utR+LK
         RVGKpOgQ5Ku/nhaSyapj0CoO1nEDoKh9bFcykIT8HJ2wG/bTeYpPS/S9x1q4QeX/Z0Se
         Yy2irPQYYTrLc9k2vNGycFmNy9LYQrql6n0O1P48KO6aIfLZ/A7VTZQ26Sg4l0KaoYOS
         yPyZXre04xJ4r1s/HxB8rVw5bxmmB6tEh0KcI8tiyvkrP1t68SXtBzOzl0PUmMcFxt/s
         l+gQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaCpwS0T4WTX3PYHG1mr6gnJR42Q2NSqtwtAyxL3H+XdoYivah7
	YqGE6vWOJg3u9OrivR/DdyIzF/+I6vFINMLn6Ldsj87GxHKZsKeJne33oIVRKJiXIMaiNwMRDxL
	w2nLtnd4o504TOu/DdP5oWWAUfpAPZSUbojl9Hsqvr53bTCu1Ljy1WXkkOupBDo+JWw==
X-Received: by 2002:a05:6102:18f:: with SMTP id r15mr9804410vsq.215.1551117719532;
        Mon, 25 Feb 2019 10:01:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaodnDyUFPS12nP4Qvg1ryny6Gh5kRmFRjxmXf1P1kU/h6H+uMwtE1gHRaFqgT0MTrrlsKB
X-Received: by 2002:a05:6102:18f:: with SMTP id r15mr9804343vsq.215.1551117718319;
        Mon, 25 Feb 2019 10:01:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551117718; cv=none;
        d=google.com; s=arc-20160816;
        b=PsGO648DljwXBoCCFzkHy6wbzGKN89EZ6PfPfGryp9xmzh8fCnsexKgFXRCE083zUS
         daShxXnZlgTchuCR8ufK0L2K7bwbET1vzZfc9iGU6dJnN7AjFtc2RJxdlHWFpm9L6fvh
         +vk1tbdTq3pRcx1jHb23SYS61+Ls09PjSLwaQsaOlTAbv5jlm5WFBmgBCwNWPhiT1c3z
         X0e4EbYuJ67Ap0sIfp7WpxRD5V0ptn2mQ6DV1GmI2C9St4eXuqxn7HOElOGpaCYFq2ep
         LdDXP0TTmz/vrtzJ+xrVIxVvYffmwlc7WmuBrkJwCXM2zE29qlH0LKR9Y4yNoq48NqtE
         Y7eA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=S0bVXpwyi1F6jSqVincTOMCcxOyV3ffmnkfaGP/JGFA=;
        b=PNMPvq3RFMxlrhRhAMVJZijR0/UYXw9IFPMY99VBxZMwbA6ndi1yY24xnKra9ar3/O
         ZDj6XSiYdp09K4iekRV2AH1FJG2iasoNK3rOZPWBxxst/8Xcu57YN3O59LZ0WSs+AkZi
         Vpy5tP9ukQxhxC1oCF9pYjg6tb0SMer7CG23DZ63QZuFPBsCogervm5XZ/N/e5Kd5Ema
         4iFwrq6a8e22dBPS05YdFWfL78Jrl+XdIXZ/+PZWsrguz1C5/T8aXaArc/VGM0+X6rWI
         uSeA0sb9hwm0HpCtXvl2atMktrHFxgQ/S2X21eCEyb0gE0cpyod+m1tjR1e9Rt2gdi9v
         q6sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 186si1809111vsl.341.2019.02.25.10.01.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 10:01:58 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PI1agB052062
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:01:57 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvkugmnar-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:01:40 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 18:00:27 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 18:00:21 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PI0Kn960817580
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 18:00:20 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F3E6E11C04A;
	Mon, 25 Feb 2019 18:00:19 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0234111C052;
	Mon, 25 Feb 2019 18:00:16 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.26])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 18:00:15 +0000 (GMT)
Date: Mon, 25 Feb 2019 20:00:13 +0200
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
Subject: Re: [PATCH v2 12/26] userfaultfd: wp: apply _PAGE_UFFD_WP bit
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-13-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-13-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022518-0016-0000-0000-0000025ABA76
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022518-0017-0000-0000-000032B51929
Message-Id: <20190225180011.GF24917@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250132
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:18AM +0800, Peter Xu wrote:
> Firstly, introduce two new flags MM_CP_UFFD_WP[_RESOLVE] for
> change_protection() when used with uffd-wp and make sure the two new
> flags are exclusively used.  Then,
> 
>   - For MM_CP_UFFD_WP: apply the _PAGE_UFFD_WP bit and remove _PAGE_RW
>     when a range of memory is write protected by uffd
> 
>   - For MM_CP_UFFD_WP_RESOLVE: remove the _PAGE_UFFD_WP bit and recover
>     _PAGE_RW when write protection is resolved from userspace
> 
> And use this new interface in mwriteprotect_range() to replace the old
> MM_CP_DIRTY_ACCT.
> 
> Do this change for both PTEs and huge PMDs.  Then we can start to
> identify which PTE/PMD is write protected by general (e.g., COW or soft
> dirty tracking), and which is for userfaultfd-wp.
> 
> Since we should keep the _PAGE_UFFD_WP when doing pte_modify(), add it
> into _PAGE_CHG_MASK as well.  Meanwhile, since we have this new bit, we
> can be even more strict when detecting uffd-wp page faults in either
> do_wp_page() or wp_huge_pmd().
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  arch/x86/include/asm/pgtable_types.h |  2 +-
>  include/linux/mm.h                   |  5 +++++
>  mm/huge_memory.c                     | 14 +++++++++++++-
>  mm/memory.c                          |  4 ++--
>  mm/mprotect.c                        | 12 ++++++++++++
>  mm/userfaultfd.c                     |  8 ++++++--
>  6 files changed, 39 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index 8cebcff91e57..dd9c6295d610 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -133,7 +133,7 @@
>   */
>  #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
>  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
> -			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
> +			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP | _PAGE_UFFD_WP)
>  #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
> 
>  /*
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 9fe3b0066324..f38fbe9c8bc9 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1657,6 +1657,11 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
>  #define  MM_CP_DIRTY_ACCT                  (1UL << 0)
>  /* Whether this protection change is for NUMA hints */
>  #define  MM_CP_PROT_NUMA                   (1UL << 1)
> +/* Whether this change is for write protecting */
> +#define  MM_CP_UFFD_WP                     (1UL << 2) /* do wp */
> +#define  MM_CP_UFFD_WP_RESOLVE             (1UL << 3) /* Resolve wp */
> +#define  MM_CP_UFFD_WP_ALL                 (MM_CP_UFFD_WP | \
> +					    MM_CP_UFFD_WP_RESOLVE)
> 
>  extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
>  			      unsigned long end, pgprot_t newprot,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 8d65b0f041f9..817335b443c2 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1868,6 +1868,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	bool preserve_write;
>  	int ret;
>  	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
> +	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
> +	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
> 
>  	ptl = __pmd_trans_huge_lock(pmd, vma);
>  	if (!ptl)
> @@ -1934,6 +1936,13 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	entry = pmd_modify(entry, newprot);
>  	if (preserve_write)
>  		entry = pmd_mk_savedwrite(entry);
> +	if (uffd_wp) {
> +		entry = pmd_wrprotect(entry);
> +		entry = pmd_mkuffd_wp(entry);
> +	} else if (uffd_wp_resolve) {
> +		entry = pmd_mkwrite(entry);
> +		entry = pmd_clear_uffd_wp(entry);
> +	}
>  	ret = HPAGE_PMD_NR;
>  	set_pmd_at(mm, addr, pmd, entry);
>  	BUG_ON(vma_is_anonymous(vma) && !preserve_write && pmd_write(entry));
> @@ -2083,7 +2092,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	struct page *page;
>  	pgtable_t pgtable;
>  	pmd_t old_pmd, _pmd;
> -	bool young, write, soft_dirty, pmd_migration = false;
> +	bool young, write, soft_dirty, pmd_migration = false, uffd_wp = false;
>  	unsigned long addr;
>  	int i;
> 
> @@ -2165,6 +2174,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  		write = pmd_write(old_pmd);
>  		young = pmd_young(old_pmd);
>  		soft_dirty = pmd_soft_dirty(old_pmd);
> +		uffd_wp = pmd_uffd_wp(old_pmd);
>  	}
>  	VM_BUG_ON_PAGE(!page_count(page), page);
>  	page_ref_add(page, HPAGE_PMD_NR - 1);
> @@ -2198,6 +2208,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  				entry = pte_mkold(entry);
>  			if (soft_dirty)
>  				entry = pte_mksoft_dirty(entry);
> +			if (uffd_wp)
> +				entry = pte_mkuffd_wp(entry);
>  		}
>  		pte = pte_offset_map(&_pmd, addr);
>  		BUG_ON(!pte_none(*pte));
> diff --git a/mm/memory.c b/mm/memory.c
> index 00781c43407b..f8d83ae16eff 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2483,7 +2483,7 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
> 
> -	if (userfaultfd_wp(vma)) {
> +	if (userfaultfd_pte_wp(vma, *vmf->pte)) {
>  		pte_unmap_unlock(vmf->pte, vmf->ptl);
>  		return handle_userfault(vmf, VM_UFFD_WP);
>  	}
> @@ -3692,7 +3692,7 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
>  static inline vm_fault_t wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
>  {
>  	if (vma_is_anonymous(vmf->vma)) {
> -		if (userfaultfd_wp(vmf->vma))
> +		if (userfaultfd_huge_pmd_wp(vmf->vma, orig_pmd))
>  			return handle_userfault(vmf, VM_UFFD_WP);
>  		return do_huge_pmd_wp_page(vmf, orig_pmd);
>  	}
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index a6ba448c8565..9d4433044c21 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -46,6 +46,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  	int target_node = NUMA_NO_NODE;
>  	bool dirty_accountable = cp_flags & MM_CP_DIRTY_ACCT;
>  	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
> +	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
> +	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
> 
>  	/*
>  	 * Can be called with only the mmap_sem for reading by
> @@ -117,6 +119,14 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  			if (preserve_write)
>  				ptent = pte_mk_savedwrite(ptent);
> 
> +			if (uffd_wp) {
> +				ptent = pte_wrprotect(ptent);
> +				ptent = pte_mkuffd_wp(ptent);
> +			} else if (uffd_wp_resolve) {
> +				ptent = pte_mkwrite(ptent);
> +				ptent = pte_clear_uffd_wp(ptent);
> +			}
> +
>  			/* Avoid taking write faults for known dirty pages */
>  			if (dirty_accountable && pte_dirty(ptent) &&
>  					(pte_soft_dirty(ptent) ||
> @@ -301,6 +311,8 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
>  {
>  	unsigned long pages;
> 
> +	BUG_ON((cp_flags & MM_CP_UFFD_WP_ALL) == MM_CP_UFFD_WP_ALL);
> +
>  	if (is_vm_hugetlb_page(vma))
>  		pages = hugetlb_change_protection(vma, start, end, newprot);
>  	else
> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index 73a208c5c1e7..80bcd642911d 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -73,8 +73,12 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
>  		goto out_release;
> 
>  	_dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
> -	if (dst_vma->vm_flags & VM_WRITE && !wp_copy)
> -		_dst_pte = pte_mkwrite(_dst_pte);
> +	if (dst_vma->vm_flags & VM_WRITE) {
> +		if (wp_copy)
> +			_dst_pte = pte_mkuffd_wp(_dst_pte);
> +		else
> +			_dst_pte = pte_mkwrite(_dst_pte);
> +	}
> 
>  	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
>  	if (dst_vma->vm_file) {
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

