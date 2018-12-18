Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE518E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 16:14:29 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id c71so17347176qke.18
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 13:14:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a15si707236qvm.111.2018.12.18.13.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 13:14:28 -0800 (PST)
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <58509504-4c30-3385-6eda-72c2abad60e7@redhat.com>
Date: Tue, 18 Dec 2018 22:14:25 +0100
MIME-Version: 1.0
In-Reply-To: <20181218204656.4297-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de

On 18.12.18 21:46, Wei Yang wrote:
> Below is a brief call flow for __offline_pages() and
> alloc_contig_range():
> 
>   __offline_pages()/alloc_contig_range()
>       start_isolate_page_range()
>           set_migratetype_isolate()
>               drain_all_pages()
>       drain_all_pages()
> 
> Current logic is: isolate and drain pcp list for each pageblock and
> drain pcp list again. This is not necessary and we could just drain pcp
> list once after isolate this whole range.
> 
> The reason is start_isolate_page_range() will set the migrate type of
> a range to MIGRATE_ISOLATE. After doing so, this range will never be
> allocated from Buddy, neither to a real user nor to pcp list.
> 
> Since drain_all_pages() is zone based, by reduce times of
> drain_all_pages() also reduce some contention on this particular zone.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Yes, as far as I can see, when a MIGRATE_ISOLATE page gets freed, it
will not go onto the pcp list again.

However, start_isolate_page_range() is also called via
alloc_contig_range(). Are you sure we can effectively drop the
drain_all_pages() for that call path?

> 
> ---
> v2: adjust changelog with MIGRATE_ISOLATE effects for the isolated range
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
> 


-- 

Thanks,

David / dhildenb
