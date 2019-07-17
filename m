Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31493C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 19:43:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE04521849
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 19:43:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pTU141rS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE04521849
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3923F6B0005; Wed, 17 Jul 2019 15:43:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 342396B0006; Wed, 17 Jul 2019 15:43:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 231BD8E0001; Wed, 17 Jul 2019 15:43:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF0C06B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 15:43:36 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k20so15244368pgg.15
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 12:43:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=B4KkASSByiIr8GwQ9SOJWtTimb9yBfYMRGwI3wSnBvU=;
        b=dhRt5pHB5jU+Dmsd8Hy30otk0Im6y2Oe9hyyj47HioPK160S7pDKZST7/WRkKK2njk
         QIpP4oPa9dfzC/P1esySJFwDSJ4nuYlyh+Z0p48LA9j9J+IEST6vbrrtbOWuRX3c6dks
         VUm83fJIwBV4QwTZnbpyfG1UwO08Lc51XnC8vtO/mOiGVlFjhS8IzUx6rBB+EA0AGVkF
         EesOv2RmZOMmTbem4l2KfzYCY+Y3zyr/O/XshbXxW2wcjKgXx2ty20hHhCH6hQVQRtH9
         GQ6c+2a5XSn5VAx+rLLB6DPFALFrw/vI43bfp9E/v7IdZEbrw9ykaiIvqWj5wGDJKql4
         mg8g==
X-Gm-Message-State: APjAAAV3NkmhUBD5Jbi1/2OW3mHrv+e5UWxj+K3/FJG3qgkms2KCFkNT
	0gzP9R/NgoEV/0mpVGWwz6AtLBFA5O9UZBZNeGPrHDNUiLSalPFDGuEVA81b2G235tYMdPAXpfn
	7xNuesESp9EL+WMiwquFZSp5TUKdvnq8nm3aNUMUPJ7xecl6CR4D3qrCfKTivF28kVg==
X-Received: by 2002:a17:90a:1ae2:: with SMTP id p89mr43837306pjp.26.1563392616507;
        Wed, 17 Jul 2019 12:43:36 -0700 (PDT)
X-Received: by 2002:a17:90a:1ae2:: with SMTP id p89mr43837254pjp.26.1563392615770;
        Wed, 17 Jul 2019 12:43:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563392615; cv=none;
        d=google.com; s=arc-20160816;
        b=1F1YoVrXt6TWlsZ7zwc1qbOoy8Iy81fVC4RQ3v/fWo720u4LFz5sv6uK6HLEbBSGQL
         9iDmNG9oBxVYyDf9ZxkCD4HQDbHW6n7+p69ooeP3wahsYx2PR7jCC+9DYXsZ7o3+HzIX
         8udBQYOLVFvfLze38ZF9g9uHvmFMurI/4Zqw0orM+jZk44ovYvs9zokmo1nd/iAPDO8p
         iJnibp4icbxq/aNsWaY7z3Px1SASsDc3zpP1wlnEASQVXB18u78FZuXiDcK3FWFMsVRs
         Em8Ow9KNBlnSeuS8g0WRdWDvqWdKwLZd3lTOTo6GqWNspuVe6USqy1ZKeVave77sokMe
         d7hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=B4KkASSByiIr8GwQ9SOJWtTimb9yBfYMRGwI3wSnBvU=;
        b=gyfu8gKa3DdwIshOPQCFJ/xg3I9CHhg6CzBFr+dzqoOX1lQ8w8H0NgY0plQeLfJ2hx
         sCIJCF/C/XCtJP1j+Qg21y2L+zw6OsVyiybo/hLQq/la6a1reONPwMF/h2Wg0Rh0bgNs
         GM6jj1HqZh802LIz56azCXx7ARC5pEY+Sr/7J4vO6zKKr+PZSktI63AFpBB/Wa6qEoxm
         6m/otlZNHCS6grQvO8QrQITdAQGzHhNodOnz0ukTEuJck0DlyALWtiwT9SEoyiHpyLhY
         DJlfINmvvjDqJvlru+mzIC6yuHdpCMp0A2HrwvB6j3zoOiauOUy5qHCvv9eVj9JFPGQu
         yFQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pTU141rS;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor13143852pgq.12.2019.07.17.12.43.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 12:43:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pTU141rS;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=B4KkASSByiIr8GwQ9SOJWtTimb9yBfYMRGwI3wSnBvU=;
        b=pTU141rSxqpEpOL4UTml41bJC99Bbi08614VBV9iACXfdQBYQMGLsTxyZ5eWCJAsxp
         PkmS856N30EwaXjbhF/ogszdHLt5Y16oU9gI/Webo0Vzi3aLl7HBczJU2vNPyd+qTCEu
         Q3maXbuUy2yk1XlmTAlUbOmk1w6cqlSqw4Gt8BjP7ChFlly+n1AVNH7KVan6v6f2Elvx
         g4XUKTtvMIwVBZ0eeC13hoMhs+oVB4chrRXX80ycgTxXu0xYpRCAz4p4g4Z2ttJIctMO
         D5r4iEMm9pJU+QauaDTSBBFfvWV9kONhJqPiCSKskg6RibNRsS9fk61AKXSnuBtq18le
         smkA==
