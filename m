Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id A75206B00B3
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 19:06:10 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id i11so6692388oag.6
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 16:06:10 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id pp9si20259076obc.119.2014.03.24.16.06.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 16:06:09 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 24 Mar 2014 17:06:09 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A4D8F19D8036
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 17:06:02 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2ON5VFS10748264
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 00:05:31 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2ON65fZ022529
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 17:06:05 -0600
Date: Mon, 24 Mar 2014 16:05:50 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Bug in reclaim logic with exhausted nodes?
Message-ID: <20140324230550.GB18778@linux.vnet.ibm.com>
References: <20140311210614.GB946@linux.vnet.ibm.com>
 <20140313170127.GE22247@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140313170127.GE22247@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cl@linux.com, rientjes@google.com, linuxppc-dev@lists.ozlabs.org, anton@samba.org, mgorman@suse.de

Anyone have any ideas here?

On 13.03.2014 [10:01:27 -0700], Nishanth Aravamudan wrote:
> There might have been an error in my original mail, so resending...
> 
> On 11.03.2014 [14:06:14 -0700], Nishanth Aravamudan wrote:
> > We have seen the following situation on a test system:
> > 
> > 2-node system, each node has 32GB of memory.
> > 
> > 2 gigantic (16GB) pages reserved at boot-time, both of which are
> > allocated from node 1.
> > 
> > SLUB notices this:
> > 
> > [    0.000000] SLUB: Unable to allocate memory from node 1
> > [    0.000000] SLUB: Allocating a useless per node structure in order to
> > be able to continue
> > 
> > After boot, user then did:
> > 
> > echo 24 > /proc/sys/vm/nr_hugepages
> > 
> > And tasks are stuck:
> > 
> > [<c0000000010980b8>] kexec_stack+0xb8/0x8000
> > [<c0000000000144d0>] .__switch_to+0x1c0/0x390
> > [<c0000000001ac708>] .throttle_direct_reclaim.isra.31+0x238/0x2c0
> > [<c0000000001b0b34>] .try_to_free_pages+0xb4/0x210
> > [<c0000000001a2f1c>] .__alloc_pages_nodemask+0x75c/0xb00
> > [<c0000000001eafb0>] .alloc_fresh_huge_page+0x70/0x150
> > [<c0000000001eb2d0>] .set_max_huge_pages.part.37+0x130/0x2f0
> > [<c0000000001eb7c8>] .hugetlb_sysctl_handler_common+0x168/0x180
> > [<c0000000002ae21c>] .proc_sys_call_handler+0xfc/0x120
> > [<c00000000021dcc0>] .vfs_write+0xe0/0x260
> > [<c00000000021e8c8>] .SyS_write+0x58/0xd0
> > [<c000000000009e7c>] syscall_exit+0x0/0x7c
> > 
> > [<c00000004f9334b0>] 0xc00000004f9334b0
> > [<c0000000000144d0>] .__switch_to+0x1c0/0x390
> > [<c0000000001ac708>] .throttle_direct_reclaim.isra.31+0x238/0x2c0
> > [<c0000000001b0b34>] .try_to_free_pages+0xb4/0x210
> > [<c0000000001a2f1c>] .__alloc_pages_nodemask+0x75c/0xb00
> > [<c0000000001eafb0>] .alloc_fresh_huge_page+0x70/0x150
> > [<c0000000001eb2d0>] .set_max_huge_pages.part.37+0x130/0x2f0
> > [<c0000000001eb7c8>] .hugetlb_sysctl_handler_common+0x168/0x180
> > [<c0000000002ae21c>] .proc_sys_call_handler+0xfc/0x120
> > [<c00000000021dcc0>] .vfs_write+0xe0/0x260
> > [<c00000000021e8c8>] .SyS_write+0x58/0xd0
> > [<c000000000009e7c>] syscall_exit+0x0/0x7c
> > 
> > [<c00000004f91f440>] 0xc00000004f91f440
> > [<c0000000000144d0>] .__switch_to+0x1c0/0x390
> > [<c0000000001ac708>] .throttle_direct_reclaim.isra.31+0x238/0x2c0
> > [<c0000000001b0b34>] .try_to_free_pages+0xb4/0x210
> > [<c0000000001a2f1c>] .__alloc_pages_nodemask+0x75c/0xb00
> > [<c0000000001eafb0>] .alloc_fresh_huge_page+0x70/0x150
> > [<c0000000001eb2d0>] .set_max_huge_pages.part.37+0x130/0x2f0
> > [<c0000000001eb54c>] .nr_hugepages_store_common.isra.39+0xbc/0x1b0
> > [<c0000000003662cc>] .kobj_attr_store+0x2c/0x50
> > [<c0000000002b2c2c>] .sysfs_write_file+0xec/0x1c0
> > [<c00000000021dcc0>] .vfs_write+0xe0/0x260
> > [<c00000000021e8c8>] .SyS_write+0x58/0xd0
> > [<c000000000009e7c>] syscall_exit+0x0/0x7c
> > 
> > kswapd1 is also pegged at this point at 100% cpu.
> > 
> > If we go in and manually:
> > 
> > echo 24 >
> > /sys/devices/system/node/node0/hugepages/hugepages-16384kB/nr_hugepages
> > 
> > rather than relying on the interleaving allocator from the sysctl, the
> > allocation succeeds (and the echo returns immediately).
> > 
> > I think we are hitting the following:
> > 
> > mm/hugetlb.c::alloc_fresh_huge_page_node():
> > 
> >         page = alloc_pages_exact_node(nid,
> >                 htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
> >                                                 __GFP_REPEAT|__GFP_NOWARN,
> >                 huge_page_order(h));
> > 
> > include/linux/gfp.h:
> > 
> > #define GFP_THISNODE    (__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
> > 
> > and mm/page_alloc.c::__alloc_pages_slowpath():
> > 
> >         /*
> >          * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
> >          * __GFP_NOWARN set) should not cause reclaim since the subsystem
> >          * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
> >          * using a larger set of nodes after it has established that the
> >          * allowed per node queues are empty and that nodes are
> >          * over allocated.
> >          */
> >         if (IS_ENABLED(CONFIG_NUMA) &&
> >                         (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
> >                 goto nopage;
> > 
> > so we *do* reclaim in this callpath. Under my reading, since node1 is
> > exhausted, no matter how much work kswapd1 does, it will never reclaim
> > memory from node1 to satisfy a 16M page allocation request (or any
> > other, for that matter).
> > 
> > I see the following possible changes/fixes, but am unsure if
> > a) my analysis is right
> > b) which is best.
> > 
> > 1) Since we did notice early in boot that (in this case) node 1 was
> > exhausted, perhaps we should mark it as such there somehow, and if a
> > __GFP_THISNODE allocation request comes through on such a node, we
> > immediately fallthrough to nopage?
> > 
> > 2) There is the following check
> >         /*
> >          * For order > PAGE_ALLOC_COSTLY_ORDER, if __GFP_REPEAT is
> >          * specified, then we retry until we no longer reclaim any pages
> >          * (above), or we've reclaimed an order of pages at least as
> >          * large as the allocation's order. In both cases, if the
> >          * allocation still fails, we stop retrying.
> >          */
> >         if (gfp_mask & __GFP_REPEAT && pages_reclaimed < (1 << order))
> >                 return 1;
> > 
> > I wonder if we should add a check to also be sure that the pages we are
> > reclaiming, if __GFP_THISNODE is set, are from the right node?
> > 
> >        if (gfp_mask & __GFP_THISNODE && the progress we have made is on
> >        		the node requested?)
> > 
> > 3) did_some_progress could be updated to track where the progress is
> > occuring, and if we are in __GFP_THISNODE allocation request and we
> > didn't make any progress on the correct node, we fail the allocation?
> > 
> > I think this situation could be reproduced (and am working on it) by
> > exhausting a NUMA node with 16M hugepages and then using the generic
> > RR allocator to ask for more. Other node exhaustion cases probably
> > exist, but since we can't swap the hugepages, it seems like the most
> > straightforward way to try and reproduce it.
> > 
> > Any thoughts on this? Am I way off base?
> > 
> > Thanks,
> > Nish
> > 
> > _______________________________________________
> > Linuxppc-dev mailing list
> > Linuxppc-dev@lists.ozlabs.org
> > https://lists.ozlabs.org/listinfo/linuxppc-dev

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
