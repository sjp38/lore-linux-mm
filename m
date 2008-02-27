Date: Wed, 27 Feb 2008 17:09:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
Message-Id: <20080227170945.e3bd9a87.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.00.0802262349090.21857@chino.kir.corp.google.com>
References: <47C4F9C0.5010607@linux.vnet.ibm.com>
	<alpine.DEB.1.00.0802262201390.1613@chino.kir.corp.google.com>
	<20080227160746.425E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<alpine.DEB.1.00.0802262315030.11433@chino.kir.corp.google.com>
	<20080227165139.18e5933e.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.00.0802262349090.21857@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2008 23:56:39 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 27 Feb 2008, KAMEZAWA Hiroyuki wrote:
> 
> > Hmm, but kswapd, which is main worker of page reclaiming, is per-node.
> > And reclaim is done based on zone.
> > per-zone/per-node throttling seems to make sense.
> > 
> 
> That's another argument for not introducing the sysctl; the number of 
> nodes and zones are a static property of the machine that cannot change 
> without a reboot (numa=fake, mem=, introducing movable zones, etc).  We 
> don't have node hotplug that can suddenly introduce additional zones from 
> which to reclaim.

Hmm, do you know there is already zone-hotplug ? ;)
(Means, onlining new memory in new zone increase the # of zones.
 Now, in our system, possible-node turns to be online nodes.)

> My point was that there doesn't appear to be any use case for tuning this 
> via a sysctl that isn't simply attempting to workaround some other reclaim 
> problem when the VM is stressed.  If that's agreed upon, then deciding 
> between a config option that is either per-cpu or per-node should be based 
> on the benchmarks that you've run.  At this time, it appears that per-node 
> is the more advantageous.
>
I agree that what is the best is based on benchmark.
I like per-node, now.
I believe there will be some change when RvR's spilit-LRU patches are applied.
 
> > I know his environment has 4cpus per node but throttle to 3 was the best
> > number in his measurement. Then it seems num-per-cpu is excessive.
> > (At least, ratio(%) is better.)
> 
> That seems to indicate that the NUMA topology is more important than lock 
> contention for the reclaim throttle.
> 
I hear that there is also I/O bottle-neck for page reclaiming, at last.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
