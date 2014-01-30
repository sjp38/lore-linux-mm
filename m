Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id E04A56B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 11:26:54 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id n7so5334972qcx.30
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 08:26:54 -0800 (PST)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id e60si4914217qgf.32.2014.01.30.08.26.53
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 08:26:54 -0800 (PST)
Date: Thu, 30 Jan 2014 10:26:51 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <20140129223640.GA10101@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1401301017590.29392@nuc>
References: <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401240946530.12886@nuc> <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com> <20140124232902.GB30361@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com> <20140125001643.GA25344@linux.vnet.ibm.com> <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com> <20140125011041.GB25344@linux.vnet.ibm.com> <20140127055805.GA2471@lge.com>
 <20140128182947.GA1591@linux.vnet.ibm.com> <20140129223640.GA10101@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, cody@linux.vnet.ibm.com

On Wed, 29 Jan 2014, Nishanth Aravamudan wrote:

> exactly what the caller intends.
>
> int searchnode = node;
> if (node == NUMA_NO_NODE)
> 	searchnode = numa_mem_id();
> if (!node_present_pages(node))
> 	searchnode = local_memory_node(node);
>
> The difference in semantics from the previous is that here, if we have a
> memoryless node, rather than using the CPU's nearest NUMA node, we use
> the NUMA node closest to the requested one?

The idea here is that the page allocator will do the fallback to other
nodes. This check for !node_present should not be necessary. SLUB needs to
accept the page from whatever node the page allocator returned and work
with that.

The problem is the check for having a slab from the "right" node may fall
again after another attempt to allocate from the same node. SLUB will then
push the slab from the *wrong* node back to the partial lists and may
attempt another allocation that will again be successful but return memory
from another node. That way the partial lists from a particular node are
growing uselessly.

One way to solve this may be to check if memory is actually allocated
from the requested node and fallback to NUMA_NO_NODE (which will use the
last allocated slab) for future allocs if the page allocator returned
memory from a different node (unless GFP_THIS_NODE is set of course).
Otherwise we end up replicating  the page allocator logic in slub like in
slab. That is what I wanted to
avoid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
