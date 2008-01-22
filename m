Received: by fk-out-0910.google.com with SMTP id 22so3513268fkq.6
        for <linux-mm@kvack.org>; Tue, 22 Jan 2008 14:12:07 -0800 (PST)
Message-ID: <29495f1d0801221412s2642a24u6cb2ea8c9340aed2@mail.gmail.com>
Date: Tue, 22 Jan 2008 14:12:06 -0800
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <20080122214505.GA15674@aepfle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com>
	 <20080117181222.GA24411@aepfle.de>
	 <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
	 <20080117211511.GA25320@aepfle.de>
	 <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com>
	 <20080118213011.GC10491@csn.ul.ie>
	 <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com>
	 <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie>
	 <20080122214505.GA15674@aepfle.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olaf Hering <olaf@aepfle.de>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 1/22/08, Olaf Hering <olaf@aepfle.de> wrote:
> On Tue, Jan 22, Mel Gorman wrote:
>
> > http://www.csn.ul.ie/~mel/postings/slab-20080122/partial-revert-slab-changes.patch
> > .. Can you please check on your machine if it fixes your problem?
>
> It does not fix or change the nature of the crash.
>
> > Olaf, please confirm whether you need the patch below as well as the
> > revert to make your machine boot.
>
> It crashes now in a different way if the patch below is applied:

Was this with the revert Mel mentioned applied as well? I get the
feeling both patches are needed to fix up the memoryless SLAB issue.

> Linux version 2.6.24-rc8-ppc64 (olaf@lingonberry) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #43 SMP Tue Jan 22 22:39:05 CET 2008

<snip>

> early_node_map[1] active PFN ranges
>     1:        0 ->   892928

<snip>

> Unable to handle kernel paging request for data at address 0x00000058
> Faulting instruction address: 0xc0000000000fe018
> cpu 0x0: Vector: 300 (Data Access) at [c00000000075bac0]
>     pc: c0000000000fe018: .setup_cpu_cache+0x184/0x1f4
>     lr: c0000000000fdfa8: .setup_cpu_cache+0x114/0x1f4
>     sp: c00000000075bd40
>    msr: 8000000000009032
>    dar: 58
>  dsisr: 42000000
>   current = 0xc000000000665a50
>   paca    = 0xc000000000666380
>     pid   = 0, comm = swapper
> enter ? for help
> [c00000000075bd40] c0000000000fb368 .kmem_cache_create+0x3c0/0x478 (unreliable)
> [c00000000075be20] c0000000005e6780 .kmem_cache_init+0x284/0x4f4
> [c00000000075bee0] c0000000005bf8ec .start_kernel+0x2f8/0x3fc
> [c00000000075bf90] c000000000008590 .start_here_common+0x60/0xd0
> 0:mon>
>
> 0xc0000000000fe018 is in setup_cpu_cache (/home/olaf/kernel/git/linux-2.6-numa/mm/slab.c:2111).
> 2106                                    BUG_ON(!cachep->nodelists[node]);
> 2107                                    kmem_list3_init(cachep->nodelists[node]);

I might be barking up the wrong tree, but this block above is supposed
to set up the cachep->nodeslists[*] that are used immediately below.
But if the loop wasn't changed from N_NORMAL_MEMORY to N_ONLINE or
whatever, you might get a bad access right below for node 0 that has
no memory, if that's the node we're running on...

> 2108                            }
> 2109                    }
> 2110            }
> 2111            cachep->nodelists[numa_node_id()]->next_reap =
> 2112                            jiffies + REAPTIMEOUT_LIST3 +
> 2113                            ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
> 2114
> 2115            cpu_cache_get(cachep)->avail = 0;

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
