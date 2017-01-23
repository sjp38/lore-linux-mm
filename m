Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6937E6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 06:18:03 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c206so17581633wme.3
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 03:18:03 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id k188si13922918wma.76.2017.01.23.03.18.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 03:18:02 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 6147CF4023
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 11:18:01 +0000 (UTC)
Date: Mon, 23 Jan 2017 11:17:59 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 4/4] mm, page_alloc: Only use per-cpu allocator for
 irq-safe requests
Message-ID: <20170123111759.fjpox4d22rsknb4a@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-5-mgorman@techsingularity.net>
 <675145cb-e026-7ceb-ce96-446d3dd61fe0@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <675145cb-e026-7ceb-ce96-446d3dd61fe0@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, Jan 20, 2017 at 04:02:56PM +0100, Vlastimil Babka wrote:
> On 01/17/2017 10:29 AM, Mel Gorman wrote:
> 
> [...]
> 
> > @@ -1244,10 +1243,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
> >  		return;
> >  
> >  	migratetype = get_pfnblock_migratetype(page, pfn);
> > -	local_irq_save(flags);
> > -	__count_vm_events(PGFREE, 1 << order);
> > +	count_vm_events(PGFREE, 1 << order);
> 
> Maybe this could be avoided by moving the counting into free_one_page()?
> Diff suggestion at the end of e-mail.
> 

Yes, that would work.

> > @@ -2472,16 +2470,20 @@ void free_hot_cold_page(struct page *page, bool cold)
> >  {
> >  	struct zone *zone = page_zone(page);
> >  	struct per_cpu_pages *pcp;
> > -	unsigned long flags;
> >  	unsigned long pfn = page_to_pfn(page);
> >  	int migratetype;
> >  
> >  	if (!free_pcp_prepare(page))
> >  		return;
> >  
> > +	if (in_interrupt()) {
> > +		__free_pages_ok(page, 0);
> > +		return;
> > +	}
> 
> I think this should go *before* free_pcp_prepare() otherwise
> free_pages_prepare() gets done twice in interrupt.
> 

You're right, thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
