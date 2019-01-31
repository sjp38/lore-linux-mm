Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDA49C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:09:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E3C620B1F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:09:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E3C620B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2425F8E0002; Thu, 31 Jan 2019 05:09:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C6A58E0001; Thu, 31 Jan 2019 05:09:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08E1A8E0002; Thu, 31 Jan 2019 05:09:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9E7F8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:09:12 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id x26so1829829pgc.5
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:09:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OUEk/+aMbMeJPfGOUuxjCemjdxe2PAnTslWJE9F17e4=;
        b=eor2pu/prPNekhpLTvI297xwgQ+NlLuBRC5aiPRDX2CruvMO3N+5t2NY1u7WP5yAk2
         yNh6WqpqQg2d4zOZWGuQtwpIWh/qlXKOhW3SaQ34oXuEG3qQtwOZUtlaXDdfN3XPIboj
         ekYV9jkuyqR+8GrjWmmPjOnyf9DJmNyMu5j+ipapU+i+b3lLgO+TZ4StLZ7xn4FP495k
         eaKGavwvTy9YE82WqVeu8v9L9JB10AsZtgLrTZGlJvop/z61AsyvcrE5O7w85bs8MfoO
         W/vf7G8BgYzpjFcA9qD5jPDwgQZvM4zMM/yu47nxVKLdasHu/9TmJMCVFl2Ej9uifVji
         p5NQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdAE4Lrc5mBd4cqCweI4l8d1yjxka6h435YxaYThzV1TNAxRbXD
	oRrLe5LLVxxtbz591S87To9Pr0gWXG2Z4LCY6v1fZv9Eh5TB/jZjv/LAY7E87OTdx6YIEtMQl+1
	vHu1s3igDXoXRrycddLxLOElZBYaxSKvRbToTwErYvgxVwqieYw66bqIlGEId+a4=
X-Received: by 2002:a62:6143:: with SMTP id v64mr34170571pfb.142.1548929352407;
        Thu, 31 Jan 2019 02:09:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5no00zpCGD921qclHhPX1FtNxRYbBD+9uNKZk45Mjp4k3HDtqQpowDx1CHDT4gkDKsmPGt
X-Received: by 2002:a62:6143:: with SMTP id v64mr34170519pfb.142.1548929351620;
        Thu, 31 Jan 2019 02:09:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548929351; cv=none;
        d=google.com; s=arc-20160816;
        b=wUVqNgti/Xsd+p67Gg1qWcrKYOC/p2iF5bW7MrHI8udnLB2/2H4eKOpGgJpqjziOg4
         CSEc/CrFCAVmae1MZoWUnhHI8APoXR2sx4vyaDdXSMQtBeuVy4uGjVoOvJDzIkPMFX+Q
         cdBUoL+0sAlvPen7DINjiApTi+68Rbz34KK9BAEwK9ke3OZM36egSCZrQ4EjsbeozK3l
         6TsS3clkWqxpGwEt8MhcvkEcIkwajixroRZSqoETB+12geX9Sha3lTeQM5A1s3eINz+n
         fXx1PEFtM3z1h0m6KW/SprHgEgQfPsrIAW4MSinnJymXMm+j5/cjpbTRSuO+TCNjw+La
         WymQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OUEk/+aMbMeJPfGOUuxjCemjdxe2PAnTslWJE9F17e4=;
        b=IK+J4nif6R7gPpi5dV/UlOCkgdUVAiROWnBFoZE5Uyi0MoQlckJZfdqbKB/lIgv+n8
         QFO8X4d4ZU2Q56Hsgu++kgssx7YO+FVGHH2LQnRFaf38UIQ3Vg9dwXJK08B1WsHBOvA/
         qJVJzRH9ypr0V93zDqXg4ab3X97y0hTZZYWuT7MnvH+Pruzu37n6JaHxqTOop9jKGdR+
         Keuq0PtYRkhZm4yrpxtwHuaJwIQrs6iBRiWMDO2STi/rNkKe5fSGjyTMuAaQZOXQzUHm
         EU8c9A4/ChoKHTSUo+MIXUHcAiAlV5cMBzaUXBoq1mmCaf7XKjyM0tGVxsUBq7MBEOjs
         BZcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3si265355pld.331.2019.01.31.02.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 02:09:11 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C5CDDADE1;
	Thu, 31 Jan 2019 10:09:09 +0000 (UTC)
Date: Thu, 31 Jan 2019 11:09:07 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Jiri Kosina <jikos@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>, Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH 3/3] mm/mincore: provide mapped status when cached status
 is not allowed
