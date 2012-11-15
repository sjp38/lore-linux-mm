Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 023C56B005A
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 16:41:26 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1509816pad.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 13:41:26 -0800 (PST)
Date: Thu, 15 Nov 2012 13:41:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: fix a regression with HIGHMEM introduced by changeset
 7f1290f2f2a4d
In-Reply-To: <50A50CF8.9040207@gmail.com>
Message-ID: <alpine.DEB.2.00.1211151328430.27188@chino.kir.corp.google.com>
References: <1352165517-9732-1-git-send-email-jiang.liu@huawei.com> <20121106124315.79deb2bc.akpm@linux-foundation.org> <50A3B013.4030207@gmail.com> <50A4B45D.5000905@cn.fujitsu.com> <50A50CF8.9040207@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Jianguo Wu <wujianguo@huawei.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daniel Vetter <daniel.vetter@ffwll.ch>

On Thu, 15 Nov 2012, Jiang Liu wrote:

> I feel that zone->present_pages has been abused. I guess it means "physical pages 
> present in this zone" originally, but now sometimes zone->present_pages is used as
> "pages in this zone managed by the buddy system".

It's definition is all pages spanned by the zone that are not reserved and 
unavailable to the kernel to allocate from, and the implementation of 
bootmem requires that its memory be considered as "reserved" until freed.  
It's used throughout the kernel to determine the amount of memory that is 
allocatable in that zone from the page allocator since its reclaim 
heuristics and watermarks depend on this memory being allocatable.

> So I'm trying to add a new
> field "managed_pages" into zone, which accounts for pages managed by buddy system.
> That's why I thought the clean solution is a little complex:(
> 

You need to update the pgdat's node_present_pages to be consistent with 
all of its zones' present_pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
