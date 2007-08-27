Date: Mon, 27 Aug 2007 19:47:14 +0000
From: Mike Travis <travis@cthulhu.engr.sgi.com>
Subject: Re: [PATCH 1/6] x86: fix cpu_to_node references (v2)
In-Reply-To: <20070825002349.GB1894@linux-os.sc.intel.com>
Message-ID: <Pine.SGI.4.56.0708271940550.4346753@kluge.engr.sgi.com>
References: <20070824222654.687510000@sgi.com> <20070824222948.587159000@sgi.com>
 <20070825002349.GB1894@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Cc: travis@sgi.com, Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>


On Fri, 24 Aug 2007, Siddha, Suresh B wrote:

> On Fri, Aug 24, 2007 at 03:26:55PM -0700, travis@sgi.com wrote:
> > Fix four instances where cpu_to_node is referenced
> > by array instead of via the cpu_to_node macro.  This
> > is preparation to moving it to the per_cpu data area.
> >
> ...
>
> >  unsigned long __init numa_free_all_bootmem(void)
> > --- a/arch/x86_64/mm/srat.c
> > +++ b/arch/x86_64/mm/srat.c
> > @@ -431,9 +431,9 @@
> >  			setup_node_bootmem(i, nodes[i].start, nodes[i].end);
> >
> >  	for (i = 0; i < NR_CPUS; i++) {
> > -		if (cpu_to_node[i] == NUMA_NO_NODE)
> > +		if (cpu_to_node(i) == NUMA_NO_NODE)
> >  			continue;
> > -		if (!node_isset(cpu_to_node[i], node_possible_map))
> > +		if (!node_isset(cpu_to_node(i), node_possible_map))
> >  			numa_set_node(i, NUMA_NO_NODE);
> >  	}
> >  	numa_init_array();
>
> During this particular routine execution, per cpu areas are not yet setup. In
> future, when we make cpu_to_node(i) use per cpu area, then this code will break.
>
> And actually setup_per_cpu_areas() uses cpu_to_node(). So...
>

I have a scheme to use an __initdata array during __init processing which
is removed after the per cpu data area is setup.  I'm looking more closely
at all the various node <--> cpu tables.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
