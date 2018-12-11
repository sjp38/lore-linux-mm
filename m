Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 433B88E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:18:21 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e12so6711004edd.16
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 02:18:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dk19-v6si2051794ejb.124.2018.12.11.02.18.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 02:18:19 -0800 (PST)
Date: Tue, 11 Dec 2018 11:18:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: Don't bail out in do_migrate_range
 prematurely
Message-ID: <20181211101818.GE1286@dhcp22.suse.cz>
References: <20181211085042.2696-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211085042.2696-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, david@redhat.com, pasha.tatashin@soleen.com, dan.j.williams@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 11-12-18 09:50:42, Oscar Salvador wrote:
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

This is true but reorganizing the code will not help the underlying
issue. Because the permanently failing page will be still there for
scan_movable_pages to encounter.
 
> Issue debugged in 4d0c7db96 ("hwpoison, memory_hotplug: allow hwpoisoned
> pages to be offlined") has proved that.

I assume that 4d0c7db96 is a sha1 from the linux-next. Please note that
this is not going to be the case when merged upstream. So I would use a
link.

> During the debugging of that issue, it was noticed that if
> do_migrate_ranges() fails to isolate a single page, we will
> just discard the work we have done so far and bail out, which means
> that scan_movable_pages() will find again the same set of pages.
> 
> Instead, we can just skip the error, keep isolating as much pages
> as possible and then proceed with the call to migrate_pages().
> This will allow us to do some work at least.

Yes, this makes sense to me.

> There is no danger in the skipped pages to be lost, because
> scan_movable_pages() will give us them as they could not
> be isolated and therefore migrated.
> 
> Although this patch has proved to be useful when dealing with
> 4d0c7db96 because it allows us to move forward as long as the
> page is not in LRU, we still need 4d0c7db96
> ("hwpoison, memory_hotplug: allow hwpoisoned pages to be offlined")
> to handle the LRU case and the unmapping of the page if needed.
> So, this is just a follow-up cleanup.

I suspect the above paragraph is adding more confusion than necessary. I
would just drop it.

The main question here is. Do we want to migrate as much as possible or
do we want to be conservative and bail out early. The later could be an
advantage if the next attempt could fail the whole operation because the
impact of the failed operation would be somehow reduced. The former
should be better for throughput because easily done stuff is done first.

I would go with the throuput because our failure mode is to bail out
much earlier - even before we try to migrate. Even though the detection
is not perfect it works reasonably well for most usecases.

[...]
> @@ -1395,25 +1394,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  				inc_node_page_state(page, NR_ISOLATED_ANON +
>  						    page_is_file_cache(page));
>  
> -		} else {
> -			pr_warn("failed to isolate pfn %lx\n", pfn);
> -			dump_page(page, "isolation failed");
> -			put_page(page);
> -			/* Because we don't have big zone->lock. we should
> -			   check this again here. */
> -			if (page_count(page)) {
> -				not_managed++;
> -				ret = -EBUSY;
> -				break;
> -			}
>  		}

you really want to keep this branch. You just do not want to bail out.
We want to know about pages which fail to isolate and you definitely do
not want to keep the reference elevated behind. not_managed stuff can go
away.

-- 
Michal Hocko
SUSE Labs
