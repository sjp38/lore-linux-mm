Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDD5B6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 17:07:24 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o5so90535632qki.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:07:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i188si13734439qkf.93.2017.07.26.14.07.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 14:07:24 -0700 (PDT)
Date: Wed, 26 Jul 2017 17:06:59 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 0/5] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20170726210657.GE21717@redhat.com>
References: <20170726083333.17754-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170726083333.17754-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Dan Williams <dan.j.williams@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>

On Wed, Jul 26, 2017 at 10:33:28AM +0200, Michal Hocko wrote:
> Hi,
> this is another step to make the memory hotplug more usable. The primary
> goal of this patchset is to reduce memory overhead of the hot added
> memory (at least for SPARSE_VMEMMAP memory model). Currently we use
> kmalloc to poppulate memmap (struct page array) which has two main
> drawbacks a) it consumes an additional memory until the hotadded memory
> itslef is onlined and b) memmap might end up on a different numa node
> which is especially true for movable_node configuration.
> 
> a) is problem especially for memory hotplug based memory "ballooning"
> solutions when the delay between physical memory hotplug and the
> onlining can lead to OOM and that led to introduction of hacks like auto
> onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
> policy for the newly added memory")).
> b) can have performance drawbacks.
> 
> One way to mitigate both issues is to simply allocate memmap array
> (which is the largest memory footprint of the physical memory hotplug)
> from the hotadded memory itself. VMEMMAP memory model allows us to map
> any pfn range so the memory doesn't need to be online to be usable
> for the array. See patch 3 for more details. In short I am reusing an
> existing vmem_altmap which wants to achieve the same thing for nvdim
> device memory.
> 
> I am sending this as an RFC because this has seen only a very limited
> testing and I am mostly interested about opinions on the chosen
> approach. I had to touch some arch code and I have no idea whether my
> changes make sense there (especially ppc). Therefore I would highly
> appreciate arch maintainers to check patch 2.
> 
> Patches 4 and 5 should be straightforward cleanups.
> 
> There is also one potential drawback, though. If somebody uses memory
> hotplug for 1G (gigantic) hugetlb pages then this scheme will not work
> for them obviously because each memory section will contain 2MB reserved
> area.  I am not really sure somebody does that and how reliable that
> can work actually. Nevertheless, I _believe_ that onlining more memory
> into virtual machines is much more common usecase. Anyway if there ever
> is a strong demand for such a usecase we have basically 3 options a)
> enlarge memory sections b) enhance altmap allocation strategy and reuse
> low memory sections to host memmaps of other sections on the same NUMA
> node c) have the memmap allocation strategy configurable to fallback to
> the current allocation.
> 
> Are there any other concerns, ideas, comments?
> 

This does not seems to be an opt-in change ie if i am reading patch 3
correctly if an altmap is not provided to __add_pages() you fallback
to allocating from begining of zone. This will not work with HMM ie
device private memory. So at very least i would like to see some way
to opt-out of this. Maybe a new argument like bool forbid_altmap ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
