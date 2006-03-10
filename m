Message-ID: <441106C9.9040502@yahoo.com.au>
Date: Fri, 10 Mar 2006 15:55:37 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 00/03] Unmapped: Separate unmapped and mapped pages
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
In-Reply-To: <20060310034412.8340.90939.sendpatchset@cherry.local>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Magnus Damm wrote:
> Unmapped patches - Use two LRU:s per zone.
> 
> These patches break out the per-zone LRU into two separate LRU:s - one for
> mapped pages and one for unmapped pages. The patches also introduce guarantee 
> support, which allows the user to set how many percent of all pages per node
> that should be kept in memory for mapped or unmapped pages. This guarantee 
> makes it possible to adjust the VM behaviour depending on the workload.
> 
> Reasons behind the LRU separation:
> 
> - Avoid unnecessary page scanning.
>   The current VM implementation rotates mapped pages on the active list
>   until the number of mapped pages are high enough to start unmap and page out.
>   By using two LRU:s we can avoid this scanning and shrink/rotate unmapped 
>   pages only, not touching mapped pages until the threshold is reached.
> 
> - Make it possible to adjust the VM behaviour.
>   In some cases the user might want to guarantee that a certain amount of 
>   pages should be kept in memory, overriding the standard behaviour. Separating
>   pages into mapped and unmapped LRU:s allows guarantee with low overhead.
> 
> I've performed many tests on a Dual PIII machine while varying the amount of
> RAM available. Kernel compiles on a 64MB configuration gets a small speedup, 
> but the impact on other configurations and workloads seems to be unaffected.
> 
> Apply on top of 2.6.16-rc5.
> 
> Comments?
> 

I did something similar a while back which I called split active lists.
I think it is a good idea in general and I did see fairly large speedups
with heavy swapping kbuilds, but nobody else seemed to want it :P

So you split the inactive list as well - that's going to be a bit of
change in behaviour and I'm not sure whether you gain anything.

I don't think PageMapped is a very good name for the flag.

I test mapped lazily. Much better way to go IMO.

I had further patches that got rid of reclaim_mapped completely while
I was there. It is based on crazy metrics that basically completely
change meaning if there are changes in the memory configuration of
the system, or small changes in reclaim algorithms.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
