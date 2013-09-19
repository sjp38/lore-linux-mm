Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 480786B0034
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 12:57:25 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so8667424pdj.17
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 09:57:24 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id bg4so9860392pad.32
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 09:57:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5236E4D9.6010502@cn.fujitsu.com>
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com>
	<5236E4D9.6010502@cn.fujitsu.com>
Date: Fri, 20 Sep 2013 00:57:22 +0800
Message-ID: <CANBD6kHoqmWLAPci6WKFghdXEiNLRbQ-9NqCUNYS6R2OaVOzQA@mail.gmail.com>
Subject: Re: [PATCH v3 0/5] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
From: Yanfei Zhang <zhangyanfei.yes@gmail.com>
Content-Type: multipart/alternative; boundary=001a1134a31894db9204e6bf721b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, tj@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, yinghai@kernel.org
Cc: Tang Chen <tangchen@cn.fujitsu.com>, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, toshi.kani@hp.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

--001a1134a31894db9204e6bf721b
Content-Type: text/plain; charset=UTF-8

ping......

2013/9/16 Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> Hello tejun,
>
> Could you please help reviewing the patchset? As you suggested,
> we've make the patchset much simpler and cleaner.
>
> Thanks in advance!
>
> On 09/13/2013 05:30 PM, Tang Chen wrote:
> > This patch-set is based on tj's suggestion, and not fully tested.
> > Just for review and discussion.
> >
> > This patch-set is based on the latest kernel (3.11)
> > HEAD is:
> > commit d5d04bb48f0eb89c14e76779bb46212494de0bec
> > Author: Linus Torvalds <torvalds@linux-foundation.org>
> > Date:   Wed Sep 11 19:55:12 2013 -0700
> >
> >
> > [Problem]
> >
> > The current Linux cannot migrate pages used by the kerenl because
> > of the kernel direct mapping. In Linux kernel space, va = pa +
> PAGE_OFFSET.
> > When the pa is changed, we cannot simply update the pagetable and
> > keep the va unmodified. So the kernel pages are not migratable.
> >
> > There are also some other issues will cause the kernel pages not
> migratable.
> > For example, the physical address may be cached somewhere and will be
> used.
> > It is not to update all the caches.
> >
> > When doing memory hotplug in Linux, we first migrate all the pages in one
> > memory device somewhere else, and then remove the device. But if pages
> are
> > used by the kernel, they are not migratable. As a result, memory used by
> > the kernel cannot be hot-removed.
> >
> > Modifying the kernel direct mapping mechanism is too difficult to do. And
> > it may cause the kernel performance down and unstable. So we use the
> following
> > way to do memory hotplug.
> >
> >
> > [What we are doing]
> >
> > In Linux, memory in one numa node is divided into several zones. One of
> the
> > zones is ZONE_MOVABLE, which the kernel won't use.
> >
> > In order to implement memory hotplug in Linux, we are going to arrange
> all
> > hotpluggable memory in ZONE_MOVABLE so that the kernel won't use these
> memory.
> > To do this, we need ACPI's help.
> >
> > In ACPI, SRAT(System Resource Affinity Table) contains NUMA info. The
> memory
> > affinities in SRAT record every memory range in the system, and also,
> flags
> > specifying if the memory range is hotpluggable.
> > (Please refer to ACPI spec 5.0 5.2.16)
> >
> > With the help of SRAT, we have to do the following two things to achieve
> our
> > goal:
> >
> > 1. When doing memory hot-add, allow the users arranging hotpluggable as
> >    ZONE_MOVABLE.
> >    (This has been done by the MOVABLE_NODE functionality in Linux.)
> >
> > 2. when the system is booting, prevent bootmem allocator from allocating
> >    hotpluggable memory for the kernel before the memory initialization
> >    finishes.
> >
> > The problem 2 is the key problem we are going to solve. But before
> solving it,
> > we need some preparation. Please see below.
> >
> >
> > [Preparation]
> >
> > Bootloader has to load the kernel image into memory. And this memory
> must be
> > unhotpluggable. We cannot prevent this anyway. So in a memory hotplug
> system,
> > we can assume any node the kernel resides in is not hotpluggable.
> >
> > Before SRAT is parsed, we don't know which memory ranges are
> hotpluggable. But
> > memblock has already started to work. In the current kernel, memblock
> allocates
> > the following memory before SRAT is parsed:
> >
> > setup_arch()
> >  |->memblock_x86_fill()            /* memblock is ready */
> >  |......
> >  |->early_reserve_e820_mpc_new()   /* allocate memory under 1MB */
> >  |->reserve_real_mode()            /* allocate memory under 1MB */
> >  |->init_mem_mapping()             /* allocate page tables, about 2MB to
> map 1GB memory */
> >  |->dma_contiguous_reserve()       /* specified by user, should be low */
> >  |->setup_log_buf()                /* specified by user, several mega
> bytes */
> >  |->relocate_initrd()              /* could be large, but will be freed
> after boot, should reorder */
> >  |->acpi_initrd_override()         /* several mega bytes */
> >  |->reserve_crashkernel()          /* could be large, should reorder */
> >  |......
> >  |->initmem_init()                 /* Parse SRAT */
> >
> > According to Tejun's advice, before SRAT is parsed, we should try our
> best to
> > allocate memory near the kernel image. Since the whole node the kernel
> resides
> > in won't be hotpluggable, and for a modern server, a node may have at
> least 16GB
> > memory, allocating several mega bytes memory around the kernel image
> won't cross
> > to hotpluggable memory.
> >
> >
> > [About this patch-set]
> >
> > So this patch-set does the following:
> >
> > 1. Make memblock be able to allocate memory from low address to high
> address.
> >    1) Keep all the memblock APIs' prototype unmodified.
> >    2) When the direction is bottom up, keep the start address greater
> than the
> >       end of kernel image.
> >
> > 2. Improve init_mem_mapping() to support allocate page tables in bottom
> up direction.
> >
> > 3. Introduce "movablenode" boot option to enable and disable this
> functionality.
> >
> > PS: Reordering of relocate_initrd() has not been done yet.
> acpi_initrd_override()
> >     needs to access initrd with virtual address. So relocate_initrd()
> must be done
> >     before acpi_initrd_override().
> >
> >
> > Change log v2 -> v3:
> > 1. According to Toshi's suggestion, move the direction checking logic
> into memblock.
> >    And simply the code more.
> >
> > Change log v1 -> v2:
> > 1. According to tj's suggestion, implemented a new function
> memblock_alloc_bottom_up()
> >    to allocate memory from bottom upwards, whihc can simplify the code.
> >
> >
> > Tang Chen (5):
> >   memblock: Introduce allocation direction to memblock.
> >   memblock: Improve memblock to support allocation from lower address.
> >   x86, acpi, crash, kdump: Do reserve_crashkernel() after SRAT is
> >     parsed.
> >   x86, mem-hotplug: Support initialize page tables from low to high.
> >   mem-hotplug: Introduce movablenode boot option to control memblock
> >     allocation direction.
> >
> >  Documentation/kernel-parameters.txt |   15 ++++
> >  arch/x86/kernel/setup.c             |   44 ++++++++++++-
> >  arch/x86/mm/init.c                  |  121
> ++++++++++++++++++++++++++--------
> >  include/linux/memblock.h            |   22 ++++++
> >  include/linux/memory_hotplug.h      |    5 ++
> >  mm/memblock.c                       |  120
> +++++++++++++++++++++++++++++++----
> >  mm/memory_hotplug.c                 |    9 +++
> >  7 files changed, 293 insertions(+), 43 deletions(-)
> >
> >
>
>
> --
> Thanks.
> Zhang Yanfei
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--001a1134a31894db9204e6bf721b
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

