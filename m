Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2F37B6B0092
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 04:39:41 -0400 (EDT)
Date: Tue, 19 Jul 2011 09:39:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH]vmscan: fix a livelock in kswapd
Message-ID: <20110719083932.GD5349@suse.de>
References: <1311059367.15392.299.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311059367.15392.299.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, Jul 19, 2011 at 03:09:27PM +0800, Shaohua Li wrote:
> I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
> After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
> kswapd2 are keeping running and I can't access filesystem, but most memory is
> free. This looks like a regression since commit 08951e545918c159.
> Node 2 and 3 have only ZONE_NORMAL, but balance_pgdat() will return 0 for
> classzone_idx. The reason is end_zone in balance_pgdat() is 0 by default, if
> all zones have watermark ok, end_zone will keep 0.
> Later sleeping_prematurely() always returns true. Because this is an order 3
> wakeup, and if classzone_idx is 0, both balanced_pages and present_pages
> in pgdat_balanced() are 0.
> We add a special case here. If a zone has no page, we think it's balanced. This
> fixes the livelock.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 

Acked-by: Mel Gorman <mgorman@suse.de>

It's also needed for 3.0 and 2.6.39-stable I believe.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
