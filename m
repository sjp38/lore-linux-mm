Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 71E596B006C
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 14:36:57 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id w8so5580082qac.30
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:36:57 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1blp0187.outbound.protection.outlook.com. [207.46.163.187])
        by mx.google.com with ESMTPS id m15si30221543qav.131.2014.07.21.11.36.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Jul 2014 11:36:56 -0700 (PDT)
Message-ID: <53CD5DBC.7010301@amd.com>
Date: Mon, 21 Jul 2014 21:36:44 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
References: <53C7D645.3070607@amd.com> <20140720174652.GE3068@gmail.com>
 <53CD0961.4070505@amd.com> <53CD17FD.3000908@vodafone.de>
 <53CD1FB6.1000602@amd.com> <20140721155437.GA4519@gmail.com>
 <53CD5122.5040804@amd.com> <20140721181433.GA5196@gmail.com>
In-Reply-To: <20140721181433.GA5196@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: =?UTF-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?= <deathsimple@vodafone.de>, David
 Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew
 Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?B?TWljaGVsIETDpG56ZXI=?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On 21/07/14 21:14, Jerome Glisse wrote:
> On Mon, Jul 21, 2014 at 08:42:58PM +0300, Oded Gabbay wrote:
>> On 21/07/14 18:54, Jerome Glisse wrote:
>>> On Mon, Jul 21, 2014 at 05:12:06PM +0300, Oded Gabbay wrote:
>>>> On 21/07/14 16:39, Christian K=C3=B6nig wrote:
>>>>> Am 21.07.2014 14:36, schrieb Oded Gabbay:
>>>>>> On 20/07/14 20:46, Jerome Glisse wrote:
>>>>>>> On Thu, Jul 17, 2014 at 04:57:25PM +0300, Oded Gabbay wrote:
>>>>>>>> Forgot to cc mailing list on cover letter. Sorry.
>>>>>>>>
>>>>>>>> As a continuation to the existing discussion, here is a v2 patch=
 series
>>>>>>>> restructured with a cleaner history and no totally-different-ear=
ly-versions
>>>>>>>> of the code.
>>>>>>>>
>>>>>>>> Instead of 83 patches, there are now a total of 25 patches, wher=
e 5 of them
>>>>>>>> are modifications to radeon driver and 18 of them include only a=
mdkfd code.
>>>>>>>> There is no code going away or even modified between patches, on=
ly added.
>>>>>>>>
>>>>>>>> The driver was renamed from radeon_kfd to amdkfd and moved to re=
side under
>>>>>>>> drm/radeon/amdkfd. This move was done to emphasize the fact that=
 this driver
>>>>>>>> is an AMD-only driver at this point. Having said that, we do for=
esee a
>>>>>>>> generic hsa framework being implemented in the future and in tha=
t case, we
>>>>>>>> will adjust amdkfd to work within that framework.
>>>>>>>>
>>>>>>>> As the amdkfd driver should support multiple AMD gfx drivers, we=
 want to
>>>>>>>> keep it as a seperate driver from radeon. Therefore, the amdkfd =
code is
>>>>>>>> contained in its own folder. The amdkfd folder was put under the=
 radeon
>>>>>>>> folder because the only AMD gfx driver in the Linux kernel at th=
is point
>>>>>>>> is the radeon driver. Having said that, we will probably need to=
 move it
>>>>>>>> (maybe to be directly under drm) after we integrate with additio=
nal AMD gfx
>>>>>>>> drivers.
>>>>>>>>
>>>>>>>> For people who like to review using git, the v2 patch set is loc=
ated at:
>>>>>>>> http://cgit.freedesktop.org/~gabbayo/linux/log/?h=3Dkfd-next-3.1=
7-v2
>>>>>>>>
>>>>>>>> Written by Oded Gabbayh <oded.gabbay@amd.com>
>>>>>>>
>>>>>>> So quick comments before i finish going over all patches. There i=
s many
>>>>>>> things that need more documentation espacialy as of right now the=
re is
>>>>>>> no userspace i can go look at.
>>>>>> So quick comments on some of your questions but first of all, than=
ks for the
>>>>>> time you dedicated to review the code.
>>>>>>>
>>>>>>> There few show stopper, biggest one is gpu memory pinning this is=
 a big
