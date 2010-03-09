Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 66D256B00C8
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 17:03:38 -0500 (EST)
Received: by wwg30 with SMTP id 30so3604183wwg.14
        for <linux-mm@kvack.org>; Tue, 09 Mar 2010 14:03:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1267644632.4023.28.camel@useless.americas.hpqcorp.net>
References: <1267644632.4023.28.camel@useless.americas.hpqcorp.net>
Date: Tue, 9 Mar 2010 23:03:34 +0100
Message-ID: <4e5e476b1003091403h361984acocc71377660317373@mail.gmail.com>
Subject: Re: [BUG] 2.6.33-mmotm-100302 "page-allocator-reduce-fragmentation-in-buddy-allocator..."
	patch causes Oops at boot
From: Corrado Zoccolo <czoccolo@gmail.com>
Content-Type: multipart/mixed; boundary=0016e6d77e716350b80481655a33
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

--0016e6d77e716350b80481655a33
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Lee,
the correct fix is attached.
It has the good property that the check is compiled out when not
needed (i.e. when !CONFIG_HOLES_IN_ZONE).
Can you give it a spin on your machine?

Thanks,
Corrado

On Wed, Mar 3, 2010 at 8:30 PM, Lee Schermerhorn
<Lee.Schermerhorn@hp.com> wrote:
> Against 2.6.33-mmotm-100302...
>
> The patch: =C2=A0"page-allocator-reduce-fragmentation-in-buddy-allocator-=
by-adding-buddies-that-are-merging-to-the-tail-of-the-free-lists.patch"
> is causing our ia64 platforms to Oops and hang at boot:
>
> ...
> Built 5 zonelists in Zone order, mobility grouping on. =C2=A0Total pages:=
 1043177
