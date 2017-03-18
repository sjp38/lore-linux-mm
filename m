Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 75EC16B0398
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 21:34:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p189so71871118pfp.5
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 18:34:11 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id b13si10218805pga.132.2017.03.17.18.34.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 18:34:10 -0700 (PDT)
Subject: Re: [HMM 2/2] hmm: heterogeneous memory management documentation
References: <1489778823-8694-1-git-send-email-jglisse@redhat.com>
 <1489778823-8694-3-git-send-email-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <d1dd967c-69e6-f673-0c88-06bb4e234872@nvidia.com>
Date: Fri, 17 Mar 2017 18:32:27 -0700
MIME-Version: 1.0
In-Reply-To: <1489778823-8694-3-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>

On 03/17/2017 12:27 PM, J=C3=A9r=C3=B4me Glisse wrote:
> This add documentation for HMM (Heterogeneous Memory Management). It
> presents the motivation behind it, the features necessary for it to
> be usefull and and gives an overview of how this is implemented.

For this patch, I will leave it to others to decide how to proceed, given t=
he following:

1. This hmm.txt has a lot of critical information in it.

2. It is, however, more of a first draft than a final draft: lots of errors=
 in each sentence, and=20
lots of paragraphs that need re-doing, for example. After a quick pass thro=
ugh a few other=20
Documentation/vm/*.txt documents to gage the quality bar, I am inclined to =
recommend (or do) a=20
second draft of this, before submitting it.

Since I'm the one being harsh here (and Jerome, you already know I'm harsh!=
 haha), I can provide a=20
second draft. But it won't look much like the current draft, so brace yours=
elf before saying yes... :)

thanks
John Hubbard
NVIDIA

>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
>  Documentation/vm/hmm.txt | 362 +++++++++++++++++++++++++++++++++++++++++=
++++++
>  1 file changed, 362 insertions(+)
>  create mode 100644 Documentation/vm/hmm.txt
>
> diff --git a/Documentation/vm/hmm.txt b/Documentation/vm/hmm.txt
> new file mode 100644
> index 0000000..a6829ba
> --- /dev/null
> +++ b/Documentation/vm/hmm.txt
> @@ -0,0 +1,362 @@
> +Heterogeneous Memory Management (HMM)
> +
> +Transparently allow any component of a program to use any memory region =
of said
> +program with a device without using device specific memory allocator. Th=
is is
> +becoming a requirement to simplify the use of advance heterogeneous comp=
uting
> +where GPU, DSP or FPGA are use to perform various computations.
> +
> +This document is divided as follow, in the first section i expose the pr=
oblems
> +related to the use of a device specific allocator. The second section i =
expose
> +the hardware limitations that are inherent to many platforms. The third =
section
> +gives an overview of HMM designs. The fourth section explains how CPU pa=
ge-
> +table mirroring works and what is HMM purpose in this context. Fifth sec=
tion
> +deals with how device memory is represented inside the kernel. Finaly th=
e last
> +section present the new migration helper that allow to leverage the devi=
ce DMA
> +engine.
> +
> +
> +------------------------------------------------------------------------=
-------
> +
> +1) Problems of using device specific memory allocator:
> +
> +Device with large amount of on board memory (several giga bytes) like GP=
U have
> +historicaly manage their memory through dedicated driver specific API. T=
his
> +creates a disconnect between memory allocated and managed by device driv=
er and
> +regular application memory (private anonynous, share memory or regular f=
ile
> +back memory). From here on i will refer to this aspect as split address =
space.
> +I use share address space to refer to the opposite situation ie one in w=
hich
> +any memory region can be use by device transparently.
> +
> +Split address space because device can only access memory allocated thro=
ugh the
> +device specific API. This imply that all memory object in a program are =
not
> +equal from device point of view which complicate large program that rely=
 on a
> +wide set of libraries.
> +
> +Concretly this means that code that wants to leverage device like GPU ne=
ed to
> +copy object between genericly allocated memory (malloc, mmap private/sha=
re/)
> +and memory allocated through the device driver API (this still end up wi=
th an
> +mmap but of the device file).
> +
> +For flat dataset (array, grid, image, ...) this isn't too hard to achiev=
e but
> +complex data-set (list, tree, ...) are hard to get right. Duplicating a =
complex
> +data-set need to re-map all the pointer relations between each of its el=
ements.
> +This is error prone and program gets harder to debug because of the dupl=
icate
> +data-set.
> +
> +Split address space also means that library can not transparently use da=
ta they
> +are getting from core program or other library and thus each library mig=
ht have
> +to duplicate its input data-set using specific memory allocator. Large p=
roject
> +suffer from this and waste resources because of the various memory copy.
> +
> +Duplicating each library API to accept as input or output memory allocte=
d by
> +each device specific allocator is not a viable option. It would lead to =
a
> +combinatorial explosions in the library entry points.
> +
> +Finaly with the advance of high level langage constructs (in C++ but in =
other
> +langage too) it is now possible for compiler to leverage GPU or other de=
vices
> +without even the programmer knowledge. Some of compiler identified patte=
rns are
> +only do-able with a share address. It is as well more reasonable to use =
a share
> +address space for all the other patterns.
> +
> +
> +------------------------------------------------------------------------=
-------
> +
> +2) System bus, device memory characteristics
> +
> +System bus cripple share address due to few limitations. Most system bus=
 only
> +allow basic memory access from device to main memory, even cache coheren=
cy is
> +often optional. Access to device memory from CPU is even more limited, m=
ost
> +often than not it is not cache coherent.
> +
> +If we only consider the PCIE bus than device can access main memory (oft=
en
> +through an IOMMU) and be cache coherent with the CPUs. However it only a=
llows
> +a limited set of atomic operation from device on main memory. This is wo=
rse
> +in the other direction the CPUs can only access a limited range of the d=
evice
> +memory and can not perform atomic operations on it. Thus device memory c=
an not
> +be consider like regular memory from kernel point of view.
> +
> +Another crippling factor is the limited bandwidth (~32GBytes/s with PCIE=
 4.0
> +and 16 lanes). This is 33 times less that fastest GPU memory (1 TBytes/s=
).
> +The final limitation is latency, access to main memory from the device h=
as an
> +order of magnitude higher latency than when the device access its own me=
mory.
> +
> +Some platform are developing new system bus or additions/modifications t=
o PCIE
> +to address some of those limitations (OpenCAPI, CCIX). They mainly allow=
 two
> +way cache coherency between CPU and device and allow all atomic operatio=
ns the
> +architecture supports. Saddly not all platform are following this trends=
 and
> +some major architecture are left without hardware solutions to those pro=
blems.
> +
> +So for share address space to make sense not only we must allow device t=
o
> +access any memory memory but we must also permit any memory to be migrat=
ed to
> +device memory while device is using it (blocking CPU access while it hap=
pens).
> +
> +
> +------------------------------------------------------------------------=
-------
> +
> +3) Share address space and migration
> +
> +HMM intends to provide two main features. First one is to share the addr=
ess
> +space by duplication the CPU page table into the device page table so sa=
me
> +address point to same memory and this for any valid main memory address =
in
> +the process address space.
> +
> +To achieve this, HMM offer a set of helpers to populate the device page =
table
> +while keeping track of CPU page table updates. Device page table updates=
 are
> +not as easy as CPU page table updates. To update the device page table y=
ou must
> +allow a buffer (or use a pool of pre-allocated buffer) and write GPU spe=
cifics
> +commands in it to perform the update (unmap, cache invalidations and flu=
sh,
> +...). This can not be done through common code for all device. Hence why=
 HMM
> +provides helpers to factor out everything that can be while leaving the =
gory
> +details to the device driver.
> +
> +The second mechanism HMM provide is a new kind of ZONE_DEVICE memory tha=
t does
> +allow to allocate a struct page for each page of the device memory. Thos=
e page
> +are special because the CPU can not map them. They however allow to migr=
ate
> +main memory to device memory using exhisting migration mechanism and eve=
rything
> +looks like if page was swap out to disk from CPU point of view. Using a =
struct
> +page gives the easiest and cleanest integration with existing mm mechani=
sms.
> +Again here HMM only provide helpers, first to hotplug new ZONE_DEVICE me=
mory
> +for the device memory and second to perform migration. Policy decision o=
f what
> +and when to migrate things is left to the device driver.
> +
> +Note that any CPU access to a device page trigger a page fault and a mig=
ration
> +back to main memory ie when a page backing an given address A is migrate=
d from
> +a main memory page to a device page then any CPU acess to address A trig=
ger a
> +page fault and initiate a migration back to main memory.
> +
> +
> +With this two features, HMM not only allow a device to mirror a process =
address
> +space and keeps both CPU and device page table synchronize, but also all=
ow to
> +leverage device memory by migrating part of data-set that is actively us=
e by a
> +device.
> +
> +
> +------------------------------------------------------------------------=
-------
> +
> +4) Address space mirroring implementation and API
> +
> +Address space mirroring main objective is to allow to duplicate range of=
 CPU
> +page table into a device page table and HMM helps keeping both synchroni=
ze. A
> +device driver that want to mirror a process address space must start wit=
h the
> +registration of an hmm_mirror struct:
> +
> +  int hmm_mirror_register(struct hmm_mirror *mirror,
> +                          struct mm_struct *mm);
> +  int hmm_mirror_register_locked(struct hmm_mirror *mirror,
> +                                 struct mm_struct *mm);
> +
> +The locked varient is to be use when the driver is already holding the m=
map_sem
> +of the mm in write mode. The mirror struct has a set of callback that ar=
e use
> +to propagate CPU page table:
> +
> +  struct hmm_mirror_ops {
> +      /* update() - update virtual address range of memory
> +       *
> +       * @mirror: pointer to struct hmm_mirror
> +       * @update: update's type (turn read only, unmap, ...)
> +       * @start: virtual start address of the range to update
> +       * @end: virtual end address of the range to update
> +       *
> +       * This callback is call when the CPU page table is updated, the d=
evice
> +       * driver must update device page table accordingly to update's ac=
tion.
> +       *
> +       * Device driver callback must wait until the device has fully upd=
ated
> +       * its view for the range. Note we plan to make this asynchronous =
in
> +       * later patches, so that multiple devices can schedule update to =
their
> +       * page tables, and once all device have schedule the update then =
we
> +       * wait for them to propagate.
> +       */
> +       void (*update)(struct hmm_mirror *mirror,
> +                      enum hmm_update action,
> +                      unsigned long start,
> +                      unsigned long end);
> +  };
> +
> +Device driver must perform update to the range following action (turn ra=
nge
> +read only, or fully unmap, ...). Once driver callback returns the device=
 must
