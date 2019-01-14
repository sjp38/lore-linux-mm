Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6706D8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 06:48:57 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m19so8871590edc.6
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 03:48:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s16si1286629edd.300.2019.01.14.03.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 03:48:55 -0800 (PST)
Date: Mon, 14 Jan 2019 12:48:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
Message-ID: <20190114114853.GE21345@dhcp22.suse.cz>
References: <20190114082416.30939-1-mhocko@kernel.org>
 <87pnszzg9s.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87pnszzg9s.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon 14-01-19 21:26:39, Michael Ellerman wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > From: Michal Hocko <mhocko@suse.com>
> >
> > Pingfan Liu has reported the following splat
> > [    5.772742] BUG: unable to handle kernel paging request at 0000000000002088
> > [    5.773618] PGD 0 P4D 0
> > [    5.773618] Oops: 0000 [#1] SMP NOPTI
> > [    5.773618] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.20.0-rc1+ #3
> > [    5.773618] Hardware name: Dell Inc. PowerEdge R7425/02MJ3T, BIOS 1.4.3 06/29/2018
> > [    5.773618] RIP: 0010:__alloc_pages_nodemask+0xe2/0x2a0
> > [    5.773618] Code: 00 00 44 89 ea 80 ca 80 41 83 f8 01 44 0f 44 ea 89 da c1 ea 08 83 e2 01 88 54 24 20 48 8b 54 24 08 48 85 d2 0f 85 46 01 00 00 <3b> 77 08 0f 82 3d 01 00 00 48 89 f8 44 89 ea 48 89
> > e1 44 89 e6 89
> > [    5.773618] RSP: 0018:ffffaa600005fb20 EFLAGS: 00010246
> > [    5.773618] RAX: 0000000000000000 RBX: 00000000006012c0 RCX: 0000000000000000
> > [    5.773618] RDX: 0000000000000000 RSI: 0000000000000002 RDI: 0000000000002080
> > [    5.773618] RBP: 00000000006012c0 R08: 0000000000000000 R09: 0000000000000002
> > [    5.773618] R10: 00000000006080c0 R11: 0000000000000002 R12: 0000000000000000
> > [    5.773618] R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000000002
> > [    5.773618] FS:  0000000000000000(0000) GS:ffff8c69afe00000(0000) knlGS:0000000000000000
> > [    5.773618] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [    5.773618] CR2: 0000000000002088 CR3: 000000087e00a000 CR4: 00000000003406e0
> > [    5.773618] Call Trace:
> > [    5.773618]  new_slab+0xa9/0x570
> > [    5.773618]  ___slab_alloc+0x375/0x540
> > [    5.773618]  ? pinctrl_bind_pins+0x2b/0x2a0
> > [    5.773618]  __slab_alloc+0x1c/0x38
> > [    5.773618]  __kmalloc_node_track_caller+0xc8/0x270
> > [    5.773618]  ? pinctrl_bind_pins+0x2b/0x2a0
> > [    5.773618]  devm_kmalloc+0x28/0x60
> > [    5.773618]  pinctrl_bind_pins+0x2b/0x2a0
> > [    5.773618]  really_probe+0x73/0x420
> > [    5.773618]  driver_probe_device+0x115/0x130
> > [    5.773618]  __driver_attach+0x103/0x110
> > [    5.773618]  ? driver_probe_device+0x130/0x130
> > [    5.773618]  bus_for_each_dev+0x67/0xc0
> > [    5.773618]  ? klist_add_tail+0x3b/0x70
> > [    5.773618]  bus_add_driver+0x41/0x260
> > [    5.773618]  ? pcie_port_setup+0x4d/0x4d
> > [    5.773618]  driver_register+0x5b/0xe0
> > [    5.773618]  ? pcie_port_setup+0x4d/0x4d
> > [    5.773618]  do_one_initcall+0x4e/0x1d4
> > [    5.773618]  ? init_setup+0x25/0x28
> > [    5.773618]  kernel_init_freeable+0x1c1/0x26e
> > [    5.773618]  ? loglevel+0x5b/0x5b
> > [    5.773618]  ? rest_init+0xb0/0xb0
> > [    5.773618]  kernel_init+0xa/0x110
> > [    5.773618]  ret_from_fork+0x22/0x40
> > [    5.773618] Modules linked in:
> > [    5.773618] CR2: 0000000000002088
> > [    5.773618] ---[ end trace 1030c9120a03d081 ]---
> >
> > with his AMD machine with the following topology
> >   NUMA node0 CPU(s):     0,8,16,24
> >   NUMA node1 CPU(s):     2,10,18,26
> >   NUMA node2 CPU(s):     4,12,20,28
> >   NUMA node3 CPU(s):     6,14,22,30
> >   NUMA node4 CPU(s):     1,9,17,25
> >   NUMA node5 CPU(s):     3,11,19,27
> >   NUMA node6 CPU(s):     5,13,21,29
> >   NUMA node7 CPU(s):     7,15,23,31
> >
> > [    0.007418] Early memory node ranges
> > [    0.007419]   node   1: [mem 0x0000000000001000-0x000000000008efff]
> > [    0.007420]   node   1: [mem 0x0000000000090000-0x000000000009ffff]
> > [    0.007422]   node   1: [mem 0x0000000000100000-0x000000005c3d6fff]
> > [    0.007422]   node   1: [mem 0x00000000643df000-0x0000000068ff7fff]
> > [    0.007423]   node   1: [mem 0x000000006c528000-0x000000006fffffff]
> > [    0.007424]   node   1: [mem 0x0000000100000000-0x000000047fffffff]
> > [    0.007425]   node   5: [mem 0x0000000480000000-0x000000087effffff]
> >
> > and nr_cpus set to 4. The underlying reason is tha the device is bound
> > to node 2 which doesn't have any memory and init_cpu_to_node only
> > initializes memory-less nodes for possible cpus which nr_cpus restrics.
> > This in turn means that proper zonelists are not allocated and the page
> > allocator blows up.
> >
> > Fix the issue by reworking how x86 initializes the memory less nodes.
> > The current implementation is hacked into the workflow and it doesn't
> > allow any flexibility. There is init_memory_less_node called for each
> > offline node that has a CPU as already mentioned above. This will make
> > sure that we will have a new online node without any memory. Much later
> > on we build a zone list for this node and things seem to work, except
> > they do not (e.g. due to nr_cpus). Not to mention that it doesn't really
> > make much sense to consider an empty node as online because we just
> > consider this node whenever we want to iterate nodes to use and empty
> > node is obviously not the best candidate. This is all just too fragile.
> >
> > Reported-by: Pingfan Liu <kernelfans@gmail.com>
> > Tested-by: Pingfan Liu <kernelfans@gmail.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >
> > Hi,
> > I am sending this as an RFC because I am not sure this is the proper way
> > to go myself. I am especially not sure about other architectures
> > supporting memoryless nodes (ppc and ia64 AFAICS or are there more?).
> >
> > I would appreciate a help with those architectures because I couldn't
> > really grasp how the memoryless nodes are really initialized there. E.g.
> > ppc only seem to call setup_node_data for online nodes but I couldn't
> > find any special treatment for nodes without any memory.
> 
> We have a somewhat dubious hack in our hotplug code, see:
> 
> e67e02a544e9 ("powerpc/pseries: Fix cpu hotplug crash with memoryless nodes")
> 
> Which basically onlines the node when we hotplug a CPU into it.

Hmm, interesting. So what happens if somebody tries to allocate a memory
from a node when it is not online yet? E.g. something like the above.

And do I get it right that this patch will not break the current ppc
code?
-- 
Michal Hocko
SUSE Labs
