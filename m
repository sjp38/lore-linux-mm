Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9116B0269
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:16:52 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w69so212158466qka.6
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:16:52 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id 29si6602865qkq.54.2016.10.25.08.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 08:16:46 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id s49so1074375qta.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:16:46 -0700 (PDT)
Date: Tue, 25 Oct 2016 11:16:37 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
Message-ID: <20161025151637.GA6072@gmail.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com>
 <87a8dtawas.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87a8dtawas.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

On Tue, Oct 25, 2016 at 09:56:35AM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <j.glisse@gmail.com> writes:
> 
> > On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:
> >
> >> [...]
> >
> >> 	Core kernel memory features like reclamation, evictions etc. might
> >> need to be restricted or modified on the coherent device memory node as
> >> they can be performance limiting. The RFC does not propose anything on this
> >> yet but it can be looked into later on. For now it just disables Auto NUMA
> >> for any VMA which has coherent device memory.
> >> 
> >> 	Seamless integration of coherent device memory with system memory
> >> will enable various other features, some of which can be listed as follows.
> >> 
> >> 	a. Seamless migrations between system RAM and the coherent memory
> >> 	b. Will have asynchronous and high throughput migrations
> >> 	c. Be able to allocate huge order pages from these memory regions
> >> 	d. Restrict allocations to a large extent to the tasks using the
> >> 	   device for workload acceleration
> >> 
> >> 	Before concluding, will look into the reasons why the existing
> >> solutions don't work. There are two basic requirements which have to be
> >> satisfies before the coherent device memory can be integrated with core
> >> kernel seamlessly.
> >> 
> >> 	a. PFN must have struct page
> >> 	b. Struct page must able to be inside standard LRU lists
> >> 
> >> 	The above two basic requirements discard the existing method of
> >> device memory representation approaches like these which then requires the
> >> need of creating a new framework.
> >
> > I do not believe the LRU list is a hard requirement, yes when faulting in
> > a page inside the page cache it assumes it needs to be added to lru list.
> > But i think this can easily be work around.
> >
> > In HMM i am using ZONE_DEVICE and because memory is not accessible from CPU
> > (not everyone is bless with decent system bus like CAPI, CCIX, Gen-Z, ...)
> > so in my case a file back page must always be spawn first from a regular
> > page and once read from disk then i can migrate to GPU page.
> >
> > So if you accept this intermediary step you can easily use ZONE_DEVICE for
> > device memory. This way no lru, no complex dance to make the memory out of
> > reach from regular memory allocator.
> 
> One of the reason to look at this as a NUMA node is to allow things like
> over-commit of coherent device memory. The pages backing CDM being part of
> lru and considering the coherent device as a numa node makes that really
> simpler (we can run kswapd for that node).

I am not convince that kswapd is what you want for overcommit, for HMM i leave
overcommit to device driver and they seem quite happy about handling that
themself. Only the device driver have enough information on what is worth
evicting or what need to be evicted.
 
> > I think we would have much to gain if we pool our effort on a single common
> > solution for device memory. In my case the device memory is not accessible
> > by the CPU (because PCIE restrictions), in your case it is. Thus the only
> > difference is that in my case it can not be map inside the CPU page table
> > while in yours it can.
> 
> IMHO, we should be able to share the HMM migration approach. We
> definitely won't need the mirror page table part. That is one of the
> reson I requested HMM mirror page table to be a seperate patchset.

They will need to share one thing, that is hmm_pfn_t which is a special pfn
type in which i store HMM and migrate specific flag for migration. Because
i can not use the struct list_head lru of struct page i have to do migration
using array of pfn and i need to keep some flags per page during migration.

So i share the same type hmm_pfn_t btw mirror and migrate code. But that's
pretty small and it can be factor out of HMM, i can also just use pfn_t and
add flag i need their.
 