Message-ID: <20190131100907.GS18811@dhcp22.suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130124420.1834-4-vbabka@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 30-01-19 13:44:20, Vlastimil Babka wrote:
> After "mm/mincore: make mincore() more conservative" we sometimes restrict the
> information about page cache residency, which we have to do without breaking
> existing userspace, if possible. We thus fake the resulting values as 1, which
> should be safer than faking them as 0, as there might theoretically exist code
> that would try to fault in the page(s) until mincore() returns 1.
> 
> Faking 1 however means that such code would not fault in a page even if it was
> not in page cache, with unwanted performance implications. We can improve the
> situation by revisting the approach of 574823bfab82 ("Change mincore() to count
> "mapped" pages rather than "cached" pages") but only applying it to cases where
> page cache residency check is restricted. Thus mincore() will return 0 for an
> unmapped page (which may or may not be resident in a pagecache), and 1 after
> the process faults it in.
> 
> One potential downside is that mincore() will be again able to recognize when a
> previously mapped page was reclaimed. While that might be useful for some
> attack scenarios, it's not as crucial as recognizing that somebody else faulted
> the page in, and there are also other ways to recognize reclaimed pages anyway.

Is this really worth it? Do we know about any specific usecase that
would benefit from this change? TBH I would rather wait for the report
than add a hard to evaluate side channel.

> Cc: Jiri Kosina <jikos@kernel.org>
> Cc: Dominique Martinet <asmadeus@codewreck.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Kevin Easton <kevin@guarana.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Cyril Hrubis <chrubis@suse.cz>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Daniel Gruss <daniel@gruss.cc>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/mincore.c | 49 +++++++++++++++++++++++++++++++++----------------
>  1 file changed, 33 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/mincore.c b/mm/mincore.c
> index 747a4907a3ac..d6784a803ae7 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -21,12 +21,18 @@
>  #include <linux/uaccess.h>
>  #include <asm/pgtable.h>
>  
> +struct mincore_walk_private {
> +	unsigned char *vec;
> +	bool can_check_pagecache;
> +};
> +
>  static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
>  			unsigned long end, struct mm_walk *walk)
>  {
>  #ifdef CONFIG_HUGETLB_PAGE
>  	unsigned char present;
> -	unsigned char *vec = walk->private;
> +	struct mincore_walk_private *walk_private = walk->private;
> +	unsigned char *vec = walk_private->vec;
>  
>  	/*
>  	 * Hugepages under user process are always in RAM and never
> @@ -35,7 +41,7 @@ static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
>  	present = pte && !huge_pte_none(huge_ptep_get(pte));
>  	for (; addr != end; vec++, addr += PAGE_SIZE)
>  		*vec = present;
> -	walk->private = vec;
> +	walk_private->vec = vec;
>  #else
>  	BUG();
>  #endif
> @@ -85,7 +91,8 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
>  }
>  
>  static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
> -				struct vm_area_struct *vma, unsigned char *vec)
> +				struct vm_area_struct *vma, unsigned char *vec,
> +				bool can_check_pagecache)
>  {
>  	unsigned long nr = (end - addr) >> PAGE_SHIFT;
>  	int i;
> @@ -95,7 +102,9 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
>  
>  		pgoff = linear_page_index(vma, addr);
>  		for (i = 0; i < nr; i++, pgoff++)
> -			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
> +			vec[i] = can_check_pagecache ?
> +				 mincore_page(vma->vm_file->f_mapping, pgoff)
> +				 : 0;
>  	} else {
>  		for (i = 0; i < nr; i++)
>  			vec[i] = 0;
> @@ -106,8 +115,11 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
>  static int mincore_unmapped_range(unsigned long addr, unsigned long end,
>  				   struct mm_walk *walk)
>  {
> -	walk->private += __mincore_unmapped_range(addr, end,
> -						  walk->vma, walk->private);
> +	struct mincore_walk_private *walk_private = walk->private;
> +	unsigned char *vec = walk_private->vec;
> +
> +	walk_private->vec += __mincore_unmapped_range(addr, end, walk->vma,
> +				vec, walk_private->can_check_pagecache);
>  	return 0;
>  }
>  
> @@ -117,7 +129,8 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	spinlock_t *ptl;
>  	struct vm_area_struct *vma = walk->vma;
>  	pte_t *ptep;
> -	unsigned char *vec = walk->private;
> +	struct mincore_walk_private *walk_private = walk->private;
> +	unsigned char *vec = walk_private->vec;
>  	int nr = (end - addr) >> PAGE_SHIFT;
>  
>  	ptl = pmd_trans_huge_lock(pmd, vma);
> @@ -128,7 +141,8 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	}
>  
>  	if (pmd_trans_unstable(pmd)) {
> -		__mincore_unmapped_range(addr, end, vma, vec);
> +		__mincore_unmapped_range(addr, end, vma, vec,
> +					walk_private->can_check_pagecache);
>  		goto out;
>  	}
>  
> @@ -138,7 +152,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  
>  		if (pte_none(pte))
>  			__mincore_unmapped_range(addr, addr + PAGE_SIZE,
> -						 vma, vec);
> +				 vma, vec, walk_private->can_check_pagecache);
>  		else if (pte_present(pte))
>  			*vec = 1;
>  		else { /* pte is a swap entry */
> @@ -152,8 +166,12 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  				*vec = 1;
>  			} else {
>  #ifdef CONFIG_SWAP
> -				*vec = mincore_page(swap_address_space(entry),
> +				if (walk_private->can_check_pagecache)
> +					*vec = mincore_page(
> +						    swap_address_space(entry),
>  						    swp_offset(entry));
> +				else
> +					*vec = 0;
>  #else
>  				WARN_ON(1);
>  				*vec = 1;
> @@ -187,22 +205,21 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
>  	struct vm_area_struct *vma;
>  	unsigned long end;
>  	int err;
> +	struct mincore_walk_private walk_private = {
> +		.vec = vec
> +	};
>  	struct mm_walk mincore_walk = {
>  		.pmd_entry = mincore_pte_range,
>  		.pte_hole = mincore_unmapped_range,
>  		.hugetlb_entry = mincore_hugetlb,
> -		.private = vec,
> +		.private = &walk_private
>  	};
>  
>  	vma = find_vma(current->mm, addr);
>  	if (!vma || addr < vma->vm_start)
>  		return -ENOMEM;
>  	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
> -	if (!can_do_mincore(vma)) {
> -		unsigned long pages = (end - addr) >> PAGE_SHIFT;
> -		memset(vec, 1, pages);
> -		return pages;
> -	}
> +	walk_private.can_check_pagecache = can_do_mincore(vma);
>  	mincore_walk.mm = vma->vm_mm;
>  	err = walk_page_range(addr, end, &mincore_walk);
>  	if (err < 0)
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

