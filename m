Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4DDv5mD270464
	for <linux-mm@kvack.org>; Fri, 13 May 2005 09:57:05 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4DDv4LY258826
	for <linux-mm@kvack.org>; Fri, 13 May 2005 07:57:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4DDv4iR017632
	for <linux-mm@kvack.org>; Fri, 13 May 2005 07:57:04 -0600
Subject: Re: NUMA aware slab allocator V2
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0505130436380.4500@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
	 <20050512000444.641f44a9.akpm@osdl.org>
	 <Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
	 <20050513000648.7d341710.akpm@osdl.org>
	 <Pine.LNX.4.58.0505130411300.4500@schroedinger.engr.sgi.com>
	 <20050513043311.7961e694.akpm@osdl.org>
	 <Pine.LNX.4.58.0505130436380.4500@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 13 May 2005 06:56:53 -0700
Message-Id: <1115992613.7129.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-05-13 at 04:37 -0700, Christoph Lameter wrote:
> On Fri, 13 May 2005, Andrew Morton wrote:
> > > The definition for the number of NUMA nodes is dependent on
> > > CONFIG_FLATMEM instead of CONFIG_NUMA in mm.
> > > CONFIG_FLATMEM is not set on ppc64 because CONFIG_DISCONTIG is set! And
> > > consequently nodes exist in a non NUMA config.
> >
> > I was testing 2.6.12-rc4 base.
> 
> There we still have the notion of nodes depending on CONFIG_DISCONTIG and
> not on CONFIG_NUMA. The node stuff needs to be
> 
> #ifdef CONFIG_FLATMEM
> 
> or
> 
> #ifdef CONFIG_DISCONTIG

I think I found the problem.  Could you try the attached patch?

As I said before FLATMEM is really referring to things like the
mem_map[] or max_mapnr.

CONFIG_NEED_MULTIPLE_NODES is what gets turned on for DISCONTIG or for
NUMA.  We'll slowly be removing all of the DISCONTIG cases, so
eventually it will merge back to be one with NUMA.

-- Dave

--- clean/include/linux/numa.h.orig	2005-05-13 06:44:56.000000000 -0700
+++ clean/include/linux/numa.h	2005-05-13 06:52:05.000000000 -0700
@@ -3,7 +3,7 @@
 
 #include <linux/config.h>
 
-#ifndef CONFIG_FLATMEM
+#ifdef CONFIG_NEED_MULTIPLE_NODES
 #include <asm/numnodes.h>
 #endif
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
