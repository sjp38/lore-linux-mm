Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5F16B0036
	for <linux-mm@kvack.org>; Sun, 20 Jul 2014 13:46:56 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id w8so4496848qac.16
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 10:46:56 -0700 (PDT)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id d6si24345745qaf.31.2014.07.20.10.46.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 20 Jul 2014 10:46:55 -0700 (PDT)
Received: by mail-qc0-f171.google.com with SMTP id i17so4944369qcy.16
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 10:46:55 -0700 (PDT)
Date: Sun, 20 Jul 2014 13:46:53 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
Message-ID: <20140720174652.GE3068@gmail.com>
References: <53C7D645.3070607@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <53C7D645.3070607@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>
Cc: David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <deathsimple@vodafone.de>, Michel =?iso-8859-1?Q?D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On Thu, Jul 17, 2014 at 04:57:25PM +0300, Oded Gabbay wrote:
> Forgot to cc mailing list on cover letter. Sorry.
> 
> As a continuation to the existing discussion, here is a v2 patch series
> restructured with a cleaner history and no totally-different-early-versions
> of the code.
> 
> Instead of 83 patches, there are now a total of 25 patches, where 5 of them
> are modifications to radeon driver and 18 of them include only amdkfd code.
> There is no code going away or even modified between patches, only added.
> 
> The driver was renamed from radeon_kfd to amdkfd and moved to reside under
> drm/radeon/amdkfd. This move was done to emphasize the fact that this driver
> is an AMD-only driver at this point. Having said that, we do foresee a
> generic hsa framework being implemented in the future and in that case, we
> will adjust amdkfd to work within that framework.
> 
> As the amdkfd driver should support multiple AMD gfx drivers, we want to
> keep it as a seperate driver from radeon. Therefore, the amdkfd code is
> contained in its own folder. The amdkfd folder was put under the radeon
> folder because the only AMD gfx driver in the Linux kernel at this point
> is the radeon driver. Having said that, we will probably need to move it
> (maybe to be directly under drm) after we integrate with additional AMD gfx
> drivers.
> 
> For people who like to review using git, the v2 patch set is located at:
> http://cgit.freedesktop.org/~gabbayo/linux/log/?h=kfd-next-3.17-v2
> 
> Written by Oded Gabbayh <oded.gabbay@amd.com>

So quick comments before i finish going over all patches. There is many
things that need more documentation espacialy as of right now there is
no userspace i can go look at.

There few show stopper, biggest one is gpu memory pinning this is a big
no, that would need serious arguments for any hope of convincing me on
that side.

It might be better to add a drivers/gpu/drm/amd directory and add common
stuff there.

Given that this is not intended to be final HSA api AFAICT then i would
say this far better to avoid the whole kfd module and add ioctl to radeon.
This would avoid crazy communication btw radeon and kfd.

The whole aperture business needs some serious explanation. Especialy as
you want to use userspace address there is nothing to prevent userspace
program from allocating things at address you reserve for lds, scratch,
... only sane way would be to move those lds, scratch inside the virtual
address reserved for kernel (see kernel memory map).

The whole business of locking performance counter for exclusive per process
access is a big NO. Which leads me to the questionable usefullness of user
space command ring. I only see issues with that. First and foremost i would
need to see solid figures that kernel ioctl or syscall has a higher an
overhead that is measurable in any meaning full way against a simple
function call. I know the userspace command ring is a big marketing features
that please ignorant userspace programmer. But really this only brings issues
and for absolutely not upside afaict.

So i would rather see a very simple ioctl that write the doorbell and might
do more than that in case of ring/queue overcommit where it would first have
to wait for a free ring/queue to schedule stuff. This would also allow sane
implementation of things like performance counter that could be acquire by
kernel for duration of a job submitted by userspace. While still not optimal
this would be better that userspace locking.


I might have more thoughts once i am done with all the patches.

Cheers,
Jerome

