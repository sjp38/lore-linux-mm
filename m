Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA9B6B0491
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 19:44:21 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f188so275455844pgc.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 16:44:21 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d4si10547222pfb.185.2016.11.18.16.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 16:44:20 -0800 (PST)
Date: Fri, 18 Nov 2016 16:41:21 -0800
From: John Hubbard <jhubbard@nvidia.com>
Subject: Re: [HMM v13 00/18] HMM (Heterogeneous Memory Management) v13
In-Reply-To: <1479493107-982-1-git-send-email-jglisse@redhat.com>
Message-ID: <alpine.LNX.2.20.1611181638370.53648@blueforge.nvidia.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="296541600-505592587-1479516081=:53648"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--296541600-505592587-1479516081=:53648
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT

On Fri, 18 Nov 2016, JA(C)rA'me Glisse wrote:

> Cliff note: HMM offers 2 things (each standing on its own). First
> it allows to use device memory transparently inside any process
> without any modifications to process program code. Second it allows
> to mirror process address space on a device.
> 
> Change since v12 is the use of struct page for device memory even if
> the device memory is not accessible by the CPU (because of limitation
> impose by the bus between the CPU and the device).
> 
> Using struct page means that their are minimal changes to core mm
> code. HMM build on top of ZONE_DEVICE to provide struct page, it
> adds new features to ZONE_DEVICE. The first 7 patches implement
> those changes.
> 
> Rest of patchset is divided into 3 features that can each be use
> independently from one another. First is the process address space
> mirroring (patch 9 to 13), this allow to snapshot CPU page table
> and to keep the device page table synchronize with the CPU one.
> 
> Second is a new memory migration helper which allow migration of
> a range of virtual address of a process. This memory migration
> also allow device to use their own DMA engine to perform the copy
> between the source memory and destination memory. This can be
> usefull even outside HMM context in many usecase.
> 
> Third part of the patchset (patch 17-18) is a set of helper to
> register a ZONE_DEVICE node and manage it. It is meant as a
> convenient helper so that device drivers do not each have to
> reimplement over and over the same boiler plate code.
> 
> 
> I am hoping that this can now be consider for inclusion upstream.
> Bottom line is that without HMM we can not support some of the new
> hardware features on x86 PCIE. I do believe we need some solution
> to support those features or we won't be able to use such hardware
> in standard like C++17, OpenCL 3.0 and others.
> 
> I have been working with NVidia to bring up this feature on their
> Pascal GPU. There are real hardware that you can buy today that
> could benefit from HMM. We also intend to leverage this inside the
> open source nouveau driver.
> 

Hi,

We (NVIDIA engineering) have been working closely with Jerome on this for 
several years now, and I wanted to mention that NVIDIA is committed to 
using HMM. We've done initial testing of this patchset on Pascal GPUs (a 
bit more detail below) and it is looking good.
  
The HMM features are a prerequisite to an important part of NVIDIA's 
efforts to make writing code for GPUs (and other page-faulting devices) 
easier--by making it more like writing code for CPUs. A big part of that 
story involves being able to use malloc'd memory transparently everywhere. 
Here's a tiny example (in case it's not obvious from the HMM patchset 
documentation) of HMM in action:

        int *p = (int*)malloc(SIZE); *p = 5; /* on the CPU */

        x = *p;   /* on a GPU, or on any page-fault-capable device */
   
1. A device page fault occurs because the malloc'd memory was never 
allocated in the device's page tables.
  
2. The device driver receives a page fault interrupt, but fails to 
recognize the address, so it calls into HMM.

3. HMM knows that p is valid on the CPU, and coordinates with the device 
driver to unmap the CPU page, allocate a page on the device, and then 
migrate (copy) the data to the device. This allows full device memory 
bandwidth to be available, which is critical to getting good performance.

    a) Alternatively, leave the page on the CPU, and create a device 
PTE to point to that page. This might be done if our performance counters 
show that a page is thrashing.
   
4. The device driver issues a replay-page-fault to the device.
 
5. The device program continues running, and x == 5 now.

When version 1 of this patchset was created (2.5 years ago! in May, 2014), 
one huge concern was that we didn't yet have hardware that could use it.  
But now we do: Pascal GPUs, which have been shipping this year, all 
support replayable page faults.

Testing:

We have done some testing of this latest patchset on Pascal GPUs using our 
nvidia-uvm.ko module (which is open source, separate from the closed 
source nvidia.ko). There is still much more testing to do, of course, but 
basic page mirroring and page migration (between CPU and GPU), and even 
some multi-GPU cases, are all working.