X-Google-Smtp-Source: APXvYqzKGlDmY51u8++gkpOHjmKk/bWpr+ftMMYT73CajTWO+QPVJd5fQMfIA9xY+GncnpV3QweYkw==
X-Received: by 2002:a63:d944:: with SMTP id e4mr42815562pgj.261.1563392614248;
        Wed, 17 Jul 2019 12:43:34 -0700 (PDT)
Received: from [100.112.64.100] ([104.133.8.100])
        by smtp.gmail.com with ESMTPSA id r75sm27194536pfc.18.2019.07.17.12.43.33
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Jul 2019 12:43:33 -0700 (PDT)
Date: Wed, 17 Jul 2019 12:43:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Yang Shi <yang.shi@linux.alibaba.com>
cc: hughd@google.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, 
    vbabka@suse.cz, rientjes@google.com, akpm@linux-foundation.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH 1/2] mm: thp: make transhuge_vma_suitable available
 for anonymous THP
In-Reply-To: <1560401041-32207-2-git-send-email-yang.shi@linux.alibaba.com>
Message-ID: <alpine.LSU.2.11.1907171207080.1177@eggly.anvils>
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com> <1560401041-32207-2-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jun 2019, Yang Shi wrote:

> The transhuge_vma_suitable() was only available for shmem THP, but
> anonymous THP has the same check except pgoff check.  And, it will be
> used for THP eligible check in the later patch, so make it available for
> all kind of THPs.  This also helps reduce code duplication slightly.
> 
> Since anonymous THP doesn't have to check pgoff, so make pgoff check
> shmem vma only.

Yes, I think you are right to avoid the pgoff check on anonymous.
I had originally thought that it would work out okay even with the
pgoff check on anonymous, and usually it would: but could give the
wrong answer on an mremap-moved anonymous area.

> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Almost Acked-by me, but there's one nit I'd much prefer to change:
sorry for being such a late nuisance...

> ---
>  mm/huge_memory.c |  2 +-
>  mm/internal.h    | 25 +++++++++++++++++++++++++
>  mm/memory.c      | 13 -------------
>  3 files changed, 26 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 9f8bce9..4bc2552 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -691,7 +691,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
>  	struct page *page;
>  	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
>  
> -	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
> +	if (!transhuge_vma_suitable(vma, haddr))
>  		return VM_FAULT_FALLBACK;
>  	if (unlikely(anon_vma_prepare(vma)))
>  		return VM_FAULT_OOM;
> diff --git a/mm/internal.h b/mm/internal.h
> index 9eeaf2b..7f096ba 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -555,4 +555,29 @@ static inline bool is_migrate_highatomic_page(struct page *page)
>  
>  void setup_zone_pageset(struct zone *zone);
>  extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
> +static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
> +		unsigned long haddr)
> +{
> +	/* Don't have to check pgoff for anonymous vma */
> +	if (!vma_is_anonymous(vma)) {
> +		if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
> +			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
> +			return false;
> +	}
> +
> +	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
> +		return false;
> +	return true;
> +}
> +#else
> +static inline bool transhuge_vma_suitable(struct vma_area_struct *vma,
> +		unsigned long haddr)
> +{
> +	return false;
> +}
> +#endif
> +
>  #endif	/* __MM_INTERNAL_H */

... maybe I'm just not much of a fan of mm/internal.h (where at last you
find odd bits and pieces which you had expected to find elsewhere), and
maybe others will disagree: but I'd say transhuge_vma_suitable() surely
belongs in include/linux/huge_mm.h, near __transparent_hugepage_enabled().

But then your correct use of vma_is_anonymous() gets more complicated:
because that declaration is over in include/linux/mm.h; and although
linux/mm.h includes linux/huge_mm.h, vma_is_anonymous() comes lower down.

However... linux/mm.h's definition of vma_set_anonymous() comes higher
up, and it would make perfect sense to move vma_is_anonymous up to just
after vma_set_anonymous(), wouldn't it?  Should vma_is_shmem() and
vma_is_stack_for_current() declarations move with it? Probably yes:
they make more sense near vma_is_anonymous() than where they were.

Hugh

> diff --git a/mm/memory.c b/mm/memory.c
> index 96f1d47..2286424 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3205,19 +3205,6 @@ static vm_fault_t pte_alloc_one_map(struct vm_fault *vmf)
>  }
>  
>  #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
> -
> -#define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
> -static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
> -		unsigned long haddr)
> -{
> -	if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
> -			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
> -		return false;
> -	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
> -		return false;
> -	return true;
> -}
> -
>  static void deposit_prealloc_pte(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
> -- 
> 1.8.3.1