> Policy zone: Normal
> <snip pci stuff>
> Unable to handle kernel paging request at virtual address a07fffff9f00000=
0
> swapper[0]: Oops 8813272891392 [1]
> Modules linked in:
>
> Pid: 0, CPU 0, comm: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0swap=
per
> psr : 00001010084a2018 ifs : 8000000000000996 ip =C2=A0: [<a0000001001619=
c0>] =C2=A0 =C2=A0Not tainted (2.6.33-mmotm-100302-1838-dbg)
> ip is at free_one_page+0x4e0/0x820
> unat: 0000000000000000 pfs : 0000000000000996 rsc : 0000000000000003
> rnat: 000000000000000f bsps: 0000000affffffff pr =C2=A0: 666696015982aa59
> ldrs: 0000000000000000 ccv : 0000000000005e9d fpsr: 0009804c8a70433f
> csd : 0000000000000000 ssd : 0000000000000000
> b0 =C2=A0: a0000001001619b0 b6 =C2=A0: a00000010052e8c0 b7 =C2=A0: a00000=
01000687a0
> f6 =C2=A0: 1003e00000000000014a8 f7 =C2=A0: 1003e0000000000000295
> f8 =C2=A0: 1003e0000000000000008 f9 =C2=A0: 1003e0000000000000a48
> f10 : 1003e0000000000000149 f11 : 1003e0000000000000008
> r1 =C2=A0: a000000100c9d220 r2 =C2=A0: a07ffffddf000000 r3 =C2=A0: a00000=
0100ab5688
> r8 =C2=A0: 0000000000000001 r9 =C2=A0: 0000000000000000 r10 : 00000000000=
80000
> r11 : 000000000000000d r12 : a0000001009bfe00 r13 : a0000001009b0000
> r14 : 0000000000000000 r15 : ffffffffffff0000 r16 : a07fffff9f200000
> r17 : 0000000000000001 r18 : a07fffff9f20003f r19 : 0000000000200000
> r20 : a07ffffddf000000 r21 : 0000000000008000 r22 : fffffffffff00000
> r23 : ffffffffffffc000 r24 : 0000000000000000 r25 : 0000000000008000
> r26 : ffffffffffffbfff r27 : ffffffffffffbfff r28 : a000000100ab5b30
> r29 : a000000100ab5688 r30 : 000000000883fc00 r31 : a000000100ab5b38
>
> <2nd Oops>
> Unable to handle kernel NULL pointer dereference (address 000000000000000=
0)
> swapper[0]: Oops 11012296146944 [2]
> Modules linked in:
>
> Pid: 0, CPU 0, comm: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0swap=
per
> psr : 0000121008022018 ifs : 800000000000040b ip =C2=A0: [<a0000001001cdb=
b1>] =C2=A0 =C2=A0Not tainted (2.6.33-mmotm-100302-1838-dbg)
> ip is at kmem_cache_alloc+0x1b1/0x380
> unat: 0000000000000000 pfs : 0000000000000792 rsc : 0000000000000003
> rnat: 0000000000000000 bsps: c0000ffc50057290 pr =C2=A0: 6666960159826965
> ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
> csd : 0000000000000000 ssd : 0000000000000000
> b0 =C2=A0: a0000001000444c0 b6 =C2=A0: a0000001000447a0 b7 =C2=A0: a00000=
010000c170
> f6 =C2=A0: 1003eaca103779b0a35c6 f7 =C2=A0: 1003e9e3779b97f4a7c16
> f8 =C2=A0: 1003e0a00000010001589 f9 =C2=A0: 1003e0000000000000a48
> f10 : 1003e0000000000000149 f11 : 1003e0000000000000008
> r1 =C2=A0: a000000100c9d220 r2 =C2=A0: 0000000012000000 r3 =C2=A0: a00000=
01009b0014
> r8 =C2=A0: 0000000000000000 r9 =C2=A0: 00000000003fff2f r10 : a000000100a=
18788
> r11 : a000000100a9da68 r12 : a0000001009bf2e0 r13 : a0000001009b0000
> r14 : 0000000000000000 r15 : a0000001009bf344 r16 : 0000000000000000
> r17 : 0000000000200000 r18 : 0000000000000000 r19 : a0000001009bf318
> r20 : 0000000000000000 r21 : 0000000000000000 r22 : 0000000000000000
> r23 : a0000001009bf340 r24 : a0000001009bf344 r25 : a000000100ab3d30
> r26 : 0000000000000000 r27 : 0000000000000000 r28 : a0000001009bf340
> r29 : 0000000000000000 r30 : a0000001009b0d94 r31 : a00000010070bca0
>
>
> I think this is pointing at:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0free_one_page+0x4e0:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D> static inline void __free_one_page()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D>static inline int page_is_bu=
ddy()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page_zone_id(p=
age) !=3D page_zone_id(buddy))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ =C2=A0 ???
>
> I expect this has something to do with the alignment of the
> virtual mem_map w/rt the actual start of valid page structs.
> The instrumentation shows that the problem occurs when the
> combined_idx for the last coalesced page =3D=3D 0, resulting in
> a page struct address < start of node 0's node_mem_map.
>
> I've included a work-around patch below, but I'm pretty sure
> it's not the right long-term solution.
>
>
> More info from the boot log, including some ad hoc
> instrumentation of the patched region of __free_one_page().
>
> ...
>
> Virtual mem_map starts at 0xa07ffffddf000000
> Node 0 memmap at 0xa07ffffddf000000 size 0 first pfn 0xa07fffff9f080000
> !!! -------------------------------------------------------------^^^^^^
> Node 1 memmap at 0xa07ffffddf000000 size 0 first pfn 0xa07fffffbf000000
> Node 2 memmap at 0xa07ffffddf000000 size 0 first pfn 0xa07fffffdf000000
> Node 3 memmap at 0xa07ffffddf000000 size 0 first pfn 0xa07fffffff000000
> Node 4 memmap at 0xa07ffffddf000000 size 0 first pfn 0xa07ffffddf000000
>
> On node 0 totalpages: 252672
> free_area_init_node: node 0, pgdat e000070020100000, node_mem_map a07ffff=
f9f080000
> =C2=A0Normal zone: 247 pages used for memmap
> =C2=A0Normal zone: 252425 pages, LIFO batch:1
> On node 1 totalpages: 261120
> free_area_init_node: node 1, pgdat e000078000110080, node_mem_map a07ffff=
fbf000000
> =C2=A0Normal zone: 255 pages used for memmap
> =C2=A0Normal zone: 260865 pages, LIFO batch:1
> On node 2 totalpages: 261119
> free_area_init_node: node 2, pgdat e000080000120100, node_mem_map a07ffff=
fdf000000
> =C2=A0Normal zone: 255 pages used for memmap
> =C2=A0Normal zone: 260864 pages, LIFO batch:1
> On node 3 totalpages: 261097
> free_area_init_node: node 3, pgdat e000088000130180, node_mem_map a07ffff=
fff000000
> =C2=A0Normal zone: 255 pages used for memmap
> =C2=A0Normal zone: 260842 pages, LIFO batch:1
> On node 4 totalpages: 8189
> free_area_init_node: node 4, pgdat e000000000140200, node_mem_map a07ffff=
ddf000000
> =C2=A0DMA zone: 8 pages used for memmap
> =C2=A0DMA zone: 0 pages reserved
> =C2=A0DMA zone: 8181 pages, LIFO batch:0
>
> ...
>
> Instrumentation from __free_one_page() when combined_idx =3D=3D 0:
>
> __free_one_page: =C2=A0page =3D a07fffff9f100000, order =3D 14, page_idx =
=3D 16384
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
000000, higher_buddy =3D a07fffff9f200000
> __free_one_page: =C2=A0page =3D a07fffff9f200000, order =3D 15, page_idx =
=3D 32768
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
000000, higher_buddy =3D a07fffff9f400000
>
>>The higher_page's above appear to be below the start of node 0's node_mem=
_map.
>>The first combined_idx =3D=3D 0 was causing the Oops.
>
>
>> Some [most? all?] of the following from nodes 0 and 1 may be OK? =C2=A0p=
age addresses appear
>> to be in range of their respecitive node's node_mem_map.
>
> __free_one_page: =C2=A0page =3D a07fffff9f800000, order =3D 6, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
800000, higher_buddy =3D a07fffff9f802000
> __free_one_page: =C2=A0page =3D a07fffff9f800000, order =3D 7, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
800000, higher_buddy =3D a07fffff9f804000
> __free_one_page: =C2=A0page =3D a07fffff9f800000, order =3D 8, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
800000, higher_buddy =3D a07fffff9f808000
> __free_one_page: =C2=A0page =3D a07fffff9f800000, order =3D 9, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
800000, higher_buddy =3D a07fffff9f810000
> __free_one_page: =C2=A0page =3D a07fffff9f800000, order =3D 10, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
800000, higher_buddy =3D a07fffff9f820000
> __free_one_page: =C2=A0page =3D a07fffff9f800000, order =3D 11, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
800000, higher_buddy =3D a07fffff9f840000
> __free_one_page: =C2=A0page =3D a07fffff9f800000, order =3D 12, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
800000, higher_buddy =3D a07fffff9f880000
> __free_one_page: =C2=A0page =3D a07fffff9f800000, order =3D 13, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
800000, higher_buddy =3D a07fffff9f900000
> __free_one_page: =C2=A0page =3D a07fffff9f800000, order =3D 14, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
800000, higher_buddy =3D a07fffff9fa00000
> __free_one_page: =C2=A0page =3D a07fffff9f800000, order =3D 15, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffff9f=
800000, higher_buddy =3D a07fffff9fc00000
> <Node 1>
> __free_one_page: =C2=A0page =3D a07fffffbf008000, order =3D 9, page_idx =
=3D 512
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
000000, higher_buddy =3D a07fffffbf010000
> __free_one_page: =C2=A0page =3D a07fffffbf010000, order =3D 10, page_idx =
=3D 1024
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
000000, higher_buddy =3D a07fffffbf020000
> __free_one_page: =C2=A0page =3D a07fffffbf020000, order =3D 11, page_idx =
=3D 2048
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
000000, higher_buddy =3D a07fffffbf040000
> __free_one_page: =C2=A0page =3D a07fffffbf040000, order =3D 12, page_idx =
=3D 4096
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
000000, higher_buddy =3D a07fffffbf080000
> __free_one_page: =C2=A0page =3D a07fffffbf080000, order =3D 13, page_idx =
=3D 8192
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
000000, higher_buddy =3D a07fffffbf100000
> __free_one_page: =C2=A0page =3D a07fffffbf100000, order =3D 14, page_idx =
=3D 16384
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
000000, higher_buddy =3D a07fffffbf200000
> __free_one_page: =C2=A0page =3D a07fffffbf200000, order =3D 15, page_idx =
=3D 32768
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
000000, higher_buddy =3D a07fffffbf400000
> __free_one_page: =C2=A0page =3D a07fffffbf800000, order =3D 6, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
800000, higher_buddy =3D a07fffffbf802000
> __free_one_page: =C2=A0page =3D a07fffffbf800000, order =3D 7, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
800000, higher_buddy =3D a07fffffbf804000
> __free_one_page: =C2=A0page =3D a07fffffbf800000, order =3D 8, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
800000, higher_buddy =3D a07fffffbf808000
> __free_one_page: =C2=A0page =3D a07fffffbf800000, order =3D 9, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
800000, higher_buddy =3D a07fffffbf810000
> __free_one_page: =C2=A0page =3D a07fffffbf800000, order =3D 10, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
800000, higher_buddy =3D a07fffffbf820000
> __free_one_page: =C2=A0page =3D a07fffffbf800000, order =3D 11, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
800000, higher_buddy =3D a07fffffbf840000
> __free_one_page: =C2=A0page =3D a07fffffbf800000, order =3D 12, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
800000, higher_buddy =3D a07fffffbf880000
> __free_one_page: =C2=A0page =3D a07fffffbf800000, order =3D 13, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
800000, higher_buddy =3D a07fffffbf900000
> __free_one_page: =C2=A0page =3D a07fffffbf800000, order =3D 14, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
800000, higher_buddy =3D a07fffffbfa00000
> __free_one_page: =C2=A0page =3D a07fffffbf800000, order =3D 15, page_idx =
=3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D 0, higher_page =3D a07fffffbf=
800000, higher_buddy =3D a07fffffbfc00000
> <snip similar lines for nodes 2, 3, & 4>
> Memory: 66735232k/66807296k available (6886k code, 93440k reserved, 4015k=
 data, 704k init)
