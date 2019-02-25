Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5390C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:43:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8106F2087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:43:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8106F2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 227EB8E000F; Mon, 25 Feb 2019 10:43:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D92B8E000D; Mon, 25 Feb 2019 10:43:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A09C8E000F; Mon, 25 Feb 2019 10:43:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BEAAB8E000D
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:43:18 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 11so7282347pgd.19
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:43:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=bnN+qgB0DxYQdrS9j8iU146LfKv+VjbCba5GbXg/Cd4=;
        b=Y7Aa6YwrB3nRm2W7sCuZzliOWTaudWo7khjpq/kLgxaWId7stILj1x9qH9UYFxd0YJ
         0IpCpFEuIQa2xwuBHmRAgvoQX/CWpW9iMumo+9WZ49Y89u48vvNUrU2NWNaErZN+ZzqQ
         voIX8BDcTfjcmNELKy+dZn+I7ta51rI4d6MZh8cvC4uBPnytHBfRbPusJnwefWzcCqQS
         57Z0MFrBtlqb4AE9poRVE8xSkFFthc0Tpf8agg5xqswIQ6tz/1Yaj7kJigAVnmmoBd6g
         hOOnjqecd81zJzH/+ONfhHtL7g7EjcQpk3kJUcRmUaTAbhZ941lK5QIB/WxJI7t0+1ma
         TqQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuYgmZeBGIo0trLPI+VSE74yprBWyPa+kz2CtKteakJIFKxrKgt9
	1SZGW9sLBPvhvskK6HAi7ckALLK2UaJ7uZpouASat2k6hshAwMuGutETJY0wrN+Cll2ddUX/9U+
	ubbBHK2xenoIgb7crovTm9GdHKqr6c5VvsPTKuTq8e4kHH7Zhr0nrOVPR4pVdOJ5KOQ==
X-Received: by 2002:a63:d64:: with SMTP id 36mr19109083pgn.360.1551109398381;
        Mon, 25 Feb 2019 07:43:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYCHmTorqlMGo6d305dt9lNxAYe/0Abean8Y3hKJ/SlIGCe9V9b92OrdQWWoe9H07HRF0bd
X-Received: by 2002:a63:d64:: with SMTP id 36mr19109021pgn.360.1551109397408;
        Mon, 25 Feb 2019 07:43:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551109397; cv=none;
        d=google.com; s=arc-20160816;
        b=uaGT4gzF0/ievj7vWG1dc5ROnqAWVF8Ia/0UFS97AWHnNsIhtD7F8sQWFpyhhVv4rF
         oM+v4CJusySar2DAya5H2Bz0Azoz03ceaCH8xHkku+I/bwBvHJhwAeOQdZgrjtW7uhNf
         xb6ao5iM3NotQ++IQJjKSMCA+eU0smQjWlUDWNgVou+03q5mn0BV7FwndNfTY6BE1620
         pgPdLiog86opPC2F5F1LflF8vzr62TrPmcP6POXkvjsXc6h1OxRbqBJxkFl/A6Kn5aUV
         Fz3igYJ59mNOcol95mtAODysG0sDs8AIYCOdeSAKPIPdax66vA6kNXk/nhdWLH0mZsxy
         2lvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=bnN+qgB0DxYQdrS9j8iU146LfKv+VjbCba5GbXg/Cd4=;
        b=wYBXIZ2+rtA5JyOMmeiJaqDP40z8Rm5TRbvq6TPDCn7dhVARat9IcajA91zhUVpitD
         lnp54V2clNr0+EZ8020pWxl/osfYdqjrVmpjRiCQIS/5/ALuDEerdtHddjXULdO7LCjX
         oVut+LZNGSg3dAF3U/q6fEGietOcjwyhSnpIhaVCa1NFd1Z3QN8cokO4YGX4RliXxDwl
         IeofAYlfd5bkNxDyBeP+ml3X1rXxuuxDjkJlBU+OW9JF59JkbDoJ0Ndu2CMafrUCE6bn
         fMaKBO46x2gGf/IvFjfosv6UJvsQ/EikXCy/5yXe6QYTHr2tq993qnJekvqEl3Kyzltt
         y5yA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f5si6635953plf.275.2019.02.25.07.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 07:43:17 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PFYjFP026499
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:43:16 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvgfyh73b-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:43:16 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 15:43:13 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 15:43:07 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PFh69w62718128
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 25 Feb 2019 15:43:06 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B6C12A4054;
	Mon, 25 Feb 2019 15:43:06 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0BA8FA405C;
	Mon, 25 Feb 2019 15:43:05 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.26])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 15:43:04 +0000 (GMT)
