Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6316B0035
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 19:30:58 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id l13so9200589iga.16
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 16:30:58 -0700 (PDT)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id qp5si10045042igb.49.2014.08.18.16.30.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 18 Aug 2014 16:30:57 -0700 (PDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 18 Aug 2014 17:30:56 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 2D74B3E4003F
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 17:30:54 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s7INT8dk63570136
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 01:29:08 +0200
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7INUrOR010950
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 17:30:53 -0600
Date: Mon, 18 Aug 2014 16:30:41 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
Message-ID: <20140818233041.GA15310@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <20140721172331.GB4156@linux.vnet.ibm.com>
 <CA+8MBbK+ZdisT_yXh_jkWSd4hWEMisG614s4s0EyNV3j-7YOow@mail.gmail.com>
 <20140721175736.GG4156@linux.vnet.ibm.com>
 <53CF7048.20302@linux.intel.com>
 <20140724233230.GD24458@linux.vnet.ibm.com>
 <53D1B7C9.9040907@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53D1B7C9.9040907@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-hotplug@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Gerry,

On 25.07.2014 [09:50:01 +0800], Jiang Liu wrote:
> 
> 
> On 2014/7/25 7:32, Nishanth Aravamudan wrote:
> > On 23.07.2014 [16:20:24 +0800], Jiang Liu wrote:
> >>
> >>
> >> On 2014/7/22 1:57, Nishanth Aravamudan wrote:
> >>> On 21.07.2014 [10:41:59 -0700], Tony Luck wrote:
> >>>> On Mon, Jul 21, 2014 at 10:23 AM, Nishanth Aravamudan
> >>>> <nacc@linux.vnet.ibm.com> wrote:
> >>>>> It seems like the issue is the order of onlining of resources on a
> >>>>> specific x86 platform?
> >>>>
> >>>> Yes. When we online a node the BIOS hits us with some ACPI hotplug events:
> >>>>
> >>>> First: Here are some new cpus
> >>>
> >>> Ok, so during this period, you might get some remote allocations. Do you
> >>> know the topology of these CPUs? That is they belong to a
> >>> (soon-to-exist) NUMA node? Can you online that currently offline NUMA
> >>> node at this point (so that NODE_DATA()) resolves, etc.)?
> >> Hi Nishanth,
> >> 	We have method to get the NUMA information about the CPU, and
> >> patch "[RFC Patch V1 30/30] x86, NUMA: Online node earlier when doing
> >> CPU hot-addition" tries to solve this issue by onlining NUMA node
> >> as early as possible. Actually we are trying to enable memoryless node
> >> as you have suggested.
> > 
> > Ok, it seems like you have two sets of patches then? One is to fix the
> > NUMA information timing (30/30 only). The rest of the patches are
> > general discussions about where cpu_to_mem() might be used instead of
> > cpu_to_node(). However, based upon Tejun's feedback, it seems like
> > rather than force all callers to use cpu_to_mem(), we should be looking
> > at the core VM to ensure fallback is occuring appropriately when
> > memoryless nodes are present. 
> > 
> > Do you have a specific situation, once you've applied 30/30, where
> > kmalloc_node() leads to an Oops?
> Hi Nishanth,
> 	After following the two threads related to support of memoryless
> node and digging more code, I realized my first version path set is an
> overkill. As Tejun has pointed out, we shouldn't expose the detail of
> memoryless node to normal user, but there are still some special users
> who need the detail. So I have tried to summarize it as:
> 1) Arch code should online corresponding NUMA node before onlining any
>    CPU or memory, otherwise it may cause invalid memory access when
>    accessing NODE_DATA(nid).

I think that's reasonable.

A related caveat is that NUMA topology information should be stored as
early as possible in boot for *all* CPUs [I think only cpu_to_* is used,
at least for now], not just the boot CPU, etc. This is because (at least
on my examination) pre-SMP initcalls are not prevented from using
cpu_to_node, which will falsely return 0 for all CPUs until
set_cpu_numa_node() is called.

> 2) For normal memory allocations without __GFP_THISNODE setting in the
>    gfp_flags, we should prefer numa_node_id()/cpu_to_node() instead of
>    numa_mem_id()/cpu_to_mem() because the latter loses hardware topology
>    information as pointed out by Tejun:
>            A - B - X - C - D
>         Where X is the memless node.  numa_mem_id() on X would return
>         either B or C, right?  If B or C can't satisfy the allocation,
>         the allocator would fallback to A from B and D for C, both of
>         which aren't optimal. It should first fall back to C or B
>         respectively, which the allocator can't do anymoe because the
>         information is lost when the caller side performs numa_mem_id().

Yes, this seems like a very good description of the reasoning.

> 3) For memory allocation with __GFP_THISNODE setting in gfp_flags,
>    numa_node_id()/cpu_to_node() should be used if caller only wants to
>    allocate from local memory, otherwise numa_mem_id()/cpu_to_mem()
>    should be used if caller wants to allocate from the nearest node.
>
> 4) numa_mem_id()/cpu_to_mem() should be used if caller wants to check
>    whether a page is allocated from the nearest node.

I'm less clear on what you mean here, I'll look at your v2 patches. I
mean, numa_node_id()/cpu_to_node() should be used to indicate node-local
preference with appropriate failure handling. But I don't know why one
would prefer to use numa_node_id() to numa_mem_id() in such a path? The
only time they differ is if memoryless nodes are present, which is what
your local memory allocation would ideally be for those nodes anyways?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
