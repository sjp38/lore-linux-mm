Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k1NIG3JK004197
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 13:16:03 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k1NIG3St235196
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 13:16:03 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k1NIG2ki017321
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 13:16:03 -0500
Subject: Re: [PATCH 4/7] ppc64 - Specify amount of kernel memory at boot
	time
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0602231740410.24093@skynet.skynet.ie>
References: <20060217141552.7621.74444.sendpatchset@skynet.csn.ul.ie>
	 <20060217141712.7621.49906.sendpatchset@skynet.csn.ul.ie>
	 <1140196618.21383.112.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0602211445160.4335@skynet.skynet.ie>
	 <1140543359.8693.32.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0602221625100.2801@skynet.skynet.ie>
	 <1140712969.8697.33.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0602231646530.24093@skynet.skynet.ie>
	 <1140716304.8697.53.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0602231740410.24093@skynet.skynet.ie>
Content-Type: text/plain
Date: Thu, 23 Feb 2006 10:15:55 -0800
Message-Id: <1140718555.8697.73.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thu, 2006-02-23 at 18:01 +0000, Mel Gorman wrote:
> On Thu, 23 Feb 2006, Dave Hansen wrote:
> > OK, back to the hapless system admin using kernelcore. They have a
> > 4-node system with 2GB of RAM in each node for 8GB total.  They use
> > kernelcore=1GB.  They end up with 4x1GB ZONE_DMA and 4x1GB
> > ZONE_EASYRCLM.  Perfect.  You can safely remove 4GB of RAM.
> >
> > Now, imagine that the machine has been heavily used for a while, there
> > is only 1 node's memory available, but CPUs are available in the same
> > places as before.  So, you start up your partition again have 8GB of
> > memory in one node.  Same kernelcore=1GB option.  You get 1x7GB ZONE_DMA
> > and 1x1GB ZONE_EASYRCLM.  I'd argue this is going to be a bit of a
> > surprise to the poor admin.
> >
> 
> That sort of surprise is totally unacceptable but the behaviour of 
> kernelcore needs to be consistent on both the x86 and the ppc (any any 
> other ar. How about;
> 
> 1. kernelcore=X determines the total amount of memory for !ZONE_EASYRCLM
>     (be it ZONE_DMA, ZONE_NORMAL or ZONE_HIGHMEM)

Sounds reasonable.  But, if you're going to do that, should we just make
it the opposite and explicitly be easy_reclaim_mem=?  Do we want the
limit to be set as "I need this much kernel memory", or "I want this
much removable memory".  I dunno.

> 2. For every node that can have ZONE_EASYRCLM, split the kernelcore across
>     the nodes as a percentage of the node size
> 
>     Example: 4 nodes, 1 GiB each, kernelcore=512MB
>  		node 0 ZONE_DMA = 128MB
>  		node 1 ZONE_DMA = 128MB
>  		node 2 ZONE_DMA = 128MB
>  		node 3 ZONE_DMA = 128MB
> 
>  	    2 nodes, 3GiB and 1GIB, kernelcore=512MB
>  		node 0 ZONE_DMA = 384
>  		node 1 ZONE_DMA = 128
> 
> It gets a bit more complex on NUMA for x86 because ZONE_NORMAL is 
> involved but the idea would essentially be the same.

Yes, chopping it up seems like the right thing (or as close as we can
get) to me.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
