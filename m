Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A65B76B0007
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:27:54 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 65-v6so19699966qkl.11
        for <linux-mm@kvack.org>; Wed, 23 May 2018 11:27:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h45-v6si5951123qtc.12.2018.05.23.11.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 11:27:53 -0700 (PDT)
Subject: Re: [PATCH RFCv2 0/4] virtio-mem: paravirtualized memory
References: <20180523182404.11433-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <d1b3e5cb-a96b-bb93-71f2-55fb82dd5e49@redhat.com>
Date: Wed, 23 May 2018 20:27:48 +0200
MIME-Version: 1.0
In-Reply-To: <20180523182404.11433-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cornelia Huck <cohuck@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Halil Pasic <pasic@linux.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Jason Wang <jasowang@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Len Brown <lenb@kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Stefan Hajnoczi <stefanha@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, KVM <kvm@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, qemu-s390x <qemu-s390x@nongnu.org>

On 23.05.2018 20:24, David Hildenbrand wrote:
> This is the Linux driver side of virtio-mem. Compared to the QEMU side,
> it is in a pretty complete and clean state.
> 
> virtio-mem is a paravirtualized mechanism of adding/removing memory to/from
> a VM. We can do this on a 4MB granularity right now. In Linux, all
> memory is added to the ZONE_NORMAL, so unplugging cannot be guaranteed -
> but will be more likely to succeed compared to unplugging 128MB+ chunks.
> We might implement some optimizations in that area in the future that will
> make memory unplug more reliable.
> 
> For now, this is an easy way to give a VM access to more memory and
> eventually to remove some memory again. I am testing it on x86 and
> s390x (under QEMU TCG so far only).
> 
> This is the follow up on [1], but the concept, user interface and
> virtio protocol has been heavily changed. I am only including the important
> parts in this cover letter (because otherwise nobody will read it).  Please
> feel free to ask in case there are any questions.
> 
> This series is based on [4] and shows how it is being used. It contains
> further information. Also have a look at the description of patch nr 4 in
> this series.
> 
> This work is the result of the initital idea of Andrea Arcangeli to host
> enforce guest access to memory inflated in virtio-balloon using
> userfaultfd, which turned out to be problematic to implement. That's how
> I came up with virtio-mem.
> 
> --------------------------------------------------------------------------
> 1. High level concept
> --------------------------------------------------------------------------
> 
> Each virtio-mem device owns a memory region in the physical address space.
> The guest is allowed to plug and online up to 'requested_size' of memory.
> It will not be allowed to plug more than that size. Unplugged memory will
> be protected by configurable mechanisms (e.g. random discard, userfaultfd
> protection, etc.). virtio-mem is designed in a way that a guest may never
> assume to be able to even read unplugged memory. This is a big difference
> to classical balloon drivers.
> 
> The usable memory region might grow over time, so not all parts of the
> device memory region might be usable from the start. This is an
> optimization to allow a smarter implementation in the hypervisor (reduce
> size of dirty bitmaps, size of memory regions ...).
> 
> When the device driver starts up, it will query 'requested_size' and start
> to add memory to the system. This memory is not indicated e.g. via ACPI,
> so unmodified systems will not silently try to use unplugged memory that
> they are not supposed to touch.
> 
> Updates on the 'requested_size' indicate hypervisor requests to plug or
> unplug memory.
> 
> As each virtio-mem device can belong to a NUMA node, we can easily
> plug/unplug memory on a NUMA basis. And of course, we can have several
> independent virtio-mem devices for a VM.
> 
> The idea is *not* to add new virtio-mem devices when hotplugging memory,
> the idea is to resize (grow/shrink) virtio-mem devices.
> 
> --------------------------------------------------------------------------
> 2. Benefits
> --------------------------------------------------------------------------
> 
> Guest side:
> - Increase memory usable by Linux in 4MB steps (vs. section size like 128MB
>   on x86 or 2GB on e.g. some arm if I'm not mistaking)
> - Remove struct pages once all 4MB chunks of a section are offline (in
>   contrast to all balloon drivers where this never happens)
> - Don't fragment memory, while still being able to unplug smaller chunks
>   than ordinary DIMM sizes.
> - Memory hotplug support for architectures that have no proper interface
>   (e.g. s390x misses the external notification part) or e.g. QEMU/Linux
>   support is complicated to implement.
> - Automatic management of onlining/offlining in the device driver -
>   no manual interaction from an admin/tool necessary.
> 
> QEMU side:
> - Resizing (plug/unplug) has a single interface - in contrast to a mixture
>   of ACPI and virtio-balloon. See the example below.
> - Migration works out of the box - no need to specify new DIMMs or new
>   sizes on the migration target. It simply works.
> - We can resize in arbitrary steps and sizes (in contrast to e.g. ACPI,
>   where we have to know upfront in which granularity we later on want to
>   remove memory or even how much memory we eventually want to add to our
>   guest)
> - One interface to rule them (architectures) all :)
> 
> --------------------------------------------------------------------------
> 3. Reboot handling
> --------------------------------------------------------------------------
> 
> After a reboot, all memory is unplugged. This allows the hypervisor
> to see if support for virtio-mem is available in the freshly booted system.
> This way we could charge only for the actually "plugged" memory size. And
> it avoids to sense for plugged memory in the guest.
> 
> E.g. on every size change of a virtio-mem device, we can notify management
> layers. So we can track how much memory a VM has plugged.
> 
> --------------------------------------------------------------------------
> 4. Example
> --------------------------------------------------------------------------
> 
> (not including resizable memory regions on the QEMU side yet, so don't
>  focus on that part - it will consume a lot of memory right now for e.g.
>  dirty bitmaps and memory slot tracking data)
> 
> Start QEMU with two virtio-mem devices that provide little memory inititally.
> 	$ qemu-system-x86_64 -m 4G,maxmem=504G \
> 		-smp sockets=2,cores=2 \
> 		[...]
> 		-object memory-backend-ram,id=mem0,size=256G \
> 		-device virtio-mem-pci,id=vm0,memdev=mem0,node=0,size=4160M \
> 		-object memory-backend-ram,id=mem1,size=256G \
> 		-device virtio-mem-pci,id=vm1,memdev=mem1,node=1,size=3G
> 
> Query the configuration ('size' tells us the guest driver is active):
> 	(qemu) info memory-devices
> 	info memory-devices
> 	Memory device [virtio-mem]: "vm0"
> 	  phys-addr: 0x140000000
> 	  node: 0
> 	  requested-size: 4362076160
> 	  size: 4362076160
> 	  max-size: 274877906944
> 	  block-size: 4194304
> 	  memdev: /objects/mem0
> 	Memory device [virtio-mem]: "vm1"
> 	  phys-addr: 0x4140000000
> 	  node: 1
> 	  requested-size: 3221225472
> 	  size: 3221225472
> 	  max-size: 274877906944
> 	  block-size: 4194304
> 	  memdev: /objects/mem1
> 
> Change the size of a virtio-mem device:
> 	(qemu) memory-device-resize vm0 40960
> 	memory-device-resize vm0 40960
> 	...
> 	(qemu) info memory-devices
> 	info memory-devices
> 	Memory device [virtio-mem]: "vm0"
> 	  phys-addr: 0x140000000
> 	  node: 0
> 	  requested-size: 42949672960
> 	  size: 42949672960
> 	  max-size: 274877906944
> 	  block-size: 4194304
> 	  memdev: /objects/mem0
> 	...
> 
> Try to unplug memory (KASAN active in the guest - a lot of memory wasted):
> 	(qemu) memory-device-resize vm0 1024
> 	memory-device-resize vm0 1024
> 	...
> 	(qemu) info memory-devices
> 	info memory-devices
> 	Memory device [virtio-mem]: "vm0"
> 	  phys-addr: 0x140000000
> 	  node: 0
> 	  requested-size: 1073741824
> 	  size: 6169821184
> 	  max-size: 274877906944
> 	  block-size: 4194304
> 	  memdev: /objects/mem0
> 	...
> 
> I am sharing for now only the linux driver side. The current code can be
> found at [2]. The QEMU side is still heavily WIP, the current QEMU
> prototype can be found at [3].
> 
> 
> [1] https://lists.gnu.org/archive/html/qemu-devel/2017-06/msg03870.html
> [2] https://github.com/davidhildenbrand/linux/tree/virtio-mem
> [3] https://github.com/davidhildenbrand/qemu/tree/virtio-mem
> [4] https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1698014.html
> 
> David Hildenbrand (4):
>   ACPI: NUMA: export pxm_to_node
>   s390: mm: support removal of memory
>   s390: numa: implement memory_add_physaddr_to_nid()
>   virtio-mem: paravirtualized memory
> 
>  arch/s390/mm/init.c             |   18 +-
>  arch/s390/numa/numa.c           |   12 +
>  drivers/acpi/numa.c             |    1 +
>  drivers/virtio/Kconfig          |   15 +
>  drivers/virtio/Makefile         |    1 +
>  drivers/virtio/virtio_mem.c     | 1040 +++++++++++++++++++++++++++++++
>  include/uapi/linux/virtio_ids.h |    1 +
>  include/uapi/linux/virtio_mem.h |  134 ++++
>  8 files changed, 1216 insertions(+), 6 deletions(-)
>  create mode 100644 drivers/virtio/virtio_mem.c
>  create mode 100644 include/uapi/linux/virtio_mem.h
> 

cc-ing some further mailing lists

-- 

Thanks,

David / dhildenb
