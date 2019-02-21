Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECC5DC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:19:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B74E52083B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:19:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B74E52083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54E688E00A4; Thu, 21 Feb 2019 13:19:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FD1C8E0094; Thu, 21 Feb 2019 13:19:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C37A8E00A4; Thu, 21 Feb 2019 13:19:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14EEB8E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:19:43 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id y6so3824941qke.1
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:19:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=JO/keiiaIBO3hroLw/Ff2gIs831VRUkdsuRsFT/Z7n0=;
        b=K8OxbVOuC+G1ItWOHetmshia+R8UgbIfcg4WdCX/qGGTVDngmPa+1faiQ0qQUQWUEq
         ShXpeKSqTH/pfriKhG/bv1EVHcWlJFpkO7D2qGjsmF7NjfynAQgwe/ulA7pMtaA50zXd
         iy5B0dJLJWa1syvwU7gCQPsGHY80kI4gqp79uugsQFvVm/lM1E47oBGW3X/rrnHO1vgC
         hSyYhbOCIHV18zn18h1/vRdg2WVRMAwlmHBqieh9HHIqO2MM8+kgynavHv6ccUtE6dwT
         kaxp6E5lKMLly/NR/NtSzotiRrc7f8TM9TqzVWcdxEg0V8/lbt7CA+DfrMaeRf8ua8eC
         zeEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaONtBEyoq2eTixVCVAhcwESKHnmeG2D+s7KYipEZjjqYvQpRfr
	/ykDM478ORzKY9NNHA2aIoRTJCQofxrN4Vaa8ydiBlpmlWDEgI1i9UiNaSxNL25S/9EwHaeo7xl
	ZmHfWZcA/KNonKcJVCMuK3X3tNZxkr5l0SlzSRqc38KizAzEnwPZ1WAL9hQkkiX+waw==
X-Received: by 2002:ae9:ea0f:: with SMTP id f15mr30312443qkg.113.1550773182813;
        Thu, 21 Feb 2019 10:19:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IblSy1xyJqIidIrFJltIO47xQx6u38UFS4YkckF00LCdjWup2eEXf0ID2DUT+KCUTzlXK0H
X-Received: by 2002:ae9:ea0f:: with SMTP id f15mr30312412qkg.113.1550773182216;
        Thu, 21 Feb 2019 10:19:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550773182; cv=none;
        d=google.com; s=arc-20160816;
        b=oZ8M5ppiI6Zdvt3hg6QCxI/EdK545pBeRf6JnKpleepP4uFdv7JoUa9WuloJXYnga0
         hxEt3a8I16Q3Hm017tuCSa2A7F5I5AxWxXXm83qsVO5nYwTLBa9aIZWxdCA4w5R2qJ5A
         XQ252WcSzD3NHamn2bD/Or9KIQdWcjuv+7LIlA52MFp9hTW+gkd0viqdNnRHimUICYqp
         2KI1JGDlknEhE99/YYKSyOwu6lBwz5wTJfVpfFQvNS+COOpvg0/PYRzAk9MC4AHiboiX
         dJM0xYxlk+BsoDYEXbFMzZ/xlX/zqsOx44PZ6wNl1re/wKv81JOCBJKgx/OlmIMKehJD
         2IkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=JO/keiiaIBO3hroLw/Ff2gIs831VRUkdsuRsFT/Z7n0=;
        b=gcPgf2LN8nD0OkhcJ/Xqsg9AiXJh31++ZR56GPHb+Pnm+ofzRiP7Zc8kzWeiH69u3+
         CucAZSLJEA5+UK6dPIBpoMQ3xmHx3D8T+QzH0bRnXC9IaIYBdsImZxFv9tBUcVngoMdV
         QL9oSar4OsPmymQ/Kx/aLklghxf7QmgwPzPBc512J2DhHxSa/IM6divA19ywO6IZT+aB
         KJ4ip4r+R9Rdauyb1hmIqLtqUPoClAv065W1Snmr7ZdGzQkipXR7oV6Ord1fGlOiToX2
         4fY002SmtV1xywbX2PRTlXnbeG48wVjC7mKl1Lv4fR4gKIn1B3p7IDGtcL9DVPwKq2iQ
         EErQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d27si2083937qtk.55.2019.02.21.10.19.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:19:42 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3E0B459452;
	Thu, 21 Feb 2019 18:19:41 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 932D95D9D3;
	Thu, 21 Feb 2019 18:19:33 +0000 (UTC)
Date: Thu, 21 Feb 2019 13:19:32 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 19/26] userfaultfd: introduce helper vma_find_uffd
Message-ID: <20190221181931.GS2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-20-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-20-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 21 Feb 2019 18:19:41 +0000 (UTC)
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

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

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

