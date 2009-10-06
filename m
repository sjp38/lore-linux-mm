Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 132146B0055
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 12:28:55 -0400 (EDT)
Subject: Re: [PATCH 11/11] hugetlb:  offload per node attribute
 registrations
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20091006160139.GT1656@one.firstfloor.org>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
	 <20091006031924.22576.35018.sendpatchset@localhost.localdomain>
	 <20091006160139.GT1656@one.firstfloor.org>
Content-Type: text/plain
Date: Tue, 06 Oct 2009 12:28:49 -0400
Message-Id: <1254846529.13943.69.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-10-06 at 18:01 +0200, Andi Kleen wrote:
> On Mon, Oct 05, 2009 at 11:19:24PM -0400, Lee Schermerhorn wrote:
> > [PATCH 11/11] hugetlb:  offload [un]registration of sysfs attr to worker thread
> > 
> > Against:  2.6.31-mmotm-090925-1435
> > 
> > New in V6
> > 
> > V7:  + remove redundant check for memory{ful|less} node from 
> >        node_hugetlb_work().  Rely on [added] return from
> >        hugetlb_register_node() to differentiate between transitions
> >        to/from memoryless state.
> > 
> > This patch offloads the registration and unregistration of per node
> > hstate sysfs attributes to a worker thread rather than attempt the
> > allocation/attachment or detachment/freeing of the attributes in 
> > the context of the memory hotplug handler.
> 
> Why this change? The hotplug handler should be allowed to sleep, shouldn't it?

Andy:  perhaps it can.  I'm not familiar with hotplug, so I followed a
pattern found elsewhere.  I created a separate patch in case someone
familiar with this area says I don't need it.


> 
> > N.B.,  Only tested build, boot, libhugetlbfs regression.
> >        i.e., no memory hotplug testing.
> 
> Yes, you have to because I know for a fact it's broken (outside your code) :)

We need to be able to remove all memory from a node without that node
disappearing [as I think it does on x86_64] to even exercise this code.
I think some ia64 platforms can do that, perhaps others.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
