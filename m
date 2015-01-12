Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 423BA6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:05:56 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so32247533pdj.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:05:56 -0800 (PST)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bon0147.outbound.protection.outlook.com. [157.56.111.147])
        by mx.google.com with ESMTPS id su9si24476067pab.162.2015.01.12.12.05.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 Jan 2015 12:05:54 -0800 (PST)
Message-ID: <54B4290C.6070208@amd.com>
Date: Mon, 12 Jan 2015 22:05:32 +0200
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] HMM: introduce heterogeneous memory management v2.
References: <1420497889-10088-1-git-send-email-j.glisse@gmail.com>
 <1420497889-10088-4-git-send-email-j.glisse@gmail.com>
 <54B2799A.5000809@amd.com> <20150112154643.GD1938@gmail.com>
In-Reply-To: <20150112154643.GD1938@gmail.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind
 Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John
 Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?windows-1252?Q?J=E9r=F4?= =?windows-1252?Q?me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>



On 01/12/2015 05:46 PM, Jerome Glisse wrote:
> On Sun, Jan 11, 2015 at 03:24:42PM +0200, Oded Gabbay wrote:
>>
>>
>> On 01/06/2015 12:44 AM, j.glisse@gmail.com wrote:
>>> From: J=E9r=F4me Glisse <jglisse@redhat.com>
>>>
>>> This patch only introduce core HMM functions for registering a new mi=
rror and
>>> stopping a mirror as well as registering and unregistering a device.
>>>
>>> The lifecycle of HMM object is handled differently then one of mmu_no=
tifier
>>> because unlike mmu_notifier there can be concurrent call from both mm=
 code to
