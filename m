Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B8AF46B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 15:44:26 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o8TJiOEU026842
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 12:44:24 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by kpbe11.cbf.corp.google.com with ESMTP id o8TJiMtc016208
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 12:44:23 -0700
Received: by pwj6 with SMTP id 6so675710pwj.0
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 12:44:22 -0700 (PDT)
Date: Wed, 29 Sep 2010 12:44:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zone state overhead
In-Reply-To: <20100929100307.GA14204@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009291228160.5734@chino.kir.corp.google.com>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com> <20100929100307.GA14204@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Mel Gorman wrote:

> > It's plausible that we never reclaim sufficient memory that we ever get 
> > above the high watermark since we only trigger reclaim when we can't 
> > allocate above low, so we may be stuck calling zone_page_state_snapshot() 
> > constantly.
> > 
> 
> Except that zone_page_state_snapshot() is only called while kswapd is
> awake which is the proxy indicator of pressure. Just being below
> percpu_drift_mark is not enough to call zone_page_state_snapshot.
> 

Right, so zone_page_state_snapshot() is always called to check the min 
watermark for the subsequent allocation immediately after kswapd is kicked 
in the slow path, meaning it is called for every allocation when the zone 
is between low and min.  That's 360 pages for Shaohua's system and even 
more if GFP_ATOMIC.  kswapd will reclaim to the high watermark, 360 pages 
above low, using zone_page_state_snapshot() the whole time as well.  So 
under heavy memory pressure, it seems like the majority of 
zone_watermark_ok() calls are using zone_page_state_snapshot() anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
