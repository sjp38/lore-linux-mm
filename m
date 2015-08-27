Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 43EB36B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:54:23 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so25048105pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:54:23 -0700 (PDT)
Received: from m12-16.163.com (m12-16.163.com. [220.181.12.16])
        by mx.google.com with ESMTP id my7si3572903pbc.24.2015.08.27.05.52.03
        for <linux-mm@kvack.org>;
        Thu, 27 Aug 2015 05:54:22 -0700 (PDT)
Date: Thu, 27 Aug 2015 20:50:31 +0800
From: Yaowei Bai <bywxiaobai@163.com>
Subject: Re: [PATCH v2] mm/page_alloc: add a helper function to check page
 before alloc/free
Message-ID: <20150827125031.GA3481@bbox>
References: <1440509190-3622-1-git-send-email-bywxiaobai@163.com>
 <20150825140322.GC6285@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150825140322.GC6285@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 25, 2015 at 04:03:22PM +0200, Michal Hocko wrote:
> On Tue 25-08-15 21:26:30, Yaowei Bai wrote:
> [...]
> >  static inline int check_new_page(struct page *page)
> >  {
> > -	const char *bad_reason = NULL;
> > -	unsigned long bad_flags = 0;
> > -
> > -	if (unlikely(page_mapcount(page)))
> > -		bad_reason = "nonzero mapcount";
> > -	if (unlikely(page->mapping != NULL))
> > -		bad_reason = "non-NULL mapping";
> > -	if (unlikely(atomic_read(&page->_count) != 0))
> > -		bad_reason = "nonzero _count";
> > -	if (unlikely(page->flags & __PG_HWPOISON)) {
> > -		bad_reason = "HWPoisoned (hardware-corrupted)";
> > -		bad_flags = __PG_HWPOISON;
> > -	}
> 
> You have removed this check AFAICS. Now looking at 39ad4f19671d ("mm:
> check __PG_HWPOISON separately from PAGE_FLAGS_CHECK_AT_*") I am not
> sure it is correct to check it in the free path as it was removed from
> the mask by this commit.

I just refactored these two function and it looks well, will resend it soon.

> 
> > -	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_PREP)) {
> > -		bad_reason = "PAGE_FLAGS_CHECK_AT_PREP flag set";
> > -		bad_flags = PAGE_FLAGS_CHECK_AT_PREP;
> > -	}
> > -#ifdef CONFIG_MEMCG
> > -	if (unlikely(page->mem_cgroup))
> > -		bad_reason = "page still charged to cgroup";
> > -#endif
> > -	if (unlikely(bad_reason)) {
> > -		bad_page(page, bad_reason, bad_flags);
> > -		return 1;
> > -	}
> > -	return 0;
> > +	return check_one_page(page, PAGE_FLAGS_CHECK_AT_PREP);
> >  }
> >  
> >  static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
> > -- 
> > 1.9.1
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
