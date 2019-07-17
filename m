Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1511C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 22:14:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88EA1217F4
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 22:14:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="emeuTjc+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88EA1217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D3D56B0005; Wed, 17 Jul 2019 18:14:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 087126B0006; Wed, 17 Jul 2019 18:14:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB5768E0001; Wed, 17 Jul 2019 18:14:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4F2D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 18:14:52 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 65so12745145plf.16
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 15:14:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=bni+Z42fzJug5JhYQ5stiuRJiEWmfpZ/sFa5RIyPdd4=;
        b=PwiNYZAeppcoSUuMNanQgXyQLL3XMdwD6SNxK8BrM1fhWHx0jfLLnoC81SAmFobbEC
         UjdxgUE0dOSjLBVE2+HKByAo34tjgnYZTHF5so16Nas8mfvesIR0iYeAsLKYWuWw7KlW
         PSTzOGDKCrMtWrZCi7HrsHm9crip/+jthRQLI5FWUhjjLhrdgi0Wspzq5vQNnQR8rxR6
         bSNGBvqrHXl6uD92N1R92LvX8uLBVhECAxi7DUQlfCs285z/MN1SF+5oYRZwpji1OqDz
         WdMLG9Niwp5J0e6mlJUm04UooqEphnX3soN7l3gYip7Jb0xZ7GGAlZzj0WaBKksN9F7L
         IyqQ==
X-Gm-Message-State: APjAAAU11zr4HWLE6e9h+wIRT8zW88+dH0Htwop413INaataF1UWA5Wf
	H28bgHiDXcFjo/8K3GQU4Pr2jLYsZBXxCTjJdT0bESmfeVHjPUA4VDmrg7pRI/jcpNhhmdDqZkZ
	OJUJiYLTcaMU+04m4zgYMzvmq30T8eFbr5wT9kH2HAg5f1eijf2cnCEiDwGz+pNWfoA==
X-Received: by 2002:a17:902:28c9:: with SMTP id f67mr6161473plb.19.1563401692256;
        Wed, 17 Jul 2019 15:14:52 -0700 (PDT)
X-Received: by 2002:a17:902:28c9:: with SMTP id f67mr6161411plb.19.1563401691368;
        Wed, 17 Jul 2019 15:14:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563401691; cv=none;
        d=google.com; s=arc-20160816;
        b=fIKEytn4C+mUq5tP5QtyXRJOQO84p0b0ELJq4FiEwjVpjBJLTysoLjPan1pfrrK543
         NH1i+09qYJTqWNCWe2mVO60q2ZcnOdadqsCLNJM8cuC31/xAqvBi/JEKMOoItSvEiInj
         1V/4Bxixmd8lMpgoFA4cOoy+z0bkTGbM3TaGt9GI6/qnqTeb+rPu0EtzY4sBwkanWEpQ
         JKxgPAFFdSAKjKdOjAXpThvzH4BwR+O46GkaGecXkNZziAn5tkAkkghHe0vocBa0mh+d
         5OO+yYSZgMxkTZG1PW4b0cqypRZrLk/n8Ibur0kvGKCMOeIN0B4Sjy2ll8L2BfInO1XQ
         fMTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=bni+Z42fzJug5JhYQ5stiuRJiEWmfpZ/sFa5RIyPdd4=;
        b=CgtWFlKnQaIM7ku3PY6l6eQW3TdvleiTa+igYVAUXD9GVvvcgp7Vm1M97T3Nrqsvvl
         jPti0dQgbsugfdnMOTTnTir2G8+Yb25+gIOXaGU6KyePNeneAWarCh9xaRBdX9rNjzjQ
         mybIoWop7DK/jQZe9zrMpFdUUEDIx8PmmLVNsS26dYADcL4gWAtfI1Ty6DFllkUE7aki
         PvoyQy61TRGRlYtWjlOiemvjY+HsxjIMdFJieyjJ4bGcQxUWyj478bwd3Q3gXnxrvcOv
         ThalB70z6ZGevheZCYIc0ZOX7ozk4kJjASVdmwsdBNhu0vXmirOVLQQ0LwIQtKoUj2Wd
         o+sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=emeuTjc+;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h90sor30660834plb.26.2019.07.17.15.14.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 15:14:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=emeuTjc+;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=bni+Z42fzJug5JhYQ5stiuRJiEWmfpZ/sFa5RIyPdd4=;
        b=emeuTjc+mXVOEbjKQSGjm9CTjjRmVL0k9KVsdgLViBbSz4c0MlMsZPuJoZ9nbSJw5L
         OFXue6RA4LeGHn8VRW3VPXoRi6c+e+3VnffcqtVTDq4CdOv5dyfgJtIwK6KuzBfA9bpO
         BkGdW7ZgeklhFzPd2RYS+RCz9i6Op8NbJhAJxNcBytHVVHBpmP1IuS0XdjNrNjEpiKYs
         0oeCPZMBE9AwPF8P1AhEopgZqEvAdiQoDTKwtlZxWv/xsn/wLlVJY+ENcS1ZNx3J53D1
         T1W0NS4jkJkOdBtTdDzS0fAKkplvc1e79V5oyKTtkgHmPAEWAvnKvt4l6K9xsxcnfkbA
         7YjQ==
