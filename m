Date: Fri, 18 Jan 2008 20:36:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] x86: Change size of node ids from u8 to u16 fixup
In-Reply-To: <86802c440801182003vd94044ex7fb13e61e5f79c81@mail.gmail.com>
Message-ID: <alpine.DEB.0.9999.0801182026130.32726@chino.kir.corp.google.com>
References: <20080118183011.354965000@sgi.com>  <20080118183011.527888000@sgi.com> <86802c440801182003vd94044ex7fb13e61e5f79c81@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jan 2008, Yinghai Lu wrote:

> > +#if MAX_NUMNODES > 256
> > +typedef u16 numanode_t;
> > +#else
> > +typedef u8 numanode_t;
> > +#endif
> > +
> >  #endif /* _LINUX_NUMA_H */
> 
> that is wrong, you can not change pxm_to_node_map from int to u8 or u16.
> 

Yeah, NID_INVAL is negative so no unsigned type will work here, 
unfortunately.  And that reduces the intended savings of your change since 
the smaller type can only be used with a smaller CONFIG_NODES_SHIFT.

> int acpi_map_pxm_to_node(int pxm)
> {
>         int node = pxm_to_node_map[pxm];
> 
>         if (node < 0){
>                 if (nodes_weight(nodes_found_map) >= MAX_NUMNODES)
>                         return NID_INVAL;
>                 node = first_unset_node(nodes_found_map);
>                 __acpi_map_pxm_to_node(pxm, node);
>                 node_set(node, nodes_found_map);
>         }
> 
>         return node;
> }
> 
> node will will be always 255 or 65535
> 

Right.

> please keep that to int.
> 
> I got
> SART: PXM 0 -> APIC 0 -> Node 255
> SART: PXM 0 -> APIC 1 -> Node 255
> SART: PXM 1 -> APIC 2 -> Node 255
> SART: PXM 1 -> APIC 3 -> Node 255
> 

I assume this is a typo and those proximity mappings are actually from the 
SRAT.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
