Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDF06B05B5
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 15:36:57 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b4-v6so12479378plb.3
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 12:36:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h31si3922429pgl.482.2018.11.15.12.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Nov 2018 12:36:55 -0800 (PST)
Date: Thu, 15 Nov 2018 12:36:54 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/7] node: Link memory nodes to their compute nodes
Message-ID: <20181115203654.GA28246@bombadil.infradead.org>
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181115135710.GD19286@bombadil.infradead.org>
 <20181115145920.GG11416@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115145920.GG11416@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Nov 15, 2018 at 07:59:20AM -0700, Keith Busch wrote:
> On Thu, Nov 15, 2018 at 05:57:10AM -0800, Matthew Wilcox wrote:
> > On Wed, Nov 14, 2018 at 03:49:14PM -0700, Keith Busch wrote:
> > > Memory-only nodes will often have affinity to a compute node, and
> > > platforms have ways to express that locality relationship.
> > > 
> > > A node containing CPUs or other DMA devices that can initiate memory
> > > access are referred to as "memory iniators". A "memory target" is a
> > > node that provides at least one phyiscal address range accessible to a
> > > memory initiator.
> > 
> > I think I may be confused here.  If there is _no_ link from node X to
> > node Y, does that mean that node X's CPUs cannot access the memory on
> > node Y?  In my mind, all nodes can access all memory in the system,
> > just not with uniform bandwidth/latency.
> 
> The link is just about which nodes are "local". It's like how nodes have
> a cpulist. Other CPUs not in the node's list can acces that node's memory,
> but the ones in the mask are local, and provide useful optimization hints.

So ... let's imagine a hypothetical system (I've never seen one built like
this, but it doesn't seem too implausible).  Connect four CPU sockets in
a square, each of which has some regular DIMMs attached to it.  CPU A is
0 hops to Memory A, one hop to Memory B and Memory C, and two hops from
Memory D (each CPU only has two "QPI" links).  Then maybe there's some
special memory extender device attached on the PCIe bus.  Now there's
Memory B1 and B2 that's attached to CPU B and it's local to CPU B, but
not as local as Memory B is ... and we'd probably _prefer_ to allocate
memory for CPU A from Memory B1 than from Memory D.  But ... *mumble*,
this seems hard.

I understand you're trying to reflect what the HMAT table is telling you,
I'm just really fuzzy on who's ultimately consuming this information
and what decisions they're trying to drive from it.

> Would a node mask would be prefered to symlinks?

I don't have a strong opinion here, but what Dan says makes sense.