>>> HMM code and/or from device driver code to HMM code. Moreover lifetim=
e of HMM
>>> can be uncorrelated from the lifetime of the process that is being mi=
rror.
>>>
>>> Changed since v1:
>>>   - Updated comment of hmm_device_register().
>>>
>>> Signed-off-by: J=E9r=F4me Glisse <jglisse@redhat.com>
>>> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
>>> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
>>> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
>>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>>> Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
>>> ---
>>>  MAINTAINERS              |   7 +
>>>  include/linux/hmm.h      | 129 ++++++++++++++++
>>>  include/linux/mm.h       |  11 ++
>>>  include/linux/mm_types.h |  14 ++
>>>  kernel/fork.c            |   2 +
>>>  mm/Kconfig               |  15 ++
>>>  mm/Makefile              |   1 +
>>>  mm/hmm.c                 | 373 +++++++++++++++++++++++++++++++++++++=
++++++++++
>>>  8 files changed, 552 insertions(+)
>>>  create mode 100644 include/linux/hmm.h
>>>  create mode 100644 mm/hmm.c
>>>
>>> diff --git a/MAINTAINERS b/MAINTAINERS
>>> index c03bc6c..3ec87c4 100644
>>> --- a/MAINTAINERS
>>> +++ b/MAINTAINERS
>>> @@ -4533,6 +4533,13 @@ F:	include/uapi/linux/if_hippi.h
>>>  F:	net/802/hippi.c
>>>  F:	drivers/net/hippi/
>>> =20
>>> +HMM - Heterogeneous Memory Management
>>> +M:	J=E9r=F4me Glisse <jglisse@redhat.com>
>>> +L:	linux-mm@kvack.org
>>> +S:	Maintained
>>> +F:	mm/hmm.c
>>> +F:	include/linux/hmm.h
>>> +
>>>  HOST AP DRIVER
>>>  M:	Jouni Malinen <j@w1.fi>
>>>  L:	hostap@shmoo.com (subscribers-only)
>>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
>>> new file mode 100644
>>> index 0000000..8eddc15
>>> --- /dev/null
>>> +++ b/include/linux/hmm.h
>>> @@ -0,0 +1,129 @@
>>> +/*
>>> + * Copyright 2013 Red Hat Inc.
>>> + *
>>> + * This program is free software; you can redistribute it and/or mod=
ify
>>> + * it under the terms of the GNU General Public License as published=
 by
>>> + * the Free Software Foundation; either version 2 of the License, or
>>> + * (at your option) any later version.
>>> + *
>>> + * This program is distributed in the hope that it will be useful,
>>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>>> + * GNU General Public License for more details.
>>> + *
>>> + * Authors: J=E9r=F4me Glisse <jglisse@redhat.com>
>>> + */
>>> +/* This is a heterogeneous memory management (hmm). In a nutshell th=
is provide
>>> + * an API to mirror a process address on a device which has its own =
mmu using
>>> + * its own page table for the process. It supports everything except=
 special
>>> + * vma.
>>> + *
>>> + * Mandatory hardware features :
>>> + *   - An mmu with pagetable.
>>> + *   - Read only flag per cpu page.
>>> + *   - Page fault ie hardware must stop and wait for kernel to servi=
ce fault.
>>> + *
>>> + * Optional hardware features :
>>> + *   - Dirty bit per cpu page.
>>> + *   - Access bit per cpu page.
>>> + *
>>> + * The hmm code handle all the interfacing with the core kernel mm c=
ode and
>>> + * provide a simple API. It does support migrating system memory to =
device
>>> + * memory and handle migration back to system memory on cpu page fau=
lt.
>>> + *
>>> + * Migrated memory is considered as swaped from cpu and core mm code=
 point of
>>> + * view.
>>> + */
>>> +#ifndef _HMM_H
>>> +#define _HMM_H
>>> +
>>> +#ifdef CONFIG_HMM
>>> +
>>> +#include <linux/list.h>
>>> +#include <linux/spinlock.h>
>>> +#include <linux/atomic.h>
>>> +#include <linux/mm_types.h>
>>> +#include <linux/mmu_notifier.h>
>>> +#include <linux/workqueue.h>
>>> +#include <linux/mman.h>
>>> +
>>> +
>>> +struct hmm_device;
>>> +struct hmm_mirror;
>>> +struct hmm;
>>> +
>>> +
>>> +/* hmm_device - Each device must register one and only one hmm_devic=
e.
>>> + *
>>> + * The hmm_device is the link btw HMM and each device driver.
>>> + */
>>> +
>>> +/* struct hmm_device_operations - HMM device operation callback
>>> + */
>>> +struct hmm_device_ops {
>>> +	/* release() - mirror must stop using the address space.
>>> +	 *
>>> +	 * @mirror: The mirror that link process address space with the dev=
ice.
>>> +	 *
>>> +	 * This callback is call either on mm destruction or as result to a
>>> +	 * call to hmm_mirror_release(). Device driver have to stop all hw
>>> +	 * thread and all usage of the address space, it has to dirty all p=
ages
>>> +	 * that have been dirty by the device. But it must not clear any en=
try
>>> +	 * from the mirror page table.
>>> +	 */
>>> +	void (*release)(struct hmm_mirror *mirror);
>>> +};
>>> +
>>> +/* struct hmm_device - per device HMM structure
>>> + *
>>> + * @name: Device name (uniquely identify the device on the system).
>>> + * @ops: The hmm operations callback.
>>> + * @mirrors: List of all active mirrors for the device.
>>> + * @mutex: Mutex protecting mirrors list.
>>> + *
>>> + * Each device that want to mirror an address space must register on=
e of this
>>> + * struct (only once per linux device).
>>> + */
>>> +struct hmm_device {
>>> +	const char			*name;
>>> +	const struct hmm_device_ops	*ops;
>>> +	struct list_head		mirrors;
>>> +	struct mutex			mutex;
>>> +};
>>> +
>>> +int hmm_device_register(struct hmm_device *device);
>>> +int hmm_device_unregister(struct hmm_device *device);
>>> +
>>> +
>>> +/* hmm_mirror - device specific mirroring functions.
>>> + *
>>> + * Each device that mirror a process has a uniq hmm_mirror struct as=
sociating
>>> + * the process address space with the device. Same process can be mi=
rrored by
>>> + * several different devices at the same time.
>>> + */
>>> +
>>> +/* struct hmm_mirror - per device and per mm HMM structure
>>> + *
>>> + * @device: The hmm_device struct this hmm_mirror is associated to.
>>> + * @hmm: The hmm struct this hmm_mirror is associated to.
>>> + * @dlist: List of all hmm_mirror for same device.
>>> + * @mlist: List of all hmm_mirror for same process.
>>> + *
>>> + * Each device that want to mirror an address space must register on=
e of this
>>> + * struct for each of the address space it wants to mirror. Same dev=
ice can
>>> + * mirror several different address space. As well same address spac=
e can be
>>> + * mirror by different devices.
>>> + */
>>> +struct hmm_mirror {
>>> +	struct hmm_device	*device;
>>> +	struct hmm		*hmm;
>>> +	struct list_head	dlist;
>>> +	struct hlist_node	mlist;
>>> +};
>>> +
>>> +int hmm_mirror_register(struct hmm_mirror *mirror, struct hmm_device=
 *device);
