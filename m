Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id MAA22316
	for <linux-mm@kvack.org>; Wed, 2 Oct 2002 12:36:37 -0700 (PDT)
Message-ID: <3D9B4AC2.4EAF1B85@digeo.com>
Date: Wed, 02 Oct 2002 12:36:34 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: VolanoMark Benchmark results for 2.5.26, 2.5.26 + rmap, 2.5.35 +
 mm1, and 2.5.38 + mm3
References: <Pine.LNX.4.44L.0209172219200.1857-100000@imladris.surriel.com> <3D948EA6.A6EFC26B@austin.ibm.com> <3D94A43B.49C65AE8@digeo.com> <3D9B402D.601E52B6@austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Hartner <hartner@austin.ibm.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

Bill Hartner wrote:
> 
> Andrew Morton wrote:
> >
> > Bill Hartner wrote:
> > >
> > > ...
> > > 2.5.35       44693  86.1 1.45        1,982,236 KB  5,393,152 KB  7,375,388 KB
> > > 2.5.35mm1    39679  99.6 1.50       *2,720,600 KB *6,154,512 KB *8,875,112 KB
> > >
> >
> > 2.5.35 was fairly wretched from the swapout point of view.
> > Would be interesting to retest on 2.5.38-mm/2.5.39 sometime.
> >
> 
> Here are VolanoMark results for 2.5.38 and 2.5.38-mm3 for both
> 3GB (memory pressure) and 4GB.  I will repeat for 2.5.40 mm1 or
> what ever is the latest and greatest on Friday.

Thanks again.

> SUT same as :
> 
> http://marc.theaimsgroup.com/?l=linux-mm&m=103229747000714&w=2
> 
> NOTE : the swap device is on ServeRAID which is probably bouncing for
> the HIGHMEM pages in most if not all of the tests so results will
> likely improve when bouncing is eliminated.  Need to work this problem next.
> 
> 2419     = 2.4.19 + o(1) scheduler
> 2419rmap = 2.4.19 + rmap14b + o(1) scheduler
> 
> %sys/%user = ratio of %system CPU utilization to %user CPU utilization.
> 
> ========================================
> The results for the 3 GB mem test were :
> ========================================
> 
> kernel       msg/s  %CPU %sys/%user  Total swpin   Total swpout  Total swapio
> -----------  -----  ---- ----------  ------------  ------------  ------------
> 
> 2.5.38       46081  90.1 1.44        1,992,608 KB  2,881,056 KB  4,873,664 KB
> 2.5.38mm3    44950  99.8 1.52        did not collect io - /proc/stat changed

That's probably due to the more aggressive promote-reads-before-writes
tuning.  The same is observable with the `qsbench' benchmark.

> =============================== old data below===============================
> 2.4.19       ***** system hard hangs - requires reset. *****
> 2.4.19rmap   37767  76.9 1.46        2,274,380 KB  3,800,336 KB  6,074,716 KB
> 2.5.26       51824  96.3 1.42        1,987,024 KB  2,148,100 KB  4,135,124 KB
> 2.5.26rmap   46053  90.8 1.55        3,139,324 KB  3,887,368 KB  7,026,692 KB
> 2.5.35       44693  86.1 1.45        1,982,236 KB  5,393,152 KB  7,375,388 KB
> 2.5.35mm1    39679  99.6 1.50       *2,720,600 KB *6,154,512 KB *8,875,112 KB
> 
> * used pgin/pgout instead of swapin/swapout since /proc/stat changed.
> 
> 2.5.38 does not perform as well as 2.5.26 (before rmap).
> 46081/51284 = 89.9 % or 10.1 % degradation.
> 
> 2.5.38mm3 does not perform as well as 2.5.38.
> 44950/46081 = 97.5 % or 2.5 % degradation.
> CPU utilization is also higher - 99.8 vs 90.1.

Yes, we're generally more eager to start swapout.
 
> ========================================
> The results for the 4 GB mem test were :
> ========================================
> 
> kernel       msg/s  %CPU %sys/%user  Total swpin   Total swpout  Total swapio
> -----------  -----  ---- ----------  ------------  ------------  ------------
> 
> 2.5.38       53084  99.9 1.41        0             0             0
> 2.5.38mm3    49933  99.9 1.47        0             0             0
> 
> =============================== old data below===============================
> 2.4.19       55386  99.8 1.40        0             0             0
> 2.4.19rmap   52330  99.5 1.43        0             2,363,388 KB  2,363,388 KB
> 2.5.26       55446  99.4 1.40        0             0             0
> 2.5.35       52845  99.9 1.38        0             0             0
> 2.5.35mm1    52755  99.9 1.42        0             0             0
> 
> 2.5.38 does not perform as well as 2.5.26.
> 53084/55426 = 95.8 % or 4.2 % degradation.
> 
> 2.5.38mm3 does not perform as well as 2.5.38.
> 49933/53084 = 94.1 % or 5.9 % degradation. Higher ratio of system CPU.

Davem says that the loopback network device is currently doing an
extra copy, which will go away soon.  (That was news to me).

I wonder if volanomark does tcp to localhost?  `ifconfig lo' will
tell us.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
