Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 325928D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 13:45:27 -0500 (EST)
Received: by qyk7 with SMTP id 7so1535768qyk.14
        for <linux-mm@kvack.org>; Mon, 07 Feb 2011 10:45:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1297092614-1906-1-git-send-email-namhyung@gmail.com>
References: <1297092614-1906-1-git-send-email-namhyung@gmail.com>
Date: Mon, 7 Feb 2011 10:45:23 -0800
Message-ID: <AANLkTim2GcBMMMr0tABf=3GwHX8oX05-Dn8tdZbYpt_b@mail.gmail.com>
Subject: Re: [RFC] Split up mm/bootmem.c
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 7, 2011 at 7:30 AM, Namhyung Kim <namhyung@gmail.com> wrote:
> The bootmem code contained many #ifdefs in it so that it could be
> splitted into two files for the readability. The split was quite
> mechanical and only function need to be shared was free_bootmem_late.
>
> Tested on x86-64 and um which use nobootmem and bootmem respectively.
>
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>


https://lkml.org/lkml/2010/6/16/44
...



> ---
> =A0mm/Makefile =A0 =A0| =A0 =A08 +-
> =A0mm/bootmem.c =A0 | =A0164 +--------------------
> =A0mm/nobootmem.c | =A0445 ++++++++++++++++++++++++++++++++++++++++++++++=
++++++++++
> =A03 files changed, 454 insertions(+), 163 deletions(-)
> =A0create mode 100644 mm/nobootmem.c
>
> diff --git a/mm/Makefile b/mm/Makefile
> index 2b1b575ae712..e9a074dbad15 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -7,7 +7,7 @@ mmu-$(CONFIG_MMU) =A0 =A0 =A0 :=3D fremap.o highmem.o mad=
vise.o memory.o mincore.o \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mlock.o mmap.o mprote=
ct.o mremap.o msync.o rmap.o \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vmalloc.o pagewalk.o =
pgtable-generic.o
>
> -obj-y =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0:=3D bootmem.o filemap.o mempoo=
l.o oom_kill.o fadvise.o \
> +obj-y =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0:=3D filemap.o mempool.o oom_ki=
ll.o fadvise.o \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 maccess.o page_alloc.=
o page-writeback.o \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 readahead.o swap.o tr=
uncate.o vmscan.o shmem.o \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prio_tree.o util.o mm=
zone.o vmstat.o backing-dev.o \
> @@ -15,6 +15,12 @@ obj-y =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0:=
=3D bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 $(mmu-y)
> =A0obj-y +=3D init-mm.o
>
> +ifeq ($(CONFIG_NO_BOOTMEM),y)
> +obj-y +=3D nobootmem.o
> +else
> +obj-y +=3D bootmem.o
> +endif
> +
> =A0obj-$(CONFIG_HAVE_MEMBLOCK) +=3D memblock.o
>
> =A0obj-$(CONFIG_BOUNCE) =A0 +=3D bounce.o
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 13b0caa9793c..209be265ad94 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -35,7 +35,6 @@ unsigned long max_pfn;
> =A0unsigned long saved_max_pfn;
> =A0#endif
>
> -#ifndef CONFIG_NO_BOOTMEM
> =A0bootmem_data_t bootmem_node_data[MAX_NUMNODES] __initdata;
>
> =A0static struct list_head bdata_list __initdata =3D LIST_HEAD_INIT(bdata=
_list);
> @@ -146,8 +145,8 @@ unsigned long __init init_bootmem(unsigned long start=
, unsigned long pages)
> =A0 =A0 =A0 =A0min_low_pfn =3D start;
> =A0 =A0 =A0 =A0return init_bootmem_core(NODE_DATA(0)->bdata, start, 0, pa=
ges);
> =A0}
> -#endif
> -/*
> +
> +/**
> =A0* free_bootmem_late - free bootmem pages directly to page allocator
> =A0* @addr: starting address of the range
> =A0* @size: size of the range in bytes
> @@ -171,53 +170,6 @@ void __init free_bootmem_late(unsigned long addr, un=
signed long size)
> =A0 =A0 =A0 =A0}
> =A0}
>
> -#ifdef CONFIG_NO_BOOTMEM
> -static void __init __free_pages_memory(unsigned long start, unsigned lon=
g end)
> -{
> - =A0 =A0 =A0 int i;
> - =A0 =A0 =A0 unsigned long start_aligned, end_aligned;
> - =A0 =A0 =A0 int order =3D ilog2(BITS_PER_LONG);
> -
> - =A0 =A0 =A0 start_aligned =3D (start + (BITS_PER_LONG - 1)) & ~(BITS_PE=
R_LONG - 1);
> - =A0 =A0 =A0 end_aligned =3D end & ~(BITS_PER_LONG - 1);
> -
> - =A0 =A0 =A0 if (end_aligned <=3D start_aligned) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D start; i < end; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_bootmem(pfn_to=
_page(i), 0);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 for (i =3D start; i < start_aligned; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_bootmem(pfn_to_page(i), 0);
> -
> - =A0 =A0 =A0 for (i =3D start_aligned; i < end_aligned; i +=3D BITS_PER_=
LONG)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_bootmem(pfn_to_page(i), order)=
;
> -
> - =A0 =A0 =A0 for (i =3D end_aligned; i < end; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_bootmem(pfn_to_page(i), 0);
> -}
> -
> -unsigned long __init free_all_memory_core_early(int nodeid)
> -{
> - =A0 =A0 =A0 int i;
> - =A0 =A0 =A0 u64 start, end;
> - =A0 =A0 =A0 unsigned long count =3D 0;
> - =A0 =A0 =A0 struct range *range =3D NULL;
> - =A0 =A0 =A0 int nr_range;
> -
> - =A0 =A0 =A0 nr_range =3D get_free_all_memory_range(&range, nodeid);
> -
> - =A0 =A0 =A0 for (i =3D 0; i < nr_range; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D range[i].start;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D range[i].end;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D end - start;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_memory(start, end);
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 return count;
> -}
> -#else
> =A0static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdat=
a)
> =A0{
> =A0 =A0 =A0 =A0int aligned;
> @@ -278,7 +230,6 @@ static unsigned long __init free_all_bootmem_core(boo=
tmem_data_t *bdata)
>
> =A0 =A0 =A0 =A0return count;
> =A0}
> -#endif
>
> =A0/**
> =A0* free_all_bootmem_node - release a node's free pages to the buddy all=
ocator
> @@ -289,12 +240,7 @@ static unsigned long __init free_all_bootmem_core(bo=
otmem_data_t *bdata)
> =A0unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
> =A0{
> =A0 =A0 =A0 =A0register_page_bootmem_info_node(pgdat);
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 /* free_all_memory_core_early(MAX_NUMNODES) will be called =
later */
> - =A0 =A0 =A0 return 0;
> -#else
> =A0 =A0 =A0 =A0return free_all_bootmem_core(pgdat->bdata);
> -#endif
> =A0}
>
> =A0/**
> @@ -304,16 +250,6 @@ unsigned long __init free_all_bootmem_node(pg_data_t=
 *pgdat)
> =A0*/
> =A0unsigned long __init free_all_bootmem(void)
> =A0{
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* We need to use MAX_NUMNODES instead of NODE_DATA(0)->n=
ode_id
> - =A0 =A0 =A0 =A0* =A0because in some case like Node0 doesnt have RAM ins=
talled
> - =A0 =A0 =A0 =A0* =A0low ram will be on Node1
> - =A0 =A0 =A0 =A0* Use MAX_NUMNODES will make sure all ranges in early_no=
de_map[]
> - =A0 =A0 =A0 =A0* =A0will be used instead of only Node0 related
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 return free_all_memory_core_early(MAX_NUMNODES);
> -#else
> =A0 =A0 =A0 =A0unsigned long total_pages =3D 0;
> =A0 =A0 =A0 =A0bootmem_data_t *bdata;
>
> @@ -321,10 +257,8 @@ unsigned long __init free_all_bootmem(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_pages +=3D free_all_bootmem_core(bda=
ta);
>
> =A0 =A0 =A0 =A0return total_pages;
> -#endif
> =A0}
>
> -#ifndef CONFIG_NO_BOOTMEM
> =A0static void __init __free(bootmem_data_t *bdata,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long sidx, unsign=
ed long eidx)
> =A0{
> @@ -419,7 +353,6 @@ static int __init mark_bootmem(unsigned long start, u=
nsigned long end,
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0BUG();
> =A0}
> -#endif
>
> =A0/**
> =A0* free_bootmem_node - mark a page range as usable
> @@ -434,10 +367,6 @@ static int __init mark_bootmem(unsigned long start, =
unsigned long end,
> =A0void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long =
size)
> =A0{
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 kmemleak_free_part(__va(physaddr), size);
> - =A0 =A0 =A0 memblock_x86_free_range(physaddr, physaddr + size);
> -#else
> =A0 =A0 =A0 =A0unsigned long start, end;
>
> =A0 =A0 =A0 =A0kmemleak_free_part(__va(physaddr), size);
> @@ -446,7 +375,6 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsig=
ned long physaddr,
> =A0 =A0 =A0 =A0end =3D PFN_DOWN(physaddr + size);
>
> =A0 =A0 =A0 =A0mark_bootmem_node(pgdat->bdata, start, end, 0, 0);
> -#endif
> =A0}
>
> =A0/**
> @@ -460,10 +388,6 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsi=
gned long physaddr,
> =A0*/
> =A0void __init free_bootmem(unsigned long addr, unsigned long size)
> =A0{
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 kmemleak_free_part(__va(addr), size);
> - =A0 =A0 =A0 memblock_x86_free_range(addr, addr + size);
> -#else
> =A0 =A0 =A0 =A0unsigned long start, end;
>
> =A0 =A0 =A0 =A0kmemleak_free_part(__va(addr), size);
> @@ -472,7 +396,6 @@ void __init free_bootmem(unsigned long addr, unsigned=
 long size)
> =A0 =A0 =A0 =A0end =3D PFN_DOWN(addr + size);
>
> =A0 =A0 =A0 =A0mark_bootmem(start, end, 0, 0);
> -#endif
> =A0}
>
> =A0/**
> @@ -489,17 +412,12 @@ void __init free_bootmem(unsigned long addr, unsign=
ed long size)
> =A0int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physad=
dr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned =
long size, int flags)
> =A0{
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 panic("no bootmem");
> - =A0 =A0 =A0 return 0;
> -#else
> =A0 =A0 =A0 =A0unsigned long start, end;
>
> =A0 =A0 =A0 =A0start =3D PFN_DOWN(physaddr);
> =A0 =A0 =A0 =A0end =3D PFN_UP(physaddr + size);
>
> =A0 =A0 =A0 =A0return mark_bootmem_node(pgdat->bdata, start, end, 1, flag=
s);
> -#endif
> =A0}
>
> =A0/**
> @@ -515,20 +433,14 @@ int __init reserve_bootmem_node(pg_data_t *pgdat, u=
nsigned long physaddr,
> =A0int __init reserve_bootmem(unsigned long addr, unsigned long size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int flags)
> =A0{
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 panic("no bootmem");
> - =A0 =A0 =A0 return 0;
> -#else
> =A0 =A0 =A0 =A0unsigned long start, end;
>
> =A0 =A0 =A0 =A0start =3D PFN_DOWN(addr);
> =A0 =A0 =A0 =A0end =3D PFN_UP(addr + size);
>
> =A0 =A0 =A0 =A0return mark_bootmem(start, end, 1, flags);
> -#endif
> =A0}
>
> -#ifndef CONFIG_NO_BOOTMEM
> =A0int __weak __init reserve_bootmem_generic(unsigned long phys, unsigned=
 long len,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int f=
lags)
> =A0{
> @@ -685,33 +597,12 @@ static void * __init alloc_arch_preferred_bootmem(b=
ootmem_data_t *bdata,
> =A0#endif
> =A0 =A0 =A0 =A0return NULL;
> =A0}
> -#endif
>
> =A0static void * __init ___alloc_bootmem_nopanic(unsigned long size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0unsigned long align,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0unsigned long goal,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0unsigned long limit)
> =A0{
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 void *ptr;
> -
> - =A0 =A0 =A0 if (WARN_ON_ONCE(slab_is_available()))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc(size, GFP_NOWAIT);
> -
> -restart:
> -
> - =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, align=
, goal, limit);
> -
> - =A0 =A0 =A0 if (ptr)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> -
> - =A0 =A0 =A0 if (goal !=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto restart;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 return NULL;
> -#else
> =A0 =A0 =A0 =A0bootmem_data_t *bdata;
> =A0 =A0 =A0 =A0void *region;
>
> @@ -737,7 +628,6 @@ restart:
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return NULL;
> -#endif
> =A0}
>
> =A0/**
> @@ -758,10 +648,6 @@ void * __init __alloc_bootmem_nopanic(unsigned long =
size, unsigned long align,
> =A0{
> =A0 =A0 =A0 =A0unsigned long limit =3D 0;
>
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 limit =3D -1UL;
> -#endif
> -
> =A0 =A0 =A0 =A0return ___alloc_bootmem_nopanic(size, align, goal, limit);
> =A0}
>
> @@ -798,14 +684,9 @@ void * __init __alloc_bootmem(unsigned long size, un=
signed long align,
> =A0{
> =A0 =A0 =A0 =A0unsigned long limit =3D 0;
>
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 limit =3D -1UL;
> -#endif
> -
> =A0 =A0 =A0 =A0return ___alloc_bootmem(size, align, goal, limit);
> =A0}
>
> -#ifndef CONFIG_NO_BOOTMEM
> =A0static void * __init ___alloc_bootmem_node(bootmem_data_t *bdata,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned l=
ong size, unsigned long align,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned l=
ong goal, unsigned long limit)
> @@ -822,7 +703,6 @@ static void * __init ___alloc_bootmem_node(bootmem_da=
ta_t *bdata,
>
> =A0 =A0 =A0 =A0return ___alloc_bootmem(size, align, goal, limit);
> =A0}
> -#endif
>
> =A0/**
> =A0* __alloc_bootmem_node - allocate boot memory from a specific node
> @@ -847,17 +727,7 @@ void * __init __alloc_bootmem_node(pg_data_t *pgdat,=
 unsigned long size,
> =A0 =A0 =A0 =A0if (WARN_ON_ONCE(slab_is_available()))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return kzalloc_node(size, GFP_NOWAIT, pgda=
t->node_id);
>
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(pgdat->node_id, size, ali=
gn,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0goal, -1ULL);
> - =A0 =A0 =A0 if (ptr)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> -
> - =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, align=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0goal, -1ULL);
> -#else
> =A0 =A0 =A0 =A0ptr =3D ___alloc_bootmem_node(pgdat->bdata, size, align, g=
oal, 0);
> -#endif
>
> =A0 =A0 =A0 =A0return ptr;
> =A0}
> @@ -880,13 +750,8 @@ void * __init __alloc_bootmem_node_high(pg_data_t *p=
gdat, unsigned long size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long new_goal;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new_goal =3D MAX_DMA32_PFN << PAGE_SHIFT;
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D =A0__alloc_memory_core_early(pgdat-=
>node_id, size, align,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0new_goal, -1ULL);
> -#else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptr =3D alloc_bootmem_core(pgdat->bdata, s=
ize, align,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 new_goal, 0);
> -#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ptr;
> =A0 =A0 =A0 =A0}
> @@ -907,16 +772,6 @@ void * __init __alloc_bootmem_node_high(pg_data_t *p=
gdat, unsigned long size,
> =A0void * __init alloc_bootmem_section(unsigned long size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0un=
signed long section_nr)
> =A0{
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 unsigned long pfn, goal, limit;
> -
> - =A0 =A0 =A0 pfn =3D section_nr_to_pfn(section_nr);
> - =A0 =A0 =A0 goal =3D pfn << PAGE_SHIFT;
> - =A0 =A0 =A0 limit =3D section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
> -
> - =A0 =A0 =A0 return __alloc_memory_core_early(early_pfn_to_nid(pfn), siz=
e,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0SMP_CACHE_BYTES, goal, limit);
> -#else
> =A0 =A0 =A0 =A0bootmem_data_t *bdata;
> =A0 =A0 =A0 =A0unsigned long pfn, goal, limit;
>
> @@ -926,7 +781,6 @@ void * __init alloc_bootmem_section(unsigned long siz=
e,
> =A0 =A0 =A0 =A0bdata =3D &bootmem_node_data[early_pfn_to_nid(pfn)];
>
> =A0 =A0 =A0 =A0return alloc_bootmem_core(bdata, size, SMP_CACHE_BYTES, go=
al, limit);
> -#endif
> =A0}
> =A0#endif
>
> @@ -938,16 +792,11 @@ void * __init __alloc_bootmem_node_nopanic(pg_data_=
t *pgdat, unsigned long size,
> =A0 =A0 =A0 =A0if (WARN_ON_ONCE(slab_is_available()))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return kzalloc_node(size, GFP_NOWAIT, pgda=
t->node_id);
>
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 ptr =3D =A0__alloc_memory_core_early(pgdat->node_id, size, =
align,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0goal, -1ULL);
> -#else
> =A0 =A0 =A0 =A0ptr =3D alloc_arch_preferred_bootmem(pgdat->bdata, size, a=
lign, goal, 0);
> =A0 =A0 =A0 =A0if (ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ptr;
>
> =A0 =A0 =A0 =A0ptr =3D alloc_bootmem_core(pgdat->bdata, size, align, goal=
, 0);
> -#endif
> =A0 =A0 =A0 =A0if (ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ptr;
>
> @@ -1000,16 +849,7 @@ void * __init __alloc_bootmem_low_node(pg_data_t *p=
gdat, unsigned long size,
> =A0 =A0 =A0 =A0if (WARN_ON_ONCE(slab_is_available()))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return kzalloc_node(size, GFP_NOWAIT, pgda=
t->node_id);
>
> -#ifdef CONFIG_NO_BOOTMEM
> - =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(pgdat->node_id, size, ali=
gn,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal, ARCH_=
LOW_ADDRESS_LIMIT);
> - =A0 =A0 =A0 if (ptr)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> - =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, align=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal, ARCH_=
LOW_ADDRESS_LIMIT);
> -#else
> =A0 =A0 =A0 =A0ptr =3D ___alloc_bootmem_node(pgdat->bdata, size, align,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goal, ARCH=
_LOW_ADDRESS_LIMIT);
> -#endif
> =A0 =A0 =A0 =A0return ptr;
> =A0}
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> new file mode 100644
> index 000000000000..e93c3475011b
> --- /dev/null
> +++ b/mm/nobootmem.c
> @@ -0,0 +1,445 @@
> +/*
> + * =A0nobootmem - A boot-time physical memory allocator and configurator
> + *
> + * =A0Copyright (C) 1999 Ingo Molnar
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01999 Kanoj Sarcar, SGI
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A02008 Johannes Weiner
> + *
> + * =A0Split out of bootmem.c by Namhyung Kim <namhyung@gmail.com>
> + *
> + * Access to this subsystem has to be serialized externally (which is tr=
ue
> + * for the boot process anyway).
> + */
> +#include <linux/init.h>
> +#include <linux/pfn.h>
> +#include <linux/slab.h>
> +#include <linux/bootmem.h>
> +#include <linux/module.h>
> +#include <linux/kmemleak.h>
> +#include <linux/range.h>
> +#include <linux/memblock.h>
> +
> +#include <asm/bug.h>
> +#include <asm/io.h>
> +#include <asm/processor.h>
> +
> +#include "internal.h"
> +
> +unsigned long max_low_pfn;
> +unsigned long min_low_pfn;
> +unsigned long max_pfn;
> +
> +#ifdef CONFIG_CRASH_DUMP
> +/*
> + * If we have booted due to a crash, max_pfn will be a very low value. W=
e need
> + * to know the amount of memory that the previous kernel used.
> + */
> +unsigned long saved_max_pfn;
> +#endif
> +
> +/**
> + * free_bootmem_late - free bootmem pages directly to page allocator
> + * @addr: starting address of the range
> + * @size: size of the range in bytes
> + *
> + * This is only useful when the bootmem allocator has already been torn
> + * down, but we are still initializing the system. =A0Pages are given di=
rectly
> + * to the page allocator, no bootmem metadata is updated because it is g=
one.
> + */
> +void __init free_bootmem_late(unsigned long addr, unsigned long size)
> +{
> + =A0 =A0 =A0 unsigned long cursor, end;
> +
> + =A0 =A0 =A0 kmemleak_free_part(__va(addr), size);
> +
> + =A0 =A0 =A0 cursor =3D PFN_UP(addr);
> + =A0 =A0 =A0 end =3D PFN_DOWN(addr + size);
> +
> + =A0 =A0 =A0 for (; cursor < end; cursor++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_bootmem(pfn_to_page(cursor), 0=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 totalram_pages++;
> + =A0 =A0 =A0 }
> +}
> +
> +static void __init __free_pages_memory(unsigned long start, unsigned lon=
g end)
> +{
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 unsigned long start_aligned, end_aligned;
> + =A0 =A0 =A0 int order =3D ilog2(BITS_PER_LONG);
> +
> + =A0 =A0 =A0 start_aligned =3D (start + (BITS_PER_LONG - 1)) & ~(BITS_PE=
R_LONG - 1);
> + =A0 =A0 =A0 end_aligned =3D end & ~(BITS_PER_LONG - 1);
> +
> + =A0 =A0 =A0 if (end_aligned <=3D start_aligned) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D start; i < end; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_bootmem(pfn_to=
_page(i), 0);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 for (i =3D start; i < start_aligned; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_bootmem(pfn_to_page(i), 0);
> +
> + =A0 =A0 =A0 for (i =3D start_aligned; i < end_aligned; i +=3D BITS_PER_=
LONG)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_bootmem(pfn_to_page(i), order)=
;
> +
> + =A0 =A0 =A0 for (i =3D end_aligned; i < end; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_bootmem(pfn_to_page(i), 0);
> +}
> +
> +unsigned long __init free_all_memory_core_early(int nodeid)
> +{
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 u64 start, end;
> + =A0 =A0 =A0 unsigned long count =3D 0;
> + =A0 =A0 =A0 struct range *range =3D NULL;
> + =A0 =A0 =A0 int nr_range;
> +
> + =A0 =A0 =A0 nr_range =3D get_free_all_memory_range(&range, nodeid);
> +
> + =A0 =A0 =A0 for (i =3D 0; i < nr_range; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D range[i].start;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D range[i].end;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D end - start;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages_memory(start, end);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return count;
> +}
> +
> +/**
> + * free_all_bootmem_node - release a node's free pages to the buddy allo=
cator
> + * @pgdat: node to be released
> + *
> + * Returns the number of pages actually released.
> + */
> +unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
> +{
> + =A0 =A0 =A0 register_page_bootmem_info_node(pgdat);
> +
> + =A0 =A0 =A0 /* free_all_memory_core_early(MAX_NUMNODES) will be called =
later */
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/**
> + * free_all_bootmem - release free pages to the buddy allocator
> + *
> + * Returns the number of pages actually released.
> + */
> +unsigned long __init free_all_bootmem(void)
> +{
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We need to use MAX_NUMNODES instead of NODE_DATA(0)->n=
ode_id
> + =A0 =A0 =A0 =A0* =A0because in some case like Node0 doesnt have RAM ins=
talled
> + =A0 =A0 =A0 =A0* =A0low ram will be on Node1
> + =A0 =A0 =A0 =A0* Use MAX_NUMNODES will make sure all ranges in early_no=
de_map[]
> + =A0 =A0 =A0 =A0* =A0will be used instead of only Node0 related
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 return free_all_memory_core_early(MAX_NUMNODES);
> +}
> +
> +/**
> + * free_bootmem_node - mark a page range as usable
> + * @pgdat: node the range resides on
> + * @physaddr: starting address of the range
> + * @size: size of the range in bytes
> + *
> + * Partial pages will be considered reserved and left as they are.
> + *
> + * The range must reside completely on the specified node.
> + */
> +void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long s=
ize)
> +{
> + =A0 =A0 =A0 kmemleak_free_part(__va(physaddr), size);
> + =A0 =A0 =A0 memblock_x86_free_range(physaddr, physaddr + size);
> +}
> +
> +/**
> + * free_bootmem - mark a page range as usable
> + * @addr: starting address of the range
> + * @size: size of the range in bytes
> + *
> + * Partial pages will be considered reserved and left as they are.
> + *
> + * The range must be contiguous but may span node boundaries.
> + */
> +void __init free_bootmem(unsigned long addr, unsigned long size)
> +{
> + =A0 =A0 =A0 kmemleak_free_part(__va(addr), size);
> + =A0 =A0 =A0 memblock_x86_free_range(addr, addr + size);
> +}
> +
> +/**
> + * reserve_bootmem_node - mark a page range as reserved
> + * @pgdat: node the range resides on
> + * @physaddr: starting address of the range
> + * @size: size of the range in bytes
> + * @flags: reservation flags (see linux/bootmem.h)
> + *
> + * Partial pages will be reserved.
> + *
> + * The range must reside completely on the specified node.
> + */
> +int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned=
 long size, int flags)
> +{
> + =A0 =A0 =A0 panic("no bootmem");
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/**
> + * reserve_bootmem - mark a page range as usable
> + * @addr: starting address of the range
> + * @size: size of the range in bytes
> + * @flags: reservation flags (see linux/bootmem.h)
> + *
> + * Partial pages will be reserved.
> + *
> + * The range must be contiguous but may span node boundaries.
> + */
> +int __init reserve_bootmem(unsigned long addr, unsigned long size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int flags)
> +{
> + =A0 =A0 =A0 panic("no bootmem");
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void * __init ___alloc_bootmem_nopanic(unsigned long size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long align,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long goal,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long limit)
> +{
> + =A0 =A0 =A0 void *ptr;
> +
> + =A0 =A0 =A0 if (WARN_ON_ONCE(slab_is_available()))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc(size, GFP_NOWAIT);
> +
> +restart:
> +
> + =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, align=
, goal, limit);
> +
> + =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 if (goal !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto restart;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +/**
> + * __alloc_bootmem_nopanic - allocate boot memory without panicking
> + * @size: size of the request in bytes
> + * @align: alignment of the region
> + * @goal: preferred starting address of the region
> + *
> + * The goal is dropped if it can not be satisfied and the allocation wil=
l
> + * fall back to memory below @goal.
> + *
> + * Allocation may happen on any node in the system.
> + *
> + * Returns NULL on failure.
> + */
> +void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long =
align,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long goal)
> +{
> + =A0 =A0 =A0 unsigned long limit =3D -1UL;
> +
> + =A0 =A0 =A0 return ___alloc_bootmem_nopanic(size, align, goal, limit);
> +}
> +
> +static void * __init ___alloc_bootmem(unsigned long size, unsigned long =
align,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long goal, unsigned long limit)
> +{
> + =A0 =A0 =A0 void *mem =3D ___alloc_bootmem_nopanic(size, align, goal, l=
imit);
> +
> + =A0 =A0 =A0 if (mem)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return mem;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Whoops, we cannot satisfy the allocation request.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", s=
ize);
> + =A0 =A0 =A0 panic("Out of memory");
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +/**
> + * __alloc_bootmem - allocate boot memory
> + * @size: size of the request in bytes
> + * @align: alignment of the region
> + * @goal: preferred starting address of the region
> + *
> + * The goal is dropped if it can not be satisfied and the allocation wil=
l
> + * fall back to memory below @goal.
> + *
> + * Allocation may happen on any node in the system.
> + *
> + * The function panics if the request can not be satisfied.
> + */
> +void * __init __alloc_bootmem(unsigned long size, unsigned long align,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long g=
oal)
> +{
> + =A0 =A0 =A0 unsigned long limit =3D -1UL;
> +
> + =A0 =A0 =A0 return ___alloc_bootmem(size, align, goal, limit);
> +}
> +
> +/**
> + * __alloc_bootmem_node - allocate boot memory from a specific node
> + * @pgdat: node to allocate from
> + * @size: size of the request in bytes
> + * @align: alignment of the region
> + * @goal: preferred starting address of the region
> + *
> + * The goal is dropped if it can not be satisfied and the allocation wil=
l
> + * fall back to memory below @goal.
> + *
> + * Allocation may fall back to any node in the system if the specified n=
ode
> + * can not hold the requested memory.
> + *
> + * The function panics if the request can not be satisfied.
> + */
> +void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned long align, unsigned long goal)
> +{
> + =A0 =A0 =A0 void *ptr;
> +
> + =A0 =A0 =A0 if (WARN_ON_ONCE(slab_is_available()))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc_node(size, GFP_NOWAIT, pgdat=
->node_id);
> +
> + =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(pgdat->node_id, size, ali=
gn,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0goal, -1ULL);
> + =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, align=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0goal, -1ULL);
> +
> + =A0 =A0 =A0 return ptr;
> +}
> +
> +void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long =
size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned long align, unsigned long goal)
> +{
> +#ifdef MAX_DMA32_PFN
> + =A0 =A0 =A0 unsigned long end_pfn;
> +
> + =A0 =A0 =A0 if (WARN_ON_ONCE(slab_is_available()))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc_node(size, GFP_NOWAIT, pgdat=
->node_id);
> +
> + =A0 =A0 =A0 /* update goal according ...MAX_DMA32_PFN */
> + =A0 =A0 =A0 end_pfn =3D pgdat->node_start_pfn + pgdat->node_spanned_pag=
es;
> +
> + =A0 =A0 =A0 if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
> + =A0 =A0 =A0 =A0 =A0 (goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *ptr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long new_goal;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_goal =3D MAX_DMA32_PFN << PAGE_SHIFT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D =A0__alloc_memory_core_early(pgdat-=
>node_id, size, align,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0new_goal, -1ULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> + =A0 =A0 =A0 }
> +#endif
> +
> + =A0 =A0 =A0 return __alloc_bootmem_node(pgdat, size, align, goal);
> +
> +}
> +
> +#ifdef CONFIG_SPARSEMEM
> +/**
> + * alloc_bootmem_section - allocate boot memory from a specific section
> + * @size: size of the request in bytes
> + * @section_nr: sparse map section to allocate from
> + *
> + * Return NULL on failure.
> + */
> +void * __init alloc_bootmem_section(unsigned long size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uns=
igned long section_nr)
> +{
> + =A0 =A0 =A0 unsigned long pfn, goal, limit;
> +
> + =A0 =A0 =A0 pfn =3D section_nr_to_pfn(section_nr);
> + =A0 =A0 =A0 goal =3D pfn << PAGE_SHIFT;
> + =A0 =A0 =A0 limit =3D section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
> +
> + =A0 =A0 =A0 return __alloc_memory_core_early(early_pfn_to_nid(pfn), siz=
e,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0SMP_CACHE_BYTES, goal, limit);
> +}
> +#endif
> +
> +void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned lo=
ng size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned long align, unsigned long goal)
> +{
> + =A0 =A0 =A0 void *ptr;
> +
> + =A0 =A0 =A0 if (WARN_ON_ONCE(slab_is_available()))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc_node(size, GFP_NOWAIT, pgdat=
->node_id);
> +
> + =A0 =A0 =A0 ptr =3D =A0__alloc_memory_core_early(pgdat->node_id, size, =
align,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0goal, -1ULL);
> + =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 return __alloc_bootmem_nopanic(size, align, goal);
> +}
> +
> +#ifndef ARCH_LOW_ADDRESS_LIMIT
> +#define ARCH_LOW_ADDRESS_LIMIT 0xffffffffUL
> +#endif
> +
> +/**
> + * __alloc_bootmem_low - allocate low boot memory
> + * @size: size of the request in bytes
> + * @align: alignment of the region
> + * @goal: preferred starting address of the region
> + *
> + * The goal is dropped if it can not be satisfied and the allocation wil=
l
> + * fall back to memory below @goal.
> + *
> + * Allocation may happen on any node in the system.
> + *
> + * The function panics if the request can not be satisfied.
> + */
> +void * __init __alloc_bootmem_low(unsigned long size, unsigned long alig=
n,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigne=
d long goal)
> +{
> + =A0 =A0 =A0 return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS=
_LIMIT);
> +}
> +
> +/**
> + * __alloc_bootmem_low_node - allocate low boot memory from a specific n=
ode
> + * @pgdat: node to allocate from
> + * @size: size of the request in bytes
> + * @align: alignment of the region
> + * @goal: preferred starting address of the region
> + *
> + * The goal is dropped if it can not be satisfied and the allocation wil=
l
> + * fall back to memory below @goal.
> + *
> + * Allocation may fall back to any node in the system if the specified n=
ode
> + * can not hold the requested memory.
> + *
> + * The function panics if the request can not be satisfied.
> + */
> +void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long s=
ize,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0unsigned long align, unsigned long goal)
> +{
> + =A0 =A0 =A0 void *ptr;
> +
> + =A0 =A0 =A0 if (WARN_ON_ONCE(slab_is_available()))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc_node(size, GFP_NOWAIT, pgdat=
->node_id);
> +
> + =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(pgdat->node_id, size, ali=
gn,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal, ARCH_=
LOW_ADDRESS_LIMIT);
> + =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, align=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal, ARCH_=
LOW_ADDRESS_LIMIT);
> + =A0 =A0 =A0 return ptr;
> +}
> --
> 1.7.3.4.600.g982838b0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
