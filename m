Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 18B036B0BE1
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 17:55:40 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id p29so16877961ote.3
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 14:55:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t204-v6sor14388003oif.64.2018.11.16.14.55.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 14:55:38 -0800 (PST)
MIME-Version: 1.0
References: <20181114224921.12123-2-keith.busch@intel.com> <20181115135710.GD19286@bombadil.infradead.org>
 <20181115145920.GG11416@localhost.localdomain> <20181115203654.GA28246@bombadil.infradead.org>
In-Reply-To: <20181115203654.GA28246@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 16 Nov 2018 14:55:27 -0800
Message-ID: <CAPcyv4iBL74HN5N+f1x_BxGJ4xjk7rb8V-DGLHQEtG7zkeWKpA@mail.gmail.com>
Subject: Re: [PATCH 1/7] node: Link memory nodes to their compute nodes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, Nov 15, 2018 at 12:37 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Nov 15, 2018 at 07:59:20AM -0700, Keith Busch wrote:
> > On Thu, Nov 15, 2018 at 05:57:10AM -0800, Matthew Wilcox wrote:
> > > On Wed, Nov 14, 2018 at 03:49:14PM -0700, Keith Busch wrote:
> > > > Memory-only nodes will often have affinity to a compute node, and
> > > > platforms have ways to express that locality relationship.
> > > >
> > > > A node containing CPUs or other DMA devices that can initiate memory
> > > > access are referred to as "memory iniators". A "memory target" is a
> > > > node that provides at least one phyiscal address range accessible to a
> > > > memory initiator.
> > >
> > > I think I may be confused here.  If there is _no_ link from node X to
> > > node Y, does that mean that node X's CPUs cannot access the memory on
> > > node Y?  In my mind, all nodes can access all memory in the system,
> > > just not with uniform bandwidth/latency.
> >
> > The link is just about which nodes are "local". It's like how nodes have
> > a cpulist. Other CPUs not in the node's list can acces that node's memory,
> > but the ones in the mask are local, and provide useful optimization hints.
>
> So ... let's imagine a hypothetical system (I've never seen one built like
> this, but it doesn't seem too implausible).  Connect four CPU sockets in
> a square, each of which has some regular DIMMs attached to it.  CPU A is
> 0 hops to Memory A, one hop to Memory B and Memory C, and two hops from
> Memory D (each CPU only has two "QPI" links).  Then maybe there's some
> special memory extender device attached on the PCIe bus.  Now there's
> Memory B1 and B2 that's attached to CPU B and it's local to CPU B, but
> not as local as Memory B is ... and we'd probably _prefer_ to allocate
> memory for CPU A from Memory B1 than from Memory D.  But ... *mumble*,
> this seems hard.
>
> I understand you're trying to reflect what the HMAT table is telling you,
> I'm just really fuzzy on who's ultimately consuming this information
> and what decisions they're trying to drive from it.

The singular "local" is a limitation of the HMAT, but I would expect
the Linux translation of "local" would allow for multiple initiators
that can achieve some semblance of the "best" performance. Anything
less than best is going to have a wide range of variance and will
likely devolve to looking at the platform firmware data table
directly. The expected 80% case is software wants to be able to ask
"which CPUs should I run on to get the best access to this memory?"
