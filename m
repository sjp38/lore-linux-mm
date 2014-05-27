Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 528FA6B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 19:44:29 -0400 (EDT)
Received: by mail-yk0-f174.google.com with SMTP id 9so7731986ykp.5
        for <linux-mm@kvack.org>; Tue, 27 May 2014 16:44:29 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id u56si27858361yhg.74.2014.05.27.16.44.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 27 May 2014 16:44:28 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 27 May 2014 17:44:27 -0600
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 69B6538C804A
	for <linux-mm@kvack.org>; Tue, 27 May 2014 19:44:24 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4RNiO9J4260114
	for <linux-mm@kvack.org>; Tue, 27 May 2014 23:44:24 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4RNiNHR015683
	for <linux-mm@kvack.org>; Tue, 27 May 2014 19:44:24 -0400
Date: Tue, 27 May 2014 16:44:20 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH v2 1/2] powerpc: numa: enable USE_PERCPU_NUMA_NODE_ID
Message-ID: <20140527234420.GE4104@linux.vnet.ibm.com>
References: <20140516233945.GI8941@linux.vnet.ibm.com>
 <20140519181423.GL8941@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140519181423.GL8941@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, Ben Herrenschmidt <benh@kernel.crashing.org>

On 19.05.2014 [11:14:23 -0700], Nishanth Aravamudan wrote:
> Hi Andrew,
> 
> I found one issue with my patch, fixed below...
> 
> On 16.05.2014 [16:39:45 -0700], Nishanth Aravamudan wrote:
> > Based off 3bccd996 for ia64, convert powerpc to use the generic per-CPU
> > topology tracking, specifically:
> >     
> > 	initialize per cpu numa_node entry in start_secondary
> >     	remove the powerpc cpu_to_node()
> >     	define CONFIG_USE_PERCPU_NUMA_NODE_ID if NUMA
> >     
> > Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> 
> <snip>
> 
> > diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
> > index e2a4232..b95be24 100644
> > --- a/arch/powerpc/kernel/smp.c
> > +++ b/arch/powerpc/kernel/smp.c
> > @@ -750,6 +750,11 @@ void start_secondary(void *unused)
> >  	}
> >  	traverse_core_siblings(cpu, true);
> >  
> > +	/*
> > +	 * numa_node_id() works after this.
> > +	 */
> > +	set_numa_node(numa_cpu_lookup_table[cpu]);
> > +
> 
> Similar change is needed for the boot CPU. Update patch:
> 
> 
> powerpc: numa: enable USE_PERCPU_NUMA_NODE_ID
>     
> Based off 3bccd996 for ia64, convert powerpc to use the generic per-CPU
> topology tracking, specifically:
>     
>     initialize per cpu numa_node entry in start_secondary
>     remove the powerpc cpu_to_node()
>     define CONFIG_USE_PERCPU_NUMA_NODE_ID if NUMA
>     
> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

Ping on this and patch 2/2. Ben, would you be willing to pull these into
your -next branch so they'd get some testing?

http://patchwork.ozlabs.org/patch/350368/
http://patchwork.ozlabs.org/patch/349838/

Without any further changes, these two help quite a bit with the slab
consumption on CONFIG_SLUB kernels when memoryless nodes are present.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
