Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 438B6C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:48:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEB132087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:48:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEB132087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AEEC8E000D; Mon, 25 Feb 2019 15:48:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75B458E000C; Mon, 25 Feb 2019 15:48:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 654028E000D; Mon, 25 Feb 2019 15:48:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 370D18E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:48:32 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id k13so8893000iop.0
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:48:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=GOg+yGA0nUuU+236yPWaJyiMMHiLtxiC8b775poBAQk=;
        b=izoWd5KXGzkg6bEJmKsuiwywGSdVeZRAdJxwUnI6vLaUxQgm4eE0R+kF/7w5N/5h+v
         M9PQFJX5yqDD0sVCuckyjcULkKaq06Xt5JJuFhHiBh9DguMTQ1bG9FlGDsvOlgYafwdN
         z4qn+uU0nP/ML8HgPj2p/nO5p3FaQTkfWTSnJML/zTxBGBU6F9artmSORnF3kW3BldBH
         8+HUN46ZHiwEm+lGzYkbFZauSuZEQue962dkFMAxMxFaKr4fnYULSGsE/Dr808QYn2X9
         UtYr8wRt1q2lZHueAU1h4DmV8RbR0W5LjUv6RBwqwjHa6aTRUUE6X2fo/zbUQxnd3Ui6
         VsPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZYaoBF9bBSXr91VMgOUooiikjIn5rAndEZJfn6aeLqzrUPSaGQ
	FuEojJjU7OrQnMdBU/UGtJyWLt9aTfDX56c5DZOrgvwpHLFKPKfkLGOTyQBp4SkQAMAgmeWRs3G
	Ec3dsm5J5xUvI+9x12jIe7wGGpdf+N+sYZgnrTk8x862Ew1OSKw9Wi+sMvzguI6zbRQ==
X-Received: by 2002:a05:660c:344:: with SMTP id b4mr408346itl.155.1551127711809;
        Mon, 25 Feb 2019 12:48:31 -0800 (PST)
X-Google-Smtp-Source: APXvYqzF0XCh8w5UOzQjTKSbkUuSEuxivP9SA2FFgrK1bA1+L5n0zPakyYXB6iQ16kc1nCNTsFoM
X-Received: by 2002:a05:660c:344:: with SMTP id b4mr408298itl.155.1551127710663;
        Mon, 25 Feb 2019 12:48:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551127710; cv=none;
        d=google.com; s=arc-20160816;
        b=q2cUDqFsYwLifw3C/XnsNpgdHc/yk28l/zEz0oaOpZonR/JkU9QMbVM8FGopeVysha
         ci308tdknfCBvWJhFyrRgI04tQpgkd7SR5+pe7++0DnrS4M7bKk19GKVMklGrdt9EOQL
         gxgGstQOtuFUI7LQvfRnbMapeXNiTUze0BZCJcAnZz8DycAonByohhuYWih5jiGMkrdr
         E6EUhPjZKHVOq1YEfFigaZmg7+0KDU+GNoptc1aVvqxRpg5l6Ni4cVPeKzZddK0NrrJR
         YnrM45Z8XzDIOlfk0rFRlfPjzW9RUVWFHFhtRw7mzPBJdufIW8kHDVHTxEdgzQuEZvGi
         G0YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=GOg+yGA0nUuU+236yPWaJyiMMHiLtxiC8b775poBAQk=;
        b=aPeP6xT9m0OI756HUl3n2AJHgdtj/gGduroGWTSL1AVQ4DsWNEjjO74Z+cZQeAehjH
         HGIJjXg+UzvK2Ssqvyoqq37uiUKqD6Ok9sOJ5tG5tAwiEYZqPpt9rA2/EQEkt/diF37k
         VNIOZBLIK/rDzlM43LD8a1PtXlQU6nFPeNHN2pq6rnMAldUrgsWS6SnJveIW2dGhUIjx
         dcBldC3LTGgF3g99SdD2Pf0H0pCDdKjonn69rdRBgRaOatF1sejqk3MzzU3XSIZDJV9P
         qka5bHffv0i3ON7RC6tDGaiHjmnxzsfVU36+9jJAimePeHCVyfPqlOgg5juRyp+k065m
         cKRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d24si4854387ioc.101.2019.02.25.12.48.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 12:48:30 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PKixKY173438
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:48:29 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qvnc7pqah-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:48:29 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 20:48:27 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 20:48:22 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PKmLPL30670850
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 20:48:21 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 13A2C11C064;
	Mon, 25 Feb 2019 20:48:21 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 743B411C04C;
	Mon, 25 Feb 2019 20:48:18 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.243])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 20:48:18 +0000 (GMT)