>>>>>>> no, that would need serious arguments for any hope of convincing =
me on
>>>>>>> that side.
>>>>>> We only do gpu memory pinning for kernel objects. There are no use=
rspace
>>>>>> objects that are pinned on the gpu memory in our driver. If that i=
s the case,
>>>>>> is it still a show stopper ?
>>>>>>
>>>>>> The kernel objects are:
>>>>>> - pipelines (4 per device)
>>>>>> - mqd per hiq (only 1 per device)
>>>>>> - mqd per userspace queue. On KV, we support up to 1K queues per p=
rocess, for
>>>>>> a total of 512K queues. Each mqd is 151 bytes, but the allocation =
is done in
>>>>>> 256 alignment. So total *possible* memory is 128MB
>>>>>> - kernel queue (only 1 per device)
>>>>>> - fence address for kernel queue
>>>>>> - runlists for the CP (1 or 2 per device)
>>>>>
>>>>> The main questions here are if it's avoid able to pin down the memo=
ry and if the
>>>>> memory is pinned down at driver load, by request from userspace or =
by anything
>>>>> else.
>>>>>
>>>>> As far as I can see only the "mqd per userspace queue" might be a b=
it
>>>>> questionable, everything else sounds reasonable.
>>>>>
>>>>> Christian.
>>>>
>>>> Most of the pin downs are done on device initialization.
>>>> The "mqd per userspace" is done per userspace queue creation. Howeve=
r, as I
>>>> said, it has an upper limit of 128MB on KV, and considering the 2G l=
ocal
>>>> memory, I think it is OK.
>>>> The runlists are also done on userspace queue creation/deletion, but=
 we only
>>>> have 1 or 2 runlists per device, so it is not that bad.
>>>
>>> 2G local memory ? You can not assume anything on userside configurati=
on some
>>> one might build an hsa computer with 512M and still expect a function=
ing
>>> desktop.
>> First of all, I'm only considering Kaveri computer, not "hsa" computer=
.
>> Second, I would imagine we can build some protection around it, like
>> checking total local memory and limit number of queues based on some
>> percentage of that total local memory. So, if someone will have only
>> 512M, he will be able to open less queues.
>>
>>
>>>
>>> I need to go look into what all this mqd is for, what it does and wha=
t it is
>>> about. But pinning is really bad and this is an issue with userspace =
command
>>> scheduling an issue that obviously AMD fails to take into account in =
design
>>> phase.
>> Maybe, but that is the H/W design non-the-less. We can't very well
>> change the H/W.
>=20
> You can not change the hardware but it is not an excuse to allow bad de=
sign to
> sneak in software to work around that. So i would rather penalize bad h=
ardware
> design and have command submission in the kernel, until AMD fix its har=
dware to
> allow proper scheduling by the kernel and proper control by the kernel.=
=20
I'm sorry but I do *not* think this is a bad design. S/W scheduling in
the kernel can not, IMO, scale well to 100K queues and 10K processes.

> Because really where we want to go is having GPU closer to a CPU in ter=
m of scheduling
> capacity and once we get there we want the kernel to always be able to =
take over
> and do whatever it wants behind process back.
Who do you refer to when you say "we" ? AFAIK, the hw scheduling
direction is where AMD is now and where it is heading in the future.
That doesn't preclude the option to allow the kernel to take over and do
what he wants. I agree that in KV we have a problem where we can't do a
mid-wave preemption, so theoretically, a long running compute kernel can
make things messy, but in Carrizo, we will have this ability. Having
said that, it will only be through the CP H/W scheduling. So AMD is
_not_ going to abandon H/W scheduling. You can dislike it, but this is
the situation.
>=20
>>>>>
>>>>>>>
>>>>>>> It might be better to add a drivers/gpu/drm/amd directory and add=
 common
>>>>>>> stuff there.
>>>>>>>
>>>>>>> Given that this is not intended to be final HSA api AFAICT then i=
 would
