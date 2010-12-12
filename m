Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 840DB6B0088
	for <linux-mm@kvack.org>; Sun, 12 Dec 2010 19:04:59 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBD04uhC017215
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 13 Dec 2010 09:04:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B3E6D45DE59
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 09:04:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ADCF45DE56
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 09:04:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C329E38002
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 09:04:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 48370E38001
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 09:04:56 +0900 (JST)
Date: Mon, 13 Dec 2010 08:58:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/6] mm: kswapd: Treat zone->all_unreclaimable in
 sleeping_prematurely similar to balance_pgdat()
Message-Id: <20101213085855.d0e907bd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101210105532.GM20133@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
	<1291893500-12342-6-git-send-email-mel@csn.ul.ie>
	<20101210102337.8ff1fad2.kamezawa.hiroyu@jp.fujitsu.com>
	<20101210105532.GM20133@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2010 10:55:32 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> On Fri, Dec 10, 2010 at 10:23:37AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu,  9 Dec 2010 11:18:19 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > After DEF_PRIORITY, balance_pgdat() considers all_unreclaimable zones to
> > > be balanced but sleeping_prematurely does not. This can force kswapd to
> > > stay awake longer than it should. This patch fixes it.
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > Hmm, maybe the logic works well but I don't like very much.
> > 
> > How about adding below instead of pgdat->node_present_pages ?
> > 
> > static unsigned long required_balanced_pages(pgdat, classzone_idx)
> > {
> > 	unsigned long present = 0;
> > 
> > 	for_each_zone_in_node(zone, pgdat) {
> > 		if (zone->all_unreclaimable) /* Ignore unreclaimable zone at checking balance */
> > 			continue;
> > 		if (zone_idx(zone) > classzone_idx)
> > 			continue;
> > 		present = zone->present_pages;
> > 	}
> > 	return present;
> > }
> > 
> 
> I'm afraid I do not really understand. After your earlier comments,
> pgdat_balanced() now looks like
> 
> static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
>                                                 int classzone_idx)
> {
>         unsigned long present_pages = 0;
>         int i;
> 
>         for (i = 0; i <= classzone_idx; i++)
>                 present_pages += pgdat->node_zones[i].present_pages;
> 
>         return balanced_pages > (present_pages >> 2);
> }
> 
> so the classzone is being taken into account. I'm not sure what you're
> asking for it to be changed to. Maybe it'll be clearer after V4 comes
> out rebased on top of mmotm.
> 

Ah, this seems okay to me.

Thank you.
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
