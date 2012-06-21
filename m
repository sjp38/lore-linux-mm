Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 6041E6B00A1
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 05:01:47 -0400 (EDT)
Received: by dakp5 with SMTP id p5so752156dak.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 02:01:46 -0700 (PDT)
Date: Thu, 21 Jun 2012 02:01:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: abort compaction if migration page cannot be
 charged to memcg
In-Reply-To: <alpine.DEB.2.00.1206210124380.6635@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1206210158360.10975@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com> <4FE2D73C.3060001@kernel.org> <alpine.DEB.2.00.1206210124380.6635@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 21 Jun 2012, David Rientjes wrote:

> It's possible that subsequent pageblocks would contain memory allocated 
> from solely non-oom memcgs, but it's certainly not a guarantee and results 
> in terrible performance as exhibited above.  Is there another good 
> criteria to use when deciding when to stop isolating and attempting to 
> migrate all of these pageblocks?
> 
> Other ideas?
> 

The only other alternative that I can think of is to check 
mem_cgroup_margin() in isolate_migratepages_range() and return a NULL 
lruvec that would break that pageblock and return, and then set a bit in 
struct mem_cgroup that labels it as oom so we can check for it on 
subsequent pageblocks without incurring the locking to do 
mem_cgroup_margin() in res_counter, and then clear that bit on every 
uncharge to a memcg, but this still seems like a tremendous waste of cpu 
(especially if /sys/kernel/mm/transparent_hugepage/defrag == always) if 
most pageblocks contain pages from an oom memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
