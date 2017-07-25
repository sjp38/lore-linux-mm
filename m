Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BE8C6B02C3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 04:21:53 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i19so35558581qte.5
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 01:21:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m49si1410604qtb.439.2017.07.25.01.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 01:21:50 -0700 (PDT)
Subject: Re: [RFC] virtio-mem: paravirtualized memory
From: David Hildenbrand <david@redhat.com>
References: <547865a9-d6c2-7140-47e2-5af01e7d761d@redhat.com>
Message-ID: <c244851d-ef0d-f680-090d-e90b5be3103e@redhat.com>
Date: Tue, 25 Jul 2017 10:21:43 +0200
MIME-Version: 1.0
In-Reply-To: <547865a9-d6c2-7140-47e2-5af01e7d761d@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KVM <kvm@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>

(ping)

Hi,

this has been on these lists for quite some time now. I want to start
preparing a virtio spec for virtio-mem soon.

So if you have any more comments/ideas/objections/questions, now is the
right time to post them :)

Thanks!


On 16.06.2017 16:20, David Hildenbrand wrote:
> Hi,
> 
> this is an idea that is based on Andrea Arcangeli's original idea to
> host enforce guest access to memory given up using virtio-balloon using
> userfaultfd in the hypervisor. While looking into the details, I
> realized that host-enforcing virtio-balloon would result in way too many
> problems (mainly backwards compatibility) and would also have some
> conceptual restrictions that I want to avoid. So I developed the idea of
> virtio-mem - "paravirtualized memory".
> 
> The basic idea is to add memory to the guest via a paravirtualized
> mechanism (so the guest can hotplug it) and remove memory via a
> mechanism similar to a balloon. This avoids having to online memory as
> "online-movable" in the guest and allows more fain grained memory
> hot(un)plug. In addition, migrating QEMU guests after adding/removing
> memory gets a lot easier.
> 
> Actually, this has a lot in common with the XEN balloon or the Hyper-V
> balloon (namely: paravirtualized hotplug and ballooning), but is very
> different when going into the details.
> 
> Getting this all implemented properly will take quite some effort,
> that's why I want to get some early feedback regarding the general
> concept. If you have some alternative ideas, or ideas how to modify this
> concept, I'll be happy to discuss. Just please make sure to have a look
> at the requirements first.
> 
> -----------------------------------------------------------------------
> 0. Outline:
> -----------------------------------------------------------------------
> - I.    General concept
> - II.   Use cases
> - III.  Identified requirements
> - IV.   Possible modifications
> - V.    Prototype
> - VI.   Problems to solve / things to sort out / missing in prototype
> - VII.  Questions
> - VIII. Q&A
> 
> ------------------------------------------------------------------------
> I. General concept
> ------------------------------------------------------------------------
> 
> We expose memory regions to the guest via a paravirtualize interface. So
> instead of e.g. a DIMM on x86, such memory is not anounced via ACPI.
> Unmodified guests (without a virtio-mem driver) won't be able to see/use
> this memory. The virtio-mem guest driver is needed to detect and manage
> these memory areas. What makes this memory special is that it can grow
> while the guest is running ("plug memory") and might shrink on a reboot
> (to compensate "unplugged" memory - see next paragraph). Each virtio-mem
> device manages exactly one such memory area. By having multiple ones
> assigned to different NUMA nodes, we can modify memory on a NUMA basis.
> 
> Of course, we cannot shrink these memory areas while the guest is
> running. To be able to unplug memory, we do something like a balloon
> does, however limited to this very memory area that belongs to the
> virtio-mem device. The guest will hand back small chunks of memory. If
> we want to add memory to the guest, we first "replug" memory that has
> previously been given up by the guest, before we grow our memory area.
> 
> On a reboot, we want to avoid any memory holes in our memory, therefore
> we resize our memory area (shrink it) to compensate memory that has been
> unplugged. This highly simplifies hotplugging memory in the guest (
> hotplugging memory with random memory holes is basically impossible).
> 
> We have to make sure that all memory chunks the guest hands back on
> unplug requests will not consume memory in the host. We do this by
> write-protecting that memory chunk in the host and then dropping the
> backing pages. The guest can read this memory (reading from the ZERO
> page) but no longer write to it. For now, this will only work on
> anonymous memory. We will use userfaultfd WP (write-protect mode) to
> avoid creating too many VMAs. Huge pages will require more effort (no
> explicit ZERO page).
> 
> As we unplug memory on a fine grained basis (and e.g. not on
> a complete DIMM basis), there is no need to online virtio-mem memory
> as online-movable. Also, memory unplug support for Windows might be
> supported that way. You can find more details in the Q/A section below.
> 
> 
> The important points here are:
> - After a reboot, every memory the guest sees can be accessed and used.
>   (in contrast to e.g. the XEN balloon, see Q/A fore more details)
> - Rebooting into an unmodified guest will not result into random
>   crashed. The guest will simply not be able to use all memory without a
>   virtio-mem driver.
> - Adding/Removing memory will not require modifying the QEMU command
>   line on the migration target. Migration simply works (re-sizing memory
>   areas is already part of the migration protocol!). Essentially, this
>   makes adding/removing memory to/from a guest way simpler and
>   independent of the underlying architecture. If the guest OS can online
>   new memory, we can add more memory this way.
> - Unplugged memory can be read. This allows e.g. kexec() without nasty
>   modifications. Especially relevant for Windows' kexec() variant.
> - It will play nicely with other things mapped into the address space,
>   e.g. also other DIMMs or NVDIMM. virtio-mem will only work on its own
>   memory region (in contrast e.g. to virtio-balloon). Especially it will
>   not give up ("allocate") memory on other DIMMs, hindering them to get
>   unplugged the ACPI way.
> - We can add/remove memory without running into KVM memory slot or other
>   (e.g. ACPI slot) restrictions. The granularity in which we can add
>   memory is only limited by the granularity the guest can add memory
>   (e.g. Windows 2MB, Linux on x86 128MB for now).
> - By not having to online memory as online-movable we don't run into any
>   memory restrictions in the guest. E.g. page tables can only be created
>   on !movable memory. So while there might be plenty of online-movable
>   memory left, allocation of page tables might fail. See Q/A for more
>   details.
> - The admin will not have to set memory offline in the guest first in
>   order to unplug it. virtio-mem will handle this internally and not
>   require interaction with an admin or a guest-agent.
> 
> Important restrictions of this concept:
> - Guests without a virtio-mem guest driver can't see that memory.
> - We will always require some boot memory that cannot get unplugged.
>   Also, virtio-mem memory (as all other hotplugged memory) cannot become
>   DMA memory under Linux. So the boot memory also defines the amount of
>   DMA memory.
> - Hibernation/Sleep+Restore while virtio-mem is active is not supported.
>   On a reboot/fresh start, the size of the virtio-mem memory area might
>   change and a running/loaded guest can't deal with that.
> - Unplug support for hugetlbfs/shmem will take quite some time to
>   support. The larger the used page size, the harder for the guest to
>   give up memory. We can still use DIMM based hotplug for that.
> - Huge huge pages are problematic, as the guest would have to give up
>   e.g. 1GB chunks. This is not expected to be supported. We can still
>   use DIMM based hotplug for setups that require that.
> - For any memory we unplug using this mechanism, for now we will still
>   have struct pages allocated in the guest. This means, that roughly
>   1.6% of unplugged memory will still be allocated in the guest, being
>   unusable.
> 
> 
> ------------------------------------------------------------------------
> II. Use cases
> ------------------------------------------------------------------------
> 
> Of course, we want to deny any access to unplugged memory. In contrast
> to virtio-balloon or other similar ideas (free page hinting), this is
> not about cooperative memory management, but about guarantees. The idea
> is, that both concepts can coexist.
> 
> So one use case is of course cloud providers. Customers can add
> or remove memory to/from a VM without having to care about how to
> online memory or in which amount to add memory in the first place in
> order to remove it again. In cloud environments, we care about
> guarantees. E.g. for virtio-balloon a malicious guest can simply reuse
> any deflated memory, and the hypervisor can't even tell if the guest is
> malicious (e.g. a harmless guest reboot might look like a malicious
> guest). For virtio-mem, we guarantee that the guest can't reuse any
> memory that it previously gave up.
> 
> But also for ordinary VMs (!cloud), this avoids having to online memory
> in the guest as online-movable and therefore not running into allocation
> problems if there are e.g. many processes needing many page tables on
> !movable memory. Also here, we don't have to know how much memory we
> want to remove some-when in the future before we add memory. (e.g. if we
> add a 128GB DIMM, we can only remove that 128GB DIMM - if we are lucky).
> 
> We might be able to support memory unplug for Windows (as for now,
> ACPI unplug is not supported), more details have to be clarified.
> 
> As we can grow these memory areas quite easily, another use case might
> be guests that tell us they need more memory. Thinking about VMs to
> protect containers, there seems to be the general problem that we don't
> know how much memory the container will actually need. We could
> implement a mechanism (in virtio-mem or guest driver), by which the
> guest can request more memory. If the hypervisor agrees, it can simply
> give the guest more memory. As this is all handled within QEMU,
> migration is not a problem. Adding more memory will not result in new
> DIMM devices.
> 
> 
> ------------------------------------------------------------------------
> III. Identified requirements
> ------------------------------------------------------------------------
> 
> I considered the following requirements.
> 
> NUMA aware:
>   We want to be able to add/remove memory to/from NUMA nodes.
> Different page-size support:
>   We want to be able to support different page sizes, e.g. because of
>   huge pages in the hypervisor or because host and guest have different
>   page sizes (powerpc 64k vs 4k).
> Guarantees:
>   There has to be no way the guest can reuse unplugged memory without
>   host consent. Still, we could implement a mechanism for the guest to
>   request more memory. The hypervisor then has to decide how it wants to
>   handle that request.
> Architecture independence:
>   We want this to work independently of other technologies bound to
>   specific architectures, like ACPI.
> Avoid online-movable:
>   We don't want to have to online memory in the guest as online-movable
>   just to be able to unplug (at least parts of) it again.
> Migration support:
>   Be able to migrate without too much hassle. Especially, to handle it
>   completely within QEMU (not having to add new devices to the target
>   command line).
> Windows support:
>   We definitely want to support Windows guests in the long run.
> Coexistence with other hotplug mechanisms:
>   Allow to hotplug DIMMs / NVDIMMs, therefore to share the "hotplug"
>   address space part with other devices.
> Backwards compatibility:
>   Don't break if rebooting into an unmodified guest after having
>   unplugged some memory. All memory a freshly booted guest sees must not
>   contain memory holes that will crash it if it tries to access it.
> 
> 
> ------------------------------------------------------------------------
> IV. Possible modifications
> ------------------------------------------------------------------------
> 
> Adding a guest->host request mechanism would make sense to e.g. be able
> to request further memory from the hypervisor directly from the guest.
> 
> Adding memory will be much easier than removing memory. We can split
> this up and first introduce "adding memory" and later add "removing
> memory". Removing memory will require userfaultfd WP in the hypervisor
> and a special fancy allocator in the guest. So this will take some time.
> 
> Adding a mechanism to trade in memory blocks might make sense to allow
> some sort of memory compaction. However I expect this to be highly
> complicated and basically not feasible.
> 
> Being able to unplug memory "any" memory instead of only memory
> belonging to the virtio-mem device sounds tempting (and simplifies
> certain parts), however it has a couple of side effects I want to avoid.
> You can read more about that in the Q/A below.
> 
> 
> ------------------------------------------------------------------------
> V. Prototype
> ------------------------------------------------------------------------
> 
> To identify potential problems I developed a very basic prototype. It
> is incomplete, full of hacks and most probably broken in various ways.
> I used it only in the given setup, only on x86 and only with an initrd.
> 
> It uses a fixed page size of 256k for now, has a very ugly allocator
> hack in the guest, the virtio protocol really needs some tuning and
> an async job interface towards the user is missing. Instead of using
> userfaultfd WP, I am using simply mprotect() in this prototype. Basic
> migration works (not involving userfaultfd).
> 
> Please, don't even try to review it (that's why I will also not attach
> any patches to this mail :) ), just use this as an inspiration what this
> could look like. You can find the latest hack at:
> 
> QEMU: https://github.com/davidhildenbrand/qemu/tree/virtio-mem
> 
> Kernel: https://github.com/davidhildenbrand/linux/tree/virtio-mem
> 
> Use the kernel in the guest and make sure to compile the virtio-mem
> driver into the kernel (CONFIG_VIRTIO_MEM=y). A host kernel patch is
> contained to allow atomic resize of KVM memory regions, however it is
> pretty much untested.
> 
> 
> 1. Starting a guest with virtio-mem memory:
>    We will create a guest with 2 NUMA nodes and 4GB of "boot + DMA"
>    memory. This memory is visible also to guests without virtio-mem.
>    Also, we will add 4GB to NUMA node 0 and 3GB to NUMA node 1 using
>    virtio-mem. We allow both virtio-mem devices to grow up to 8GB. The
>    last 4 lines are the important part.
> 
> --> qemu/x86_64-softmmu/qemu-system-x86_64 \
> 	--enable-kvm
> 	-m 4G,maxmem=20G \
> 	-smp sockets=2,cores=2 \
> 	-numa node,nodeid=0,cpus=0-1 -numa node,nodeid=1,cpus=2-3 \
> 	-machine pc \
> 	-kernel linux/arch/x86_64/boot/bzImage \
> 	-nodefaults \
> 	-chardev stdio,id=serial \
> 	-device isa-serial,chardev=serial \
> 	-append "console=ttyS0 rd.shell rd.luks=0 rd.lvm=0" \
> 	-initrd /boot/initramfs-4.10.8-200.fc25.x86_64.img \
> 	-chardev socket,id=monitor,path=/var/tmp/monitor,server,nowait \
> 	-mon chardev=monitor,mode=readline \
> 	-object memory-backend-ram,id=mem0,size=4G,max-size=8G \
> 	-device virtio-mem-pci,id=reg0,memdev=mem0,node=0 \
> 	-object memory-backend-ram,id=mem1,size=3G,max-size=8G \
> 	-device virtio-mem-pci,id=reg1,memdev=mem1,node=1
> 
> 2. Listing current memory assignment:
> 
> --> (qemu) info memory-devices
> 	Memory device [virtio-mem]: "reg0"
> 	  addr: 0x140000000
> 	  node: 0
> 	  size: 4294967296
> 	  max-size: 8589934592
> 	  memdev: /objects/mem0
> 	Memory device [virtio-mem]: "reg1"
> 	  addr: 0x340000000
> 	  node: 1
> 	  size: 3221225472
> 	  max-size: 8589934592
> 	  memdev: /objects/mem1
> --> (qemu) info numa
> 	2 nodes
> 	node 0 cpus: 0 1
> 	node 0 size: 6144 MB
> 	node 1 cpus: 2 3
> 	node 1 size: 5120 MB
> 
> 3. Resize a virtio-mem device: Unplugging memory.
>    Setting reg0 to 2G (remove 2G from NUMA node 0)
> 
> --> (qemu) virtio-mem reg0 2048
> 	virtio-mem reg0 2048
> --> (qemu) info numa
> 	info numa
> 	2 nodes
> 	node 0 cpus: 0 1
> 	node 0 size: 4096 MB
> 	node 1 cpus: 2 3
> 	node 1 size: 5120 MB
> 
> 4. Resize a virtio-mem device: Plugging memory
>    Setting reg0 to 8G (adding 6G to NUMA node 0) will replug 2G and plug
>    4G, automatically re-sizing the memory area. You might experience
>    random crashes at this point if the host kernel missed a KVM patch
>    (as the memory slot is not re-sized in an atomic fashion).
> 
> --> (qemu) virtio-mem reg0 8192
> 	virtio-mem reg0 8192
> --> (qemu) info numa
> 	info numa
> 	2 nodes
> 	node 0 cpus: 0 1
> 	node 0 size: 10240 MB
> 	node 1 cpus: 2 3
> 	node 1 size: 5120 MB
> 
> 5. Resize a virtio-mem device: Try to unplug all memory.
>    Setting reg0 to 0G (removing 8G from NUMA node 0) will not work. The
>    guest will not be able to unplug all memory. In my example, 164M
>    cannot be unplugged (out of memory).
> 
> --> (qemu) virtio-mem reg0 0
> 	virtio-mem reg0 0
> --> (qemu) info numa
> 	info numa
> 	2 nodes
> 	node 0 cpus: 0 1
> 	node 0 size: 2212 MB
> 	node 1 cpus: 2 3
> 	node 1 size: 5120 MB
> --> (qemu) info virtio-mem reg0
> 	info virtio-mem reg0
> 	Status: ready
> 	Request status: vm-oom
> 	Page size: 2097152 bytes
> --> (qemu) info memory-devices
> 	Memory device [virtio-mem]: "reg0"
> 	  addr: 0x140000000
> 	  node: 0
> 	  size: 171966464
> 	  max-size: 8589934592
> 	  memdev: /objects/mem0
> 	Memory device [virtio-mem]: "reg1"
> 	  addr: 0x340000000
> 	  node: 1
> 	  size: 3221225472
> 	  max-size: 8589934592
> 	  memdev: /objects/mem1
> 
> At any point, we can migrate our guest without having to care about
> modifying the QEMU command line on the target side. Simply start the
> target e.g. with an additional '-incoming "exec: cat IMAGE"' and you're
> done.
> 
> ------------------------------------------------------------------------
> VI. Problems to solve / things to sort out / missing in prototype
> ------------------------------------------------------------------------
> 
> General:
> - We need an async job API to send the unplug/replug/plug requests to
>   the guest and query the state. [medium/hard]
> - Handle various alignment problems. [medium]
> - We need a virtio spec
> 
> Relevant for plug:
> - Resize QEMU memory regions while the guest is running (esp. grow).
>   While I implemented a demo solution for KVM memory slots, something
>   similar would be needed for vhost. Re-sizing of memory slots has to be
>   an atomic operation. [medium]
> - NUMA: Most probably the NUMA node should not be part of the virtio-mem
>   device, this should rather be indicated via e.g. ACPI. [medium]
> - x86: Add the complete possible memory to the a820 map as reserved.
>   [medium]
> - x86/powerpc/...: Indicate to which NUMA node the memory belongs using
>   ACPI. [medium]
> - x86/powerpc/...: Share address space with ordinary DIMMS/NVDIMMs, for
>   now this is blocked for simplicity. [medium/hard]
> - If the bitmaps become too big, migrate them like memory. [medium]
> 
> Relevant for unplug:
> - Allocate memory in Linux from a specific memory range. Windows has a
>   nice interface for that (at least it looks nice when reading the API).
>   This could be done using fake NUMA nodes or a new ZONE. My prototype
>   just uses a very ugly hack. [very hard]
> - Use userfaultfd WP (write-protect) insted of mprotect. Especially,
>   have multiple userfaultfd user in QEMU at a time (postcopy).
>   [medium/hard]
> 
> Stuff for the future:
> - Huge pages are problematic (no ZERO page support). This might not be
>   trivial to support. [hard/very hard]
> - Try to free struct pages, to avoid the 1.6% overhead [very very hard]
> 
> 
> ------------------------------------------------------------------------
> VII. Questions
> ------------------------------------------------------------------------
> 
> To get unplug working properly, it will require quite some effort,
> that's why I want to get some basic feedback before continuing working
> on a RFC implementation + RFC virtio spec.
> 
> a) Did I miss anything important? Are there any ultimate blockers that I
>    ignored? Any concepts that are broken?
> 
> b) Are there any alternatives? Any modifications that could make life
>    easier while still taking care of the requirements?
> 
> c) Are there other use cases we should care about and focus on?
> 
> d) Am I missing any requirements? What else could be important for
>    !cloud and cloud?
> 
> e) Are there any possible solutions to the allocator problem (allocating
>    memory from a specific memory area)? Please speak up!
> 
> f) Anything unclear?
> 
> e) Any feelings about this? Yay or nay?
> 
> 
> As you reached this point: Thanks for having a look!!! Highly appreciated!
> 
> 
> ------------------------------------------------------------------------
> VIII. Q&A
> ------------------------------------------------------------------------
> 
> ---
> Q: What's the problem with ordinary memory hot(un)plug?
> 
> A: 1. We can only unplug in the granularity we plugged. So we have to
>       know in advance, how much memory we want to remove later on. If we
>       plug a 2G dimm, we can only unplug a 2G dimm.
>    2. We might run out of memory slots. Although very unlikely, this
>       would strike if we try to always plug small modules in order to be
>       able to unplug again (e.g. loads of 128MB modules).
>    3. Any locked page in the guest can hinder us from unplugging a dimm.
>       Even if memory was onlined as online_movable, a single locked page
>       can hinder us from unplugging that memory dimm.
>    4. Memory has to be onlined as online_movable. If we don't put that
>       memory into the movable zone, any non-movable kernel allocation
>       could end up on it, turning the complete dimm unpluggable. As
>       certain allocations cannot go into the movable zone (e.g. page
>       tables), the ratio between online_movable/online memory depends on
>       the workload in the guest. Ratios of 50% -70% are usually fine.
>       But it could happen, that there is plenty of memory available,
>       but kernel allocations fail. (source: Andrea Arcangeli)
>    5. Unplugging might require several attempts. It takes some time to
>       migrate all memory from the dimm. At that point, it is then not
>       really obvious why it failed, and whether it could ever succeed.
>    6. Windows does support memory hotplug but not memory hotunplug. So
>       this could be a way to support it also for Windows.
> ---
> Q: Will this work with Windows?
> 
> A: Most probably not in the current form. Memory has to be at least
>    added to the a820 map and ACPI (NUMA). Hyper-V ballon is also able to
>    hotadd memory using a paravirtualized interface, so there are very
>    good chances that this will work. But we won't know for sure until we
>    also start prototyping.
> ---
> Q: How does this compare to virtio-balloo?
> 
> A: In contrast to virtio-balloon, virtio-mem
>    1. Supports multiple page sizes, even different ones for different
>       virtio-mem devices in a guest.
>    2. Is NUMA aware.
>    3. Is able to add more memory.
>    4. Doesn't work on all memory, but only on the managed one.
>    5. Has guarantees. There is now way for the guest to reclaim memory.
> ---
> Q: How does this compare to XEN balloon?
> 
> A: XEN balloon also has a way to hotplug new memory. However, on a
>    reboot, the guest will "see" more memory than it actually has.
>    Compared to XEN balloon, virtio-mem:
>    1. Supports multiple page sizes.
>    2. Is NUMA aware.
>    3. The guest can survive a reboot into a system without the guest
>       driver. If the XEN guest driver doesn't come up, the guest will
>       get killed once it touches too much memory.
>    4. Reboots don't require any hacks.
>    5. The guest knows which memory is special. And it remains special
>       during a reboot. Hotplugged memory not suddenly becomes base
>       memory. The balloon mechanism will only work on a specific memory
>       area.
> ---
> Q: How does this compare to Hyper-V balloon?
> 
> A: Based on the code from the Linux Hyper-V balloon driver, I can say
>    that Hyper-V also has a way to hotplug new memory. However, memory
>    will remain plugged on a reboot. Therefore, the guest will see more
>    memory than the hypervisor actually wants to assign to it.
>    Virtio-mem in contrast:
>    1. Supports multiple page sizes.
>    2. Is NUMA aware.
>    3. I have no idea what happens under Hyper-v when
>       a) rebooting into a guest without a fitting guest driver
>       b) kexec() touches all memory
>       c) the guest misbehaves
>    4. The guest knows which memory is special. And it remains special
>       during a reboot. Hotpplugged memory not suddenly becomes base
>       memory. The balloon mechanism will only work on a specific memory
>       area.
>    In general, it looks like the hypervisor has to deal with malicious
>    guests trying to access more memory than desired by providing enough
>    swap space.
> ---
> Q: How is virtio-mem NUMA aware?
> 
> A: Each virtio-mem device belongs exactly to one NUMA node (if NUMA is
>    enabled). As we can resize these regions separately, we can control
>    from/to which node to remove/add memory.
> ---
> Q: Why do we need support for multiple page sizes?
> 
> A: If huge pages are used in the host, we can only guarantee that they
>    are not accessible by the guest anymore, if the guest gives up memory
>    in this granularity. We prepare for that. Also, powerpc can have 64k
>    pages in the host but 4k pages in the guest. So the guest must only
>    give up 64k chunks. In addition, unplugging 4k pages might be bad
>    when it comes to fragmentation. My prototype currently uses 256k. We
>    can make this configurable - and it can vary for each virtio-mem
>    device.
> ---
> Q: What are the limitations with paravirtualized memory hotplug?
> 
> A: The same as for DIMM based hotplug, but we don't run out of any
>    memory/ACPI slots. E.g. on x86 Linux, only 128MB chunks can be
>    hotplugged, on x86 Windows it's 2MB. In addition, of course we
>    have to take care of maximum address limits in the guest. The idea
>    is to communicate these limits to the hypervisor via virtio-mem,
>    to give hints when trying to add/remove memory.
> ---
> Q: Why not simply unplug *any* memory like virtio-balloon does?
> 
> A: This could be done and a previous prototype did it like that.
>    However, there are some points to consider here.
>    1. If we combine this with ordinary memory hotplug (DIMM), we most
>       likely won't be able to unplug DIMMs anymore as virtio-mem memory
>       gets "allocated" on these.
>    2. All guests using virtio-mem cannot use huge pages as backing
>       storage at all (as virtio-mem only supports anonymous pages).
>    3. We need to track unplugged memory for the complete address space,
>       so we need a global state in QEMU. Bitmaps get bigger. We will not
>       be abe to dynamically grow the bitmaps for a virtio-mem device.
>    4. Resolving/checking memory to be unplugged gets significantly
>       harder. How should the guest know which memory it can unplug for a
>       specific virtio-mem device? E.g. if NUMA is active, only that NUMA
>       node to which a virtio-mem device belongs can be used.
>    5. We will need userfaultfd handler for the complete address space,
>       not just for the virtio-mem managed memory.
>       Especially, if somebody hotplugs a DIMM, we dynamically will have
>       to enable the userfaultfd handler.
>    6. What shall we do if somebody hotplugs a DIMM with huge pages? How
>       should we tell the guest, that this memory cannot be used for
>       unplugging?
>    In summary: This concept is way cleaner, but also harder to
>    implement.
> ---
> Q: Why not reuse virtio-balloon?
> 
> A: virtio-balloon is for cooperative memory management. It has a fixed
>    page size and will deflate in certain situations. Any change we
>    introduce will break backwards compatibility. virtio-balloon was not
>    designed to give guarantees. Nobody can hinder the guest from
>    deflating/reusing inflated memory. In addition, it might make perfect
>    sense to have both, virtio-balloon and virtio-mem at the same time,
>    especially looking at the DEFLATE_ON_OOM or STATS features of
>    virtio-balloon. While virtio-mem is all about guarantees, virtio-
>    balloon is about cooperation.
> ---
> Q: Why not reuse acpi hotplug?
> 
> A: We can easily run out of slots, migration in QEMU will just be
>    horrible and we don't want to bind virtio* to architecture specific
>    technologies.
>    E.g. thinking about s390x - no ACPI. Also, mixing an ACPI driver with
>    a virtio-driver sounds very weird. If the virtio-driver performs the
>    hotplug itself, we might later perform some extra tricks: e.g.
>    actually unplug certain regions to give up some struct pages.
> 
>    We want to manage the way memory is added/removed completely in QEMU.
>    We cannot simply add new device from within QEMU and expect that
>    migration in QEMU will work.
> ---
> Q: Why do we need resizable memory regions?
> 
> A: Migration in QEMU is special. Any device we have on our source VM has
>    to already be around on our target VM. So simply creating random
>    devides internally in QEMU is not going to work. The concept of
>    resizable memory regions in QEMU already exists and is part of the
>    migration protocol. Before memory is migrated, the memory is resized.
>    So in essence, this makes migration support _a lot_ easier.
> 
>    In addition, we won't run in any slot number restriction when
>    automatically managing how to add memory in QEMU.
> ---
> Q: Why do we have to resize memory regions on a reboot?
> 
> A: We have to compensate all memory that has been unplugged for that
>    area by shrinking it, so that a fresh guest can use all memory when
>    initializing the virtio-mem device.
> ---
> Q: Why do we need userfaultfd?
> 
> A: mprotect() will create a lot of VMAs in the kernel. This will degrade
>    performance and might even fail at one point. userfaultfd avoids this
>    by not creating a new VMA for every protected range. userfaultfd WP
>    is currently still under development and suffers from false positives
>    that make it currently impossible to properly integrate this into the
>    prototype.
> ---
> Q: Why do we have to allow reading unplugged memory?
> 
> A: E.g. if the guest crashes and want's to write a memory dump, it will
>    blindly access all memory. While we could find ways to fixup kexec,
>    Windows dumps might be more problematic. Allowing the guest to read
>    all memory (resulting in reading all 0's) safes us from a lot of
>    trouble.
> 
>    The downside is, that page tables full of zero pages might be
>    created. (we might be able to find ways to optimize this)
> ---
> Q: Will this work with postcopy live-migration?
> 
> A: Not in the current form. And it doesn't really make sense to spend
>    time on it as long as we don't use userfaultfd. Combining both
>    handlers will be interesting. It can be done with some effort on the
>    QEMU side.
> ---
> Q: What's the problem with shmem/hugetlbfs?
> 
> A: We currently rely on the ZERO page to be mapped when the guest tries
>    to read unplugged memory. For shmem/hugetlbfs, there is no ZERO page,
>    so read access would result in memory getting populated. We could
>    either introduce an explicit ZERO page, or manage it using one dummy
>    ZERO page (using regular usefaultfd, allow only one such page to be
>    mapped at a time). For now, only anonymous memory.
> ---
> Q: Ripping out random page ranges, won't this fragment our guest memory?
> 
> A: Yes, but depending on the virtio-mem page size, this might be more or
>    less problematic. The smaller the virtio-mem page size, the more we
>    fragment and make small allocations fail. The bigger the virtio-mem
>    page size, the higher the chance that we can't unplug any more
>    memory.
> ---
> Q: Why can't we use memory compaction like virtio-balloon?
> 
> A: If the virtio-mem page size > PAGE_SIZE, we can't do ordinary
>    page migration, migration would have to be done in blocks. We could
>    later add an guest->host virtqueue, via which the guest can
>    "exchange" memory ranges. However, also mm has to support this kind
>    of migration. So it is not completely out of scope, but will require
>    quite some work.
> ---
> Q: Do we really need yet another paravirtualized interface for this?
> 
> A: You tell me :)
> ---
> 
> Thanks,
> 
> David
> 


-- 

Thanks,

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