ping......<br><br><div class=3D"gmail_quote">2013/9/16 Zhang Yanfei <span d=
ir=3D"ltr">&lt;<a href=3D"mailto:zhangyanfei@cn.fujitsu.com" target=3D"_bla=
nk">zhangyanfei@cn.fujitsu.com</a>&gt;</span><br><blockquote class=3D"gmail=
_quote" style=3D"margin:0px 0px 0px 0.8ex;padding-left:1ex;border-left-colo=
r:rgb(204,204,204);border-left-width:1px;border-left-style:solid">
Hello tejun,<br>
<br>
Could you please help reviewing the patchset? As you suggested,<br>
we&#39;ve make the patchset much simpler and cleaner.<br>
<br>
Thanks in advance!<br>
<div><div class=3D"h5"><br>
On 09/13/2013 05:30 PM, Tang Chen wrote:<br>
&gt; This patch-set is based on tj&#39;s suggestion, and not fully tested.<=
br>
&gt; Just for review and discussion.<br>
&gt;<br>
&gt; This patch-set is based on the latest kernel (3.11)<br>
&gt; HEAD is:<br>
&gt; commit d5d04bb48f0eb89c14e76779bb46212494de0bec<br>
&gt; Author: Linus Torvalds &lt;<a href=3D"mailto:torvalds@linux-foundation=
.org">torvalds@linux-foundation.org</a>&gt;<br>
&gt; Date: =C2=A0 Wed Sep 11 19:55:12 2013 -0700<br>
&gt;<br>
&gt;<br>
&gt; [Problem]<br>
&gt;<br>
&gt; The current Linux cannot migrate pages used by the kerenl because<br>
&gt; of the kernel direct mapping. In Linux kernel space, va =3D pa + PAGE_=
OFFSET.<br>
&gt; When the pa is changed, we cannot simply update the pagetable and<br>
&gt; keep the va unmodified. So the kernel pages are not migratable.<br>
&gt;<br>
&gt; There are also some other issues will cause the kernel pages not migra=
table.<br>
&gt; For example, the physical address may be cached somewhere and will be =
used.<br>
&gt; It is not to update all the caches.<br>
&gt;<br>
&gt; When doing memory hotplug in Linux, we first migrate all the pages in =
one<br>
&gt; memory device somewhere else, and then remove the device. But if pages=
 are<br>
