Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F0A0E6B0055
	for <linux-mm@kvack.org>; Wed, 20 May 2009 22:43:30 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4L2i9rW003878
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 21 May 2009 11:44:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4115745DE5C
	for <linux-mm@kvack.org>; Thu, 21 May 2009 11:44:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 151E645DE5B
	for <linux-mm@kvack.org>; Thu, 21 May 2009 11:44:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EB20B1DB8043
	for <linux-mm@kvack.org>; Thu, 21 May 2009 11:44:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 77EF61DB8037
	for <linux-mm@kvack.org>; Thu, 21 May 2009 11:44:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <20090520140045.GA29447@sgi.com>
References: <20090519102003.4EAB.A69D9226@jp.fujitsu.com> <20090520140045.GA29447@sgi.com>
Message-Id: <20090521090549.63B5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 21 May 2009 11:44:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, May 19, 2009 at 11:53:44AM +0900, KOSAKI Motohiro wrote:
> > Hi
> > 
> > > > Current linux policy is, zone_reclaim_mode is enabled by default if the machine
> > > > has large remote node distance. it's because we could assume that large distance 
> > > > mean large server until recently.
> > > > 
> > > > Unfortunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
> > > > memory controller. IOW it's seen as NUMA from software view.
> > > > 
> > > > Some Core i7 machine has large remote node distance, but zone_reclaim don't
> > > > fit desktop and small file server. it cause performance degression.
> > > > 
> > > > Thus, zone_reclaim == 0 is better by default if the machine is small.
> > > 
> > > What if I had a node 0 with 32GB or 128GB of memory.  In that case,
> > > we would have 3GB for DMA32, 125GB for Normal and then a node 1 with
> > > 128GB.  I would suggest that zone reclaim would perform normally and
> > > be beneficial.
> > > 
> > > You are unfairly classifying this as a size of machine problem when it is
> > > really a problem with the underlying zone reclaim code being triggered
> > > due to imbalanced node/zones, part of which is due to a single node
> > > having multiple zones and those multiple zones setting up the conditions
> > > for extremely agressive reclaim.  In other words, you are putting a
> > > bandage in place to hide a problem on your particular hardware.
> > > 
> > > Can RECLAIM_DISTANCE be adjusted so your Ci7 boxes are no longer caught?
> > > Aren't 4 node Ci7 boxes soon to be readily available?  How are your apps
> > > different from my apps in that you are not impacted by node locality?
> > > Are you being too insensitive to node locality?  Conversely am I being
> > > too sensitive?
> > > 
> > > All that said, I would not stop this from going in.  I just think the
> > > selection criteria is rather random.  I think we know the condition we
> > > are trying to avoid which is a small Normal zone on one node and a larger
> > > Normal zone on another causing zone reclaim to be overly agressive.
> > > I don't know how to quantify "small" versus "large".  I would suggest
> > > that a node 0 with 16 or more GB should have zone reclaim on by default
> > > as well.  Can that be expressed in the selection criteria.
> > 
> > I post my opinion as another mail. please see it.
> 
> I don't think you addressed my actual question.  How much of this is
> a result of having a node where 1/4 of the memory is in the 'Normal'
> zone and 3/4 is in the DMA32 zone?  How much is due to the imbalance
> between Node 0 'Normal' and Node 1 'Normal'?  Shouldn't that type of
> sanity check be used for turning on zone reclaim instead of some random
> number of nodes.

I can't catch up your message. Can you post your patch?
Can you explain your sanity check?

Now, I decide to remove "nr_online_nodes >= 4" condition.
Apache regression is really non-sense.

> Even with 128 nodes and 256 cpus, I _NEVER_ see the
> system swapping out before allocating off node so I can certainly not
> reproduce the situation you are seeing.

hmhm. but I don't think we can assume hpc workload.


> 
> The imbalance I have seen was when I had two small memory nodes and two
> large memory nodes and then oversubscribed memory.  In that situation,
> I noticed that the apps on the small memory nodes were more frequently
> impacted.  This unfairness made sense to me and seemed perfectly
> reasonable.


The node imbalancing is ok. example, typical linux init script makes many deamon process
to node0, we can't avoid it and it don't make strange behavior.

but zone imbalancing is bad. I don't want discuss all item again. but you
can google about inter zone reclaim issue instead.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