Date: Mon, 25 Feb 2019 17:43:03 +0200
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
Subject: Re: [PATCH v2 07/26] userfaultfd: wp: hook userfault handler to
 write protection fault
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-8-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-8-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022515-0020-0000-0000-0000031B07E6
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022515-0021-0000-0000-0000216C6969
Message-Id: <20190225154302.GB24917@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250114
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:13AM +0800, Peter Xu wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> There are several cases write protection fault happens. It could be a
> write to zero page, swaped page or userfault write protected
> page. When the fault happens, there is no way to know if userfault
> write protect the page before. Here we just blindly issue a userfault
> notification for vma with VM_UFFD_WP regardless if app write protects
> it yet. Application should be ready to handle such wp fault.
> 
> v1: From: Shaohua Li <shli@fb.com>
> 
> v2: Handle the userfault in the common do_wp_page. If we get there a
> pagetable is present and readonly so no need to do further processing
> until we solve the userfault.
> 
> In the swapin case, always swapin as readonly. This will cause false
> positive userfaults. We need to decide later if to eliminate them with
> a flag like soft-dirty in the swap entry (see _PAGE_SWP_SOFT_DIRTY).
> 
> hugetlbfs wouldn't need to worry about swapouts but and tmpfs would
> be handled by a swap entry bit like anonymous memory.
> 
> The main problem with no easy solution to eliminate the false
> positives, will be if/when userfaultfd is extended to real filesystem
> pagecache. When the pagecache is freed by reclaim we can't leave the
> radix tree pinned if the inode and in turn the radix tree is reclaimed
> as well.
> 
> The estimation is that full accuracy and lack of false positives could
> be easily provided only to anonymous memory (as long as there's no
> fork or as long as MADV_DONTFORK is used on the userfaultfd anonymous
> range) tmpfs and hugetlbfs, it's most certainly worth to achieve it
> but in a later incremental patch.
> 
> v3: Add hooking point for THP wrprotect faults.
> 
> CC: Shaohua Li <shli@fb.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  mm/memory.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9dd823f..00781c43407b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2483,6 +2483,11 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
> 
> +	if (userfaultfd_wp(vma)) {
> +		pte_unmap_unlock(vmf->pte, vmf->ptl);
> +		return handle_userfault(vmf, VM_UFFD_WP);
> +	}
> +
>  	vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
>  	if (!vmf->page) {
>  		/*
> @@ -2800,6 +2805,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>  	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
>  	pte = mk_pte(page, vma->vm_page_prot);
> +	if (userfaultfd_wp(vma))
> +		vmf->flags &= ~FAULT_FLAG_WRITE;
>  	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
>  		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
>  		vmf->flags &= ~FAULT_FLAG_WRITE;
> @@ -3684,8 +3691,11 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
>  /* `inline' is required to avoid gcc 4.1.2 build error */
>  static inline vm_fault_t wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
>  {
> -	if (vma_is_anonymous(vmf->vma))
> +	if (vma_is_anonymous(vmf->vma)) {
> +		if (userfaultfd_wp(vmf->vma))
> +			return handle_userfault(vmf, VM_UFFD_WP);
>  		return do_huge_pmd_wp_page(vmf, orig_pmd);
> +	}
>  	if (vmf->vma->vm_ops->huge_fault)
>  		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PMD);
> 
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