&gt; used by the kernel, they are not migratable. As a result, memory used =
by<br>
&gt; the kernel cannot be hot-removed.<br>
&gt;<br>
&gt; Modifying the kernel direct mapping mechanism is too difficult to do. =
And<br>
&gt; it may cause the kernel performance down and unstable. So we use the f=
ollowing<br>
&gt; way to do memory hotplug.<br>
&gt;<br>
&gt;<br>
&gt; [What we are doing]<br>
&gt;<br>
&gt; In Linux, memory in one numa node is divided into several zones. One o=
f the<br>
&gt; zones is ZONE_MOVABLE, which the kernel won&#39;t use.<br>
&gt;<br>
&gt; In order to implement memory hotplug in Linux, we are going to arrange=
 all<br>
&gt; hotpluggable memory in ZONE_MOVABLE so that the kernel won&#39;t use t=
hese memory.<br>
&gt; To do this, we need ACPI&#39;s help.<br>
&gt;<br>
&gt; In ACPI, SRAT(System Resource Affinity Table) contains NUMA info. The =
memory<br>
&gt; affinities in SRAT record every memory range in the system, and also, =
flags<br>
&gt; specifying if the memory range is hotpluggable.<br>
&gt; (Please refer to ACPI spec 5.0 5.2.16)<br>
&gt;<br>
&gt; With the help of SRAT, we have to do the following two things to achie=
ve our<br>
&gt; goal:<br>
&gt;<br>
&gt; 1. When doing memory hot-add, allow the users arranging hotpluggable a=
s<br>
&gt; =C2=A0 =C2=A0ZONE_MOVABLE.<br>
&gt; =C2=A0 =C2=A0(This has been done by the MOVABLE_NODE functionality in =
Linux.)<br>
&gt;<br>
&gt; 2. when the system is booting, prevent bootmem allocator from allocati=
ng<br>
&gt; =C2=A0 =C2=A0hotpluggable memory for the kernel before the memory init=
ialization<br>
&gt; =C2=A0 =C2=A0finishes.<br>
&gt;<br>
&gt; The problem 2 is the key problem we are going to solve. But before sol=
ving it,<br>
&gt; we need some preparation. Please see below.<br>
&gt;<br>
&gt;<br>
&gt; [Preparation]<br>
&gt;<br>
&gt; Bootloader has to load the kernel image into memory. And this memory m=
ust be<br>
&gt; unhotpluggable. We cannot prevent this anyway. So in a memory hotplug =
system,<br>
&gt; we can assume any node the kernel resides in is not hotpluggable.<br>
&gt;<br>
&gt; Before SRAT is parsed, we don&#39;t know which memory ranges are hotpl=
uggable. But<br>
&gt; memblock has already started to work. In the current kernel, memblock =
allocates<br>
&gt; the following memory before SRAT is parsed:<br>
&gt;<br>
&gt; setup_arch()<br>
&gt; =C2=A0|-&gt;memblock_x86_fill() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* memblock is ready */<br>
&gt; =C2=A0|......<br>
&gt; =C2=A0|-&gt;early_reserve_e820_mpc_new() =C2=A0 /* allocate memory und=
er 1MB */<br>
&gt; =C2=A0|-&gt;reserve_real_mode() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* allocate memory under 1MB */<br>
&gt; =C2=A0|-&gt;init_mem_mapping() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* allocate page tables, about 2MB to map 1GB memory */<br>
&gt; =C2=A0|-&gt;dma_contiguous_reserve() =C2=A0 =C2=A0 =C2=A0 /* specified=
 by user, should be low */<br>
&gt; =C2=A0|-&gt;setup_log_buf() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0/* specified by user, several mega bytes */<br>
&gt; =C2=A0|-&gt;relocate_initrd() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* could be large, but will be freed after boot, should reorder *=
/<br>
&gt; =C2=A0|-&gt;acpi_initrd_override() =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* seve=
ral mega bytes */<br>
&gt; =C2=A0|-&gt;reserve_crashkernel() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*=
 could be large, should reorder */<br>
