Message-ID: <47967560.8080101@cs.helsinki.fi>
Date: Wed, 23 Jan 2008 00:59:44 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: crash in kmem_cache_init
References: <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com> <20080117211511.GA25320@aepfle.de> <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com> <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com> <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie> <Pine.LNX.4.64.0801221203340.27950@schroedinger.engr.sgi.com> <20080122212654.GB15567@csn.ul.ie> <Pine.LNX.4.64.0801221330390.1652@schroedinger.engr.sgi.com> <20080122225046.GA866@csn.ul.ie>
In-Reply-To: <20080122225046.GA866@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi,

Mel Gorman wrote:
> Faulting instruction address: 0xc0000000003c8c00
> cpu 0x0: Vector: 300 (Data Access) at [c0000000005c3840]
>     pc: c0000000003c8c00: __lock_text_start+0x20/0x88
>     lr: c0000000000dadec: .cache_grow+0x7c/0x338
>     sp: c0000000005c3ac0
>    msr: 8000000000009032
>    dar: 40
>  dsisr: 40000000
>   current = 0xc000000000500f10
>   paca    = 0xc000000000501b80
>     pid   = 0, comm = swapper
> enter ? for help
> [c0000000005c3b40] c0000000000dadec .cache_grow+0x7c/0x338
> [c0000000005c3c00] c0000000000db54c .fallback_alloc+0x1c0/0x224
> [c0000000005c3cb0] c0000000000db958 .kmem_cache_alloc+0xe0/0x14c
> [c0000000005c3d50] c0000000000dcccc .kmem_cache_create+0x230/0x4cc
> [c0000000005c3e30] c0000000004c05f4 .kmem_cache_init+0x310/0x640
> [c0000000005c3ee0] c00000000049f8d8 .start_kernel+0x304/0x3fc
> [c0000000005c3f90] c000000000008594 .start_here_common+0x54/0xc0
> 0:mon>

I mentioned this already but received no response (maybe I am missing 
something totally obvious here):

When we call fallback_alloc() because the current node has ->nodelists 
set to NULL, we end up calling kmem_getpages() with -1 as the node id 
which is then translated to numa_node_id() by alloc_pages_node. But the 
reason we called fallback_alloc() in the first place is because 
numa_node_id() doesn't have a ->nodelist which makes cache_grow() oops.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
