Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id CD7C36B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 21:03:14 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id tp5so7528532ieb.37
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 18:03:14 -0700 (PDT)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id dy5si32990723igb.58.2014.07.21.18.03.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 18:03:14 -0700 (PDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 21 Jul 2014 19:03:13 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 84D723E4003B
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 19:03:10 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6LMxSn262259304
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 00:59:28 +0200
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6M1390h006038
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 19:03:10 -0600
Date: Mon, 21 Jul 2014 18:03:05 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140722010305.GJ4156@linux.vnet.ibm.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
 <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.02.1402080154140.9668@chino.kir.corp.google.com>
 <20140210010936.GA12574@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140210010936.GA12574@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 10.02.2014 [10:09:36 +0900], Joonsoo Kim wrote:
> On Sat, Feb 08, 2014 at 01:57:39AM -0800, David Rientjes wrote:
> > On Fri, 7 Feb 2014, Joonsoo Kim wrote:
> > 
> > > > It seems like a better approach would be to do this when a node is brought 
> > > > online and determine the fallback node based not on the zonelists as you 
> > > > do here but rather on locality (such as through a SLIT if provided, see 
> > > > node_distance()).
> > > 
> > > Hmm...
> > > I guess that zonelist is base on locality. Zonelist is generated using
> > > node_distance(), so I think that it reflects locality. But, I'm not expert
> > > on NUMA, so please let me know what I am missing here :)
> > > 
> > 
> > The zonelist is, yes, but I'm talking about memoryless and cpuless nodes.  
> > If your solution is going to become the generic kernel API that determines 
> > what node has local memory for a particular node, then it will have to 
> > support all definitions of node.  That includes nodes that consist solely 
> > of I/O, chipsets, networking, or storage devices.  These nodes may not 
> > have memory or cpus, so doing it as part of onlining cpus isn't going to 
> > be generic enough.  You want a node_to_mem_node() API for all possible 
> > node types (the possible node types listed above are straight from the 
> > ACPI spec).  For 99% of people, node_to_mem_node(X) is always going to be 
> > X and we can optimize for that, but any solution that relies on cpu online 
> > is probably shortsighted right now.
> > 
> > I think it would be much better to do this as a part of setting a node to 
> > be online.
> 
> Okay. I got your point.
> I will change it to rely on node online if this patch is really needed.

Sorry for bringing up this old thread again, but I had a question for
you, David. node_to_mem_node(), which does seem like a useful API,
doesn't seem like it can just node_distance() solely, right? Because
that just tells us the relative cost (or so I think about it) of using
resources from that node. But we also need to know if that node itself
has memory, etc. So using the zonelists is required no matter what? And
upon memory hotplug (or unplug), the topology can change in a way that
affects things, so node online time isn't right either?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
