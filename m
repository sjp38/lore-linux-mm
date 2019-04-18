Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B0C7C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:03:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C720720663
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:03:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C720720663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 676036B0007; Thu, 18 Apr 2019 16:03:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 625546B0008; Thu, 18 Apr 2019 16:03:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53B906B000A; Thu, 18 Apr 2019 16:03:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30DC56B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 16:03:53 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x23so2610000qka.19
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 13:03:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=FAFx4ShAp+k2LdSC3QzNP/2DuySOkLTNB2MoyBAl6xk=;
        b=CUd8cxqaV5I04iTzdP7jsenN+ZIVzntgvThIcF6bl1xOmXdYIpt9N273QSl6yVB1nx
         L/zaxeiRQaAQnWpZBBxZ7MYVPTbVlWT5SvZfofCSkdtyOgz31pF1QM+TvKs8IjtzwsLw
         frG/3LwHvowMWIS21tk4M2rxFGtSIz8+nMDjbGB/+VahbtH3zP5RWKUq16SKZ7upoPtu
         7gvMMUOPbS7slx2xvzgdyz8dYau6F8WCUYjsxsuydKiwDBg7fjPTKLAL0PVYnKOHG1m+
         Vn+mC2znSiG9AGNh83a/EdqYjkF3KGJIDZf8GzI0Mf85XOgf27bojOzj0C0DK+LBS3YE
         Ol/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUxtvmW0M+RpzY96N9bApalfA5LG6gOvQgyfJKcNJKSOtGqOzAw
	PRuZFdrZfJ69lRLcr7d3UsvN9OYLdK6YhU6WT8mC3cTjgy3D9SICutBkOe8HUdsJYXwZHmW7ebf
	PI38foXtfNIBHZ1vWHvJBKCjdfr53z74wwjNpUcFKVBk7TRhqXNlfrtwooGc2WjDZrQ==
X-Received: by 2002:a37:4dd0:: with SMTP id a199mr70942305qkb.164.1555617832897;
        Thu, 18 Apr 2019 13:03:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNztExm4LvDoRBmrIi0Qxsi2Fc7SIbjRuzePpFYzC+RG2oT7h8Tm25Fd89ohqAP8GXHGgJ
X-Received: by 2002:a37:4dd0:: with SMTP id a199mr70942219qkb.164.1555617831972;
        Thu, 18 Apr 2019 13:03:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555617831; cv=none;
        d=google.com; s=arc-20160816;
        b=ClyC8zqf979mtmxeyHR+UWlc+OUuEexERx43T0zN+Pz28hCtUi61rmxQEW48Ba0Mbz
         gbjHzqH7oBj2Wt5Tj/vWW+lCyFS7oU+wX7SDZMXt7t1M/yDsL2wZioo3Si61Q7m7uJxQ
         PFTvYLU6oMLoYGYIYruyi1i51O99dzUnJbl1J4UPZipmx4lQYL2+6t0loq3HVqliKdDF
         QWNpp0dO301pl+YcjSRGnwjxJWs8I76h16AIPGtGTsqIUW9lG88xIcJAwywHO6YgclHF
         KwuWjWxw/7+slygC0UasA/NkE/XlNT1yvoxhiGjqXlXnYXyGPWJkN+/IBuTuDzNRn7ix
         XjRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=FAFx4ShAp+k2LdSC3QzNP/2DuySOkLTNB2MoyBAl6xk=;
        b=xqfUT0WKy4ESNHRcsDXofxKxNUFv6CxzpulIBLRMeJ/YaI7hwPp+ZERCO6EyUjCJu/
         Um7rEflJpczIkjWfD6X2aBpWzGQnJ+2BgZG5he1ocl2+xX/UqJ0rmz+KuGrwANZH/aZL
         WjmwJjMu2auyYQAvczmQdGNZMVzpADFG1gqheZs/C0KZ0lTk+X3z6+r/Yf9hb5bAU2oo
         yhaeHcIljmYjr6kxU+qPtGoniITch83HwIm5yep/OjRSlLMlvdohkwCOj0JdLQSBDxcf
         JWI+0pYPm6oQYrFKEMbA2KxldA3BWt/utgtsxTjlo07Dg4m5Ya0WP/pjT5p8KDu+fG+j
         p8mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a23si1804334qth.45.2019.04.18.13.03.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 13:03:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9965588AC0;
	Thu, 18 Apr 2019 20:03:50 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0957A19C79;
	Thu, 18 Apr 2019 20:03:44 +0000 (UTC)
Date: Thu, 18 Apr 2019 16:03:43 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 07/28] userfaultfd: wp: hook userfault handler to
 write protection fault
Message-ID: <20190418200342.GI3288@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-8-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190320020642.4000-8-peterx@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 18 Apr 2019 20:03:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 10:06:21AM +0800, Peter Xu wrote:
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
> [peterx: don't conditionally drop FAULT_FLAG_WRITE in do_swap_page]
> Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>


Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  mm/memory.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9dd823f..567686ec086d 100644
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
> @@ -3684,8 +3689,11 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
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