>>>>>>> say this far better to avoid the whole kfd module and add ioctl t=
o radeon.
>>>>>>> This would avoid crazy communication btw radeon and kfd.
>>>>>>>
>>>>>>> The whole aperture business needs some serious explanation. Espec=
ialy as
>>>>>>> you want to use userspace address there is nothing to prevent use=
rspace
>>>>>>> program from allocating things at address you reserve for lds, sc=
ratch,
>>>>>>> ... only sane way would be to move those lds, scratch inside the =
virtual
>>>>>>> address reserved for kernel (see kernel memory map).
>>>>>>>
>>>>>>> The whole business of locking performance counter for exclusive p=
er process
>>>>>>> access is a big NO. Which leads me to the questionable usefullnes=
s of user
>>>>>>> space command ring.
>>>>>> That's like saying: "Which leads me to the questionable usefulness=
 of HSA". I
>>>>>> find it analogous to a situation where a network maintainer nackin=
g a driver
>>>>>> for a network card, which is slower than a different network card.=
 Doesn't
>>>>>> seem reasonable this situation is would happen. He would still put=
 both the
>>>>>> drivers in the kernel because people want to use the H/W and its f=
eatures. So,
>>>>>> I don't think this is a valid reason to NACK the driver.
>>>
>>> Let me rephrase, drop the the performance counter ioctl and modulo me=
mory pinning
>>> i see no objection. In other word, i am not NACKING whole patchset i =
am NACKING
>>> the performance ioctl.
>>>
>>> Again this is another argument for round trip to the kernel. As insid=
e kernel you
>>> could properly do exclusive gpu counter access accross single user cm=
d buffer
>>> execution.
>>>
>>>>>>
>>>>>>> I only see issues with that. First and foremost i would
>>>>>>> need to see solid figures that kernel ioctl or syscall has a high=
er an
>>>>>>> overhead that is measurable in any meaning full way against a sim=
ple
>>>>>>> function call. I know the userspace command ring is a big marketi=
ng features
>>>>>>> that please ignorant userspace programmer. But really this only b=
rings issues
>>>>>>> and for absolutely not upside afaict.
>>>>>> Really ? You think that doing a context switch to kernel space, wi=
th all its
>>>>>> overhead, is _not_ more expansive than just calling a function in =
userspace
>>>>>> which only puts a buffer on a ring and writes a doorbell ?
>>>
>>> I am saying the overhead is not that big and it probably will not mat=
ter in most
>>> usecase. For instance i did wrote the most useless kernel module that=
 add two
>>> number through an ioctl (http://people.freedesktop.org/~glisse/adder.=
tar) and
>>> it takes ~0.35microseconds with ioctl while function is ~0.025microse=
conds so
>>> ioctl is 13 times slower.
>>>
>>> Now if there is enough data that shows that a significant percentage =
of jobs
>>> submited to the GPU will take less that 0.35microsecond then yes user=
space
>>> scheduling does make sense. But so far all we have is handwaving with=
 no data
>>> to support any facts.
>>>
>>>
>>> Now if we want to schedule from userspace than you will need to do so=
mething
>>> about the pinning, something that gives control to kernel so that ker=
nel can
>>> unpin when it wants and move object when it wants no matter what user=
space is
>>> doing.
>>>
>>>>>>>
>>>>>>> So i would rather see a very simple ioctl that write the doorbell=
 and might
>>>>>>> do more than that in case of ring/queue overcommit where it would=
 first have
>>>>>>> to wait for a free ring/queue to schedule stuff. This would also =
allow sane
>>>>>>> implementation of things like performance counter that could be a=
cquire by
>>>>>>> kernel for duration of a job submitted by userspace. While still =
not optimal
>>>>>>> this would be better that userspace locking.
>>>>>>>
>>>>>>>
>>>>>>> I might have more thoughts once i am done with all the patches.
>>>>>>>
>>>>>>> Cheers,
>>>>>>> J=C3=A9r=C3=B4me
>>>>>>>
>>>>>>>>
>>>>>>>> Original Cover Letter:
>>>>>>>>
>>>>>>>> This patch set implements a Heterogeneous System Architecture (H=
SA) driver
>>>>>>>> for radeon-family GPUs.
>>>>>>>> HSA allows different processor types (CPUs, DSPs, GPUs, etc..) t=
o share
>>>>>>>> system resources more effectively via HW features including shar=
ed pageable
>>>>>>>> memory, userspace-accessible work queues, and platform-level ato=
mics. In
>>>>>>>> addition to the memory protection mechanisms in GPUVM and IOMMUv=
2, the Sea
>>>>>>>> Islands family of GPUs also performs HW-level validation of comm=
ands passed
>>>>>>>> in through the queues (aka rings).
>>>>>>>>
>>>>>>>> The code in this patch set is intended to serve both as a sample=
 driver for