> +be done with the update.
> +
> +
> +When device driver wants to populate a range of virtual address it can u=
se
> +either:
> +  int hmm_vma_get_pfns(struct vm_area_struct *vma,
> +                       struct hmm_range *range,
> +                       unsigned long start,
> +                       unsigned long end,
> +                       hmm_pfn_t *pfns);
> +  int hmm_vma_fault(struct vm_area_struct *vma,
> +                    struct hmm_range *range,
> +                    unsigned long start,
> +                    unsigned long end,
> +                    hmm_pfn_t *pfns,
> +                    bool write,
> +                    bool block);
> +
> +First one (hmm_vma_get_pfns()) will only fetch present CPU page table en=
try and
> +will not trigger a page fault on missing or non present entry. The secon=
d one
> +do trigger page fault on missing or read only entry if write parameter i=
s true.
> +Page fault use the generic mm page fault code path just like a CPU page =
fault.
> +
> +Both function copy CPU page table into their pfns array argument. Each e=
ntry in
> +that array correspond to an address in the virtual range. HMM provide a =
set of
> +flags to help driver identify special CPU page table entries.
> +
> +Locking with the update() callback is the most important aspect the driv=
er must
> +respect in order to keep things properly synchronize. The usage pattern =
is :
> +
> +  int driver_populate_range(...)
> +  {
> +       struct hmm_range range;
> +       ...
> +  again:
> +       ret =3D hmm_vma_get_pfns(vma, &range, start, end, pfns);
> +       if (ret)
> +           return ret;
> +       take_lock(driver->update);
> +       if (!hmm_vma_range_done(vma, &range)) {
> +           release_lock(driver->update);
> +           goto again;
> +       }
> +
> +       // Use pfns array content to update device page table
> +
> +       release_lock(driver->update);
> +       return 0;
> +  }
> +
> +The driver->update lock is the same lock that driver takes inside its up=
date()
> +callback. That lock must be call before hmm_vma_range_done() to avoid an=
y race
> +with a concurrent CPU page table update.
> +
> +HMM implements all this on top of the mmu_notifier API because we wanted=
 to a
