Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 201136B0031
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 04:57:43 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so4206578pab.21
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 01:57:42 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id sd3si8158585pbb.72.2014.02.08.01.57.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 08 Feb 2014 01:57:42 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id y10so4152149pdj.32
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 01:57:41 -0800 (PST)
Date: Sat, 8 Feb 2014 01:57:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140207054819.GC28952@lge.com>
Message-ID: <alpine.DEB.2.02.1402080154140.9668@chino.kir.corp.google.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com> <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com> <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com> <20140207054819.GC28952@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, 7 Feb 2014, Joonsoo Kim wrote:

> > It seems like a better approach would be to do this when a node is brought 
> > online and determine the fallback node based not on the zonelists as you 
> > do here but rather on locality (such as through a SLIT if provided, see 
> > node_distance()).
> 
> Hmm...
> I guess that zonelist is base on locality. Zonelist is generated using
> node_distance(), so I think that it reflects locality. But, I'm not expert
> on NUMA, so please let me know what I am missing here :)
> 

The zonelist is, yes, but I'm talking about memoryless and cpuless nodes.  
If your solution is going to become the generic kernel API that determines 
what node has local memory for a particular node, then it will have to 
support all definitions of node.  That includes nodes that consist solely 
of I/O, chipsets, networking, or storage devices.  These nodes may not 
have memory or cpus, so doing it as part of onlining cpus isn't going to 
be generic enough.  You want a node_to_mem_node() API for all possible 
node types (the possible node types listed above are straight from the 
ACPI spec).  For 99% of people, node_to_mem_node(X) is always going to be 
X and we can optimize for that, but any solution that relies on cpu online 
is probably shortsighted right now.

I think it would be much better to do this as a part of setting a node to 
be online.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
