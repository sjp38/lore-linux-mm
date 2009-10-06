Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 94A0F6B004F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 13:57:18 -0400 (EDT)
Subject: Re: [PATCH 11/11] hugetlb:  offload per node attribute
 registrations
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20091006164611.GW1656@one.firstfloor.org>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
	 <20091006031924.22576.35018.sendpatchset@localhost.localdomain>
	 <20091006160139.GT1656@one.firstfloor.org>
	 <1254846529.13943.69.camel@useless.americas.hpqcorp.net>
	 <20091006164611.GW1656@one.firstfloor.org>
Content-Type: text/plain
Date: Tue, 06 Oct 2009 13:57:11 -0400
Message-Id: <1254851831.13943.86.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-10-06 at 18:46 +0200, Andi Kleen wrote:
> On Tue, Oct 06, 2009 at 12:28:49PM -0400, Lee Schermerhorn wrote:
> > On Tue, 2009-10-06 at 18:01 +0200, Andi Kleen wrote:
> > > On Mon, Oct 05, 2009 at 11:19:24PM -0400, Lee Schermerhorn wrote:
> > > > [PATCH 11/11] hugetlb:  offload [un]registration of sysfs attr to worker thread
> > > > 
> > > > Against:  2.6.31-mmotm-090925-1435
> > > > 
> > > > New in V6
> > > > 
> > > > V7:  + remove redundant check for memory{ful|less} node from 
> > > >        node_hugetlb_work().  Rely on [added] return from
> > > >        hugetlb_register_node() to differentiate between transitions
> > > >        to/from memoryless state.
> > > > 
> > > > This patch offloads the registration and unregistration of per node
> > > > hstate sysfs attributes to a worker thread rather than attempt the
> > > > allocation/attachment or detachment/freeing of the attributes in 
> > > > the context of the memory hotplug handler.
> > > 
> > > Why this change? The hotplug handler should be allowed to sleep, shouldn't it?
> > 
> > Andy:  perhaps it can.  I'm not familiar with hotplug, so I followed a
> > pattern found elsewhere.  I created a separate patch in case someone
> > familiar with this area says I don't need it.
> 
> At least ACPI already puts it on a work queue.

Well, maybe we don't need it then.

> 
> > > 
> > > > N.B.,  Only tested build, boot, libhugetlbfs regression.
> > > >        i.e., no memory hotplug testing.
> > > 
> > > Yes, you have to because I know for a fact it's broken (outside your code) :)
> > 
> > We need to be able to remove all memory from a node without that node
> > disappearing [as I think it does on x86_64] to even exercise this code.
> 
> Are you sure? x86-64 doesn't support full node hotplug afaik.

I'll have to look.  At boot time on x86, we hide any memoryless nodes by
assigning their cpus to other nodes [currently just "round robin", but I
think this needs to change to distance based].  I recall seeing a memory
hotplug handler that moves the cpus when a node becomes memoryless.  If
it then unregisters the node [again, have to look.  no time now :(], the
earlier patches handle [un]registration of the per node attributes.  The
subject code only gets triggered if we have a node that becomes
memoryless as a result of hot remove but remains registered or that
starts memoryless and has memory hot-added. 


> 
> > I think some ia64 platforms can do that, perhaps others.
> 
> I've been thinking  about adding a hotadd regression test at boot time that
> only adds memory to nodes later after boot. That would at least test hotadd
> (and hot-removal is dubious anyways). 
> 
> That wouldn't be real node hotadd, but at least memory hotadd of all 
> to a node (which doesn't work currently)

That would be useful for testing the last 3 patches in the series, if
memoryless nodes can exist.  Otherwise, the per node attributes will
just come and go with the node itself.

> 
> -Andi
> 
> P.S.: You can add Reviewed-by for me to the other patches if you want.
> 

Thanks.  will do!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