> +simpler API and also to be able to perform optimization latter own like =
doing
> +concurrent device update in multi-devices scenario.
> +
> +HMM also serve as an impedence missmatch between how CPU page table upda=
te are
> +done (by CPU write to the page table and TLB flushes) from how device up=
date
> +their own page table. Device update is a multi-step process, first appro=
priate
> +commands are write to a buffer, then this buffer is schedule for executi=
on on
> +the device. It is only once the device has executed commands in the buff=
er that
> +the update is done. Creating and scheduling update command buffer can ha=
ppen
> +concurrently for multiple devices. Waiting for each device to report com=
mands
> +as executed is serialize (there is no point in doing this concurrently).
> +
> +
> +------------------------------------------------------------------------=
-------
> +
> +5) Represent and manage device memory from core kernel point of view
> +
> +Several differents design were try to support device memory. First one u=
se
> +device specific data structure to keep informations about migrated memor=
y and
> +HMM hooked itself in various place of mm code to handle any access to ad=
dress
> +that were back by device memory. It turns out that this ended up replica=
ting
> +most of the fields of struct page and also needed many kernel code path =
to be
> +updated to understand this new kind of memory.
> +
> +Thing is most kernel code path never try to access the memory behind a p=
age
> +but only care about struct page contents. Because of this HMM switchted =
to
> +directly using struct page for device memory which left most kernel code=
 path
