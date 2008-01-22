Date: Tue, 22 Jan 2008 14:57:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <20080122225046.GA866@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0801221453480.2271@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
 <20080117211511.GA25320@aepfle.de> <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com>
 <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com>
 <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie>
 <Pine.LNX.4.64.0801221203340.27950@schroedinger.engr.sgi.com>
 <20080122212654.GB15567@csn.ul.ie> <Pine.LNX.4.64.0801221330390.1652@schroedinger.engr.sgi.com>
 <20080122225046.GA866@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Olaf Hering <olaf@aepfle.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jan 2008, Mel Gorman wrote:

> > > Whatever this was a problem fixed in the past or not, it's broken again now
> > > :( . It's possible that there is a __GFP_THISNODE that can be dropped early
> > > at boot-time that would also fix this problem in a way that doesn't
> > > affect runtime (like altering cache_grow in my patch does).
> > 
> > The dropping of GFP_THISNODE has the same effect as your patch. 
> 
> The dropping of it totally? If so, this patch might fix a boot but it'll
> potentially be a performance regression on NUMA machines that only have
> nodes with memory, right?

No the dropping during early allocations.,

> o 0
> o 2
> Nodes with regular memory
> o 2
> Current running CPU 0 is associated with node 0
> Current node is 0
> 
> So node 2 has regular memory but it's trying to use node 0 at a glance.
> I've attached the patch I used against 2.6.24-rc8. It includes the revert.

We need the current processor to be attached to a node that has 
memory. We cannot fall back that early because the structures for the 
other nodes do not exist yet.

> Online nodes
> o 0
> o 2
> Nodes with regular memory
> o 2
> Current running CPU 0 is associated with node 0
> Current node is 0
>  o kmem_list3_init

This needs to be node 2.

> [c0000000005c3b40] c0000000000dadec .cache_grow+0x7c/0x338
> [c0000000005c3c00] c0000000000db54c .fallback_alloc+0x1c0/0x224

Fallback during bootstrap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
