Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id B079F6B0118
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:31:15 -0400 (EDT)
Received: by mail-yh0-f44.google.com with SMTP id f10so3053226yha.3
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 16:31:15 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id h47si28612732yhd.116.2014.06.10.16.31.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 16:31:15 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 10 Jun 2014 17:31:13 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 82AC71FF0046
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 17:31:10 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5ANUARU62849210
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 01:30:10 +0200
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5ANVAjb021371
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 17:31:10 -0600
Date: Tue, 10 Jun 2014 16:30:59 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: NUMA topology question wrt. d4edc5b6
Message-ID: <20140610233059.GA24463@linux.vnet.ibm.com>
References: <20140521200451.GB5755@linux.vnet.ibm.com>
 <537E6285.3050000@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1406091436090.5271@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1406091436090.5271@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, benh@kernel.crashing.org, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, nfont@linux.vnet.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Anton Blanchard <anton@samba.org>, Dave Hansen <dave@sr71.net>, "linuxppc-dev@lists.ozlabs.org list" <linuxppc-dev@lists.ozlabs.org>, Linux MM <linux-mm@kvack.org>

On 09.06.2014 [14:38:26 -0700], David Rientjes wrote:
> On Fri, 23 May 2014, Srivatsa S. Bhat wrote:
> 
> > diff --git a/arch/powerpc/include/asm/topology.h b/arch/powerpc/include/asm/topology.h
> > index c920215..58e6469 100644
> > --- a/arch/powerpc/include/asm/topology.h
> > +++ b/arch/powerpc/include/asm/topology.h
> > @@ -18,6 +18,7 @@ struct device_node;
> >   */
> >  #define RECLAIM_DISTANCE 10
> >  
> > +#include <linux/nodemask.h>
> >  #include <asm/mmzone.h>
> >  
> >  static inline int cpu_to_node(int cpu)
> > @@ -30,7 +31,7 @@ static inline int cpu_to_node(int cpu)
> >  	 * During early boot, the numa-cpu lookup table might not have been
> >  	 * setup for all CPUs yet. In such cases, default to node 0.
> >  	 */
> > -	return (nid < 0) ? 0 : nid;
> > +	return (nid < 0) ? first_online_node : nid;
> >  }
> >  
> >  #define parent_node(node)	(node)
> 
> I wonder what would happen on ppc if we just returned NUMA_NO_NODE here 
> for cpus that have not been mapped (they shouldn't even be possible).  

Well, with my patch (Ben sent it to Linus in the last pull request, I
think), powerpc uses the generic per-cpu stuff, so this function is
gone. Dunno if it makes sense to initialize the per-cpu data to
NUMA_NO_NODE (rather than 0?).

For powerpc, it's a timing thing. We can call cpu_to_node() quite early,
and we may not have set up the mapping information yet.

> This would at least allow callers that do
> kmalloc_node(..., cpu_to_node(cpu)) to be allocated on the local cpu 
> rather than on a perhaps offline or remote node 0.
> 
> It would seem better to catch callers that do 
> cpu_to_node(<not-possible-cpu>) rather than blindly return an online node.

Agreed, but I've not seen such a case.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
