Message-Id: <200406250449.BSB05018@ms6.netsolmail.com>
Reply-To: <shai@ftcon.com>
From: "Shai Fultheim" <shai@ftcon.com>
Subject: RE: [Lhms-devel] Re: [Lhns-devel] Merging Nonlinear and Numa style memory hotplug
Date: Thu, 24 Jun 2004 21:49:42 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20040624135838.F009.YGOTO@us.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Yasunori Goto' <ygoto@us.fujitsu.com>, 'Dave Hansen' <haveblue@us.ibm.com>
Cc: 'Linux Kernel ML' <linux-kernel@vger.kernel.org>, 'Linux Hotplug Memory Support' <lhms-devel@lists.sourceforge.net>, 'Linux-Node-Hotplug' <lhns-devel@lists.sourceforge.net>, 'linux-mm' <linux-mm@kvack.org>, "'BRADLEY CHRISTIANSEN [imap]'" <bradc1@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
> owner@vger.kernel.org] On Behalf Of Yasunori Goto
> Sent: Thursday, June 24, 2004 15:20
> To: Dave Hansen
> 
> > Some more comments on the first patch:

> > +       for(i = 0; i < numnodes; i++) {
> > +               if (!NODE_DATA(i))
> > +                       continue;
> > +               pgdat = NODE_DATA(i);
> > +               size = pgdat->node_zones[ZONE_HIGHMEM].present_pages;
> > +               if (!size)
> > +                       continue;
> > +               hsp = pgdat->node_zones[ZONE_HIGHMEM].zone_mem_map;
> > +               if (hsp)
> > +                       break;
> > +       }
> >
> > Doesn't this just find the lowest-numbered node's highmem?  Are you sure
> > that no NUMA systems have memory at lower physical addresses on
> > higher-numbered nodes?  I'm not sure that this is true.

In addition I'm involved in a NUMA-related project that might have
zone-normal on other nodes beside node0.  I also think that in some cases it
might be useful to have the code above and below in case of AMD machines
that have less than 1GB per processor (or at least less than 1GB on the
FIRST processor).

> > +
> > +#ifdef CONFIG_HOTPLUG_MEMORY_OF_NODE
> > +       for (nid = 0; nid < numnodes; nid++){
> > +               int start, end;
> > +
> > +               if ( !node_online(nid))
> > +                       continue;
> > +               if ( node_start_pfn[nid] >= max_low_pfn )
> > +                       break;
> > +
> > +               start = node_start_pfn[nid];
> > +               end = ( node_end_pfn[nid] < max_low_pfn) ?
> > +                       node_end_pfn[nid] : max_low_pfn;
> > +
> > +               for ( tmp = start; tmp < end; tmp++)
> > +                       /*
> > +                        * Only count reserved RAM pages
> > +                        */
> > +                       if (page_is_ram(tmp) &&
> PageReserved(pfn_to_page(tmp)))
> > +                               reservedpages++;
> > +       }
> > +#else
> >
> > Again, I don't see what this loop is used for.  You appear to be trying
> > to detect which nodes have lowmem.  Is there currently any x86 NUMA
> > architecture that has lowmem on any node but node 0?
> >
> >
> >
> > -- Dave

As noted above, this is possible, the cost of this code is not much, so I
would keep it in.

--shai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
