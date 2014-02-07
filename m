Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 446D16B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 00:48:24 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so2704574pdj.32
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 21:48:23 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id m1si3601764pbe.238.2014.02.06.21.48.20
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 21:48:22 -0800 (PST)
Date: Fri, 7 Feb 2014 14:48:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140207054819.GC28952@lge.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
 <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, Feb 06, 2014 at 12:52:11PM -0800, David Rientjes wrote:
> On Thu, 6 Feb 2014, Joonsoo Kim wrote:
> 
> > From bf691e7eb07f966e3aed251eaeb18f229ee32d1f Mon Sep 17 00:00:00 2001
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Date: Thu, 6 Feb 2014 17:07:05 +0900
> > Subject: [RFC PATCH 2/3 v2] topology: support node_numa_mem() for
> > determining the
> >  fallback node
> > 
> > We need to determine the fallback node in slub allocator if the allocation
> > target node is memoryless node. Without it, the SLUB wrongly select
> > the node which has no memory and can't use a partial slab, because of node
> > mismatch. Introduced function, node_numa_mem(X), will return
> > a node Y with memory that has the nearest distance. If X is memoryless
> > node, it will return nearest distance node, but, if
> > X is normal node, it will return itself.
> > 
> > We will use this function in following patch to determine the fallback
> > node.
> > 
> 
> I like the approach and it may fix the problem today, but it may not be 
> sufficient in the future: nodes may not only be memoryless but they may 
> also be cpuless.  It's possible that a node can only have I/O, networking, 
> or storage devices and we can define affinity for them that is remote from 
> every cpu and/or memory by the ACPI specification.
> 
> It seems like a better approach would be to do this when a node is brought 
> online and determine the fallback node based not on the zonelists as you 
> do here but rather on locality (such as through a SLIT if provided, see 
> node_distance()).

Hmm...
I guess that zonelist is base on locality. Zonelist is generated using
node_distance(), so I think that it reflects locality. But, I'm not expert
on NUMA, so please let me know what I am missing here :)

> Also, the names aren't very descriptive: {get,set}_numa_mem() doesn't make 
> a lot of sense in generic code.  I'd suggest something like 
> node_to_mem_node().

It's much better!
If this patch eventually will be needed, I will update it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