We do think we've found a bug in a corner case that involves invalid GPU 
memory (of course, it's always possible that the bug is on our side), 
which Jerome is investigating now. If you spot the bug by inspection, 
you'll get some major told-you-so points. :)

The performance is looking good on the testing wea??ve done so far, too.

thanks,

John Hubbard
NVIDIA Systems Software Engineer

> 
> In this patchset i restricted myself to set of core features what
> is missing:
>   - force read only on CPU for memory duplication and GPU atomic
>   - changes to mmu_notifier for optimization purposes
>   - migration of file back page to device memory
> 
> I plan to submit a couple more patchset to implement those feature
> once core HMM is upstream.
> 
> 
> Is there anything blocking HMM inclusion ? Something fundamental ?
> 
> 
> Previous patchset posting :
>     v1 http://lwn.net/Articles/597289/
>     v2 https://lkml.org/lkml/2014/6/12/559
>     v3 https://lkml.org/lkml/2014/6/13/633
>     v4 https://lkml.org/lkml/2014/8/29/423
>     v5 https://lkml.org/lkml/2014/11/3/759
>     v6 http://lwn.net/Articles/619737/
>     v7 http://lwn.net/Articles/627316/
>     v8 https://lwn.net/Articles/645515/
>     v9 https://lwn.net/Articles/651553/
>     v10 https://lwn.net/Articles/654430/
>     v11 http://www.gossamer-threads.com/lists/linux/kernel/2286424
>     v12 http://www.kernelhub.org/?msg=972982&p=2
> 
> Cheers,
> JA(C)rA'me
> 
> JA(C)rA'me Glisse (18):
>   mm/memory/hotplug: convert device parameter bool to set of flags
>   mm/ZONE_DEVICE/unaddressable: add support for un-addressable device
>     memory
>   mm/ZONE_DEVICE/free_hot_cold_page: catch ZONE_DEVICE pages
>   mm/ZONE_DEVICE/free-page: callback when page is freed
>   mm/ZONE_DEVICE/devmem_pages_remove: allow early removal of device
>     memory
>   mm/ZONE_DEVICE/unaddressable: add special swap for unaddressable
>   mm/ZONE_DEVICE/x86: add support for un-addressable device memory
>   mm/hmm: heterogeneous memory management (HMM for short)
>   mm/hmm/mirror: mirror process address space on device with HMM helpers
>   mm/hmm/mirror: add range lock helper, prevent CPU page table update
>     for the range
>   mm/hmm/mirror: add range monitor helper, to monitor CPU page table
>     update
>   mm/hmm/mirror: helper to snapshot CPU page table
>   mm/hmm/mirror: device page fault handler
>   mm/hmm/migrate: support un-addressable ZONE_DEVICE page in migration
>   mm/hmm/migrate: add new boolean copy flag to migratepage() callback
>   mm/hmm/migrate: new memory migration helper for use with device memory
>   mm/hmm/devmem: device driver helper to hotplug ZONE_DEVICE memory
>   mm/hmm/devmem: dummy HMM device as an helper for ZONE_DEVICE memory
> 
>  MAINTAINERS                                |    7 +
>  arch/ia64/mm/init.c                        |   19 +-
>  arch/powerpc/mm/mem.c                      |   18 +-
>  arch/s390/mm/init.c                        |   10 +-
>  arch/sh/mm/init.c                          |   18 +-
>  arch/tile/mm/init.c                        |   10 +-
>  arch/x86/mm/init_32.c                      |   19 +-
>  arch/x86/mm/init_64.c                      |   23 +-
>  drivers/dax/pmem.c                         |    3 +-
>  drivers/nvdimm/pmem.c                      |    5 +-
>  drivers/staging/lustre/lustre/llite/rw26.c |    8 +-
>  fs/aio.c                                   |    7 +-
>  fs/btrfs/disk-io.c                         |   11 +-
>  fs/hugetlbfs/inode.c                       |    9 +-
>  fs/nfs/internal.h                          |    5 +-
>  fs/nfs/write.c                             |    9 +-
>  fs/proc/task_mmu.c                         |   10 +-
>  fs/ubifs/file.c                            |    8 +-
>  include/linux/balloon_compaction.h         |    3 +-
>  include/linux/fs.h                         |   13 +-
>  include/linux/hmm.h                        |  516 ++++++++++++
>  include/linux/memory_hotplug.h             |   17 +-
>  include/linux/memremap.h                   |   39 +-
>  include/linux/migrate.h                    |    7 +-
>  include/linux/mm_types.h                   |    5 +
>  include/linux/swap.h                       |   18 +-
>  include/linux/swapops.h                    |   67 ++
>  kernel/fork.c                              |    2 +
>  kernel/memremap.c                          |   48 +-
>  mm/Kconfig                                 |   23 +
>  mm/Makefile                                |    1 +
>  mm/balloon_compaction.c                    |    2 +-
>  mm/hmm.c                                   | 1175 ++++++++++++++++++++++++++++
>  mm/memory.c                                |   33 +
>  mm/memory_hotplug.c                        |    4 +-
>  mm/migrate.c                               |  651 ++++++++++++++-
>  mm/mprotect.c                              |   12 +
>  mm/page_alloc.c                            |   10 +
>  mm/rmap.c                                  |   47 ++
>  tools/testing/nvdimm/test/iomap.c          |    2 +-
>  40 files changed, 2811 insertions(+), 83 deletions(-)
>  create mode 100644 include/linux/hmm.h
>  create mode 100644 mm/hmm.c
> 
> -- 
> 2.4.3
> 
> 
--296541600-505592587-1479516081=:53648--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
