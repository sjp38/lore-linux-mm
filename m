Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A420C6B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 16:37:00 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCHv2 2/5] vmscan: Kill hibernation specific reclaim logic and unify it
Date: Sun, 1 Nov 2009 22:38:13 +0100
References: <20091101234614.F401.A69D9226@jp.fujitsu.com> <20091102000855.F404.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091102000855.F404.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911012238.13083.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sunday 01 November 2009, KOSAKI Motohiro wrote:
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
> 
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
> 
> 4) SplitLRU VM always keep active/inactive ratio very carefully. inactive list only
>   shrinking break its assumption. it makes unnecessary OOM risk. it obviously suboptimal.
> 
> Then, This patch changed shrink_all_memory() to only the wrapper function of 
> do_try_to_free_pages(). it bring good reviewability and debuggability, and solve 
> above problems.
> 
> side note: Reclaim logic unificication makes two good side effect.
>  - Fix recursive reclaim bug on shrink_all_memory().
>    it did forgot to use PF_MEMALLOC. it mean the system be able to stuck into deadlock.
>  - Now, shrink_all_memory() got lockdep awareness. it bring good debuggability.

As I said previously, I don't really see a reason to keep shrink_all_memory().

Do you think that removing it will result in performance degradation?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