>>> +void hmm_mirror_unregister(struct hmm_mirror *mirror);
>>> +
>>> +
>>> +#endif /* CONFIG_HMM */
>>> +#endif
>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>> index f80d019..0e054f9 100644
>>> --- a/include/linux/mm.h
>>> +++ b/include/linux/mm.h
>>> @@ -2208,5 +2208,16 @@ void __init setup_nr_node_ids(void);
>>>  static inline void setup_nr_node_ids(void) {}
>>>  #endif
>>> =20
>>> +#ifdef CONFIG_HMM
>>> +static inline void hmm_mm_init(struct mm_struct *mm)
>>> +{
>>> +	mm->hmm =3D NULL;
>>> +}
>>> +#else /* !CONFIG_HMM */
>>> +static inline void hmm_mm_init(struct mm_struct *mm)
>>> +{
>>> +}
>>> +#endif /* !CONFIG_HMM */
>>> +
>>>  #endif /* __KERNEL__ */
>>>  #endif /* _LINUX_MM_H */
>>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>>> index 6d34aa2..57a3e1c 100644
>>> --- a/include/linux/mm_types.h
>>> +++ b/include/linux/mm_types.h
>>> @@ -15,6 +15,10 @@
>>>  #include <asm/page.h>
>>>  #include <asm/mmu.h>
>>> =20
>>> +#ifdef CONFIG_HMM
>>> +struct hmm;
>>> +#endif
>>> +
>>>  #ifndef AT_VECTOR_SIZE_ARCH
>>>  #define AT_VECTOR_SIZE_ARCH 0
>>>  #endif
>>> @@ -426,6 +430,16 @@ struct mm_struct {
>>>  #ifdef CONFIG_MMU_NOTIFIER
>>>  	struct mmu_notifier_mm *mmu_notifier_mm;
>>>  #endif
>>> +#ifdef CONFIG_HMM
>>> +	/*
>>> +	 * hmm always register an mmu_notifier we rely on mmu notifier to k=
eep
>>> +	 * refcount on mm struct as well as forbiding registering hmm on a
>>> +	 * dying mm
>>> +	 *
>>> +	 * This field is set with mmap_sem old in write mode.
>>> +	 */
>>> +	struct hmm *hmm;
>>> +#endif
>>>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>>>  	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
>>>  #endif
>>> diff --git a/kernel/fork.c b/kernel/fork.c
>>> index 4dc2dda..0bb9dc4 100644
>>> --- a/kernel/fork.c
>>> +++ b/kernel/fork.c
>>> @@ -27,6 +27,7 @@
>>>  #include <linux/binfmts.h>
>>>  #include <linux/mman.h>
>>>  #include <linux/mmu_notifier.h>
>>> +#include <linux/hmm.h>
>>>  #include <linux/fs.h>
>>>  #include <linux/mm.h>
>>>  #include <linux/vmacache.h>
>>> @@ -568,6 +569,7 @@ static struct mm_struct *mm_init(struct mm_struct=
 *mm, struct task_struct *p)
>>>  	mm_init_aio(mm);
>>>  	mm_init_owner(mm, p);
>>>  	mmu_notifier_mm_init(mm);
>>> +	hmm_mm_init(mm);
>>>  	clear_tlb_flush_pending(mm);
>>>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>>>  	mm->pmd_huge_pte =3D NULL;
>>> diff --git a/mm/Kconfig b/mm/Kconfig
>>> index 1d1ae6b..b249db0 100644
>>> --- a/mm/Kconfig
>>> +++ b/mm/Kconfig
>>> @@ -618,3 +618,18 @@ config MAX_STACK_SIZE_MB
>>>  	  changed to a smaller value in which case that is used.
>>> =20
>>>  	  A sane initial value is 80 MB.
>>> +
>>> +if STAGING
>>> +config HMM
>>> +	bool "Enable heterogeneous memory management (HMM)"
>>> +	depends on MMU
>>> +	select MMU_NOTIFIER
>>> +	select GENERIC_PAGE_TABLE
>>> +	default n
>>> +	help
>>> +	  Heterogeneous memory management provide infrastructure for a devi=
ce
>>> +	  to mirror a process address space into an hardware mmu or into an=
y
>>> +	  things supporting pagefault like event.
>>> +
>>> +	  If unsure, say N to disable hmm.
>>> +endif # STAGING
>>> diff --git a/mm/Makefile b/mm/Makefile
>>> index 3548460..cb2f9ed 100644
>>> --- a/mm/Makefile
>>> +++ b/mm/Makefile
>>> @@ -73,3 +73,4 @@ obj-$(CONFIG_GENERIC_EARLY_IOREMAP) +=3D early_iore=
map.o
>>>  obj-$(CONFIG_CMA)	+=3D cma.o
>>>  obj-$(CONFIG_MEMORY_BALLOON) +=3D balloon_compaction.o
>>>  obj-$(CONFIG_PAGE_EXTENSION) +=3D page_ext.o
>>> +obj-$(CONFIG_HMM) +=3D hmm.o
>>> diff --git a/mm/hmm.c b/mm/hmm.c
>>> new file mode 100644
>>> index 0000000..0b4e220
>>> --- /dev/null
>>> +++ b/mm/hmm.c
>>> @@ -0,0 +1,373 @@
>>> +/*
>>> + * Copyright 2013 Red Hat Inc.
>>> + *
>>> + * This program is free software; you can redistribute it and/or mod=
ify
>>> + * it under the terms of the GNU General Public License as published=
 by
>>> + * the Free Software Foundation; either version 2 of the License, or
>>> + * (at your option) any later version.
>>> + *
>>> + * This program is distributed in the hope that it will be useful,
>>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>>> + * GNU General Public License for more details.
>>> + *
>>> + * Authors: J=E9r=F4me Glisse <jglisse@redhat.com>
>>> + */
>>> +/* This is the core code for heterogeneous memory management (HMM). =
HMM intend
>>> + * to provide helper for mirroring a process address space on a devi=
ce as well
>>> + * as allowing migration of data between system memory and device me=
mory refer
>>> + * as remote memory from here on out.
>>> + *
>>> + * Refer to include/linux/hmm.h for further information on general d=
esign.
>>> + */
>>> +#include <linux/export.h>
>>> +#include <linux/bitmap.h>
>>> +#include <linux/list.h>
>>> +#include <linux/rculist.h>
>>> +#include <linux/slab.h>
>>> +#include <linux/mmu_notifier.h>
>>> +#include <linux/mm.h>
>>> +#include <linux/hugetlb.h>
>>> +#include <linux/fs.h>
>>> +#include <linux/file.h>
>>> +#include <linux/ksm.h>
>>> +#include <linux/rmap.h>
>>> +#include <linux/swap.h>
>>> +#include <linux/swapops.h>
>>> +#include <linux/mmu_context.h>
>>> +#include <linux/memcontrol.h>
>>> +#include <linux/hmm.h>
>>> +#include <linux/wait.h>
>>> +#include <linux/mman.h>
>>> +#include <linux/delay.h>
>>> +#include <linux/workqueue.h>
>>> +
>>> +#include "internal.h"
>>> +
>>> +static struct srcu_struct srcu;
>>> +
>>> +
>>> +/* struct hmm - per mm_struct HMM states.
>>> + *
>>> + * @mirrors: List of all mirror for this mm (one per device).
>>> + * @mm: The mm struct this hmm is associated with.
>>> + * @vm_end: Last valid address for this mm (exclusive).
>>> + * @lock: Serialize the mirror list modifications.
>>> + * @kref: Reference counter
>>> + * @mmu_notifier: The mmu_notifier of this mm.
>>> + *
>>> + * For each process address space (mm_struct) there is one and only =
one hmm
>>> + * struct. hmm functions will redispatch to each devices the change =
made to
>>> + * the process address space.
>>> + */
>>> +struct hmm {
>>> +	struct hlist_head	mirrors;
>>> +	struct mm_struct	*mm;
>>> +	unsigned long		vm_end;
>>> +	spinlock_t		lock;
>>> +	struct kref		kref;
>>> +	struct mmu_notifier	mmu_notifier;
>>> +};
>>> +
>>> +static struct mmu_notifier_ops hmm_notifier_ops;
>>> +
>>> +
>>> +/* hmm - core HMM functions.
>>> + *
>>> + * Core HMM functions that deal with all the process mm activities.
>>> + */
>>> +
>>> +static int hmm_init(struct hmm *hmm)
>>> +{
>>> +	hmm->mm =3D current->mm;
>>> +	hmm->vm_end =3D TASK_SIZE;
>>> +	kref_init(&hmm->kref);
>>> +	INIT_HLIST_HEAD(&hmm->mirrors);
>>> +	spin_lock_init(&hmm->lock);
>>> +
>>> +	/* register notifier */
>>> +	hmm->mmu_notifier.ops =3D &hmm_notifier_ops;
>>> +	return __mmu_notifier_register(&hmm->mmu_notifier, current->mm);
>>> +}
>>> +
>>> +static int hmm_add_mirror(struct hmm *hmm, struct hmm_mirror *mirror=
)
>>> +{
>>> +	struct hmm_mirror *tmp;
>>> +
>>> +	spin_lock(&hmm->lock);
>>> +	hlist_for_each_entry_rcu(tmp, &hmm->mirrors, mlist)
>>> +		if (tmp->device =3D=3D mirror->device) {
>>> +			/* Same device can mirror only once. */
>>> +			spin_unlock(&hmm->lock);
>>> +			return -EINVAL;
>>> +		}
>>> +	hlist_add_head(&mirror->mlist, &hmm->mirrors);
>>> +	spin_unlock(&hmm->lock);
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +static inline struct hmm *hmm_ref(struct hmm *hmm)
>>> +{
>>> +	if (!hmm || !kref_get_unless_zero(&hmm->kref))
>>> +		return NULL;
>>> +	return hmm;
>>> +}
>>> +
>>> +static void hmm_destroy(struct kref *kref)
>>> +{
>>> +	struct hmm *hmm;
>>> +
>>> +	hmm =3D container_of(kref, struct hmm, kref);
>>> +	BUG_ON(!hlist_empty(&hmm->mirrors));
>>> +
>>> +	down_write(&hmm->mm->mmap_sem);
>>> +	/* A new hmm might have been register before reaching that point. *=
/
>>> +	if (hmm->mm->hmm =3D=3D hmm)
>>> +		hmm->mm->hmm =3D NULL;
>>> +	up_write(&hmm->mm->mmap_sem);
>>> +
>>> +	mmu_notifier_unregister(&hmm->mmu_notifier, hmm->mm);
>>> +
>>> +	kfree(hmm);
>> Jerome,
>> Don't you need to handle a case where the process is terminated before=
 it
>> calls hmm_mirror_unregister() ? or if it "forgets" to call that functi=
on in
>> the first place ?
>>
>> This is the only place I saw "kfree(hmm)" and this function is only ca=
lled
>> if there are no more references to hmm. I saw you unref only in
>> hmm_mirror_unregister() but as I said, that function may never be call=
ed.
>>
>> 	Oded
>=20
> It's a design decision, ie the driver will get a callback if the proces=
s is kill
> and it then become driver responsability to call hmm_mirror_unregister(=
). As in
> most case the driver will already be cleaning up, this sounded like cle=
aniest
> way.
>=20
Yeah, I see that now. Thanks for the explanation.

	Oded
>=20
>>
>>> +}
>>> +
>>> +static inline struct hmm *hmm_unref(struct hmm *hmm)
>>> +{
>>> +	if (hmm)
>>> +		kref_put(&hmm->kref, hmm_destroy);
>>> +	return NULL;
>>> +}
>>> +
>>> +
>>> +/* hmm_notifier - HMM callback for mmu_notifier tracking change to p=
rocess mm.
>>> + *
>>> + * HMM use use mmu notifier to track change made to process address =
space.
>>> + */
>>> +static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_=
struct *mm)
>>> +{
>>> +	struct hmm *hmm;
>>> +	int id;
>>> +
>>> +	/*
>>> +	 * The hmm structure can not be free because the mmu_notifier srcu =
is
>>> +	 * read locked thus any concurrent hmm_mirror_unregister that would
>>> +	 * free hmm would have to wait on the mmu_notifier srcu.
>>> +	 */
>>> +	hmm =3D container_of(mn, struct hmm, mmu_notifier);
>>> +
>>> +	id =3D srcu_read_lock(&srcu);
>>> +	spin_lock(&hmm->lock);
>>> +	while (hmm->mirrors.first) {
>>> +		struct hmm_mirror *mirror;
>>> +
>>> +		mirror =3D hlist_entry(hmm->mirrors.first,
>>> +				     struct hmm_mirror,
>>> +				     mlist);
>>> +		hlist_del_init_rcu(&mirror->mlist);
>>> +		spin_unlock(&hmm->lock);
>>> +
>>> +		mirror->device->ops->release(mirror);
>>> +
>>> +		mutex_lock(&mirror->device->mutex);
>>> +		list_del_init(&mirror->dlist);
>>> +		mutex_unlock(&mirror->device->mutex);
>>> +
>>> +		spin_lock(&hmm->lock);
>>> +	}
>>> +	spin_unlock(&hmm->lock);
>>> +
>>> +	srcu_read_unlock(&srcu, id);
>>> +}
>>> +
>>> +static struct mmu_notifier_ops hmm_notifier_ops =3D {
>>> +	.release		=3D hmm_notifier_release,
>>> +};
>>> +
>>> +
>>> +/* hmm_mirror - per device mirroring functions.
>>> + *
>>> + * Each device that mirror a process has a uniq hmm_mirror struct. A=
 process
>>> + * can be mirror by several devices at the same time.
>>> + *
>>> + * Below are all the functions and their helpers use by device drive=
r to mirror
>>> + * the process address space. Those functions either deals with upda=
ting the
>>> + * device page table (through hmm callback). Or provide helper funct=
ions use by
>>> + * the device driver to fault in range of memory in the device page =
table.
>>> + */
>>> +
>>> +/* hmm_mirror_register() - register mirror against current process f=
or a device.
>>> + *
>>> + * @mirror: The mirror struct being registered.
>>> + * @device: The device struct to against which the mirror is registe=
red.
>>> + * Returns: 0 on success or -ENOMEM, -EINVAL on error.
>>> + *
>>> + * Call when device driver want to start mirroring a process address=
 space. The
>>> + * HMM shim will register mmu_notifier and start monitoring process =
address
>>> + * space changes. Hence callback to device driver might happen even =
before this
>>> + * function return.
>>> + *
>>> + * The task device driver want to mirror must be current !
>>> + *
>>> + * Only one mirror per mm and hmm_device can be created, it will ret=
urn NULL if
>>> + * the hmm_device already has an hmm_mirror for the the mm.
>>> + */
>>> +int hmm_mirror_register(struct hmm_mirror *mirror, struct hmm_device=
 *device)
>>> +{
>>> +	struct mm_struct *mm =3D current->mm;
>>> +	struct hmm *hmm =3D NULL;
>>> +	int ret =3D 0;
>>> +
>>> +	/* Sanity checks. */
>>> +	BUG_ON(!device);
>>> +	BUG_ON(!mm);
>>> +
>>> +	/*
>>> +	 * Initialize the mirror struct fields, the mlist init and del danc=
e is
>>> +	 * necessary to make the error path easier for driver and for hmm.
>>> +	 */
>>> +	INIT_HLIST_NODE(&mirror->mlist);
>>> +	INIT_LIST_HEAD(&mirror->dlist);
>>> +	mutex_lock(&device->mutex);
>>> +	mirror->device =3D device;
>>> +	list_add(&mirror->dlist, &device->mirrors);
>>> +	mutex_unlock(&device->mutex);
>>> +
>>> +	down_write(&mm->mmap_sem);
>>> +
>>> +	hmm =3D mm->hmm ? hmm_ref(hmm) : NULL;
>>> +	if (hmm =3D=3D NULL) {
>>> +		/* no hmm registered yet so register one */
>>> +		hmm =3D kzalloc(sizeof(*mm->hmm), GFP_KERNEL);
>>> +		if (hmm =3D=3D NULL) {
>>> +			up_write(&mm->mmap_sem);
>>> +			ret =3D -ENOMEM;
>>> +			goto error;
>>> +		}
>>> +
>>> +		ret =3D hmm_init(hmm);
>>> +		if (ret) {
>>> +			up_write(&mm->mmap_sem);
>>> +			kfree(hmm);
>>> +			goto error;
>>> +		}
>>> +
>>> +		mm->hmm =3D hmm;
>>> +	}
>>> +
>>> +	mirror->hmm =3D hmm;
>>> +	ret =3D hmm_add_mirror(hmm, mirror);
>>> +	up_write(&mm->mmap_sem);
>>> +	if (ret) {
>>> +		mirror->hmm =3D NULL;
>>> +		hmm_unref(hmm);
>>> +		goto error;
>>> +	}
>>> +	return 0;
>>> +
>>> +error:
>>> +	mutex_lock(&device->mutex);
>>> +	list_del_init(&mirror->dlist);
>>> +	mutex_unlock(&device->mutex);
>>> +	return ret;
>>> +}
>>> +EXPORT_SYMBOL(hmm_mirror_register);
>>> +
>>> +static void hmm_mirror_release(struct hmm_mirror *mirror)
>>> +{
>>> +	spin_lock(&mirror->hmm->lock);
>>> +	if (!hlist_unhashed(&mirror->mlist)) {
>>> +		hlist_del_init_rcu(&mirror->mlist);
>>> +		spin_unlock(&mirror->hmm->lock);
>>> +		mirror->device->ops->release(mirror);
>>> +
>>> +		mutex_lock(&mirror->device->mutex);
>>> +		list_del_init(&mirror->dlist);
>>> +		mutex_unlock(&mirror->device->mutex);
>>> +	} else
>>> +		spin_unlock(&mirror->hmm->lock);
>>> +}
>>> +
>>> +/* hmm_mirror_unregister() - unregister a mirror.
>>> + *
>>> + * @mirror: The mirror that link process address space with the devi=
ce.
>>> + *
>>> + * Driver can call this function when it wants to stop mirroring a p=
rocess.
>>> + * This will trigger a call to the ->stop() callback if it did not a=
leady
>>> + * happen.
>>> + */
>>> +void hmm_mirror_unregister(struct hmm_mirror *mirror)
>>> +{
>>> +	int id;
>>> +
>>> +	id =3D srcu_read_lock(&srcu);
>>> +	hmm_mirror_release(mirror);
>>> +	srcu_read_unlock(&srcu, id);
>>> +
>>> +	/*
>>> +	 * Wait for any running method to finish, of course including
>>> +	 * ->release() if it was run by hmm_notifier_release instead of us.
>>> +	 */
>>> +	synchronize_srcu(&srcu);
>>> +
>>> +	mirror->hmm =3D hmm_unref(mirror->hmm);
>>> +}
>>> +EXPORT_SYMBOL(hmm_mirror_unregister);
>>> +
>>> +
>>> +/* hmm_device - Each device driver must register one and only one hm=
m_device
>>> + *
>>> + * The hmm_device is the link btw HMM and each device driver.
>>> + */
>>> +
>>> +/* hmm_device_register() - register a device with HMM.
>>> + *
>>> + * @device: The hmm_device struct.
>>> + * Returns: 0 on success or -EINVAL otherwise.
>>> + *
>>> + *
>>> + * Call when device driver want to register itself with HMM. Device =
driver must
>>> + * only register once.
>>> + */
>>> +int hmm_device_register(struct hmm_device *device)
>>> +{
>>> +	/* sanity check */
>>> +	BUG_ON(!device);
>>> +	BUG_ON(!device->name);
>>> +	BUG_ON(!device->ops);
>>> +	BUG_ON(!device->ops->release);
>>> +
>>> +	mutex_init(&device->mutex);
>>> +	INIT_LIST_HEAD(&device->mirrors);
>>> +
>>> +	return 0;
>>> +}
>>> +EXPORT_SYMBOL(hmm_device_register);
>>> +
>>> +/* hmm_device_unregister() - unregister a device with HMM.
>>> + *
>>> + * @device: The hmm_device struct.
>>> + * Returns: 0 on success or -EBUSY otherwise.
>>> + *
>>> + * Call when device driver want to unregister itself with HMM. This =
will check
>>> + * that there is no any active mirror and returns -EBUSY if so.
>>> + */
>>> +int hmm_device_unregister(struct hmm_device *device)
>>> +{
>>> +	mutex_lock(&device->mutex);
>>> +	if (!list_empty(&device->mirrors)) {
>>> +		mutex_unlock(&device->mutex);
>>> +		return -EBUSY;
>>> +	}
>>> +	mutex_unlock(&device->mutex);
>>> +	synchronize_srcu(&srcu);
>>> +	return 0;
>>> +}
>>> +EXPORT_SYMBOL(hmm_device_unregister);
>>> +
>>> +
>>> +static int __init hmm_subsys_init(void)
>>> +{
>>> +	return init_srcu_struct(&srcu);
>>> +}
>>> +subsys_initcall(hmm_subsys_init);
>>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
