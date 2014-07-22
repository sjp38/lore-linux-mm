Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id D7B346B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 21:17:01 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id x19so7574864ier.34
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 18:17:01 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id ao2si33051748igc.44.2014.07.21.18.17.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 18:17:01 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id tp5so7546421ieb.14
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 18:17:01 -0700 (PDT)
Date: Mon, 21 Jul 2014 18:16:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140722010305.GJ4156@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1407211809140.9778@chino.kir.corp.google.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com> <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com> <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com> <20140207054819.GC28952@lge.com> <alpine.DEB.2.02.1402080154140.9668@chino.kir.corp.google.com> <20140210010936.GA12574@lge.com>
 <20140722010305.GJ4156@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Mon, 21 Jul 2014, Nishanth Aravamudan wrote:

> Sorry for bringing up this old thread again, but I had a question for
> you, David. node_to_mem_node(), which does seem like a useful API,
> doesn't seem like it can just node_distance() solely, right? Because
> that just tells us the relative cost (or so I think about it) of using
> resources from that node. But we also need to know if that node itself
> has memory, etc. So using the zonelists is required no matter what? And
> upon memory hotplug (or unplug), the topology can change in a way that
> affects things, so node online time isn't right either?
> 

I think there's two use cases of interest:

 - allocating from a memoryless node where numa_node_id() is memoryless, 
   and

 - using node_to_mem_node() for a possibly-memoryless node for kmalloc().

I believe the first should have its own node_zonelist[0], whether it's 
memoryless or not, that points to a list of zones that start with those 
with the smallest distance.  I think its own node_zonelist[1], for 
__GFP_THISNODE allocations, should point to the node with present memory 
that has the smallest distance.

For sure node_zonelist[0] cannot be NULL since things like 
first_online_pgdat() would break and it should be unnecessary to do 
node_to_mem_node() for all allocations when CONFIG_HAVE_MEMORYLESS_NODES 
since the zonelists should already be defined properly.  All nodes, 
regardless of whether they have memory or not, should probably end up 
having a struct pglist_data unless there's a reason for another level of 
indirection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
