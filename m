Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DD3766B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 08:57:31 -0400 (EDT)
Date: Thu, 1 Sep 2011 13:57:20 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: slow performance on disk/network i/o full speed after drop_caches
Message-ID: <20110901125720.GC24629@csn.ul.ie>
References: <4E560F2A.1030801@profihost.ag>
 <20110826021648.GA19529@localhost>
 <4E570AEB.1040703@profihost.ag>
 <20110826030313.GA24058@localhost>
 <D299D0AE-2F3C-42E2-9723-A3D7C0108C40@profihost.ag>
 <20110826032601.GA26282@localhost>
 <CAC8teKXqZktBK7+GbLgHn-2k+zjjf8uieRM_q_V7JK7ePAk9Lg@mail.gmail.com>
 <4E573A99.4060309@profihost.ag>
 <4E5DDE86.3040202@profihost.ag>
 <20110901041458.GA30123@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110901041458.GA30123@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, Zhu Yanhai <zhu.yanhai@gmail.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, Sep 01, 2011 at 12:14:58PM +0800, Wu Fengguang wrote:
> Hi Stefan,
> 
> On Wed, Aug 31, 2011 at 03:11:02PM +0800, Stefan Priebe - Profihost AG wrote:
> > Hi Fengguang,
> > Hi Yanhai,
> > 
> > > you're abssolutely corect zone_reclaim_mode is on - but why?
> > > There must be some linux software which switches it on.
> > >
> > > ~# grep 'zone_reclaim_mode' /etc/sysctl.* -r -i
> > > ~#
> > >
> > > also
> > > ~# grep 'zone_reclaim_mode' /etc/sysctl.* -r -i
> > > ~#
> > >
> > > tells us nothing.
> > >
> > > I've then read this:
> > >
> > > "zone_reclaim_mode is set during bootup to 1 if it is determined that
> > > pages from remote zones will cause a measurable performance reduction.
> > > The page allocator will then reclaim easily reusable pages (those page
> > > cache pages that are currently not used) before allocating off node pages."
> > >
> > > Why does the kernel do that here in our case on these machines.
> > 
> > Can nobody help why the kernel in this case set it to 1?
> 
> It's determined by RECLAIM_DISTANCE.
> 
> build_zonelists():
> 
>                 /*
>                  * If another node is sufficiently far away then it is better
>                  * to reclaim pages in a zone before going off node.
>                  */
>                 if (distance > RECLAIM_DISTANCE)
>                         zone_reclaim_mode = 1;
> 
> Since Linux v3.0 RECLAIM_DISTANCE is increased from 20 to 30 by this commit.
> It may well help your case, too.
> 

Even with that, it's known that zone_reclaim() can be a disaster when
it runs into problems. This should be fixed in 3.1 by the following
commits;

[cd38b115 mm: page allocator: initialise ZLC for first zone eligible for zone_reclaim]
[76d3fbf8 mm: page allocator: reconsider zones for allocation after direct reclaim]

The description in cd38b115 has the interesting details.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
