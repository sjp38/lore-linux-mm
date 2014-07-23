Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 511816B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 20:43:42 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id l13so874300iga.1
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:43:42 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id bj5si1463089icc.51.2014.07.22.17.43.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 17:43:41 -0700 (PDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so872682igd.14
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:43:41 -0700 (PDT)
Date: Tue, 22 Jul 2014 17:43:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140722214311.GM4156@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1407221726540.15657@chino.kir.corp.google.com>
References: <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com> <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com> <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com> <20140207054819.GC28952@lge.com> <alpine.DEB.2.02.1402080154140.9668@chino.kir.corp.google.com> <20140210010936.GA12574@lge.com> <20140722010305.GJ4156@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1407211809140.9778@chino.kir.corp.google.com> <20140722214311.GM4156@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>

On Tue, 22 Jul 2014, Nishanth Aravamudan wrote:

> > I think there's two use cases of interest:
> > 
> >  - allocating from a memoryless node where numa_node_id() is memoryless, 
> >    and
> > 
> >  - using node_to_mem_node() for a possibly-memoryless node for kmalloc().
> > 
> > I believe the first should have its own node_zonelist[0], whether it's 
> > memoryless or not, that points to a list of zones that start with those 
> > with the smallest distance.
> 
> Ok, and that would be used for falling back in the appropriate priority?
> 

There's no real fallback since there's never a case when you can allocate 
on a memoryless node.  The zonelist defines the appropriate order in which 
to try to allocate from zones, so it depends on things like the 
numa_node_id() in alloc_pages_current() and whether the zonelist for a 
memoryless node is properly initialized or whether this needs to be 
numa_mem_id().  It depends on the intended behavior of calling 
alloc_pages_{node,vma}() with a memoryless node, the complexity of 
(re-)building the zonelists at bootstrap and for memory hotplug isn't a 
hotpath.

This choice would also impact MPOL_PREFERRED mempolicies when MPOL_F_LOCAL 
is set.

> > I think its own node_zonelist[1], for __GFP_THISNODE allocations,
> > should point to the node with present memory that has the smallest
> > distance.
> 
> And so would this, but with the caveat that we can fail here and don't
> go further? Semantically, __GFP_THISNODE then means "as close as
> physically possible ignoring run-time memory constraints". I say that
> because obviously we might get off-node memory without memoryless nodes,
> but that shouldn't be used to satisfy __GPF_THISNODE allocations.
> 

alloc_pages_current() substitutes any existing mempolicy for the default 
local policy when __GFP_THISNODE is set, and that would require local 
allocation.  That, currently, is numa_node_id() and not numa_mem_id().

The slab allocator already only uses __GFP_THISNODE for numa_mem_id() so 
it will allocate remotely anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
