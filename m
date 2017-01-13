Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85C0D6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 05:18:08 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so14147556wmi.6
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:18:08 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id i10si10683840wrb.10.2017.01.13.02.18.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 02:18:07 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id D6F67993F8
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 10:18:06 +0000 (UTC)
Date: Fri, 13 Jan 2017 10:18:06 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/3] mm, page_allocator: Only use per-cpu allocator for
 irq-safe requests
Message-ID: <20170113101806.a4pm4ltxrgntp6sn@techsingularity.net>
References: <20170112104300.24345-1-mgorman@techsingularity.net>
 <20170112104300.24345-4-mgorman@techsingularity.net>
 <a99e507e-ae3c-ef45-5790-fb286bdc279d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a99e507e-ae3c-ef45-5790-fb286bdc279d@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Thu, Jan 12, 2017 at 06:02:38PM +0100, Vlastimil Babka wrote:
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> > Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> Very promising! But I have some worries. Should we put something like
> VM_BUG_ON(in_interrupt()) into free_hot_cold_page() and rmqueue_pcplist() to
> catch future potential misuses and also document this requirement? Also
> free_hot_cold_page() has other call sites besides __free_pages() and I'm not
> sure if those are all guaranteed to be !IRQ? E.g. free_hot_cold_page_list()
> which is called by release_page() which uses irq-safe lock operations...
> 

They are not guaranteed to be !irq but the API is easier to call incorrectly
than it could be. I think the checks can be pushed further down without
excessive overhead.

> Smaller nit below:
> 
> > @@ -2453,8 +2450,8 @@ void free_hot_cold_page(struct page *page, bool cold)
> > 
> >  	migratetype = get_pfnblock_migratetype(page, pfn);
> >  	set_pcppage_migratetype(page, migratetype);
> > -	local_irq_save(flags);
> > -	__count_vm_event(PGFREE);
> > +	preempt_disable();
> > +	count_vm_event(PGFREE);
> 
> AFAICS preempt_disable() is enough for using __count_vm_event(), no?
> 

It is, I'll fix it.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
