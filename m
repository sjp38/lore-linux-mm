Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2578E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 03:48:03 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d41so791551eda.12
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 00:48:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w5si278853edr.322.2018.12.13.00.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 00:48:02 -0800 (PST)
Date: Thu, 13 Dec 2018 09:48:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, memory_hotplug: Don't bail out in
 do_migrate_range prematurely
Message-ID: <20181213084800.GV1286@dhcp22.suse.cz>
References: <20181211135312.27034-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211135312.27034-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, david@redhat.com, pasha.tatashin@soleen.com, dan.j.williams@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 11-12-18 14:53:12, Oscar Salvador wrote:
> v1 -> v2:
>         - Keep branch to decrease refcount and print out
>           the failed pfn/page
>         - Modified changelog per Michal's feedback
>         - move put_page() out of the if/else branch
> 
> ---
> >From f81da873be9a5b7845249d1e62a423f054c487d5 Mon Sep 17 00:00:00 2001
> From: Oscar Salvador <osalvador@suse.com>
> Date: Tue, 11 Dec 2018 11:45:19 +0100
> Subject: [PATCH] mm, memory_hotplug: Don't bail out in do_migrate_range
>  prematurely
> 
> do_migrate_ranges() takes a memory range and tries to isolate the
> pages to put them into a list.
> This list will be later on used in migrate_pages() to know
> the pages we need to migrate.
> 
> Currently, if we fail to isolate a single page, we put all already
> isolated pages back to their LRU and we bail out from the function.
> This is quite suboptimal, as this will force us to start over again
> because scan_movable_pages will give us the same range.
> If there is no chance that we can isolate that page, we will loop here
> forever.

I still think that this doesn't give us a whole picture. Looping for
ever is a bug. Failing the isolation is quite possible and it should be
a ephemeral condition (e.g. a race with freeing the page or somebody else
isolating the page for whatever reason). And here comes the disadvantage
of the current implementation. We simply throw everything on the floor
just because of a ephemeral condition. The racy page_count check is
quite dubious to prevent from that.

> Issue debugged in [1] has proved that.
> During the debugging of that issue, it was noticed that if
> do_migrate_ranges() fails to isolate a single page, we will
> just discard the work we have done so far and bail out, which means
> that scan_movable_pages() will find again the same set of pages.
> 
> Instead, we can just skip the error, keep isolating as much pages
> as possible and then proceed with the call to migrate_pages().
> 
> This will allow us to do as much work as possible at once.
> 
> [1] https://lkml.org/lkml/2018/12/6/324

lkml.org tends to have broken archives over time. Please use
http://lkml.kernel.org/r/

instead

> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 18 ++----------------
>  1 file changed, 2 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 86ab673fc4e3..68e740b1768e 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1339,7 +1339,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  	unsigned long pfn;
>  	struct page *page;
>  	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
> -	int not_managed = 0;
>  	int ret = 0;
>  	LIST_HEAD(source);
>  
> @@ -1388,7 +1387,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  		else
>  			ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);
>  		if (!ret) { /* Success */
> -			put_page(page);
>  			list_add_tail(&page->lru, &source);
>  			move_pages--;
>  			if (!__PageMovable(page))
> @@ -1398,22 +1396,10 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  		} else {
>  			pr_warn("failed to isolate pfn %lx\n", pfn);
>  			dump_page(page, "isolation failed");
> -			put_page(page);
> -			/* Because we don't have big zone->lock. we should
> -			   check this again here. */
> -			if (page_count(page)) {
> -				not_managed++;
> -				ret = -EBUSY;
> -				break;
> -			}
>  		}
> +		put_page(page);
>  	}
>  	if (!list_empty(&source)) {
> -		if (not_managed) {
> -			putback_movable_pages(&source);
> -			goto out;
> -		}
> -
>  		/* Allocate a new page from the nearest neighbor node */
>  		ret = migrate_pages(&source, new_node_page, NULL, 0,
>  					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
> @@ -1426,7 +1412,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  			putback_movable_pages(&source);
>  		}
>  	}
> -out:
> +
>  	return ret;
>  }
>  
> -- 
> 2.13.7

-- 
Michal Hocko
SUSE Labs
