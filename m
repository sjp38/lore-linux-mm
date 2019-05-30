Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F44FC28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EE102632B
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EE102632B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B17806B027F; Thu, 30 May 2019 19:52:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC7D46B0280; Thu, 30 May 2019 19:52:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B7BD6B0281; Thu, 30 May 2019 19:52:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65AD96B027F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:52:07 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so4952521pld.15
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=w7/nh7jNGcnAjGcgOVCiCiVcfRWT6qSK62EO0/8r5q8=;
        b=OxMSDyLtPH/VOQJ6vylScAXBUUMwfX33nMH12v1fQGh4/IbIQjwT3K/L+SQMC9vj+w
         MXqZ0HX8vySR3oRXvqSmP694ybfmIx/GOdFC6zrgRVJjgJzja1nDjr5+n1cJFGQJwWpf
         X+ZJ450ix6iN+8sPgmQ4TtQxPqNBoDzsFBih5pmh4vlf1loALb+C3EZ5bSM0BbYY+P9u
         w5BS24P2rBW7/7acId5bwFtsCO2yHm9xF++DV4yyrVNU6OQ8+o6B5AQ27OtxJSdx4lWt
         HiiISfGu8ArCuaQRzVeIECxHL/T81RuS8zFgjGcvgjkRDMsc1vVhHjTmecs0OOFW+pwo
         On6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWGDkaK8Rk3772tbcu2EzcVd4Z8sS/hNgYWwpFHfMGPqkIDNM32
	Ea1yBcSYrr5+VgBrF7Tyj/41Q6q4xAKKBSG+qGsJXZhCkGq1f79gDEpDOpbBx8KWLXoUvyEMszr
	s2rvFI9cySNOfqBdDEcbxnWlcY+xcLGxgu/aMha3aD9ku07vWEpM995xVn3xJIO3n0w==
X-Received: by 2002:a63:eb01:: with SMTP id t1mr6025542pgh.385.1559260326994;
        Thu, 30 May 2019 16:52:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFuDwKBZ6HQEruVjLoHJJuHrT/PScd8BjoQtnXgBA4MRLo8dL5ciPXDYC2yy4FXfCz7afs
X-Received: by 2002:a63:eb01:: with SMTP id t1mr6025482pgh.385.1559260326207;
        Thu, 30 May 2019 16:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559260326; cv=none;
        d=google.com; s=arc-20160816;
        b=kd6hnZ+WNecBCfmx3DdUBPWimAjGUD6MW/z18QVOc84HQPPQrzh95WyXzOljAPnb+E
         wYci2IV/hPItYPeOx5SUM6jlgyDIHSwgSTzqS+R1/INX9inpJh4FJGDLXloqpiJfcAmX
         ZlysBwXfUagn5i2O8zZYhkQ3vmlk2CKaGMCkD8KrAJc9OjHcKklXl9UKki4P2Wwj4RfT
         XMYfWz/GX/M61Yv9MU7F2jcnx74ny/p+btCWUXeKOA3joCfrvVjvnncx0yduge5v0THP
         ARHT/Gj5reB79GrSmNAfBOY7gnsTFqQlc3RAEPxm2W2jrcM65Ce+L8mHE7ZUxU+aUIEa
         dj2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=w7/nh7jNGcnAjGcgOVCiCiVcfRWT6qSK62EO0/8r5q8=;
        b=iE497nd+lhe7UGPTfD5BD67x7eSmSFkEMAAowjirXXyxeH7OMsUfor3lu8/oAf5Wx9
         cg2fo4s6fuS6+/oD3LUzKvjZawayD2koVLAQjWi2/uj6bKUBtKJwhYsNyXUZ9ai993hv
         xm+mc6tz/prQUI4og1sKeHES2ojS2IH+tiAprB/1YlZbHtQXjvvuiUeT67EoG3o0Bv2H
         5cffACVAr+LwOIpBWj2+tmsl+JL4h0F+TOKdbneTGHOiGWPzUqjW5WUbxhoFJX8M+v01
         Vh+Xj1R2MTsmS7PvbCYIpkeikUDG87P3aa0iBcy7LrP1+17gMpsAMt9R0UDU2Xg8avNe
         GwBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f92si4334284plb.77.2019.05.30.16.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:52:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 16:52:05 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 30 May 2019 16:52:04 -0700
Date: Thu, 30 May 2019 16:53:08 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190530235307.GA28605@iweiny-DESK2.sc.intel.com>
References: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
 <20190530214726.GA14000@iweiny-DESK2.sc.intel.com>
 <1497636a-8658-d3ff-f7cd-05230fdead19@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497636a-8658-d3ff-f7cd-05230fdead19@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 04:21:19PM -0700, John Hubbard wrote:
