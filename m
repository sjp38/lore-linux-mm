Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B44ED6B0038
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 21:49:16 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q126so196275729pga.0
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 18:49:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1si17626708pgo.251.2017.03.05.18.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Mar 2017 18:49:15 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v262n4Nb101975
	for <linux-mm@kvack.org>; Sun, 5 Mar 2017 21:49:15 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28ytm46jw1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 05 Mar 2017 21:49:14 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 6 Mar 2017 08:19:12 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 65B57125805B
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:19:24 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v262n9XU47775754
	for <linux-mm@kvack.org>; Mon, 6 Mar 2017 08:19:09 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v262n9sY010644
	for <linux-mm@kvack.org>; Mon, 6 Mar 2017 08:19:09 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] thp: fix MADV_DONTNEED vs. MADV_FREE race
In-Reply-To: <20170302151034.27829-4-kirill.shutemov@linux.intel.com>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com> <20170302151034.27829-4-kirill.shutemov@linux.intel.com>
Date: Mon, 06 Mar 2017 08:19:03 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <871subdsrk.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> Basically the same race as with numa balancing in change_huge_pmd(), but
> a bit simpler to mitigate: we don't need to preserve dirty/young flags
> here due to MADV_FREE functionality.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> ---
>  mm/huge_memory.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index bb2b3646bd78..324217c31ec9 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1566,8 +1566,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		deactivate_page(page);
>  
>  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
> -		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
> -			tlb->fullmm);
>  		orig_pmd = pmd_mkold(orig_pmd);
>  		orig_pmd = pmd_mkclean(orig_pmd);
>  

Instead can we do a new interface that does something like

pmdp_huge_update(tlb->mm, addr, pmd, new_pmd);

We do have a variant already in ptep_set_access_flags. What we need is
something that can be used to update THP pmd, without converting it to
pmd_none and one which doens't loose reference and change bit ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