>>>>>>>> other HSA-compatible hardware devices and as a production driver=
 for
>>>>>>>> radeon-family processors. The code is architected to support mul=
tiple CPUs
>>>>>>>> each with connected GPUs, although the current implementation fo=
cuses on a
>>>>>>>> single Kaveri/Berlin APU, and works alongside the existing radeo=
n kernel
>>>>>>>> graphics driver (kgd).
>>>>>>>> AMD GPUs designed for use with HSA (Sea Islands and up) share so=
me hardware
>>>>>>>> functionality between HSA compute and regular gfx/compute (memor=
y,
>>>>>>>> interrupts, registers), while other functionality has been added
>>>>>>>> specifically for HSA compute  (hw scheduler for virtualized comp=
ute rings).
>>>>>>>> All shared hardware is owned by the radeon graphics driver, and =
an interface
>>>>>>>> between kfd and kgd allows the kfd to make use of those shared r=
esources,
>>>>>>>> while HSA-specific functionality is managed directly by kfd by s=
ubmitting
>>>>>>>> packets into an HSA-specific command queue (the "HIQ").
>>>>>>>>
>>>>>>>> During kfd module initialization a char device node (/dev/kfd) i=
s created
>>>>>>>> (surviving until module exit), with ioctls for queue creation & =
management,
>>>>>>>> and data structures are initialized for managing HSA device topo=
logy.
>>>>>>>> The rest of the initialization is driven by calls from the radeo=
n kgd at the
>>>>>>>> following points :
>>>>>>>>
>>>>>>>> - radeon_init (kfd_init)
>>>>>>>> - radeon_exit (kfd_fini)
>>>>>>>> - radeon_driver_load_kms (kfd_device_probe, kfd_device_init)
>>>>>>>> - radeon_driver_unload_kms (kfd_device_fini)
>>>>>>>>
>>>>>>>> During the probe and init processing per-device data structures =
are
>>>>>>>> established which connect to the associated graphics kernel driv=
er. This
>>>>>>>> information is exposed to userspace via sysfs, along with a vers=
ion number
>>>>>>>> allowing userspace to determine if a topology change has occurre=
d while it
>>>>>>>> was reading from sysfs.
>>>>>>>> The interface between kfd and kgd also allows the kfd to request=
 buffer
