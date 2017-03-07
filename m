Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8AC6B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 02:28:42 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id w189so187876902pfb.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 23:28:42 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l19si21633355pgo.35.2017.03.06.23.28.40
        for <linux-mm@kvack.org>;
        Mon, 06 Mar 2017 23:28:41 -0800 (PST)
Date: Tue, 7 Mar 2017 16:28:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/9] mm: fix 100% CPU kswapd busyloop on unreclaimable
 nodes
Message-ID: <20170307072817.GA335@bbox>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-2-hannes@cmpxchg.org>
 <20170303012609.GA3394@bbox>
 <20170303075954.GA31499@dhcp22.suse.cz>
 <20170306013740.GA8779@bbox>
 <20170306162410.GB2090@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20170306162410.GB2090@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Mar 06, 2017 at 11:24:10AM -0500, Johannes Weiner wrote:
> On Mon, Mar 06, 2017 at 10:37:40AM +0900, Minchan Kim wrote:
> > On Fri, Mar 03, 2017 at 08:59:54AM +0100, Michal Hocko wrote:
> > > On Fri 03-03-17 10:26:09, Minchan Kim wrote:
> > > > On Tue, Feb 28, 2017 at 04:39:59PM -0500, Johannes Weiner wrote:
> > > > > @@ -3316,6 +3325,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
> > > > >  			sc.priority--;
> > > > >  	} while (sc.priority >= 1);
> > > > >  
> > > > > +	if (!sc.nr_reclaimed)
> > > > > +		pgdat->kswapd_failures++;
> > > > 
> > > > sc.nr_reclaimed is reset to zero in above big loop's beginning so most of time,
> > > > it pgdat->kswapd_failures is increased.
> 
> That wasn't intentional; I didn't see the sc.nr_reclaimed reset.
> 
> ---
> 
> From e126db716926ff353b35f3a6205bd5853e01877b Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 6 Mar 2017 10:53:59 -0500
> Subject: [PATCH] mm: fix 100% CPU kswapd busyloop on unreclaimable nodes fix
> 
> Check kswapd failure against the cumulative nr_reclaimed count, not
> against the count from the lowest priority iteration.
> 
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