Date: Mon, 25 Feb 2019 22:48:15 +0200
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
Subject: Re: [PATCH v2 19/26] userfaultfd: introduce helper vma_find_uffd
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-20-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-20-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022520-0012-0000-0000-000002FA0E9C
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022520-0013-0000-0000-00002131B02E
Message-Id: <20190225204815.GB10454@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=953 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250149
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:25AM +0800, Peter Xu wrote:
> We've have multiple (and more coming) places that would like to find a
> userfault enabled VMA from a mm struct that covers a specific memory
> range.  This patch introduce the helper for it, meanwhile apply it to
> the code.
> 
> Suggested-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  mm/userfaultfd.c | 54 +++++++++++++++++++++++++++---------------------
>  1 file changed, 30 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index 80bcd642911d..fefa81c301b7 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -20,6 +20,34 @@
>  #include <asm/tlbflush.h>
>  #include "internal.h"
> 
> +/*
> + * Find a valid userfault enabled VMA region that covers the whole
> + * address range, or NULL on failure.  Must be called with mmap_sem
> + * held.
> + */
> +static struct vm_area_struct *vma_find_uffd(struct mm_struct *mm,
> +					    unsigned long start,
> +					    unsigned long len)
> +{
> +	struct vm_area_struct *vma = find_vma(mm, start);
> +
> +	if (!vma)
> +		return NULL;
> +
> +	/*
> +	 * Check the vma is registered in uffd, this is required to
> +	 * enforce the VM_MAYWRITE check done at uffd registration
> +	 * time.
> +	 */
> +	if (!vma->vm_userfaultfd_ctx.ctx)
> +		return NULL;
> +
> +	if (start < vma->vm_start || start + len > vma->vm_end)
> +		return NULL;
> +
> +	return vma;
> +}
> +
>  static int mcopy_atomic_pte(struct mm_struct *dst_mm,
>  			    pmd_t *dst_pmd,
>  			    struct vm_area_struct *dst_vma,
> @@ -228,20 +256,9 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
>  	 */
>  	if (!dst_vma) {
>  		err = -ENOENT;
> -		dst_vma = find_vma(dst_mm, dst_start);
> +		dst_vma = vma_find_uffd(dst_mm, dst_start, len);
>  		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
>  			goto out_unlock;
> -		/*
> -		 * Check the vma is registered in uffd, this is
> -		 * required to enforce the VM_MAYWRITE check done at
> -		 * uffd registration time.
> -		 */
> -		if (!dst_vma->vm_userfaultfd_ctx.ctx)
> -			goto out_unlock;
> -
> -		if (dst_start < dst_vma->vm_start ||
> -		    dst_start + len > dst_vma->vm_end)
> -			goto out_unlock;
> 
>  		err = -EINVAL;
>  		if (vma_hpagesize != vma_kernel_pagesize(dst_vma))
> @@ -488,20 +505,9 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  	 * both valid and fully within a single existing vma.
>  	 */
>  	err = -ENOENT;
> -	dst_vma = find_vma(dst_mm, dst_start);
> +	dst_vma = vma_find_uffd(dst_mm, dst_start, len);
>  	if (!dst_vma)
>  		goto out_unlock;
> -	/*
> -	 * Check the vma is registered in uffd, this is required to
> -	 * enforce the VM_MAYWRITE check done at uffd registration
> -	 * time.
> -	 */
> -	if (!dst_vma->vm_userfaultfd_ctx.ctx)
> -		goto out_unlock;
> -
> -	if (dst_start < dst_vma->vm_start ||
> -	    dst_start + len > dst_vma->vm_end)
> -		goto out_unlock;
> 
>  	err = -EINVAL;
>  	/*
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