> 
> Original Cover Letter:
> 
> This patch set implements a Heterogeneous System Architecture (HSA) driver
> for radeon-family GPUs.
> HSA allows different processor types (CPUs, DSPs, GPUs, etc..) to share
> system resources more effectively via HW features including shared pageable
> memory, userspace-accessible work queues, and platform-level atomics. In
> addition to the memory protection mechanisms in GPUVM and IOMMUv2, the Sea
> Islands family of GPUs also performs HW-level validation of commands passed
> in through the queues (aka rings).
> 
> The code in this patch set is intended to serve both as a sample driver for
> other HSA-compatible hardware devices and as a production driver for
> radeon-family processors. The code is architected to support multiple CPUs
> each with connected GPUs, although the current implementation focuses on a
> single Kaveri/Berlin APU, and works alongside the existing radeon kernel
> graphics driver (kgd).
> AMD GPUs designed for use with HSA (Sea Islands and up) share some hardware
> functionality between HSA compute and regular gfx/compute (memory,
> interrupts, registers), while other functionality has been added
> specifically for HSA compute  (hw scheduler for virtualized compute rings).
> All shared hardware is owned by the radeon graphics driver, and an interface
> between kfd and kgd allows the kfd to make use of those shared resources,
> while HSA-specific functionality is managed directly by kfd by submitting
> packets into an HSA-specific command queue (the "HIQ").
> 
> During kfd module initialization a char device node (/dev/kfd) is created
> (surviving until module exit), with ioctls for queue creation & management,
> and data structures are initialized for managing HSA device topology.
> The rest of the initialization is driven by calls from the radeon kgd at the
> following points :
> 
> - radeon_init (kfd_init)
> - radeon_exit (kfd_fini)
> - radeon_driver_load_kms (kfd_device_probe, kfd_device_init)
> - radeon_driver_unload_kms (kfd_device_fini)
> 
> During the probe and init processing per-device data structures are
> established which connect to the associated graphics kernel driver. This
> information is exposed to userspace via sysfs, along with a version number
> allowing userspace to determine if a topology change has occurred while it
> was reading from sysfs.
> The interface between kfd and kgd also allows the kfd to request buffer
> management services from kgd, and allows kgd to route interrupt requests to
> kfd code since the interrupt block is shared between regular
> graphics/compute and HSA compute subsystems in the GPU.
> 
> The kfd code works with an open source usermode library ("libhsakmt") which
> is in the final stages of IP review and should be published in a separate
> repo over the next few days.
> The code operates in one of three modes, selectable via the sched_policy
> module parameter :
> 
> - sched_policy=0 uses a hardware scheduler running in the MEC block within
> CP, and allows oversubscription (more queues than HW slots)
> - sched_policy=1 also uses HW scheduling but does not allow
> oversubscription, so create_queue requests fail when we run out of HW slots
> - sched_policy=2 does not use HW scheduling, so the driver manually assigns
> queues to HW slots by programming registers
> 
> The "no HW scheduling" option is for debug & new hardware bringup only, so
> has less test coverage than the other options. Default in the current code
> is "HW scheduling without oversubscription" since that is where we have the
> most test coverage but we expect to change the default to "HW scheduling
> with oversubscription" after further testing. This effectively removes the
> HW limit on the number of work queues available to applications.
> 
> Programs running on the GPU are associated with an address space through the
> VMID field, which is translated to a unique PASID at access time via a set
> of 16 VMID-to-PASID mapping registers. The available VMIDs (currently 16)
> are partitioned (under control of the radeon kgd) between current
> gfx/compute and HSA compute, with each getting 8 in the current code. The
> VMID-to-PASID mapping registers are updated by the HW scheduler when used,
> and by driver code if HW scheduling is not being used.
> The Sea Islands compute queues use a new "doorbell" mechanism instead of the
> earlier kernel-managed write pointer registers. Doorbells use a separate BAR
> dedicated for this purpose, and pages within the doorbell aperture are
> mapped to userspace (each page mapped to only one user address space).
> Writes to the doorbell aperture are intercepted by GPU hardware, allowing
> userspace code to safely manage work queues (rings) without requiring a
> kernel call for every ring update.
> First step for an application process is to open the kfd device. Calls to
> open create a kfd "process" structure only for the first thread of the
> process. Subsequent open calls are checked to see if they are from processes
> using the same mm_struct and, if so, don't do anything. The kfd per-process
> data lives as long as the mm_struct exists. Each mm_struct is associated
> with a unique PASID, allowing the IOMMUv2 to make userspace process memory
> accessible to the GPU.
> Next step is for the application to collect topology information via sysfs.
> This gives userspace enough information to be able to identify specific
> nodes (processors) in subsequent queue management calls. Application
> processes can create queues on multiple processors, and processors support
> queues from multiple processes.
> At this point the application can create work queues in userspace memory and
> pass them through the usermode library to kfd to have them mapped onto HW
> queue slots so that commands written to the queues can be executed by the
> GPU. Queue operations specify a processor node, and so the bulk of this code
> is device-specific.
> Written by John Bridgman <John.Bridgman@amd.com>
> 
> 
> Alexey Skidanov (1):
>   amdkfd: Implement the Get Process Aperture IOCTL
> 
> Andrew Lewycky (3):
>   amdkfd: Add basic modules to amdkfd
>   amdkfd: Add interrupt handling module
>   amdkfd: Implement the Set Memory Policy IOCTL
> 
> Ben Goz (8):
>   amdkfd: Add queue module
>   amdkfd: Add mqd_manager module
>   amdkfd: Add kernel queue module
>   amdkfd: Add module parameter of scheduling policy
>   amdkfd: Add packet manager module
>   amdkfd: Add process queue manager module
>   amdkfd: Add device queue manager module
>   amdkfd: Implement the create/destroy/update queue IOCTLs
> 
> Evgeny Pinchuk (3):
>   amdkfd: Add topology module to amdkfd
>   amdkfd: Implement the Get Clock Counters IOCTL
>   amdkfd: Implement the PMC Acquire/Release IOCTLs
> 
> Oded Gabbay (10):
>   mm: Add kfd_process pointer to mm_struct
>   drm/radeon: reduce number of free VMIDs and pipes in KV
>   drm/radeon/cik: Don't touch int of pipes 1-7
>   drm/radeon: Report doorbell configuration to amdkfd
>   drm/radeon: adding synchronization for GRBM GFX
>   drm/radeon: Add radeon <--> amdkfd interface
>   Update MAINTAINERS and CREDITS files with amdkfd info
>   amdkfd: Add IOCTL set definitions of amdkfd
>   amdkfd: Add amdkfd skeleton driver
>   amdkfd: Add binding/unbinding calls to amd_iommu driver
> 
>  CREDITS                                            |    7 +
>  MAINTAINERS                                        |   10 +
>  drivers/gpu/drm/radeon/Kconfig                     |    2 +
>  drivers/gpu/drm/radeon/Makefile                    |    3 +
>  drivers/gpu/drm/radeon/amdkfd/Kconfig              |   10 +
>  drivers/gpu/drm/radeon/amdkfd/Makefile             |   14 +
>  drivers/gpu/drm/radeon/amdkfd/cik_mqds.h           |  185 +++
>  drivers/gpu/drm/radeon/amdkfd/cik_regs.h           |  220 ++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_aperture.c       |  123 ++
>  drivers/gpu/drm/radeon/amdkfd/kfd_chardev.c        |  518 +++++++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_crat.h           |  294 +++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_device.c         |  254 ++++
>  .../drm/radeon/amdkfd/kfd_device_queue_manager.c   |  985 ++++++++++++++++
>  .../drm/radeon/amdkfd/kfd_device_queue_manager.h   |  101 ++
>  drivers/gpu/drm/radeon/amdkfd/kfd_doorbell.c       |  264 +++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_interrupt.c      |  161 +++
>  drivers/gpu/drm/radeon/amdkfd/kfd_kernel_queue.c   |  305 +++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_kernel_queue.h   |   66 ++
>  drivers/gpu/drm/radeon/amdkfd/kfd_module.c         |  131 +++
>  drivers/gpu/drm/radeon/amdkfd/kfd_mqd_manager.c    |  291 +++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_mqd_manager.h    |   54 +
>  drivers/gpu/drm/radeon/amdkfd/kfd_packet_manager.c |  488 ++++++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_pasid.c          |   97 ++
>  drivers/gpu/drm/radeon/amdkfd/kfd_pm4_headers.h    |  682 +++++++++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_pm4_opcodes.h    |  107 ++
>  drivers/gpu/drm/radeon/amdkfd/kfd_priv.h           |  466 ++++++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_process.c        |  405 +++++++
>  .../drm/radeon/amdkfd/kfd_process_queue_manager.c  |  343 ++++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_queue.c          |  109 ++
>  drivers/gpu/drm/radeon/amdkfd/kfd_topology.c       | 1207 ++++++++++++++++++++
>  drivers/gpu/drm/radeon/amdkfd/kfd_topology.h       |  168 +++
>  drivers/gpu/drm/radeon/amdkfd/kfd_vidmem.c         |   96 ++
>  drivers/gpu/drm/radeon/cik.c                       |  154 +--
>  drivers/gpu/drm/radeon/cik_reg.h                   |   65 ++
>  drivers/gpu/drm/radeon/cikd.h                      |   51 +-
>  drivers/gpu/drm/radeon/radeon.h                    |    9 +
>  drivers/gpu/drm/radeon/radeon_device.c             |   32 +
>  drivers/gpu/drm/radeon/radeon_drv.c                |    5 +
>  drivers/gpu/drm/radeon/radeon_kfd.c                |  566 +++++++++
>  drivers/gpu/drm/radeon/radeon_kfd.h                |  119 ++
>  drivers/gpu/drm/radeon/radeon_kms.c                |    7 +
>  include/linux/mm_types.h                           |   14 +
>  include/uapi/linux/kfd_ioctl.h                     |  133 +++
>  43 files changed, 9226 insertions(+), 95 deletions(-)
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/Kconfig
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/Makefile
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/cik_mqds.h
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/cik_regs.h
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_aperture.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_chardev.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_crat.h
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_device.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_device_queue_manager.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_device_queue_manager.h
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_doorbell.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_interrupt.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_kernel_queue.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_kernel_queue.h
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_module.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_mqd_manager.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_mqd_manager.h
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_packet_manager.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_pasid.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_pm4_headers.h
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_pm4_opcodes.h
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_priv.h
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_process.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_process_queue_manager.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_queue.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_topology.c
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_topology.h
>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_vidmem.c
>  create mode 100644 drivers/gpu/drm/radeon/radeon_kfd.c
>  create mode 100644 drivers/gpu/drm/radeon/radeon_kfd.h
>  create mode 100644 include/uapi/linux/kfd_ioctl.h
> 
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
