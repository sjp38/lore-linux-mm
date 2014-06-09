Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFF36B00B0
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 17:48:00 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so2066034igb.5
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 14:48:00 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id a16si64960224igh.52.2014.06.09.14.47.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 14:47:59 -0700 (PDT)
Received: by mail-ie0-f171.google.com with SMTP id x19so1165825ier.30
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 14:47:59 -0700 (PDT)
Date: Mon, 9 Jun 2014 14:47:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Node 0 not necessary for powerpc?
In-Reply-To: <20140521195743.GA5755@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1406091447240.5271@chino.kir.corp.google.com>
References: <20140311195632.GA946@linux.vnet.ibm.com> <alpine.DEB.2.10.1403120839110.6865@nuc> <20140313164949.GC22247@linux.vnet.ibm.com> <20140519182400.GM8941@linux.vnet.ibm.com> <alpine.DEB.2.10.1405210915170.7859@gentwo.org> <20140521185812.GA5259@htj.dyndns.org>
 <20140521195743.GA5755@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Tejun Heo <htejun@gmail.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, benh@kernel.crashing.org, tony.luck@intel.com

On Wed, 21 May 2014, Nishanth Aravamudan wrote:

> For context: I was looking at why N_ONLINE was statically setting Node 0
> to be online, whether or not the topology is that way -- I've been
> getting several bugs lately where Node 0 is online, but has no CPUs and
> no memory on it, on powerpc. 
> 
> On powerpc, setup_per_cpu_areas calls into ___alloc_bootmem_node using
> NODE_DATA(cpu_to_node(cpu)).
> 
> Currently, cpu_to_node() in arch/powerpc/include/asm/topology.h does:
> 
>         /*
>          * During early boot, the numa-cpu lookup table might not have been
>          * setup for all CPUs yet. In such cases, default to node 0.
>          */
>         return (nid < 0) ? 0 : nid;
> 
> And so early at boot, if node 0 is not present, we end up accessing an
> unitialized NODE_DATA(). So this seems buggy (I'll contact the powerpc
> deveopers separately on that).
> 

I think what this really wants to do is NODE_DATA(cpu_to_mem(cpu)) and I 
thought ppc had the cpu-to-local-memory-node mappings correct?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
