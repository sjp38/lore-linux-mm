Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8GJREnx003005
	for <linux-mm@kvack.org>; Sat, 16 Sep 2006 14:27:14 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k8GJPIDu53995393
	for <linux-mm@kvack.org>; Sat, 16 Sep 2006 12:25:18 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k8GJRDnB57045516
	for <linux-mm@kvack.org>; Sat, 16 Sep 2006 12:27:13 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1GOfom-0003J4-00
	for <linux-mm@kvack.org>; Sat, 16 Sep 2006 12:27:12 -0700
Date: Sat, 16 Sep 2006 12:21:16 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: A radical idea on how to solve various VM problems
Message-ID: <Pine.LNX.4.64.0609161210190.12677@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0609161227080.12713@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@vger.kernel.org
Cc: ak@suse.de, akpm@osdl.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

Ummm... Since we are using nodes for containers now how about
generalizing that and use such a node container for ZONE_DMA, ZONE_DMA32 
and ZONE_HIGHMEM?

In that case we will then have only one zone per node which simplifies the 
VM and allows optimizations in various kernel subsystems. (Note that AFAIK 
all NUMA systems have only a single zone in nodes > 0 anyways, the 
overhead for more zones is mostly unnecessary).

In that case also all system are "NUMA" systems (solving the #ifdef 
CONFIG_NUMA mess). We could give the special memory zones negative 
indexes.

F.e. a i386 UP/SMP system 

-2 DMA "node"
-1 Normal "node"
 0 Highmem "node"

A x86_64 UP/SMP system

-2 DMA "node"
-1 DMA32 "node"
0 Norma "node"

We can then add more nodes on top to get our containers and more nodes to 
the bottom to get more special allocation areas that we may need for some 
hardware. These could be added dynamically via node up node down 
functionality that already exists. So if we discover a strange DMA device
or broken DMA device with limited address range we could custom add a zone 
(no "node") that would satisfy that requirement.

The NUMA systems then become more nodes

i386 32 BIT NUMA

-2 DMA
-1 NORMAL
 0 HIGHMEM of node 0
 1 HIGHMEM of node 1
 ....

64 bit numa system with legacy allocation requirements

-2 DMA
-1 DMA32
 0 NORMAL of node 0
 1 NORMAL of node 1
 2 NORMAL of node 2

...

Pure 64 bit NUMA system (no special memory pools for
legacy DMA)

 0 NORMAL of node 0
 1 NORMAL of node 1
 ...

This also benefits the slab allocator. There is no need anymore for 
special DMA slabs. A GFP_DMA allocation is the same as a kmalloc_node 
allocation from the DMA "node".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
