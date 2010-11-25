Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E43BD6B004A
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 11:15:41 -0500 (EST)
Date: Thu, 25 Nov 2010 16:15:25 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Free memory never fully used, swapping
Message-ID: <20101125161524.GE26037@csn.ul.ie>
References: <1290647274.12777.3.camel@sli10-conroe> <20101125090328.GB14180@hostway.ca> <20101125180959.F462.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101125180959.F462.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Simon Kirby <sim@hostway.ca>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 25, 2010 at 07:51:44PM +0900, KOSAKI Motohiro wrote:
> > kswapd is throwing out many times what is needed for the order 3
> > watermark to be met.  It seems to be not as bad now, but look at these
> > pages being reclaimed (200ms intervals, whitespace-packed buddyinfo
> > followed by nr_pages_free calculation and final order-3 watermark test,
> > kswapd woken after the second sample):
> > 
> > Normal zone at the same time (shown separately for clarity):
> >
> >   Zone order:0      1     2     3    4   5  6 7 8 9 A nr_free or3-low-chk
> > 
> > Normal     452      1     0     0    0   0  0 0 0 0 0     454 -5 <= 238
> > Normal     452      1     0     0    0   0  0 0 0 0 0     454 -5 <= 238
> > (kswapd wakes)
> > Normal    7618     76     0     0    0   0  0 0 0 0 0    7770 145 <= 238
> > Normal    8860     73     1     0    0   0  0 0 0 0 0    9010 143 <= 238
> > Normal    8929     25     0     0    0   0  0 0 0 0 0    8979 43 <= 238
> > Normal    8917      0     0     0    0   0  0 0 0 0 0    8917 -7 <= 238
> > Normal    8978     16     0     0    0   0  0 0 0 0 0    9010 25 <= 238
> > Normal    9064      4     0     0    0   0  0 0 0 0 0    9072 1 <= 238
> > Normal    9068      2     0     0    0   0  0 0 0 0 0    9072 -3 <= 238
> > Normal    8992      9     0     0    0   0  0 0 0 0 0    9010 11 <= 238
> > Normal    9060      6     0     0    0   0  0 0 0 0 0    9072 5 <= 238
> > Normal    9010      0     0     0    0   0  0 0 0 0 0    9010 -7 <= 238
> > Normal    8907      5     0     0    0   0  0 0 0 0 0    8917 3 <= 238
> > Normal    8576      0     0     0    0   0  0 0 0 0 0    8576 -7 <= 238
> > Normal    8018      0     0     0    0   0  0 0 0 0 0    8018 -7 <= 238
> > Normal    6778      0     0     0    0   0  0 0 0 0 0    6778 -7 <= 238
> > Normal    6189      0     0     0    0   0  0 0 0 0 0    6189 -7 <= 238
> > Normal    6220      0     0     0    0   0  0 0 0 0 0    6220 -7 <= 238
> > Normal    6096      0     0     0    0   0  0 0 0 0 0    6096 -7 <= 238
> > Normal    6251      0     0     0    0   0  0 0 0 0 0    6251 -7 <= 238
> > Normal    6127      0     0     0    0   0  0 0 0 0 0    6127 -7 <= 238
> > Normal    6218      1     0     0    0   0  0 0 0 0 0    6220 -5 <= 238
> > Normal    6034      0     0     0    0   0  0 0 0 0 0    6034 -7 <= 238
> > Normal    6065      0     0     0    0   0  0 0 0 0 0    6065 -7 <= 238
> > Normal    6189      0     0     0    0   0  0 0 0 0 0    6189 -7 <= 238
> > Normal    6189      0     0     0    0   0  0 0 0 0 0    6189 -7 <= 238
> > Normal    6096      0     0     0    0   0  0 0 0 0 0    6096 -7 <= 238
> > Normal    6127      0     0     0    0   0  0 0 0 0 0    6127 -7 <= 238
> > Normal    6158      0     0     0    0   0  0 0 0 0 0    6158 -7 <= 238
> > Normal    6127      0     0     0    0   0  0 0 0 0 0    6127 -7 <= 238
> > (kswapd sleeps -- maybe too much turkey)
> > 
> > DMA32 get so much reclaimed that the watermark test succeeded long ago.
> > Meanwhile, Normal is being reclaimed as well, but because it's fighting
> > with allocations, it tries for a while and eventually succeeds (I think),
> > but the 200ms samples didn't catch it.
> > 
> > KOSAKI Motohiro, I'm interested in your commit 73ce02e9.  This seems
> > to be similar to this problem, but your change is not working here. 
> > We're seeing kswapd run without sleeping, KSWAPD_SKIP_CONGESTION_WAIT
> > is increasing (so has_under_min_watermark_zone is true), and pageoutrun
> > increasing all the time.  This means that balance_pgdat() keeps being
> > called, but sleeping_prematurely() is returning true, so kswapd() just
> > keeps re-calling balance_pgdat().  If your approach is correct to stop
> > kswapd here, the problem seems to be that balance_pgdat's copy of order
> > and sc.order is being set to 0, but not pgdat->kswapd_max_order, so
> > kswapd never really sleeps.  How is this supposed to work?
> 
> Um. this seems regression since commit f50de2d381 (vmscan: have kswapd sleep 
> for a short interval and double check it should be asleep)
> 

I wrote my own patch before I saw this but for one of the issues we are doing
something similar. You are checking if enough pages got reclaimed where as
my patch considers any zone being balanced for high-orders being sufficient
for kswapd to go to sleep. I think mine is a little stronger because
it's checking what state the zones are in for a given order regardless
of what has been reclaimed. Lets see what testing has to say.

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