> On 5/30/19 2:47 PM, Ira Weiny wrote:
> > On Thu, May 30, 2019 at 06:54:04AM +0800, Pingfan Liu wrote:
> [...]
> >> +				for (j = i; j < nr; j++)
> >> +					put_page(pages[j]);
> > 
> > Should be put_user_page() now.  For now that just calls put_page() but it is
> > slated to change soon.
> > 
> > I also wonder if this would be more efficient as a check as we are walking the
> > page tables and bail early.
> > 
> > Perhaps the code complexity is not worth it?
> 
> Good point, it might be worth it. Because now we've got two loops that
> we run, after the interrupts-off page walk, and it's starting to look like
> a potential performance concern. 

FWIW I don't see this being a huge issue at the moment.  Perhaps those more
familiar with CMA can weigh in here.  How was this issue found?  If it was
found by running some test perhaps that indicates a performance preference?

> 
> > 
> >> +				nr = i;
> > 
> > Why not just break from the loop here?
> > 
> > Or better yet just use 'i' in the inner loop...
> > 
> 
> ...but if you do end up putting in the after-the-fact check, then we can
> go one or two steps further in cleaning it up, by:
> 
>     * hiding the visible #ifdef that was slicing up gup_fast,
> 
>     * using put_user_pages() instead of either put_page or put_user_page,
>       thus getting rid of j entirely, and
> 
>     * renaming an ancient minor confusion: nr --> nr_pinned), 
> 
> we could have this, which is looks cleaner and still does the same thing:
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index f173fcbaf1b2..0c1f36be1863 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1486,6 +1486,33 @@ static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
>  }
>  #endif /* CONFIG_FS_DAX || CONFIG_CMA */
>  
> +#ifdef CONFIG_CMA
> +/*
> + * Returns the number of pages that were *not* rejected. This makes it
> + * exactly compatible with its callers.
> + */
> +static int reject_cma_pages(int nr_pinned, unsigned gup_flags,
> +			    struct page **pages)
> +{
> +	int i = 0;
> +	if (unlikely(gup_flags & FOLL_LONGTERM)) {
> +
> +		for (i = 0; i < nr_pinned; i++)
> +			if (is_migrate_cma_page(pages[i])) {
> +				put_user_pages(&pages[i], nr_pinned - i);

Yes this is cleaner.

> +				break;
> +			}
> +	}
> +	return i;
> +}
> +#else
> +static int reject_cma_pages(int nr_pinned, unsigned gup_flags,
> +			    struct page **pages)
> +{
> +	return nr_pinned;
> +}
> +#endif
> +
>  /*
>   * This is the same as get_user_pages_remote(), just with a
>   * less-flexible calling convention where we assume that the task
> @@ -2216,7 +2243,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  			unsigned int gup_flags, struct page **pages)
>  {
>  	unsigned long addr, len, end;
> -	int nr = 0, ret = 0;
> +	int nr_pinned = 0, ret = 0;

To be absolutely pedantic I would have split the nr_pinned change to a separate
patch.

Ira

>  
>  	start &= PAGE_MASK;
>  	addr = start;
> @@ -2231,25 +2258,27 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  
>  	if (gup_fast_permitted(start, nr_pages)) {
>  		local_irq_disable();
> -		gup_pgd_range(addr, end, gup_flags, pages, &nr);
> +		gup_pgd_range(addr, end, gup_flags, pages, &nr_pinned);
>  		local_irq_enable();
> -		ret = nr;
> +		ret = nr_pinned;
>  	}
>  
> -	if (nr < nr_pages) {
> +	nr_pinned = reject_cma_pages(nr_pinned, gup_flags, pages);
> +
> +	if (nr_pinned < nr_pages) {
>  		/* Try to get the remaining pages with get_user_pages */
> -		start += nr << PAGE_SHIFT;
> -		pages += nr;
> +		start += nr_pinned << PAGE_SHIFT;
> +		pages += nr_pinned;
>  
> -		ret = __gup_longterm_unlocked(start, nr_pages - nr,
> +		ret = __gup_longterm_unlocked(start, nr_pages - nr_pinned,
>  					      gup_flags, pages);
>  
>  		/* Have to be a bit careful with return values */
> -		if (nr > 0) {
> +		if (nr_pinned > 0) {
>  			if (ret < 0)
> -				ret = nr;
> +				ret = nr_pinned;
>  			else
> -				ret += nr;
> +				ret += nr_pinned;
>  		}
>  	}
>  
> 
> Rather lightly tested...I've compile-tested with CONFIG_CMA and !CONFIG_CMA, 
> and boot tested with CONFIG_CMA, but could use a second set of eyes on whether
> I've added any off-by-one errors, or worse. :)
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