X-Google-Smtp-Source: APXvYqxqTE3Ak4PslnTEdETq6mYvLmSYVFMaDKC39P/K6Xxy0gPBa0uji6xX9ZEZ1IcX9kCFU6w1WQ==
X-Received: by 2002:a17:902:e282:: with SMTP id cf2mr46538329plb.301.1563401690083;
        Wed, 17 Jul 2019 15:14:50 -0700 (PDT)
Received: from [100.112.64.100] ([104.133.8.100])
        by smtp.gmail.com with ESMTPSA id f64sm27346303pfa.115.2019.07.17.15.14.48
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Jul 2019 15:14:49 -0700 (PDT)
Date: Wed, 17 Jul 2019 15:14:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Yang Shi <yang.shi@linux.alibaba.com>
cc: hughd@google.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, 
    vbabka@suse.cz, rientjes@google.com, akpm@linux-foundation.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v4 PATCH 1/2] mm: thp: make transhuge_vma_suitable available
 for anonymous THP
In-Reply-To: <1563400758-124759-2-git-send-email-yang.shi@linux.alibaba.com>
Message-ID: <alpine.LSU.2.11.1907171512030.6309@eggly.anvils>
References: <1563400758-124759-1-git-send-email-yang.shi@linux.alibaba.com> <1563400758-124759-2-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jul 2019, Yang Shi wrote:

> The transhuge_vma_suitable() was only available for shmem THP, but
> anonymous THP has the same check except pgoff check.  And, it will be
> used for THP eligible check in the later patch, so make it available for
> all kind of THPs.  This also helps reduce code duplication slightly.
> 
> Since anonymous THP doesn't have to check pgoff, so make pgoff check
> shmem vma only.
> 
> And regroup some functions in include/linux/mm.h to solve compile issue since
> transhuge_vma_suitable() needs call vma_is_anonymous() which was defined
> after huge_mm.h is included.
> 
> Cc: Hugh Dickins <hughd@google.com>

Thanks!
Acked-by: Hugh Dickins <hughd@google.com>

> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  include/linux/huge_mm.h | 23 +++++++++++++++++++++++
>  include/linux/mm.h      | 34 +++++++++++++++++-----------------
>  mm/huge_memory.c        |  2 +-
>  mm/memory.c             | 13 -------------
>  4 files changed, 41 insertions(+), 31 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 7cd5c15..45ede62 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -121,6 +121,23 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
>  
>  bool transparent_hugepage_enabled(struct vm_area_struct *vma);
>  
> +#define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
> +
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
> +
>  #define transparent_hugepage_use_zero_page()				\
>  	(transparent_hugepage_flags &					\
>  	 (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG))
> @@ -271,6 +288,12 @@ static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>  	return false;
>  }
>  
> +static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
> +		unsigned long haddr)
> +{
> +	return false;
> +}
> +
>  static inline void prep_transhuge_page(struct page *page) {}
>  
>  #define transparent_hugepage_flags 0UL
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0389c34..beae0ae 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -541,6 +541,23 @@ static inline void vma_set_anonymous(struct vm_area_struct *vma)
>  	vma->vm_ops = NULL;
>  }
>  
> +static inline bool vma_is_anonymous(struct vm_area_struct *vma)
> +{
> +	return !vma->vm_ops;
> +}
> +
> +#ifdef CONFIG_SHMEM
> +/*
> + * The vma_is_shmem is not inline because it is used only by slow
> + * paths in userfault.
> + */
> +bool vma_is_shmem(struct vm_area_struct *vma);
> +#else
> +static inline bool vma_is_shmem(struct vm_area_struct *vma) { return false; }
> +#endif
> +
> +int vma_is_stack_for_current(struct vm_area_struct *vma);
> +
>  /* flush_tlb_range() takes a vma, not a mm, and can care about flags */
>  #define TLB_FLUSH_VMA(mm,flags) { .vm_mm = (mm), .vm_flags = (flags) }
>  
> @@ -1629,23 +1646,6 @@ static inline void cancel_dirty_page(struct page *page)
>  
>  int get_cmdline(struct task_struct *task, char *buffer, int buflen);
>  
> -static inline bool vma_is_anonymous(struct vm_area_struct *vma)
> -{
> -	return !vma->vm_ops;
> -}
> -
> -#ifdef CONFIG_SHMEM
> -/*
> - * The vma_is_shmem is not inline because it is used only by slow
> - * paths in userfault.
> - */
> -bool vma_is_shmem(struct vm_area_struct *vma);
> -#else
> -static inline bool vma_is_shmem(struct vm_area_struct *vma) { return false; }
> -#endif
> -
> -int vma_is_stack_for_current(struct vm_area_struct *vma);
> -
>  extern unsigned long move_page_tables(struct vm_area_struct *vma,
>  		unsigned long old_addr, struct vm_area_struct *new_vma,
>  		unsigned long new_addr, unsigned long len,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 885642c..782dd14 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -689,7 +689,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
>  	struct page *page;
>  	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
>  
> -	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
> +	if (!transhuge_vma_suitable(vma, haddr))
>  		return VM_FAULT_FALLBACK;
>  	if (unlikely(anon_vma_prepare(vma)))
>  		return VM_FAULT_OOM;
> diff --git a/mm/memory.c b/mm/memory.c
> index 89325f9..e2bb51b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3162,19 +3162,6 @@ static vm_fault_t pte_alloc_one_map(struct vm_fault *vmf)
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
> 
> 

