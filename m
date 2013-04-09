Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B938E6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:37:46 -0400 (EDT)
Date: Tue, 9 Apr 2013 17:37:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] soft reclaim rework
Message-ID: <20130409153742.GL29860@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365509595-665-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

On Tue 09-04-13 14:13:12, Michal Hocko wrote:
[...]
> 2) kbuild test showed more or less the same results
> usage_in_bytes
> Base
> 		Group A		Group B
> Median		394817536	395634688
> 
> Patches applied
> median		483481600	302131200
> 
> A is kept closer to the soft limit again. There is some fluctuation
> around the limit because kbuild creates a lot of short lived processes.
> Base: 	 pgscan_kswapd_dma32 1648718	pgsteal_kswapd_dma32 1510749
> Patched: pgscan_kswapd_dma32 2042065	pgsteal_kswapd_dma32 1667745

OK, so I have patched the base version with the patch bellow which
uncovers soft reclaim scanning and reclaim and guess what:
Base:	 pgscan_kswapd_dma32 3710092	pgsteal_kswapd_dma32 3225191
Patched: pgscan_kswapd_dma32 1846700	pgsteal_kswapd_dma32 1442232
Base:	 pgscan_direct_dma32 2417683	pgsteal_direct_dma32 459702
Patched: pgscan_direct_dma32 1839331	pgsteal_direct_dma32 244338

The numbers are obviously timing dependent (wrt. previous run ~10% for
the patched kernel) but the ~1/2 half wrt. the base kernel seems real
we just haven't seen it previously because it wasn't accounted. I guess
this can be attributed to prio-0 soft reclaim behavior and a lot of
dirty pages on the LRU.

> The differences are much bigger now so it would be interesting how much
> has been scanned/reclaimed during soft reclaim in the base kernel.
---
