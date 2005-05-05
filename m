Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j454hST9551458
	for <linux-mm@kvack.org>; Thu, 5 May 2005 00:43:28 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j454hSmf369218
	for <linux-mm@kvack.org>; Wed, 4 May 2005 22:43:28 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j454hRRL032759
	for <linux-mm@kvack.org>; Wed, 4 May 2005 22:43:27 -0600
Subject: Re: [2/3] add memory present for ppc64
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050505023119.GA20283@austin.ibm.com>
References: <E1DTQVJ-0002WU-Fd@pinky.shadowen.org>
	 <20050505023119.GA20283@austin.ibm.com>
Content-Type: text/plain
Date: Wed, 04 May 2005 21:43:18 -0700
Message-Id: <1115268198.9286.11.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olof Johansson <olof@lixom.net>
Cc: Andy Whitcroft <apw@shadowen.org>, PPC64 External List <linuxppc64-dev@ozlabs.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2005-05-04 at 21:31 -0500, Olof Johansson wrote:
> On Wed, May 04, 2005 at 09:29:57PM +0100, Andy Whitcroft wrote:
> > diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/ppc64/Kconfig current/arch/ppc64/Kconfig
> > --- reference/arch/ppc64/Kconfig	2005-05-04 20:54:50.000000000 +0100
> > +++ current/arch/ppc64/Kconfig	2005-05-04 20:54:50.000000000 +0100
> > @@ -212,8 +212,8 @@ config ARCH_FLATMEM_ENABLE
> >  source "mm/Kconfig"
> >  
> >  config HAVE_ARCH_EARLY_PFN_TO_NID
> > -	bool
> > -	default y
> > +	def_bool y
> > +	depends on NEED_MULTIPLE_NODES
> 
> Ok, time to show my lack of undestanding here, but when can we ever be
> CONFIG_NUMA and NOT need multiple nodes?

NEED_MULTIPLE_NODES is for DISCONTIG || NUMA.  It is a blanket config
option that helps us separate those two very intertwined options.

> > @@ -481,6 +483,7 @@ static void __init setup_nonnuma(void)
> >  
> >  	for (i = 0 ; i < top_of_ram; i += MEMORY_INCREMENT)
> >  		numa_memory_lookup_table[i >> MEMORY_INCREMENT_SHIFT] = 0;
> > +	memory_present(0, 0, init_node_data[0].node_end_pfn);
> 
> Isn't the memory_present stuff and numa_memory_lookup_table two
> implementations doing the same thing (mapping memory to nodes)?

They have similar functions: record the physical layout of the system.
But, memory_present() is for sparsemem, which basically implements
pfn_to_page() and page_to_pfn().

The numa_memory_lookup_table[] is used for pfn_to_nid(), which is
actually orthogonal to what sparsemem needs.

> Can we kill numa_memory_lookup_table with this?

Nope, we still need it for pfn_to_nid().  We could possibly replace the
current implementation like this:

#define pfn_to_nid(pfn)
page_zone(__pfn_to_section(pfn)->section_mem_map[pfn])->zone_pgdat->node_id

But, that might have a few performance implications :)  There are
certainly some options that sparsemem opens up here, and I hope that we
explore them further as we move away from discontig.

We could even do something like store the nid directly in the
mem_section.  But, as I said, that's an optimization that can come
later.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