>>>>>>>> management services from kgd, and allows kgd to route interrupt =
requests to
>>>>>>>> kfd code since the interrupt block is shared between regular
>>>>>>>> graphics/compute and HSA compute subsystems in the GPU.
>>>>>>>>
>>>>>>>> The kfd code works with an open source usermode library ("libhsa=
kmt") which
>>>>>>>> is in the final stages of IP review and should be published in a=
 separate
>>>>>>>> repo over the next few days.
>>>>>>>> The code operates in one of three modes, selectable via the sche=
d_policy
>>>>>>>> module parameter :
>>>>>>>>
>>>>>>>> - sched_policy=3D0 uses a hardware scheduler running in the MEC =
block within
>>>>>>>> CP, and allows oversubscription (more queues than HW slots)
>>>>>>>> - sched_policy=3D1 also uses HW scheduling but does not allow
>>>>>>>> oversubscription, so create_queue requests fail when we run out =
of HW slots
>>>>>>>> - sched_policy=3D2 does not use HW scheduling, so the driver man=
ually assigns
>>>>>>>> queues to HW slots by programming registers
>>>>>>>>
>>>>>>>> The "no HW scheduling" option is for debug & new hardware bringu=
p only, so
>>>>>>>> has less test coverage than the other options. Default in the cu=
rrent code
>>>>>>>> is "HW scheduling without oversubscription" since that is where =
we have the
>>>>>>>> most test coverage but we expect to change the default to "HW sc=
heduling
>>>>>>>> with oversubscription" after further testing. This effectively r=
emoves the
>>>>>>>> HW limit on the number of work queues available to applications.
>>>>>>>>
>>>>>>>> Programs running on the GPU are associated with an address space=
 through the
>>>>>>>> VMID field, which is translated to a unique PASID at access time=
 via a set
>>>>>>>> of 16 VMID-to-PASID mapping registers. The available VMIDs (curr=
ently 16)
>>>>>>>> are partitioned (under control of the radeon kgd) between curren=
t
>>>>>>>> gfx/compute and HSA compute, with each getting 8 in the current =
code. The
>>>>>>>> VMID-to-PASID mapping registers are updated by the HW scheduler =
when used,
>>>>>>>> and by driver code if HW scheduling is not being used.
>>>>>>>> The Sea Islands compute queues use a new "doorbell" mechanism in=
stead of the
>>>>>>>> earlier kernel-managed write pointer registers. Doorbells use a =
separate BAR
>>>>>>>> dedicated for this purpose, and pages within the doorbell apertu=
re are
>>>>>>>> mapped to userspace (each page mapped to only one user address s=
pace).
>>>>>>>> Writes to the doorbell aperture are intercepted by GPU hardware,=
 allowing
>>>>>>>> userspace code to safely manage work queues (rings) without requ=
iring a
>>>>>>>> kernel call for every ring update.
>>>>>>>> First step for an application process is to open the kfd device.=
 Calls to
>>>>>>>> open create a kfd "process" structure only for the first thread =
of the
>>>>>>>> process. Subsequent open calls are checked to see if they are fr=
om processes
>>>>>>>> using the same mm_struct and, if so, don't do anything. The kfd =
per-process
>>>>>>>> data lives as long as the mm_struct exists. Each mm_struct is as=
sociated
>>>>>>>> with a unique PASID, allowing the IOMMUv2 to make userspace proc=
ess memory
>>>>>>>> accessible to the GPU.
>>>>>>>> Next step is for the application to collect topology information=
 via sysfs.
>>>>>>>> This gives userspace enough information to be able to identify s=
pecific
>>>>>>>> nodes (processors) in subsequent queue management calls. Applica=
tion
>>>>>>>> processes can create queues on multiple processors, and processo=
rs support
>>>>>>>> queues from multiple processes.
>>>>>>>> At this point the application can create work queues in userspac=
e memory and
>>>>>>>> pass them through the usermode library to kfd to have them mappe=
d onto HW
>>>>>>>> queue slots so that commands written to the queues can be execut=
ed by the
>>>>>>>> GPU. Queue operations specify a processor node, and so the bulk =
of this code
>>>>>>>> is device-specific.
>>>>>>>> Written by John Bridgman <John.Bridgman@amd.com>
>>>>>>>>
>>>>>>>>
>>>>>>>> Alexey Skidanov (1):
>>>>>>>>   amdkfd: Implement the Get Process Aperture IOCTL
>>>>>>>>
>>>>>>>> Andrew Lewycky (3):
>>>>>>>>   amdkfd: Add basic modules to amdkfd
>>>>>>>>   amdkfd: Add interrupt handling module
>>>>>>>>   amdkfd: Implement the Set Memory Policy IOCTL
>>>>>>>>
>>>>>>>> Ben Goz (8):
>>>>>>>>   amdkfd: Add queue module
>>>>>>>>   amdkfd: Add mqd_manager module
>>>>>>>>   amdkfd: Add kernel queue module
>>>>>>>>   amdkfd: Add module parameter of scheduling policy
>>>>>>>>   amdkfd: Add packet manager module
>>>>>>>>   amdkfd: Add process queue manager module
>>>>>>>>   amdkfd: Add device queue manager module
>>>>>>>>   amdkfd: Implement the create/destroy/update queue IOCTLs
>>>>>>>>
>>>>>>>> Evgeny Pinchuk (3):
>>>>>>>>   amdkfd: Add topology module to amdkfd
>>>>>>>>   amdkfd: Implement the Get Clock Counters IOCTL
>>>>>>>>   amdkfd: Implement the PMC Acquire/Release IOCTLs
>>>>>>>>
>>>>>>>> Oded Gabbay (10):
>>>>>>>>   mm: Add kfd_process pointer to mm_struct
>>>>>>>>   drm/radeon: reduce number of free VMIDs and pipes in KV
>>>>>>>>   drm/radeon/cik: Don't touch int of pipes 1-7
>>>>>>>>   drm/radeon: Report doorbell configuration to amdkfd
>>>>>>>>   drm/radeon: adding synchronization for GRBM GFX
>>>>>>>>   drm/radeon: Add radeon <--> amdkfd interface
>>>>>>>>   Update MAINTAINERS and CREDITS files with amdkfd info
>>>>>>>>   amdkfd: Add IOCTL set definitions of amdkfd
>>>>>>>>   amdkfd: Add amdkfd skeleton driver
>>>>>>>>   amdkfd: Add binding/unbinding calls to amd_iommu driver
>>>>>>>>
>>>>>>>>  CREDITS                                            |    7 +
>>>>>>>>  MAINTAINERS                                        |   10 +
>>>>>>>>  drivers/gpu/drm/radeon/Kconfig                     |    2 +
>>>>>>>>  drivers/gpu/drm/radeon/Makefile                    |    3 +
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/Kconfig              |   10 +
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/Makefile             |   14 +
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/cik_mqds.h           |  185 +++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/cik_regs.h           |  220 ++++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_aperture.c       |  123 ++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_chardev.c        |  518 +++++=
++++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_crat.h           |  294 +++++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_device.c         |  254 ++++
>>>>>>>>  .../drm/radeon/amdkfd/kfd_device_queue_manager.c   |  985 +++++=
+++++++++++
>>>>>>>>  .../drm/radeon/amdkfd/kfd_device_queue_manager.h   |  101 ++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_doorbell.c       |  264 +++++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_interrupt.c      |  161 +++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_kernel_queue.c   |  305 +++++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_kernel_queue.h   |   66 ++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_module.c         |  131 +++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_mqd_manager.c    |  291 +++++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_mqd_manager.h    |   54 +
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_packet_manager.c |  488 +++++=
+++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_pasid.c          |   97 ++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_pm4_headers.h    |  682 +++++=
++++++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_pm4_opcodes.h    |  107 ++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_priv.h           |  466 +++++=
+++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_process.c        |  405 +++++=
++
>>>>>>>>  .../drm/radeon/amdkfd/kfd_process_queue_manager.c  |  343 +++++=
+
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_queue.c          |  109 ++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_topology.c       | 1207
>>>>>>>> ++++++++++++++++++++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_topology.h       |  168 +++
>>>>>>>>  drivers/gpu/drm/radeon/amdkfd/kfd_vidmem.c         |   96 ++
>>>>>>>>  drivers/gpu/drm/radeon/cik.c                       |  154 +--
>>>>>>>>  drivers/gpu/drm/radeon/cik_reg.h                   |   65 ++
>>>>>>>>  drivers/gpu/drm/radeon/cikd.h                      |   51 +-
>>>>>>>>  drivers/gpu/drm/radeon/radeon.h                    |    9 +
>>>>>>>>  drivers/gpu/drm/radeon/radeon_device.c             |   32 +
>>>>>>>>  drivers/gpu/drm/radeon/radeon_drv.c                |    5 +
>>>>>>>>  drivers/gpu/drm/radeon/radeon_kfd.c                |  566 +++++=
++++
>>>>>>>>  drivers/gpu/drm/radeon/radeon_kfd.h                |  119 ++
>>>>>>>>  drivers/gpu/drm/radeon/radeon_kms.c                |    7 +
>>>>>>>>  include/linux/mm_types.h                           |   14 +
>>>>>>>>  include/uapi/linux/kfd_ioctl.h                     |  133 +++
>>>>>>>>  43 files changed, 9226 insertions(+), 95 deletions(-)
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/Kconfig
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/Makefile
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/cik_mqds.h
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/cik_regs.h
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_aperture.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_chardev.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_crat.h
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_device.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_device_que=
ue_manager.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_device_que=
ue_manager.h
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_doorbell.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_interrupt.=
c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_kernel_que=
ue.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_kernel_que=
ue.h
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_module.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_mqd_manage=
r.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_mqd_manage=
r.h
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_packet_man=
ager.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_pasid.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_pm4_header=
s.h
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_pm4_opcode=
s.h
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_priv.h
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_process.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_process_qu=
eue_manager.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_queue.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_topology.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_topology.h
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/amdkfd/kfd_vidmem.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/radeon_kfd.c
>>>>>>>>  create mode 100644 drivers/gpu/drm/radeon/radeon_kfd.h
>>>>>>>>  create mode 100644 include/uapi/linux/kfd_ioctl.h
>>>>>>>>
>>>>>>>> --
>>>>>>>> 1.9.1
>>>>>>>>
>>>>>>
>>>>>
>>>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
