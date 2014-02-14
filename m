Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id E704A6B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 19:12:39 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id c9so19329322qcz.31
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:12:39 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id 6si2477656qgy.186.2014.02.13.16.12.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 16:12:39 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 13 Feb 2014 17:12:38 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B69EC3E40044
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:12:34 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1E0C88C131370
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:12:13 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1E0CDWP020415
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:12:14 -0700
Date: Thu, 13 Feb 2014 16:11:56 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] powerpc: enable CONFIG_HAVE_MEMORYLESS_NODES
Message-ID: <20140214001156.GA1651@linux.vnet.ibm.com>
References: <20140128183457.GA9315@linux.vnet.ibm.com>
 <20140213214131.GB12409@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402131444440.13899@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402131444440.13899@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Anton Blanchard <anton@samba.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On 13.02.2014 [14:45:49 -0800], David Rientjes wrote:
> On Thu, 13 Feb 2014, Nishanth Aravamudan wrote:
> 
> > > Anton Blanchard found an issue with an LPAR that had no memory in Node
> > > 0. Christoph Lameter recommended, as one possible solution, to use
> > > numa_mem_id() for locality of the nearest memory node-wise. However,
> > > numa_mem_id() [and the other related APIs] are only useful if
> > > CONFIG_HAVE_MEMORYLESS_NODES is set. This is only the case for ia64
> > > currently, but clearly we can have memoryless nodes on ppc64. Add the
> > > Kconfig option and define it to be the same value as CONFIG_NUMA.
> > > 
> > > On the LPAR in question, which was very inefficiently using slabs, this
> > > took the slab consumption at boot from roughly 7GB to roughly 4GB.
> > 
> > Err, this should have been
> > 
> > Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> > 
> > !
> > 
> > Sorry about that Ben!
> >     
> > > ---
> > > Ben, the only question I have wrt this change is if it's appropriate to
> > > change it for all powerpc configs (that have NUMA on)?
> > > 
> 
> I'm suspecting that Ben will request that the proper set_numa_mem() calls 
> are done for ppc init to make this actually do anything other than return 
> numa_mem_id() == numa_node_id().

You're right, thanks for pointing this out. I could have sworn that in
my previous debugging I saw proper NUMA information, but perhaps it was
just correct based upon the system configuration.

> > > diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> > > index 25493a0..bb2d5fe 100644
> > > --- a/arch/powerpc/Kconfig
> > > +++ b/arch/powerpc/Kconfig
> > > @@ -447,6 +447,9 @@ config NODES_SHIFT
> > >  	default "4"
> > >  	depends on NEED_MULTIPLE_NODES
> > >  
> > > +config HAVE_MEMORYLESS_NODES
> > > +	def_bool NUMA
> > > +
> > >  config ARCH_SELECT_MEMORY_MODEL
> > >  	def_bool y
> > >  	depends on PPC64
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
