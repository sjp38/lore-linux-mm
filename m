Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 033F36B0083
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 19:07:49 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so53116860igb.1
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 16:07:48 -0700 (PDT)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id d15si823764ioe.23.2015.04.08.16.07.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Apr 2015 16:07:48 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 8 Apr 2015 17:07:47 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 716C219D8026
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 16:58:49 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t38N7hud54460458
	for <linux-mm@kvack.org>; Wed, 8 Apr 2015 16:07:43 -0700
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t38N7g7O013762
	for <linux-mm@kvack.org>; Wed, 8 Apr 2015 17:07:43 -0600
Date: Wed, 8 Apr 2015 16:07:40 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] of: return NUMA_NO_NODE from fallback of_node_to_nid()
Message-ID: <20150408230740.GB53918@linux.vnet.ibm.com>
References: <20150408165920.25007.6869.stgit@buzz>
 <55255F84.6060608@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55255F84.6060608@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Grant Likely <grant.likely@linaro.org>, devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On 08.04.2015 [20:04:04 +0300], Konstantin Khlebnikov wrote:
> On 08.04.2015 19:59, Konstantin Khlebnikov wrote:
> >Node 0 might be offline as well as any other numa node,
> >in this case kernel cannot handle memory allocation and crashes.

Isn't the bug that numa_node_id() returned an offline node? That
shouldn't happen.

#ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
...
#ifndef numa_node_id
/* Returns the number of the current Node. */
static inline int numa_node_id(void)
{
        return raw_cpu_read(numa_node);
}
#endif
...
#else   /* !CONFIG_USE_PERCPU_NUMA_NODE_ID */

/* Returns the number of the current Node. */
#ifndef numa_node_id
static inline int numa_node_id(void)
{
        return cpu_to_node(raw_smp_processor_id());
}
#endif
...

So that's either the per-cpu numa_node value, right? Or the result of
cpu_to_node on the current processor.

> Example:
> 
> [    0.027133] ------------[ cut here ]------------
> [    0.027938] kernel BUG at include/linux/gfp.h:322!

This is 

VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));

in

alloc_pages_exact_node().

And based on the trace below, that's

__slab_alloc -> alloc

alloc_pages_exact_node
	<- alloc_slab_page
		<- allocate_slab
			<- new_slab
				<- new_slab_objects
					< __slab_alloc?

which is just passing the node value down, right? Which I think was
from:

        domain = kzalloc_node(sizeof(*domain) + (sizeof(unsigned int) * size),
                              GFP_KERNEL, of_node_to_nid(of_node));

?


What platform is this on, looks to be x86? qemu emulation of a
pathological topology? What was the topology?

Note that there is a ton of code that seems to assume node 0 is online.
I started working on removing this assumption myself and it just led
down a rathole (on power, we always have node 0 online, even if it is
memoryless and cpuless, as a result).

I am guessing this is just happening early in boot before the per-cpu
areas are setup? That's why (I think) x86 has the early_cpu_to_node()
function...

Or do you not have CONFIG_OF set? So isn't the only change necessary to
the include file, and it should just return first_online_node rather
than 0?

Ah and there's more of those node 0 assumptions :)

#define first_online_node       0
#define first_memory_node       0

if MAX_NUMODES == 1...

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
