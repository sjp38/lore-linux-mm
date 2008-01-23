Date: Wed, 23 Jan 2008 13:41:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: crash in kmem_cache_init
Message-ID: <20080123134147.GA12503@csn.ul.ie>
References: <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com> <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com> <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie> <20080122214505.GA15674@aepfle.de> <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com> <20080123075821.GA17713@aepfle.de> <20080123105044.GD21455@csn.ul.ie> <20080123121459.GA18631@aepfle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080123121459.GA18631@aepfle.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olaf Hering <olaf@aepfle.de>
Cc: Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On (23/01/08 13:14), Olaf Hering didst pronounce:
> On Wed, Jan 23, Mel Gorman wrote:
> 
> > Sorry this is dragging out. Can you post the full dmesg with loglevel=8 of the
> > following patch against 2.6.24-rc8 please? It contains the debug information
> > that helped me figure out what was going wrong on the PPC64 machine here,
> > the revert and the !l3 checks (i.e. the two patches that made machines I
> > have access to work). Thanks
> 
> It boots with your change.
> 

....... Nice one! As the only addition here is debugging output, I can
only assume that the two patches were being booted in isolation instead
of combination earlier. The two threads have been a little confused with
hand waving so that can easily happen.

Looking at your log;

> early_node_map[1] active PFN ranges
>     1:        0 ->   892928

All memory on node 1

> Online nodes
> o 0
> o 1
> Nodes with regular memory
> o 1
> Current running CPU 0 is associated with node 0
> Current node is 0

Running CPU associated with node 0 so other than being node 1 instead of
node 2, your machine is similar to the one I had the problem on in terms
of memoryless nodes and CPU configuration.

> VFS: Cannot open root device "<NULL>" or unknown-block(0,0)
> Please append a correct "root=" boot option; here are the available partitions:
> Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
> Rebooting in 1 seconds..    
> 

I see it failed to complete boot but I'm going to assume this is a relatively
normal commane-line, .config or initrd problem and not a regression of
some type.

I'll post a patch suitable for pick-up shortly. The two patches ran in
combination with CONFIG_DEBUG_SLAB a compile-based stress tests without
difficulty so hopefully there is not new surprises hiding in the corners.

Thanks Olaf.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
