Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA0986B0038
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 12:33:43 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m78so5272070wma.3
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 09:33:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 28si5294119edv.450.2017.11.23.09.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 09:33:41 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vANHTKcM051865
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 12:33:40 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2edx7p41ns-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 12:33:40 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Thu, 23 Nov 2017 17:33:38 -0000
Date: Thu, 23 Nov 2017 17:33:31 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/5] Memory hotplug support for arm64 - complete
 patchset v2
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <20171123160258.xmw5lxnjfch2dxfw@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171123160258.xmw5lxnjfch2dxfw@dhcp22.suse.cz>
Message-Id: <20171123173331.GA15535@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, realean2@ie.ibm.com

On Thu 23 Nov 2017, 17:02, Michal Hocko wrote:

Hi Michal,

> I will try to have a look but I do not expect to understand any of arm64
> specific changes so I will focus on the generic code but it would help a
> _lot_ if the cover letter provided some overview of what has been done
> from a higher level POV. What are the arch pieces and what is the
> generic code missing. A quick glance over patches suggests that
> changelogs for specific patches are modest as well. Could you give us
> more information please? Reviewing hundreds lines of code without
> context is a pain.

sorry for the lack of details. I will try to provide a better
overview in the following. Please, feel free to ask for more details
where needed.

Overall, the goal of the patchset is to implement arch_memory_add and
arch_memory_remove for arm64, to support the generic memory_hotplug
framework. 

Hot add
-------
Not so many surprises here. We implement the arch specific
arch_add_memory, which builds the kernel page tables via hotplug_paging()
and then calls arch specific add_pages(). We need the arch specific
add_pages() to implement a trick that makes the satus of pages being
added accepted by the asumptions made in the generic __add_pages. (See
code comments).

Hot remove
----------
The code is basically a port of x86_64 hot remove, with several relevant
changes that I am highlithing below. 

* Architecture specific code:
- We implement arch_remove_memory() which takes care of i) calling
  the generic __remove_pages and ii) tearing down kernel page tables
  (remove_pagetable()).

- We implement the arch specific vmemmap_free(), which is called by the
  generic code to free vmemmap for memory being removed. vmemmap_free(),
  in its turn, reuses the code of remove_pagetable() to do its job.

- remove_pagetable() (called by the two functions above), removes kernel
  page tables and, in the case of vmemmap, also removes the actual
  vmemmap pages. The function never splits P[UM]D mapped page
  table entries, and fails in case such a split is requested.
  To implement this behavior, we do a two passes call of
  remove_pagetable() in arch_remove_memory(): the first pass does not
  alter any of the pagetable contents, but only checks whether some
  P[UM]D split would occur; in the case the first pass succeeds, the
  second pass does the actual removal job.
  Actually, the case where a P[UM]D would be split should be extremely
  rare - so denying the removal should not be a big deal: 
  in fact, hot-add and hot-remove add memory at the granularity of
  SECTION_SIZE_BITS, which is hardcoded to 30 for arm64 at the moment,
  and PMDs and PUDs map 2MB and 1GB worth of 4K pages, respectively. 
  In order for a split to occur, someone should first decrease 
  SECTION_SIZE_BITS and then ask to remove some p[um]d sub area that
  was mapped at boot to the full p[um]d.

* Generic code
- [SYSFS and x86 ACPI changes]. In x86, hot remove is triggered by ACPI,
  which performs memory offlining and removal in one atomic step. To
  enable memory removal in the absence of ACPI, we add a sysfs `remove`
  handle (/sys/devices/system/memory/remove), symmetrically to the
  existing memory probe device (existing since the beginning of time
  with commit 3947be1969a9 ("memory hotplug: sysfs and add/remove
  functions")). To hot-remove a section, one would first offline it
  (echo offline > /sys/devices/system/memory/memoryXX/state) and then
  call remove on this new remove handle, passing the phy address of the
  section being removed.
  Now, the x86 code assumes that offline and remove are done in one
  single atomic step (ACPI- Commit 242831eb15a0 ("Memory hotplug / ACPI:
  Simplify memory removal")). In this spirit, the generic code also
  assumed that when someone called memory_hotplug.c:remove_memory, then
  that memory would have been already offlined. If that was not the case,
  it would raise a BUG().
  In our case, offlining and removal are done in separate steps,
  so we remove this assumptions and fail the removal if the memory
  was not previously offlined. We also consider the possibility that
  arch_remove_memory itself might fail. As explained above, in some rare
  cases, it actually might in our arm64 implementation.
  While functional to our implementation, I believe that the assumption
  of offlining and removal in one atomic step is not obvious for all
  the architectures in general.
- [Memblock changes]. In x86 hot-remove implementation - commit
  ae9aae9eda2d ("memory-hotplug: common APIs to support page tables
  hot-remove") -, when freeing
  vmemmap, if a vmemmap page is only partially cleared and some of its
  content is still used, then the vmemap page is obviously not freed. 
  Instead, the partially unused content of that paged is memset to the
  seemingly totally arbitrary 0xFD constant. When all the page content
  is found to be set to 0xFD, then the page is freed. 
  After some good feedback received on the v1 of this patchset, we
  decided to get rid of this 0xFD trick for our arm64 port. Instead, we
  added a memblock flag, that we use to mark partially unused vmemmap
  areas (like 0xFD was doing before). We then check memblock rather than
  the content of the page to decide whether we can free it or not.
  
I hope this is a better cover letter. 

Best regards,
Andrea


> > Changes v1->v2:
> > - swapper pgtable updated in place on hot add, avoiding unnecessary copy
> > - stop_machine used to updated swapper on hot add, avoiding races
> > - introduced check on offlining state before hot remove
> > - new memblock flag used to mark partially unused vmemmap pages, avoiding
> >   the nasty 0xFD hack used in the prev rev (and in x86 hot remove code)
> > - proper cleaning sequence for p[um]ds,ptes and related TLB management
> > - Removed macros that changed hot remove behavior based on number
> >   of pgtable levels. Now this is hidden in the pgtable traversal macros.
> > - Check on the corner case where P[UM]Ds would have to be split during
> >   hot remove: now this is forbidden.
> > - Minor fixes and refactoring.
> > 
> > Andrea Reale (4):
> >   mm: memory_hotplug: Remove assumption on memory state before hotremove
> >   mm: memory_hotplug: memblock to track partially removed vmemmap mem
> >   mm: memory_hotplug: Add memory hotremove probe device
> >   mm: memory-hotplug: Add memory hot remove support for arm64
> > 
> > Maciej Bielski (1):
> >   mm: memory_hotplug: Memory hotplug (add) support for arm64
> > 
> >  arch/arm64/Kconfig             |  15 +
> >  arch/arm64/configs/defconfig   |   2 +
> >  arch/arm64/include/asm/mmu.h   |   7 +
> >  arch/arm64/mm/init.c           | 116 ++++++++
> >  arch/arm64/mm/mmu.c            | 609 ++++++++++++++++++++++++++++++++++++++++-
> >  drivers/acpi/acpi_memhotplug.c |   2 +-
> >  drivers/base/memory.c          |  34 ++-
> >  include/linux/memblock.h       |  12 +
> >  include/linux/memory_hotplug.h |   9 +-
> >  mm/memblock.c                  |  32 +++
> >  mm/memory_hotplug.c            |  13 +-
> >  11 files changed, 835 insertions(+), 16 deletions(-)
> > 
> > -- 
> > 2.7.4
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
