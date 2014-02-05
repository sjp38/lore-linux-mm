Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2536B0031
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 03:42:38 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id e4so308899wiv.4
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 00:42:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hd6si6701431wib.30.2014.02.05.00.42.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 00:42:36 -0800 (PST)
Date: Wed, 5 Feb 2014 09:42:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] mm, page_alloc: make first_page visible before
 PageTail
Message-ID: <20140205084235.GA30705@dhcp22.suse.cz>
References: <20140203122052.GC2495@dhcp22.suse.cz>
 <alpine.LRH.2.02.1402031426510.13382@diagnostix.dwd.de>
 <20140203162036.GJ2495@dhcp22.suse.cz>
 <52EFC93D.3030106@suse.cz>
 <alpine.DEB.2.02.1402031602060.10778@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1402040713220.13901@diagnostix.dwd.de>
 <alpine.DEB.2.02.1402041557380.10140@chino.kir.corp.google.com>
 <20140204160641.8f5d369eeb2d0318618d6d5f@linux-foundation.org>
 <alpine.DEB.2.02.1402041613450.14962@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1402041621350.14962@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402041621350.14962@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Holger Kiehl <Holger.Kiehl@dwd.de>, Christoph Lameter <cl@linux.com>, Rafael Aquini <aquini@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 04-02-14 16:22:53, David Rientjes wrote:
> Commit bf6bddf1924e ("mm: introduce compaction and migration for ballooned
> pages") introduces page_count(page) into memory compaction which
> dereferences page->first_page if PageTail(page).
> 
> Introduce a store memory barrier to ensure page->first_page is properly
> initialized so that code that does page_count(page) on pages off the lru
> always have a valid p->first_page.
> 
> Reported-by: Holger Kiehl <Holger.Kiehl@dwd.de>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v2: with commentary, per checkpatch
> 
>  mm/page_alloc.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -369,9 +369,11 @@ void prep_compound_page(struct page *page, unsigned long order)
>  	__SetPageHead(page);
>  	for (i = 1; i < nr_pages; i++) {
>  		struct page *p = page + i;
> -		__SetPageTail(p);
>  		set_page_count(p, 0);
>  		p->first_page = page;
> +		/* Make sure p->first_page is always valid for PageTail() */
> +		smp_wmb();
> +		__SetPageTail(p);

Where is the pairing smp_rmb? I would expect it in comound_head.

>  	}
>  }
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
