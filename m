Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 256646B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 00:15:02 -0400 (EDT)
Date: Thu, 1 Sep 2011 12:14:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: slow performance on disk/network i/o full speed after
 drop_caches
Message-ID: <20110901041458.GA30123@localhost>
References: <20110824093336.GB5214@localhost>
 <4E560F2A.1030801@profihost.ag>
 <20110826021648.GA19529@localhost>
 <4E570AEB.1040703@profihost.ag>
 <20110826030313.GA24058@localhost>
 <D299D0AE-2F3C-42E2-9723-A3D7C0108C40@profihost.ag>
 <20110826032601.GA26282@localhost>
 <CAC8teKXqZktBK7+GbLgHn-2k+zjjf8uieRM_q_V7JK7ePAk9Lg@mail.gmail.com>
 <4E573A99.4060309@profihost.ag>
 <4E5DDE86.3040202@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E5DDE86.3040202@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: Zhu Yanhai <zhu.yanhai@gmail.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hi Stefan,

On Wed, Aug 31, 2011 at 03:11:02PM +0800, Stefan Priebe - Profihost AG wrote:
> Hi Fengguang,
> Hi Yanhai,
> 
> > you're abssolutely corect zone_reclaim_mode is on - but why?
> > There must be some linux software which switches it on.
> >
> > ~# grep 'zone_reclaim_mode' /etc/sysctl.* -r -i
> > ~#
> >
> > also
> > ~# grep 'zone_reclaim_mode' /etc/sysctl.* -r -i
> > ~#
> >
> > tells us nothing.
> >
> > I've then read this:
> >
> > "zone_reclaim_mode is set during bootup to 1 if it is determined that
> > pages from remote zones will cause a measurable performance reduction.
> > The page allocator will then reclaim easily reusable pages (those page
> > cache pages that are currently not used) before allocating off node pages."
> >
> > Why does the kernel do that here in our case on these machines.
> 
> Can nobody help why the kernel in this case set it to 1?

It's determined by RECLAIM_DISTANCE.

build_zonelists():

                /*
                 * If another node is sufficiently far away then it is better
                 * to reclaim pages in a zone before going off node.
                 */
                if (distance > RECLAIM_DISTANCE)
                        zone_reclaim_mode = 1;

Since Linux v3.0 RECLAIM_DISTANCE is increased from 20 to 30 by this commit.
It may well help your case, too.

commit 32e45ff43eaf5c17f5a82c9ad358d515622c2562
Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date:   Wed Jun 15 15:08:20 2011 -0700

    mm: increase RECLAIM_DISTANCE to 30
    
    Recently, Robert Mueller reported (http://lkml.org/lkml/2010/9/12/236)
    that zone_reclaim_mode doesn't work properly on his new NUMA server (Dual
    Xeon E5520 + Intel S5520UR MB).  He is using Cyrus IMAPd and it's built on
    a very traditional single-process model.
    
      * a master process which reads config files and manages the other
        process
      * multiple imapd processes, one per connection
      * multiple pop3d processes, one per connection
      * multiple lmtpd processes, one per connection
      * periodical "cleanup" processes.
    
    There are thousands of independent processes.  The problem is, recent
    Intel motherboard turn on zone_reclaim_mode by default and traditional
    prefork model software don't work well on it.  Unfortunatelly, such models
    are still typical even in the 21st century.  We can't ignore them.
    
    This patch raises the zone_reclaim_mode threshold to 30.  30 doesn't have
    any specific meaning.  but 20 means that one-hop QPI/Hypertransport and
    such relatively cheap 2-4 socket machine are often used for traditional
    servers as above.  The intention is that these machines don't use
    zone_reclaim_mode.
    
    Note: ia64 and Power have arch specific RECLAIM_DISTANCE definitions.
    This patch doesn't change such high-end NUMA machine behavior.
    
    Dave Hansen said:
    
    : I know specifically of pieces of x86 hardware that set the information
    : in the BIOS to '21' *specifically* so they'll get the zone_reclaim_mode
    : behavior which that implies.
    :
    : They've done performance testing and run very large and scary benchmarks
    : to make sure that they _want_ this turned on.  What this means for them
    : is that they'll probably be de-optimized, at least on newer versions of
    : the kernel.
    :
    : If you want to do this for particular systems, maybe _that_'s what we
    : should do.  Have a list of specific configurations that need the
    : defaults overridden either because they're buggy, or they have an
    : unusual hardware configuration not really reflected in the distance
    : table.

    And later said:
    
    : The original change in the hardware tables was for the benefit of a
    : benchmark.  Said benchmark isn't going to get run on mainline until the
    : next batch of enterprise distros drops, at which point the hardware where
    : this was done will be irrelevant for the benchmark.  I'm sure any new
    : hardware will just set this distance to another yet arbitrary value to
    : make the kernel do what it wants.  :)
    :
    : Also, when the hardware got _set_ to this initially, I complained.  So, I
    : guess I'm getting my way now, with this patch.  I'm cool with it.

diff --git a/include/linux/topology.h b/include/linux/topology.h
index b91a40e..fc839bf 100644
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -60,7 +60,7 @@ int arch_update_cpu_topology(void);
  * (in whatever arch specific measurement units returned by node_distance())
  * then switch on zone reclaim on boot.
  */
-#define RECLAIM_DISTANCE 20
+#define RECLAIM_DISTANCE 30
 #endif
 #ifndef PENALTY_FOR_NODE_WITH_CPUS
 #define PENALTY_FOR_NODE_WITH_CPUS     (1)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
