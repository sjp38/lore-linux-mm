Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id B80086B0069
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 20:17:47 -0500 (EST)
Message-ID: <4F0CE313.1090008@redhat.com>
Date: Tue, 10 Jan 2012 20:17:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
References: <1324437036.4677.5.camel@hakkenden.homenet> <20111221095249.GA28474@tiehlicka.suse.cz> <20111221225512.GG23662@dastard> <1324630880.562.6.camel@rybalov.eng.ttk.net> <20111223102027.GB12731@dastard> <1324638242.562.15.camel@rybalov.eng.ttk.net> <20111223204503.GC12731@dastard> <20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com> <20111227035730.GA22840@barrios-laptop.redhat.com>
In-Reply-To: <20111227035730.GA22840@barrios-laptop.redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, nowhere <nowhere@hakkenden.ath.cx>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/26/2011 10:57 PM, Minchan Kim wrote:

> I guess it's caused by small NORMAL zone.
> The scenario I think is as follows,

I guess it is exaggerated by a small NORMAL zone.  Even on my
system, where the NORMAL zone is about 3x as large as the DMA32
zone, I can see that the pages in the NORMAL zone get recycled
slightly faster than those in the DMA32 zone...

> 1. dd comsumes memory in NORMAL zone
> 2. dd enter direct reclaim and wakeup kswapd
> 3. kswapd reclaims some memory in NORMAL zone until it reclaims high wamrk
> 4. schedule
> 5. dd consumes memory again in NORMAL zone
> 6. kswapd fail to reclaim memory by high watermark due to 5.
> 7. loop again, goto 3.
>
> The point is speed between reclaim VS memory consumption.
> So kswapd cannot reach a point which enough pages are in NORMAL zone.

I wonder if it would make sense for kswapd to count how many
pages it needs to free in each zone (at step 2), and then stop
reclaiming once it has freed that many pages.

That could leave the NORMAL (or HIGHMEM, on 32 bit) zone below
the watermark, but as long as the other zones are still good,
allocations can proceed just fine.

It would have the disadvantage of kswapd stopping reclaim with
possibly a zone below the watermark, but the advantage of
better balancing of allocations between zones.

Does this idea make sense?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