> +un-aware of the difference. We only need to make sure that no one ever t=
ry to
> +map those page from the CPU side.
> +
> +HMM provide a set of helpers to register and hotplug device memory as a =
new
> +region needing struct page. This is offer through a very simple API:
> +
> +  struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
> +                                    struct device *device,
> +                                    unsigned long size);
> +  void hmm_devmem_remove(struct hmm_devmem *devmem);
> +
> +The hmm_devmem_ops is where most of the important things are:
> +
> +  struct hmm_devmem_ops {
> +      void (*free)(struct hmm_devmem *devmem, struct page *page);
> +      int (*fault)(struct hmm_devmem *devmem,
> +                   struct vm_area_struct *vma,
> +                   unsigned long addr,
> +                   struct page *page,
> +                   unsigned flags,
> +                   pmd_t *pmdp);
> +  };
> +
> +The first callback (free()) happens when the last reference on a device =
page is
> +drop. This means the device page is now free and no longer use by anyone=
. The
> +second callback happens whenever CPU try to access a device page which i=
t can
> +not do. This second callback must trigger a migration back to system mem=
ory,
> +HMM provides an helper to do just that:
> +
> +  int hmm_devmem_fault_range(struct hmm_devmem *devmem,
> +                             struct vm_area_struct *vma,
> +                             const struct migrate_vma_ops *ops,
> +                             unsigned long mentry,
> +                             unsigned long *src,
> +                             unsigned long *dst,
> +                             unsigned long start,
> +                             unsigned long addr,
> +                             unsigned long end,
> +                             void *private);
> +
> +It relies on new migrate_vma() helper which is a generic page migration =
helper
> +that work on range of virtual address instead of working on individual p=
ages,
> +it also allow to leverage device DMA engine to perform the copy from dev=
ice to
> +main memory (or in the other direction). The next section goes over this=
 new
> +helper.
> +
> +
> +------------------------------------------------------------------------=
-------
> +
> +6) Migrate to and from device memory
> +
> +Because CPU can not access device memory, migration must use device DMA =
engine
> +to perform copy from and to device memory. For this we need a new migrat=
ion
> +helper:
> +
> +  int migrate_vma(const struct migrate_vma_ops *ops,
> +                  struct vm_area_struct *vma,
> +                  unsigned long mentries,
> +                  unsigned long start,
> +                  unsigned long end,
> +                  unsigned long *src,
> +                  unsigned long *dst,
> +                  void *private);
> +
> +Unlike other migration function it works on a range of virtual address, =
there
> +is two reasons for that. First device DMA copy has a high setup overhead=
 cost
> +and thus batching multiple pages is needed as otherwise the migration ov=
erhead
> +make the whole excersie pointless. The second reason is because driver t=
rigger
> +such migration base on range of address the device is actively accessing=
.
> +
> +The migrate_vma_ops struct define two callbacks. First one (alloc_and_co=
py())
> +control destination memory allocation and copy operation. Second one is =
there
> +to allow device driver to perform cleanup operation after migration.
> +
> +  struct migrate_vma_ops {
> +      void (*alloc_and_copy)(struct vm_area_struct *vma,
> +                             const unsigned long *src,
> +                             unsigned long *dst,
> +                             unsigned long start,
> +                             unsigned long end,
> +                             void *private);
> +      void (*finalize_and_map)(struct vm_area_struct *vma,
> +                               const unsigned long *src,
> +                               const unsigned long *dst,
> +                               unsigned long start,
> +                               unsigned long end,
> +                               void *private);
> +  };
> +
> +It is important to stress that this migration helpers allow for hole in =
the
> +virtual address range. Some pages in the range might not be migrated for=
 all
> +the usual reasons (page is pin, page is lock, ...). This helper does not=
 fail
> +but just skip over those pages.
> +
> +The alloc_and_copy() might as well decide to not migrate all pages in th=
e
> +range (for reasons under the callback control). For those the callback j=
ust
> +have to leave the corresponding dst entry empty.
> +
> +Finaly the migration of the struct page might fails (for file back page)=
 for
> +various reasons (failure to freeze reference, or update page cache, ...)=
. If
> +that happens then the finalize_and_map() can catch any pages that was no=
t
> +migrated. Note those page were still copied to new page and thus we wast=
ed
> +bandwidth but this is considered as a rare event and a price that we are
> +willing to pay to keep all the code simpler.
> --
> 2.4.11
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
