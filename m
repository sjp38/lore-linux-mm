Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E149F6B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 17:00:22 -0500 (EST)
Message-ID: <4AEE0536.6020605@crca.org.au>
Date: Mon, 02 Nov 2009 09:01:26 +1100
From: Nigel Cunningham <ncunningham@crca.org.au>
MIME-Version: 1.0
Subject: Re: [PATCHv2 2/5] vmscan: Kill hibernation specific reclaim logic
 and unify it
References: <20091101234614.F401.A69D9226@jp.fujitsu.com> <20091102000855.F404.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091102000855.F404.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi.

KOSAKI Motohiro wrote:
> shrink_all_zone() was introduced by commit d6277db4ab (swsusp: rework
> memory shrinker) for hibernate performance improvement. and sc.swap_cluster_max
> was introduced by commit a06fe4d307 (Speed freeing memory for suspend).
> 
> commit a06fe4d307 said
> 
>    Without the patch:
>    Freed  14600 pages in  1749 jiffies = 32.61 MB/s (Anomolous!)
>    Freed  88563 pages in 14719 jiffies = 23.50 MB/s
>    Freed 205734 pages in 32389 jiffies = 24.81 MB/s
> 
>    With the patch:
>    Freed  68252 pages in   496 jiffies = 537.52 MB/s
>    Freed 116464 pages in   569 jiffies = 798.54 MB/s
>    Freed 209699 pages in   705 jiffies = 1161.89 MB/s
> 
> At that time, their patch was pretty worth. However, Modern Hardware
> trend and recent VM improvement broke its worth. From several reason,
> I think we should remove shrink_all_zones() at all.
> 
> detail:
> 
> 1) Old days, shrink_zone()'s slowness was mainly caused by stupid io-throttle
>   at no i/o congestion.
>   but current shrink_zone() is sane, not slow.
> 
> 2) shrink_all_zone() try to shrink all pages at a time. but it doesn't works
>   fine on numa system.
>   example)
>     System has 4GB memory and each node have 2GB. and hibernate need 1GB.
> 
>     optimal)
>        steal 500MB from each node.
>     shrink_all_zones)
>        steal 1GB from node-0.

I haven't given much thought to numa awareness in hibernate code, but I
can say that the shrink_all_memory interface is woefully inadequate as
far as zone awareness goes. Since lowmem needs to be atomically restored
before we can restore highmem, we really need to be able to ask for a
particular number of pages of a particular zone type to be freed.

>   Oh, Cache balancing logic was broken. ;)
>   Unfortunately, Desktop system moved ahead NUMA at nowadays.
>   (Side note, if hibernate require 2GB, shrink_all_zones() never success
>    on above machine)
> 
> 3) if the node has several I/O flighting pages, shrink_all_zones() makes
>   pretty bad result.
> 
>   schenario) hibernate need 1GB
> 
>   1) shrink_all_zones() try to reclaim 1GB from Node-0
>   2) but it only reclaimed 990MB
>   3) stupidly, shrink_all_zones() try to reclaim 1GB from Node-1
>   4) it reclaimed 990MB
> 
>   Oh, well. it reclaimed twice much than required.
>   In the other hand, current shrink_zone() has sane baling out logic.
>   then, it doesn't make overkill reclaim. then, we lost shrink_zones()'s risk.

Yes, this is bad.

> 4) SplitLRU VM always keep active/inactive ratio very carefully. inactive list only
>   shrinking break its assumption. it makes unnecessary OOM risk. it obviously suboptimal.

I don't follow your logic here. Without being a mm expert, I'd imagine
that it shouldn't matter that much if most of the inactive list gets freed.

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