> 
> >
> >> 
> >> (1) Traditional ioremap
> >> 
> >> 	a. Memory is mapped into kernel (linear and virtual) and user space
> >> 	b. These PFNs do not have struct pages associated with it
> >> 	c. These special PFNs are marked with special flags inside the PTE
> >> 	d. Cannot participate in core VM functions much because of this
> >> 	e. Cannot do easy user space migrations
> >> 
> >> (2) Zone ZONE_DEVICE
> >> 
> >> 	a. Memory is mapped into kernel and user space
> >> 	b. PFNs do have struct pages associated with it
> >> 	c. These struct pages are allocated inside it's own memory range
> >> 	d. Unfortunately the struct page's union containing LRU has been
> >> 	   used for struct dev_pagemap pointer
> >> 	e. Hence it cannot be part of any LRU (like Page cache)
> >> 	f. Hence file cached mapping cannot reside on these PFNs
> >> 	g. Cannot do easy migrations
> >> 
> >> 	I had also explored non LRU representation of this coherent device
> >> memory where the integration with system RAM in the core VM is limited only
> >> to the following functions. Not being inside LRU is definitely going to
> >> reduce the scope of tight integration with system RAM.
> >> 
> >> (1) Migration support between system RAM and coherent memory
> >> (2) Migration support between various coherent memory nodes
> >> (3) Isolation of the coherent memory
> >> (4) Mapping the coherent memory into user space through driver's
> >>     struct vm_operations
> >> (5) HW poisoning of the coherent memory
> >> 
> >> 	Allocating the entire memory of the coherent device node right
> >> after hot plug into ZONE_MOVABLE (where the memory is already inside the
> >> buddy system) will still expose a time window where other user space
> >> allocations can come into the coherent device memory node and prevent the
> >> intended isolation. So traditional hot plug is not the solution. Hence
> >> started looking into CMA based non LRU solution but then hit the following
> >> roadblocks.
> >> 
> >> (1) CMA does not support hot plugging of new memory node
> >> 	a. CMA area needs to be marked during boot before buddy is
> >> 	   initialized
> >> 	b. cma_alloc()/cma_release() can happen on the marked area
> >> 	c. Should be able to mark the CMA areas just after memory hot plug
> >> 	d. cma_alloc()/cma_release() can happen later after the hot plug
> >> 	e. This is not currently supported right now
> >> 
> >> (2) Mapped non LRU migration of pages
> >> 	a. Recent work from Michan Kim makes non LRU page migratable
> >> 	b. But it still does not support migration of mapped non LRU pages
> >> 	c. With non LRU CMA reserved, again there are some additional
> >> 	   challenges
> >> 
> >> 	With hot pluggable CMA and non LRU mapped migration support there
> >> may be an alternate approach to represent coherent device memory. Please
> >> do review this RFC proposal and let me know your comments or suggestions.
> >> Thank you.
> >
> > You can take a look at hmm-v13 if you want to see how i do non LRU page
> > migration. While i put most of the migration code inside hmm_migrate.c it
> > could easily be move to migrate.c without hmm_ prefix.
> >
> > There is 2 missing piece with existing migrate code. First is to put memory
> > allocation for destination under control of who call the migrate code. Second
> > is to allow offloading the copy operation to device (ie not use the CPU to
> > copy data).
> >
> > I believe same requirement also make sense for platform you are targeting.
> > Thus same code can be use.
> >
> > hmm-v13 https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v13
> >
> > I haven't posted this patchset yet because we are doing some modifications
> > to the device driver API to accomodate some new features. But the ZONE_DEVICE
> > changes and the overall migration code will stay the same more or less (i have
> > patches that move it to migrate.c and share more code with existing migrate
> > code).
> >
> > If you think i missed anything about lru and page cache please point it to
> > me. Because when i audited code for that i didn't see any road block with
> > the few fs i was looking at (ext4, xfs and core page cache code).
> 
> I looked at the hmm-v13 w.r.t migration and I guess some form of device
> callback/acceleration during migration is something we should definitely
> have. I still haven't figured out how non addressable and coherent device
> memory can fit together there. I was waiting for the page cache
> migration support to be pushed to the repository before I start looking
> at this closely.
> 

The page cache migration does not touch the migrate code path. My issue with
page cache is writeback. The only difference with existing migrate code is
refcount check for ZONE_DEVICE page. Everything else is the same.

For writeback i need to use a bounce page so basicly i am trying to hook myself
along the ISA bounce infrastructure for bio and i think it is the easiest path
to solve this in my case.

In your case where block device can also access the device memory you don't
even need to use bounce page for writeback.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
