Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 335EF6B02FD
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:45:53 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z48so29482803wrc.4
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:45:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m29si9204531wmh.171.2017.07.26.04.45.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 04:45:52 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6QBipuH059003
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:45:50 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bxpk2bsk1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:45:50 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 26 Jul 2017 12:45:48 +0100
Date: Wed, 26 Jul 2017 13:45:39 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC PATCH 3/5] mm, memory_hotplug: allocate memmap from the
 added memory range for sparse-vmemmap
References: <20170726083333.17754-1-mhocko@kernel.org>
 <20170726083333.17754-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726083333.17754-4-mhocko@kernel.org>
Message-Id: <20170726114539.GG3218@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dan Williams <dan.j.williams@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Wed, Jul 26, 2017 at 10:33:31AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Physical memory hotadd has to allocate a memmap (struct page array) for
> the newly added memory section. kmalloc is currantly used for those
> allocations.
> 
> This has some disadvantages a) an existing memory is consumed for
> that purpose (~2MB per 128MB memory section) and b) if the whole node
> is movable then we have off-node struct pages which has performance
> drawbacks.
> 
> a) has turned out to be a problem for memory hotplug based ballooning
> because the userspace might not react in time to online memory while
> to memory consumed during physical hotadd consumes enough memory to push
> system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
> policy for the newly added memory") has been added to workaround that
> problem.
> 
> We can do much better when CONFIG_SPARSEMEM_VMEMMAP=y because vmemap
> page tables can map arbitrary memory. That means that we can simply
> use the beginning of each memory section and map struct pages there.
> struct pages which back the allocated space then just need to be treated
> carefully so that we know they are not usable.
> 
> Add {_Set,_Clear}PageVmemmap helpers to distinguish those pages in pfn
> walkers. We do not have any spare page flag for this purpose so use the
> combination of PageReserved bit which already tells that the page should
> be ignored by the core mm code and store VMEMMAP_PAGE (which sets all
> bits but PAGE_MAPPING_FLAGS) into page->mapping.
> 
> On the memory hotplug front reuse vmem_altmap infrastructure to override
> the default allocator used by __vmemap_populate. Once the memmap is
> allocated we need a way to mark altmap pfns used for the allocation
> and this is done by a new vmem_altmap::flush_alloc_pfns callback.
> mark_vmemmap_pages implementation then simply __SetPageVmemmap all
> struct pages backing those pfns. The callback is called from
> sparse_add_one_section after the memmap has been initialized to 0.
> 
> We also have to be careful about those pages during online and offline
> operations. They are simply ignored.
> 
> Finally __ClearPageVmemmap is called when the vmemmap page tables are
> torn down.
> 
> Please note that only the memory hotplug is currently using this
> allocation scheme. The boot time memmap allocation could use the same
> trick as well but this is not done yet.

Which kernel are these patches based on? I tried linux-next and Linus'
vanilla tree, however the series does not apply.

In general I do like your idea, however if I understand your patches
correctly we might have an ordering problem on s390: it is not possible to
access hot-added memory on s390 before it is online (MEM_GOING_ONLINE
succeeded).

On MEM_GOING_ONLINE we ask the hypervisor to back the potential available
hot-added memory region with physical pages. Accessing those ranges before
that will result in an exception.

However with your approach the memory is still allocated when add_memory()
is being called, correct? That wouldn't be a change to the current
behaviour; except for the ordering problem outlined above.
Just trying to make sure I get this right :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
