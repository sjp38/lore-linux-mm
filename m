Date: Sat, 19 Jan 2008 22:22:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] x86: Change size of node ids from u8 to u16 fixup
In-Reply-To: <479298AF.8040806@sgi.com>
Message-ID: <alpine.DEB.0.9999.0801192205280.11197@chino.kir.corp.google.com>
References: <20080118183011.354965000@sgi.com>  <20080118183011.527888000@sgi.com> <86802c440801182003vd94044ex7fb13e61e5f79c81@mail.gmail.com> <alpine.DEB.0.9999.0801182026130.32726@chino.kir.corp.google.com> <47926ACC.4060707@sgi.com>
 <alpine.DEB.0.9999.0801191415360.28596@chino.kir.corp.google.com> <479298AF.8040806@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
List-ID: <linux-mm.kvack.org>

On Sat, 19 Jan 2008, Mike Travis wrote:

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
> >> 	   numanode_t node = pxm_to_node_map[pxm];
> >>
> > 
> > Because NUMA_NO_NODE is 0xff on x86.  That's a valid node id for 
> > configurations with CONFIG_NODES_SHIFT equal to or greater than 8.
> 
> Perhaps numanode_t should be set to u16 if MAX_NUMNODES > 255 to
> allow for an invalid value of 255? 
> 

Throughout the NUMA code you need a way to distinguish between an invalid 
mapping and an actual node id.  NID_INVAL is used to say there are no 
additional node ids available for this system, the pxm-to-node mapping 
doesn't yet exist, etc.

You can't get away with using a magic positive integer with those 
semantics because CONFIG_NODES_SHIFT determines MAX_NUMNODES.  All 
nodemasks will have that many bits in their struct.  So 255 will always be 
a valid node id for shifts of 8 or larger.  It isn't feasible to say for 
these types of systems (or ia64 where the default shift is 10) that 255 is 
some magic node id that means its invalid.

NID_INVAL is the only way to signify an invalid node id and that has 
always been done with -1.  So objects that store node ids that have the 
possibility of being invalid must be signed.  The only time you can use 
unsigned objects are when you are guaranteed to have valid node ids.

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

You're assuming that CONFIG_NODES_SHIFT will never been larger than that 
and you still wouldn't be able to use your new numanode_t for anything 
that could return NID_INVAL.

> A quick grep shows that there are 35 arrays defined by MAX_NUMNODES in
> x86_64, 38 in X86_32 (not verified.)  So it's not exactly a trivial
> amount of memory.
> 

You're spinning the argument.  Most of those arrays are not simply 
returning node ids; most are returning structs or are arrays of unsigned 
long type that return addresses.  Those are unaffected by your change.  
Others are initdata and is freed after boot anyway.

The handful of arrays thoughout the source that return node ids and are 
not initdata would only save MAX_NUMNODES number of bytes with your 
change for 8-bytes instead of 16-bytes.  You're right, you might save a 
KB of memory with the change.  It's not worth it, especially since they 
need to be signed anyway.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
