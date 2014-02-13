Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 11D106B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:51:47 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so11133999pdj.39
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 14:51:47 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id zk9si3474786pac.144.2014.02.13.14.45.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 14:46:21 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so11379167pab.40
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 14:45:51 -0800 (PST)
Date: Thu, 13 Feb 2014 14:45:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] powerpc: enable CONFIG_HAVE_MEMORYLESS_NODES
In-Reply-To: <20140213214131.GB12409@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402131444440.13899@chino.kir.corp.google.com>
References: <20140128183457.GA9315@linux.vnet.ibm.com> <20140213214131.GB12409@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, Anton Blanchard <anton@samba.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Thu, 13 Feb 2014, Nishanth Aravamudan wrote:

> > Anton Blanchard found an issue with an LPAR that had no memory in Node
> > 0. Christoph Lameter recommended, as one possible solution, to use
> > numa_mem_id() for locality of the nearest memory node-wise. However,
> > numa_mem_id() [and the other related APIs] are only useful if
> > CONFIG_HAVE_MEMORYLESS_NODES is set. This is only the case for ia64
> > currently, but clearly we can have memoryless nodes on ppc64. Add the
> > Kconfig option and define it to be the same value as CONFIG_NUMA.
> > 
> > On the LPAR in question, which was very inefficiently using slabs, this
> > took the slab consumption at boot from roughly 7GB to roughly 4GB.
> 
> Err, this should have been
> 
> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> 
> !
> 
> Sorry about that Ben!
>     
> > ---
> > Ben, the only question I have wrt this change is if it's appropriate to
> > change it for all powerpc configs (that have NUMA on)?
> > 

I'm suspecting that Ben will request that the proper set_numa_mem() calls 
are done for ppc init to make this actually do anything other than return 
numa_mem_id() == numa_node_id().

> > diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> > index 25493a0..bb2d5fe 100644
> > --- a/arch/powerpc/Kconfig
> > +++ b/arch/powerpc/Kconfig
> > @@ -447,6 +447,9 @@ config NODES_SHIFT
> >  	default "4"
> >  	depends on NEED_MULTIPLE_NODES
> >  
> > +config HAVE_MEMORYLESS_NODES
> > +	def_bool NUMA
> > +
> >  config ARCH_SELECT_MEMORY_MODEL
> >  	def_bool y
> >  	depends on PPC64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