>
> ---
>
> The following patch--unsigned and almost certainly bogus--avoids
> the problem by ignoring pages with combined_idx =3D=3D 0. =C2=A0This will
> cause __free_one_page() to skip some valid higher order potential
> buddies. =C2=A0It would probably be more generic to verify that the
> resulting higher_page is in range of the node's mem_map. =C2=A0I haven't
> figured out how to do that efficiently here, yet.
>
> Maybe something like:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pg_data_t *pgdat =3D NODE_DATA[zone_to_nid(zon=
e)];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (higher_page > pgdat->node_mem_map && highe=
r_buddy > pgdat->node_mem_map &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page_is_buddy()...
>
> But this might be a bit heavy for this path? =C2=A0And should we check th=
e end of the
> node_mem_map as well?
>
>
> =C2=A0mm/page_alloc.c | =C2=A0 =C2=A03 ++-
> =C2=A01 file changed, 2 insertions(+), 1 deletion(-)
>
> Index: linux-2.6.33-rc7-mmotm-100211-2155/mm/page_alloc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.33-rc7-mmotm-100211-2155.orig/mm/page_alloc.c
> +++ linux-2.6.33-rc7-mmotm-100211-2155/mm/page_alloc.c
> @@ -494,7 +494,8 @@ static inline void __free_one_page(struc
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0combined_idx =3D _=
_find_combined_index(page_idx, order);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0higher_page =3D pa=
ge + combined_idx - page_idx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0higher_buddy =3D _=
_page_find_buddy(higher_page, combined_idx, order + 1);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page_is_buddy(high=
er_page, higher_buddy, order + 1)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (combined_idx &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page_is_=
buddy(higher_page, higher_buddy, order + 1)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_add_tail(&page->lru,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&zone->free_area[order].free_list[mig=
ratetype]);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto out;
>
>
>



--=20
__________________________________________________________________________

dott. Corrado Zoccolo                          mailto:czoccolo@gmail.com
PhD - Department of Computer Science - University of Pisa, Italy
--------------------------------------------------------------------------
The self-confidence of a warrior is not the self-confidence of the average
man. The average man seeks certainty in the eyes of the onlooker and calls
that self-confidence. The warrior seeks impeccability in his own eyes and
calls that humbleness.
                               Tales of Power - C. Castaneda

--0016e6d77e716350b80481655a33
Content-Type: application/octet-stream; name=fix
Content-Disposition: attachment; filename=fix
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g6l8rwuq1

ZGlmZiAtLWdpdCBhL21tL3BhZ2VfYWxsb2MuYyBiL21tL3BhZ2VfYWxsb2MuYwppbmRleCBhY2Ey
NjZkLi41ZjIzMjM4IDEwMDY0NAotLS0gYS9tbS9wYWdlX2FsbG9jLmMKKysrIGIvbW0vcGFnZV9h
bGxvYy5jCkBAIC00NTMsNiArNDUzLDcgQEAgc3RhdGljIGlubGluZSB2b2lkIF9fZnJlZV9vbmVf
cGFnZShzdHJ1Y3QgcGFnZSAqcGFnZSwKIHsKIAl1bnNpZ25lZCBsb25nIHBhZ2VfaWR4OwogCXVu
c2lnbmVkIGxvbmcgY29tYmluZWRfaWR4OworCXN0cnVjdCBwYWdlICpidWRkeTsKIAogCWlmICh1
bmxpa2VseShQYWdlQ29tcG91bmQocGFnZSkpKQogCQlpZiAodW5saWtlbHkoZGVzdHJveV9jb21w
b3VuZF9wYWdlKHBhZ2UsIG9yZGVyKSkpCkBAIC00NjYsOCArNDY3LDYgQEAgc3RhdGljIGlubGlu
ZSB2b2lkIF9fZnJlZV9vbmVfcGFnZShzdHJ1Y3QgcGFnZSAqcGFnZSwKIAlWTV9CVUdfT04oYmFk
X3JhbmdlKHpvbmUsIHBhZ2UpKTsKIAogCXdoaWxlIChvcmRlciA8IE1BWF9PUkRFUi0xKSB7Ci0J
CXN0cnVjdCBwYWdlICpidWRkeTsKLQogCQlidWRkeSA9IF9fcGFnZV9maW5kX2J1ZGR5KHBhZ2Us
IHBhZ2VfaWR4LCBvcmRlcik7CiAJCWlmICghcGFnZV9pc19idWRkeShwYWdlLCBidWRkeSwgb3Jk
ZXIpKQogCQkJYnJlYWs7CkBAIC00OTEsNyArNDkwLDcgQEAgc3RhdGljIGlubGluZSB2b2lkIF9f
ZnJlZV9vbmVfcGFnZShzdHJ1Y3QgcGFnZSAqcGFnZSwKIAkgKiBzbyBpdCdzIGxlc3MgbGlrZWx5
IHRvIGJlIHVzZWQgc29vbiBhbmQgbW9yZSBsaWtlbHkgdG8gYmUgbWVyZ2VkCiAJICogYXMgYSBo
aWdoZXIgb3JkZXIgcGFnZQogCSAqLwotCWlmIChvcmRlciA8IE1BWF9PUkRFUi0xKSB7CisJaWYg
KChvcmRlciA8IE1BWF9PUkRFUi0xKSAmJiBwZm5fdmFsaWRfd2l0aGluKHBhZ2VfdG9fcGZuKGJ1
ZGR5KSkpIHsKIAkJc3RydWN0IHBhZ2UgKmhpZ2hlcl9wYWdlLCAqaGlnaGVyX2J1ZGR5OwogCQlj
b21iaW5lZF9pZHggPSBfX2ZpbmRfY29tYmluZWRfaW5kZXgocGFnZV9pZHgsIG9yZGVyKTsKIAkJ
aGlnaGVyX3BhZ2UgPSBwYWdlICsgY29tYmluZWRfaWR4IC0gcGFnZV9pZHg7Cg==
--0016e6d77e716350b80481655a33--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