&gt; =C2=A0|......<br>
&gt; =C2=A0|-&gt;initmem_init() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 /* Parse SRAT */<br>
&gt;<br>
&gt; According to Tejun&#39;s advice, before SRAT is parsed, we should try =
our best to<br>
&gt; allocate memory near the kernel image. Since the whole node the kernel=
 resides<br>
&gt; in won&#39;t be hotpluggable, and for a modern server, a node may have=
 at least 16GB<br>
&gt; memory, allocating several mega bytes memory around the kernel image w=
on&#39;t cross<br>
&gt; to hotpluggable memory.<br>
&gt;<br>
&gt;<br>
&gt; [About this patch-set]<br>
&gt;<br>
&gt; So this patch-set does the following:<br>
&gt;<br>
&gt; 1. Make memblock be able to allocate memory from low address to high a=
ddress.<br>
&gt; =C2=A0 =C2=A01) Keep all the memblock APIs&#39; prototype unmodified.<=
br>
&gt; =C2=A0 =C2=A02) When the direction is bottom up, keep the start addres=
s greater than the<br>
&gt; =C2=A0 =C2=A0 =C2=A0 end of kernel image.<br>
&gt;<br>
&gt; 2. Improve init_mem_mapping() to support allocate page tables in botto=
m up direction.<br>
&gt;<br>
&gt; 3. Introduce &quot;movablenode&quot; boot option to enable and disable=
 this functionality.<br>
&gt;<br>
&gt; PS: Reordering of relocate_initrd() has not been done yet. acpi_initrd=
_override()<br>
&gt; =C2=A0 =C2=A0 needs to access initrd with virtual address. So relocate=
_initrd() must be done<br>
&gt; =C2=A0 =C2=A0 before acpi_initrd_override().<br>
&gt;<br>
&gt;<br>
&gt; Change log v2 -&gt; v3:<br>
&gt; 1. According to Toshi&#39;s suggestion, move the direction checking lo=
gic into memblock.<br>
&gt; =C2=A0 =C2=A0And simply the code more.<br>
&gt;<br>
&gt; Change log v1 -&gt; v2:<br>
&gt; 1. According to tj&#39;s suggestion, implemented a new function memblo=
ck_alloc_bottom_up()<br>
&gt; =C2=A0 =C2=A0to allocate memory from bottom upwards, whihc can simplif=
y the code.<br>
&gt;<br>
&gt;<br>
&gt; Tang Chen (5):<br>
&gt; =C2=A0 memblock: Introduce allocation direction to memblock.<br>
&gt; =C2=A0 memblock: Improve memblock to support allocation from lower add=
ress.<br>
&gt; =C2=A0 x86, acpi, crash, kdump: Do reserve_crashkernel() after SRAT is=
<br>
&gt; =C2=A0 =C2=A0 parsed.<br>
&gt; =C2=A0 x86, mem-hotplug: Support initialize page tables from low to hi=
gh.<br>
&gt; =C2=A0 mem-hotplug: Introduce movablenode boot option to control membl=
ock<br>
&gt; =C2=A0 =C2=A0 allocation direction.<br>
&gt;<br>
&gt; =C2=A0Documentation/kernel-parameters.txt | =C2=A0 15 ++++<br>
&gt; =C2=A0arch/x86/kernel/setup.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | =C2=A0 44 ++++++++++++-<br>
&gt; =C2=A0arch/x86/mm/init.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0| =C2=A0121 ++++++++++++++++++++++++++--------<br>
&gt; =C2=A0include/linux/memblock.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 22 ++++++<br>
&gt; =C2=A0include/linux/memory_hotplug.h =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=
=A05 ++<br>
&gt; =C2=A0mm/memblock.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0120 +++++++++++++++++++++++++++++++----=
<br>
&gt; =C2=A0mm/memory_hotplug.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 | =C2=A0 =C2=A09 +++<br>
&gt; =C2=A07 files changed, 293 insertions(+), 43 deletions(-)<br>
&gt;<br>
&gt;<br>
<br>
<br>
--<br>
</div></div>Thanks.<br>
<span class=3D"HOEnZb"><font color=3D"#888888">Zhang Yanfei<br>
</font></span><div class=3D"HOEnZb"><div class=3D"h5">--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel=
&quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at =C2=A0<a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><b=
r>
Please read the FAQ at =C2=A0<a href=3D"http://www.tux.org/lkml/" target=3D=
"_blank">http://www.tux.org/lkml/</a><br>
</div></div></blockquote></div><br>

--001a1134a31894db9204e6bf721b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
