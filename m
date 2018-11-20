Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23A196B1FCC
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:18:46 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 42so84858qtr.7
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:18:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a13si271447qtp.35.2018.11.20.06.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:18:45 -0800 (PST)
Subject: Re: [RFC PATCH 1/3] mm, memory_hotplug: try to migrate full section
 worth of pages
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-2-mhocko@kernel.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <65271adc-93b4-19fc-e54b-11db582359c5@redhat.com>
Date: Tue, 20 Nov 2018 15:18:41 +0100
MIME-Version: 1.0
In-Reply-To: <20181120134323.13007-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 20.11.18 14:43, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> do_migrate_range has been limiting the number of pages to migrate to 256
> for some reason which is not documented. Even if the limit made some
> sense back then when it was introduced it doesn't really serve a good
> purpose these days. If the range contains huge pages then
> we break out of the loop too early and go through LRU and pcp
> caches draining and scan_movable_pages is quite suboptimal.
> 
> The only reason to limit the number of pages I can think of is to reduce
> the potential time to react on the fatal signal. But even then the
> number of pages is a questionable metric because even a single page
> might migration block in a non-killable state (e.g. __unmap_and_move).
> 
> Remove the limit and offline the full requested range (this is one
> membblock worth of pages with the current code). Should we ever get a
> report that offlining takes too long to react on fatal signal then we
> should rather fix the core migration to use killable waits and bailout
> on a signal.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c82193db4be6..6263c8cd4491 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1339,18 +1339,16 @@ static struct page *new_node_page(struct page *page, unsigned long private)
>  	return new_page_nodemask(page, nid, &nmask);
>  }
>  
> -#define NR_OFFLINE_AT_ONCE_PAGES	(256)
>  static int
>  do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  {
>  	unsigned long pfn;
>  	struct page *page;
> -	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
>  	int not_managed = 0;
>  	int ret = 0;
>  	LIST_HEAD(source);
>  
> -	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
> +	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>  		if (!pfn_valid(pfn))
>  			continue;
>  		page = pfn_to_page(pfn);
> @@ -1362,8 +1360,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  				ret = -EBUSY;
>  				break;
>  			}
> -			if (isolate_huge_page(page, &source))
> -				move_pages -= 1 << compound_order(head);
> +			isolate_huge_page(page, &source);
>  			continue;
>  		} else if (PageTransHuge(page))
>  			pfn = page_to_pfn(compound_head(page))
> @@ -1382,7 +1379,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  		if (!ret) { /* Success */
>  			put_page(page);
>  			list_add_tail(&page->lru, &source);
> -			move_pages--;
>  			if (!__PageMovable(page))
>  				inc_node_page_state(page, NR_ISOLATED_ANON +
>  						    page_is_file_cache(page));
> 

Yes, there is basically no statement why it was done that way. If it is
important, there should be one.

(we could also check for pending signals inside that function if really
required)

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
