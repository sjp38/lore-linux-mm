Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 928276B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 01:06:48 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o8T56jjR003134
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 22:06:46 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by hpaq13.eem.corp.google.com with ESMTP id o8T56hf3023426
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 22:06:44 -0700
Received: by pwi5 with SMTP id 5so100258pwi.8
        for <linux-mm@kvack.org>; Tue, 28 Sep 2010 22:06:43 -0700 (PDT)
Date: Tue, 28 Sep 2010 22:06:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zone state overhead
In-Reply-To: <1285735638.27440.23.camel@sli10-conroe.sh.intel.com>
Message-ID: <alpine.DEB.2.00.1009282157100.9677@chino.kir.corp.google.com>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com>
 <1285735638.27440.23.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Shaohua Li wrote:

> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -154,7 +154,7 @@ static void refresh_zone_stat_thresholds(void)
> >  		tolerate_drift = low_wmark_pages(zone) - min_wmark_pages(zone);
> >  		max_drift = num_online_cpus() * threshold;
> >  		if (max_drift > tolerate_drift)
> > -			zone->percpu_drift_mark = high_wmark_pages(zone) +
> > +			zone->percpu_drift_mark = low_wmark_pages(zone) +
> >  					max_drift;
> >  	}
> >  }
> I'm afraid not. I tried Christoph's patch, which doesn't help.
> in that patch, the threshold = 6272/2 = 3136. and the percpu_drift_mark
> is 3136 + 2161 < 8073
> 

I think my patch is conceptually correct based on the real risk that Mel 
was describing.  With Christoph's patch the threshold would have been 49 
(max_drift is 3136), which would also increase the the cacheline bounce 
for zone_page_state_add(), but the penalty of zone_page_state_snapshot() 
is probably much higher.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
