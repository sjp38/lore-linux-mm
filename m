Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 858AA6B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 05:55:53 -0500 (EST)
Date: Fri, 10 Dec 2010 10:55:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/6] mm: kswapd: Treat zone->all_unreclaimable in
	sleeping_prematurely similar to balance_pgdat()
Message-ID: <20101210105532.GM20133@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie> <1291893500-12342-6-git-send-email-mel@csn.ul.ie> <20101210102337.8ff1fad2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101210102337.8ff1fad2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 2010 at 10:23:37AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu,  9 Dec 2010 11:18:19 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > After DEF_PRIORITY, balance_pgdat() considers all_unreclaimable zones to
> > be balanced but sleeping_prematurely does not. This can force kswapd to
> > stay awake longer than it should. This patch fixes it.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> Hmm, maybe the logic works well but I don't like very much.
> 
> How about adding below instead of pgdat->node_present_pages ?
> 
> static unsigned long required_balanced_pages(pgdat, classzone_idx)
> {
> 	unsigned long present = 0;
> 
> 	for_each_zone_in_node(zone, pgdat) {
> 		if (zone->all_unreclaimable) /* Ignore unreclaimable zone at checking balance */
> 			continue;
> 		if (zone_idx(zone) > classzone_idx)
> 			continue;
> 		present = zone->present_pages;
> 	}
> 	return present;
> }
> 

I'm afraid I do not really understand. After your earlier comments,
pgdat_balanced() now looks like

static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
                                                int classzone_idx)
{
        unsigned long present_pages = 0;
        int i;

        for (i = 0; i <= classzone_idx; i++)
                present_pages += pgdat->node_zones[i].present_pages;

        return balanced_pages > (present_pages >> 2);
}

so the classzone is being taken into account. I'm not sure what you're
asking for it to be changed to. Maybe it'll be clearer after V4 comes
out rebased on top of mmotm.


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
