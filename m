Received: by rv-out-0910.google.com with SMTP id l15so1146884rvb.26
        for <linux-mm@kvack.org>; Sat, 19 Jan 2008 17:31:43 -0800 (PST)
Message-ID: <86802c440801191731h191ed4b3hb2e43ed95c60cb2b@mail.gmail.com>
Date: Sat, 19 Jan 2008 17:31:43 -0800
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 1/5] x86: Change size of node ids from u8 to u16 fixup
In-Reply-To: <479298AF.8040806@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080118183011.354965000@sgi.com>
	 <20080118183011.527888000@sgi.com>
	 <86802c440801182003vd94044ex7fb13e61e5f79c81@mail.gmail.com>
	 <alpine.DEB.0.9999.0801182026130.32726@chino.kir.corp.google.com>
	 <47926ACC.4060707@sgi.com>
	 <alpine.DEB.0.9999.0801191415360.28596@chino.kir.corp.google.com>
	 <479298AF.8040806@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
List-ID: <linux-mm.kvack.org>

On Jan 19, 2008 4:41 PM, Mike Travis <travis@sgi.com> wrote:
> David Rientjes wrote:
> > On Sat, 19 Jan 2008, Mike Travis wrote:
> >
> >>> Yeah, NID_INVAL is negative so no unsigned type will work here,
> >>> unfortunately.  And that reduces the intended savings of your change since
> >>> the smaller type can only be used with a smaller CONFIG_NODES_SHIFT.
> >>>
> >> Excuse my ignorance but why wouldn't this work:
> >>
> >> static numanode_t pxm_to_node_map[MAX_PXM_DOMAINS]
> >>                                 = { [0 ... MAX_PXM_DOMAINS - 1] = NUMA_NO_NODE };
> >> ...
> >>>> int acpi_map_pxm_to_node(int pxm)
> >>>> {
> >>>         int node = pxm_to_node_map[pxm];
> >>>
> >>>         if (node < 0)
> >>         numanode_t node = pxm_to_node_map[pxm];
> >>
> >
> > Because NUMA_NO_NODE is 0xff on x86.  That's a valid node id for
> > configurations with CONFIG_NODES_SHIFT equal to or greater than 8.
>
> Perhaps numanode_t should be set to u16 if MAX_NUMNODES > 255 to
> allow for an invalid value of 255?
>
> #if MAX_NUMNODES > 255
> typedef u16 numanode_t;
> #else
> typedef u8 numanode_t;
> #endif
>
> >
> >>         if (node != NUMA_NO_NODE) {
> >
> > Wrong, this should be
> >
> >       node == NUMA_NO_NODE
>
> Oops, yes you're right.
>
>
> >>>>                 if (nodes_weight(nodes_found_map) >= MAX_NUMNODES)
> >>>>                         return NID_INVAL;
> >>>>                 node = first_unset_node(nodes_found_map);
> >>>>                 __acpi_map_pxm_to_node(pxm, node);
> >>>>                 node_set(node, nodes_found_map);
> >>>>         }
> >
> > The net result of this is that if a proximity domain is looked up through
> > acpi_map_pxm_to_node() and already has a mapping to node 255 (legal with
> > CONFIG_NODES_SHIFT == 8), this function will return NID_INVAL since the
> > weight of nodes_found_map is equal to MAX_NUMNODES.
>
> >
> > You simply can't use valid node id's to signify invalid or unused node
> > ids.
> >
> >> or change:
> >>      #define NID_INVAL       (-1)
> >> to
> >>      #define NID_INVAL       ((numanode_t)(-1))
> >> ...
> >>         if (node != NID_INVAL) {
> >
> > You mean
> >
> >       node == NID_INVAL
> >
> >>>>                 if (nodes_weight(nodes_found_map) >= MAX_NUMNODES)
> >>>>                         return NID_INVAL;
> >>>>                 node = first_unset_node(nodes_found_map);
> >>>>                 __acpi_map_pxm_to_node(pxm, node);
> >>>>                 node_set(node, nodes_found_map);
> >>>>         }
> >
> > That's the equivalent of your NUMA_NO_NODE code above.  The fact remains
> > that (numanode_t)-1 is still a valid node id for MAX_NUMNODES >= 256.
> >
> > So, as I said in my initial reply, the only way to get the savings you're
> > looking for is to use u8 for CONFIG_NODES_SHIFT <= 7 and then convert all
> > NID_INVAL users to use NUMA_NO_NODE.
>
> Yes, I agree.  I'll do the changes you're suggesting.
>
> > Additionally, Linux has always discouraged typedefs when they do not
> > define an architecture-specific size.  The savings from your patch for
> > CONFIG_NODES_SHIFT == 7 would be 256 bytes for this mapping.
> >
> > It's simply not worth it.
>
> So are you saying that I should just use u16 for all node ids whether
> CONFIG_NODES_SHIFT > 7 or not?  Othersise, I would think that defining a
> typedef is a fairly clean solution.
>
> A quick grep shows that there are 35 arrays defined by MAX_NUMNODES in
> x86_64, 38 in X86_32 (not verified.)  So it's not exactly a trivial
> amount of memory.

just use int for node id, and -1 will be NON_VALID...
or s16?

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
