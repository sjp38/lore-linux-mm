Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AB73D90010B
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 15:21:13 -0400 (EDT)
Date: Thu, 28 Apr 2011 20:21:04 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110428192104.GA4658@suse.de>
References: <1303990590.2081.9.camel@lenovo>
 <20110428135228.GC1696@quack.suse.cz>
 <20110428140725.GX4658@suse.de>
 <1304000714.2598.0.camel@mulgrave.site>
 <20110428150827.GY4658@suse.de>
 <1304006499.2598.5.camel@mulgrave.site>
 <1304009438.2598.9.camel@mulgrave.site>
 <1304009778.2598.10.camel@mulgrave.site>
 <20110428171826.GZ4658@suse.de>
 <1304015436.2598.19.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1304015436.2598.19.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@suse.de>
Cc: Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Thu, Apr 28, 2011 at 01:30:36PM -0500, James Bottomley wrote:
> On Thu, 2011-04-28 at 18:18 +0100, Mel Gorman wrote:
> > On Thu, Apr 28, 2011 at 11:56:17AM -0500, James Bottomley wrote:
> > > # Events: 6K cycles
> > > #
> > > # Overhead      Command        Shared Object                                   Symbol
> > > # ........  ...........  ...................  .......................................
> > > #
> > >     20.41%      kswapd0  [kernel.kallsyms]    [k] shrink_slab
> > >                 |
> > >                 --- shrink_slab
> > >                    |          
> > >                    |--99.91%-- kswapd
> > >                    |          kthread
> > >                    |          kernel_thread_helper
> > >                     --0.09%-- [...]
> > > 
> > 
> > Ok. I can't see how the patch "mm: vmscan: reclaim order-0 and use
> > compaction instead of lumpy reclaim" is related unless we are seeing
> > two problems that happen to manifest in a similar manner.
> > 
> > However, there were a number of changes made to dcache in particular
> > for 2.6.38. Specifically thinks like dentry_kill use trylock and is
> > happy to loop around if it fails to acquire anything. See things like
> > this for example;
> 
> OK, so for this, I tried a 2.6.37 kernel.  It doesn't work very well,
> networking is hosed for no reason I can see (probably systemd / cgroups
> problems).
> 
> However, it runs enough for me to say that the tar proceeds to
> completion in a non-PREEMPT kernel.  (I tried several times for good
> measure).  That makes this definitely a regression of some sort, but it
> doesn't definitively identify the dcache code ... it could be an ext4
> bug that got introduced in 2.6.38 either.
> 

True, it could be any shrinker and dcache is just a guess.

> > <SNIP>
> > 
> > Way hey, cgroups are also in the mix. How jolly.
> > 
> > Is systemd a common element of the machines hitting this bug by any
> > chance?
> 
> Well, yes, the bug report is against FC15, which needs cgroups for
> systemd.
> 

Ok although we do not have direct evidence that it's the problem yet. A
broken shrinker could just mean we are also trying to aggressively
reclaim in cgroups.

> > The remaining traces seem to be follow-on damage related to the three
> > issues of "shrinkers are bust in some manner" causing "we are not
> > getting over the min watermark" and as a side-show "we are spending lots
> > of time doing something unspecified but unhelpful in cgroups".
> 
> Heh, well find a way for me to verify this: I can't turn off cgroups
> because systemd then won't work and the machine won't boot ...
> 

Same testcase, same kernel but a distro that is not using systemd to
verify if cgroups are the problem. Not ideal I know. When I'm back
online Tuesday, I'll try reproducing this on a !Fedora distribution. In
the meantime, the following untested hatchet job might spit out
which shrinker we are getting stuck in. It is also breaking out of
the shrink_slab loop so it'd even be interesting to see if the bug
is mitigated in any way.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c74a501..ed99104 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -225,6 +225,7 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 {
 	struct shrinker *shrinker;
 	unsigned long ret = 0;
+	unsigned long shrink_expired = jiffies + HZ;
 
 	if (scanned == 0)
 		scanned = SWAP_CLUSTER_MAX;
@@ -270,6 +271,14 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 								gfp_mask);
 			if (shrink_ret == -1)
 				break;
+			if (time_after(jiffies, shrink_expired)) {
+				printk(KERN_WARNING "Slab shrinker %p gone mental"
+						" comm=%s nr=%ld\n",
+					shrinker->shrink,
+					current->comm,
+					shrinker->nr);
+				break;
+			}
 			if (shrink_ret < nr_before)
 				ret += nr_before - shrink_ret;
 			count_vm_events(SLABS_SCANNED, this_scan);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
