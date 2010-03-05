Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1AE6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 14:10:08 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o25JA3i7007977
	for <linux-mm@kvack.org>; Fri, 5 Mar 2010 19:10:03 GMT
Received: from pxi27 (pxi27.prod.google.com [10.243.27.27])
	by wpaz21.hot.corp.google.com with ESMTP id o25JA1oT028920
	for <linux-mm@kvack.org>; Fri, 5 Mar 2010 11:10:02 -0800
Received: by pxi27 with SMTP id 27so157131pxi.31
        for <linux-mm@kvack.org>; Fri, 05 Mar 2010 11:10:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B915074.4020704@kernel.org>
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com>
	<20100305032106.GA12065@cmpxchg.org> <49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com>
	<4B915074.4020704@kernel.org>
From: Greg Thelen <gthelen@google.com>
Date: Fri, 5 Mar 2010 11:09:41 -0800
Message-ID: <49b004811003051109t3215f86dy280a6317bdab9b15@mail.gmail.com>
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 5, 2010 at 10:41 AM, Yinghai Lu <yinghai@kernel.org> wrote:
> On 03/04/2010 09:17 PM, Greg Thelen wrote:
>> On Thu, Mar 4, 2010 at 7:21 PM, Johannes Weiner <hannes@cmpxchg.org> wro=
te:
>>> On Thu, Mar 04, 2010 at 01:21:41PM -0800, Greg Thelen wrote:
>>>> On several systems I am seeing a boot panic if I use mmotm
>>>> (stamp-2010-03-02-18-38). =A0If I remove
>>>> bootmem-avoid-dma32-zone-by-default.patch then no panic is seen. =A0I
>>>> find that:
>>>> * 2.6.33 boots fine.
>>>> * 2.6.33 + mmotm w/o bootmem-avoid-dma32-zone-by-default.patch: boots =
fine.
>>>> * 2.6.33 + mmotm (including
>>>> bootmem-avoid-dma32-zone-by-default.patch): panics.
> ...
>>
>> Note: mmotm has been recently updated to stamp-2010-03-04-18-05. =A0I
>> re-tested with 'make defconfig' to confirm the panic with this later
>> mmotm.
>
> please check
>
> [PATCH] early_res: double check with updated goal in alloc_memory_core_ea=
rly
>
> Johannes Weiner pointed out that new early_res replacement for alloc_boot=
mem_node
> change the behavoir about goal.
> original bootmem one will try go further regardless of goal.
>
> and it will break his patch about default goal from MAX_DMA to MAX_DMA32.=
..
> also broke uncommon machines with <=3D16M of memory.
> (really? our x86 kernel still can run on 16M system?)
>
> so try again with update goal.
>
> Reported-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>
> ---
> =A0mm/bootmem.c | =A0 28 +++++++++++++++++++++++++---
> =A01 file changed, 25 insertions(+), 3 deletions(-)
>
> Index: linux-2.6/mm/bootmem.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/bootmem.c
> +++ linux-2.6/mm/bootmem.c
> @@ -170,6 +170,28 @@ void __init free_bootmem_late(unsigned l
> =A0}
>
> =A0#ifdef CONFIG_NO_BOOTMEM
> +static void * __init ___alloc_memory_core_early(pg_data_t *pgdat, u64 si=
ze,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0u64 align, u64 goal, u64 limit)
> +{
> + =A0 =A0 =A0 void *ptr;
> + =A0 =A0 =A0 unsigned long end_pfn;
> +
> + =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(pgdat->node_id, size, ali=
gn,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0goal, limit);
> + =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 /* check goal according =A0*/
> + =A0 =A0 =A0 end_pfn =3D pgdat->node_start_pfn + pgdat->node_spanned_pag=
es;
> + =A0 =A0 =A0 if ((end_pfn << PAGE_SHIFT) < (goal + size)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal =3D pgdat->node_start_pfn << PAGE_SHIF=
T;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(pgdat->no=
de_id, size, align,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0goal, limit);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return ptr;
> +}
> +
> =A0static void __init __free_pages_memory(unsigned long start, unsigned l=
ong end)
> =A0{
> =A0 =A0 =A0 =A0int i;
> @@ -836,7 +858,7 @@ void * __init __alloc_bootmem_node(pg_da
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return kzalloc_node(size, GFP_NOWAIT, pgda=
t->node_id);
>
> =A0#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 return __alloc_memory_core_early(pgdat->node_id, size, alig=
n,
> + =A0 =A0 =A0 return =A0___alloc_memory_core_early(pgdat, size, align,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 goal, -1ULL);
> =A0#else
> =A0 =A0 =A0 =A0return ___alloc_bootmem_node(pgdat->bdata, size, align, go=
al, 0);
> @@ -920,7 +942,7 @@ void * __init __alloc_bootmem_node_nopan
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return kzalloc_node(size, GFP_NOWAIT, pgda=
t->node_id);
>
> =A0#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 ptr =3D =A0__alloc_memory_core_early(pgdat->node_id, size, =
align,
> + =A0 =A0 =A0 ptr =3D =A0___alloc_memory_core_early(pgdat, size, align,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 goal, -1ULL);
> =A0#else
> =A0 =A0 =A0 =A0ptr =3D alloc_arch_preferred_bootmem(pgdat->bdata, size, a=
lign, goal, 0);
> @@ -980,7 +1002,7 @@ void * __init __alloc_bootmem_low_node(p
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return kzalloc_node(size, GFP_NOWAIT, pgda=
t->node_id);
>
> =A0#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 return __alloc_memory_core_early(pgdat->node_id, size, alig=
n,
> + =A0 =A0 =A0 return ___alloc_memory_core_early(pgdat, size, align,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goal, ARCH=
_LOW_ADDRESS_LIMIT);
> =A0#else
> =A0 =A0 =A0 =A0return ___alloc_bootmem_node(pgdat->bdata, size, align,
>

On my 256MB VM, which detected the problem starting this thread, the
"double check with updated goal in alloc_memory_core_early" patch
(above) boots without panic.

My initial impression is that this fixes the reported problem.  Note:
I have not tested to see if any other issues are introduced.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
