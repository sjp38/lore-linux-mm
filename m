Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6144E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:25:26 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r16so10505186pgr.15
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 04:25:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r39si11070323pld.434.2018.12.17.04.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 04:25:25 -0800 (PST)
Date: Mon, 17 Dec 2018 13:25:23 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181217122523.GI30879@dhcp22.suse.cz>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214023912.77474-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Fri 14-12-18 10:39:12, Wei Yang wrote:
> Below is a brief call flow for __offline_pages() and
> alloc_contig_range():
> 
>   __offline_pages()/alloc_contig_range()
>       start_isolate_page_range()
>           set_migratetype_isolate()
>               drain_all_pages()
>       drain_all_pages()
> 
> Since set_migratetype_isolate() is only used in
> start_isolate_page_range(), which is just used in __offline_pages() and
> alloc_contig_range(). And both of them call drain_all_pages() if every
> check looks good. This means it is not necessary call drain_all_pages()
> in each iteration of set_migratetype_isolate().
> 
> By doing so, the logic seems a little bit clearer.
> set_migratetype_isolate() handles pages in Buddy, while
> drain_all_pages() takes care of pages in pcp.

I have to confess I am not sure about the purpose of the draining here.
I suspect it is to make sure that pages in the pcp lists really get
isolated and if that is the case then it makes sense.

In any case I strongly suggest not touching this code without a very
good explanation on why this is not needed. Callers do XYZ is not a
proper explanation because assumes that all callers will know that this
has to be done. So either we really need to drain and then it is better
to make it here or we don't but that requires some explanation.

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/page_isolation.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 43e085608846..f44c0e333bed 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -83,8 +83,6 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
>  	}
>  
>  	spin_unlock_irqrestore(&zone->lock, flags);
> -	if (!ret)
> -		drain_all_pages(zone);
>  	return ret;
>  }
>  
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
