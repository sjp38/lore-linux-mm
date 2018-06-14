Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6E526B0005
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 01:01:13 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id n9-v6so2919034otk.23
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 22:01:13 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id z30-v6si1808984otj.30.2018.06.13.22.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 22:01:07 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: zero remaining unavailable struct pages (Re:
 kernel panic in reading /proc/kpageflags when enabling RAM-simulated PMEM)
Date: Thu, 14 Jun 2018 04:56:30 +0000
Message-ID: <20180614045630.GA17860@hori1.linux.bs1.fc.nec.co.jp>
References: <20180606080408.GA31794@techadventures.net>
 <20180606085319.GA32052@techadventures.net>
 <20180606090630.GA27065@hori1.linux.bs1.fc.nec.co.jp>
 <20180606092405.GA6562@hori1.linux.bs1.fc.nec.co.jp>
 <20180607062218.GB22554@hori1.linux.bs1.fc.nec.co.jp>
 <20180607065940.GA7334@techadventures.net>
 <20180607094921.GA8545@techadventures.net>
 <20180607100256.GA9129@hori1.linux.bs1.fc.nec.co.jp>
 <20180613054107.GA5329@hori1.linux.bs1.fc.nec.co.jp>
 <20180613084032.GA32428@techadventures.net>
In-Reply-To: <20180613084032.GA32428@techadventures.net>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <198CEC3F902121409996458ABC1987F2@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Bob Picco <bob.picco@oracle.com>, Matthew Wilcox <willy@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>

On Wed, Jun 13, 2018 at 10:40:32AM +0200, Oscar Salvador wrote:
> On Wed, Jun 13, 2018 at 05:41:08AM +0000, Naoya Horiguchi wrote:
> > Hi everyone,=20
> >=20
> > I wrote a patch for this issue.
> > There was a discussion about prechecking approach, but I finally found
> > out it's hard to make change on memblock after numa_init, so I take
> > another apporach (see patch description).
> >=20
> > I'm glad if you check that it works for you.
> >=20
> > Thanks,
> > Naoya Horiguchi
> > ---
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Wed, 13 Jun 2018 12:43:27 +0900
> > Subject: [PATCH] mm: zero remaining unavailable struct pages
> >=20
> > There is a kernel panic that is triggered when reading /proc/kpageflags
> > on the kernel booted with kernel parameter 'memmap=3Dnn[KMG]!ss[KMG]':
> >=20
> >   BUG: unable to handle kernel paging request at fffffffffffffffe
> >   PGD 9b20e067 P4D 9b20e067 PUD 9b210067 PMD 0
> >   Oops: 0000 [#1] SMP PTI
> >   CPU: 2 PID: 1728 Comm: page-types Not tainted 4.17.0-rc6-mm1-v4.17-rc=
6-180605-0816-00236-g2dfb086ef02c+ #160
> >   Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.=
fc28 04/01/2014
> >   RIP: 0010:stable_page_flags+0x27/0x3c0
> >   Code: 00 00 00 0f 1f 44 00 00 48 85 ff 0f 84 a0 03 00 00 41 54 55 49 =
89 fc 53 48 8b 57 08 48 8b 2f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48> 8b 00 f=
6 c4 01 0f 84 10 03 00 00 31 db 49 8b 54 24 08 4c 89 e7
> >   RSP: 0018:ffffbbd44111fde0 EFLAGS: 00010202
> >   RAX: fffffffffffffffe RBX: 00007fffffffeff9 RCX: 0000000000000000
> >   RDX: 0000000000000001 RSI: 0000000000000202 RDI: ffffed1182fff5c0
> >   RBP: ffffffffffffffff R08: 0000000000000001 R09: 0000000000000001
> >   R10: ffffbbd44111fed8 R11: 0000000000000000 R12: ffffed1182fff5c0
> >   R13: 00000000000bffd7 R14: 0000000002fff5c0 R15: ffffbbd44111ff10
> >   FS:  00007efc4335a500(0000) GS:ffff93a5bfc00000(0000) knlGS:000000000=
0000000
> >   CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >   CR2: fffffffffffffffe CR3: 00000000b2a58000 CR4: 00000000001406e0
> >   Call Trace:
> >    kpageflags_read+0xc7/0x120
> >    proc_reg_read+0x3c/0x60
> >    __vfs_read+0x36/0x170
> >    vfs_read+0x89/0x130
> >    ksys_pread64+0x71/0x90
> >    do_syscall_64+0x5b/0x160
> >    entry_SYSCALL_64_after_hwframe+0x44/0xa9
> >   RIP: 0033:0x7efc42e75e23
> >   Code: 09 00 ba 9f 01 00 00 e8 ab 81 f4 ff 66 2e 0f 1f 84 00 00 00 00 =
00 90 83 3d 29 0a 2d 00 00 75 13 49 89 ca b8 11 00 00 00 0f 05 <48> 3d 01 f=
0 ff ff 73 34 c3 48 83 ec 08 e8 db d3 01 00 48 89 04 24
> >=20
> > According to kernel bisection, this problem became visible due to commi=
t
> > f7f99100d8d9 which changes how struct pages are initialized.
> >=20
> > Memblock layout affects the pfn ranges covered by node/zone. Consider
> > that we have a VM with 2 NUMA nodes and each node has 4GB memory, and
> > the default (no memmap=3D given) memblock layout is like below:
> >=20
> >   MEMBLOCK configuration:
> >    memory size =3D 0x00000001fff75c00 reserved size =3D 0x000000000300c=
000
> >    memory.cnt  =3D 0x4
> >    memory[0x0]     [0x0000000000001000-0x000000000009efff], 0x000000000=
009e000 bytes on node 0 flags: 0x0
> >    memory[0x1]     [0x0000000000100000-0x00000000bffd6fff], 0x00000000b=
fed7000 bytes on node 0 flags: 0x0
> >    memory[0x2]     [0x0000000100000000-0x000000013fffffff], 0x000000004=
0000000 bytes on node 0 flags: 0x0
> >    memory[0x3]     [0x0000000140000000-0x000000023fffffff], 0x000000010=
0000000 bytes on node 1 flags: 0x0
> >    ...
> >=20
> > If you give memmap=3D1G!4G (so it just covers memory[0x2]),
> > the range [0x100000000-0x13fffffff] is gone:
> >=20
> >   MEMBLOCK configuration:
> >    memory size =3D 0x00000001bff75c00 reserved size =3D 0x000000000300c=
000
> >    memory.cnt  =3D 0x3
> >    memory[0x0]     [0x0000000000001000-0x000000000009efff], 0x000000000=
009e000 bytes on node 0 flags: 0x0
> >    memory[0x1]     [0x0000000000100000-0x00000000bffd6fff], 0x00000000b=
fed7000 bytes on node 0 flags: 0x0
> >    memory[0x2]     [0x0000000140000000-0x000000023fffffff], 0x000000010=
0000000 bytes on node 1 flags: 0x0
> >    ...
> >=20
> > This causes shrinking node 0's pfn range because it is calculated by
> > the address range of memblock.memory. So some of struct pages in the
> > gap range are left uninitialized.
> >=20
> > We have a function zero_resv_unavail() which does zeroing the struct
> > pages outside memblock.memory, but currently it covers only the reserve=
d
> > unavailable range (i.e. memblock.memory && !memblock.reserved).
> > This patch extends it to cover all unavailable range, which fixes
> > the reported issue.
> >=20
> > Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmem=
map")
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  include/linux/memblock.h | 16 ----------------
> >  mm/page_alloc.c          | 33 ++++++++++++++++++++++++---------
> >  2 files changed, 24 insertions(+), 25 deletions(-)
> >=20
> > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > index ca59883c8364..f191e51c5d2a 100644
> > --- a/include/linux/memblock.h
> > +++ b/include/linux/memblock.h
> > @@ -236,22 +236,6 @@ void __next_mem_pfn_range(int *idx, int nid, unsig=
ned long *out_start_pfn,
> >  	for_each_mem_range_rev(i, &memblock.memory, &memblock.reserved,	\
> >  			       nid, flags, p_start, p_end, p_nid)
> > =20
> > -/**
> > - * for_each_resv_unavail_range - iterate through reserved and unavaila=
ble memory
> > - * @i: u64 used as loop variable
> > - * @flags: pick from blocks based on memory attributes
> > - * @p_start: ptr to phys_addr_t for start address of the range, can be=
 %NULL
> > - * @p_end: ptr to phys_addr_t for end address of the range, can be %NU=
LL
> > - *
> > - * Walks over unavailable but reserved (reserved && !memory) areas of =
memblock.
> > - * Available as soon as memblock is initialized.
> > - * Note: because this memory does not belong to any physical node, fla=
gs and
> > - * nid arguments do not make sense and thus not exported as arguments.
> > - */
> > -#define for_each_resv_unavail_range(i, p_start, p_end)			\
> > -	for_each_mem_range(i, &memblock.reserved, &memblock.memory,	\
> > -			   NUMA_NO_NODE, MEMBLOCK_NONE, p_start, p_end, NULL)
> > -
> >  static inline void memblock_set_region_flags(struct memblock_region *r=
,
> >  					     unsigned long flags)
> >  {
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1772513358e9..098f7c2c127b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -6487,25 +6487,40 @@ void __paginginit free_area_init_node(int nid, =
unsigned long *zones_size,
> >   * struct pages which are reserved in memblock allocator and their fie=
lds
> >   * may be accessed (for example page_to_pfn() on some configuration ac=
cesses
> >   * flags). We must explicitly zero those struct pages.
> > + *
> > + * This function also addresses a similar issue where struct pages are=
 left
> > + * uninitialized because the physical address range is not covered by
> > + * memblock.memory or memblock.reserved. That could happen when memblo=
ck
> > + * layout is manually configured via memmap=3D.
> >   */
> >  void __paginginit zero_resv_unavail(void)
> >  {
> >  	phys_addr_t start, end;
> >  	unsigned long pfn;
> >  	u64 i, pgcnt;
> > +	phys_addr_t next =3D 0;
> > =20
> >  	/*
> > -	 * Loop through ranges that are reserved, but do not have reported
> > -	 * physical memory backing.
> > +	 * Loop through unavailable ranges not covered by memblock.memory.
> >  	 */
> >  	pgcnt =3D 0;
> > -	for_each_resv_unavail_range(i, &start, &end) {
> > -		for (pfn =3D PFN_DOWN(start); pfn < PFN_UP(end); pfn++) {
> > -			if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
> > -				continue;
> > -			mm_zero_struct_page(pfn_to_page(pfn));
> > -			pgcnt++;
> > +	for_each_mem_range(i, &memblock.memory, NULL,
> > +			NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL) {
> > +		if (next < start) {
> > +			for (pfn =3D PFN_DOWN(next); pfn < PFN_UP(start); pfn++) {
> > +				if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
> > +					continue;
> > +				mm_zero_struct_page(pfn_to_page(pfn));
> > +				pgcnt++;
> > +			}
> >  		}
> > +		next =3D end;
> > +	}
> > +	for (pfn =3D PFN_DOWN(next); pfn < max_pfn; pfn++) {
> > +		if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
> > +			continue;
> > +		mm_zero_struct_page(pfn_to_page(pfn));
> > +		pgcnt++;
> >  	}
>=20
> Hi Naoya,
>=20
> Is the second loop really needed?
>=20
> AFAIK, max_pfn is set to the latest pfn of E820_TYPE_RAM type, and since
> you are going through all memory ranges within memblock.memory, and then =
assigning next =3D end,
> I think that at the time we are done with the first loop, next will alway=
s point
> to max_pfn (I only checked it for x86).
> Am I right o did I overlooked something?

Hi Oscar,

Thank you for the comment.
Some archs do set max_pfn to end pfn of E820_TYPE_RAM, but some archs
(s390, arm, mips, ...) seem to determine max_pfn in their own way.
I'm not sure this problem is visible in such archs.

>=20
> Besides that, I did some tests and I can no longer reproduce the error.
> So feel free to add:=20
>=20
> Tested-by: Oscar Salvador <osalvador@suse.de>

Thank you!
- Naoya

>=20
> > =20
> >  	/*
> > @@ -6516,7 +6531,7 @@ void __paginginit zero_resv_unavail(void)
> >  	 * this code can be removed.
> >  	 */
> >  	if (pgcnt)
> > -		pr_info("Reserved but unavailable: %lld pages", pgcnt);
> > +		pr_info("Zeroed struct page in unavailable ranges: %lld pages", pgcn=
t);
> >  }
> >  #endif /* CONFIG_HAVE_MEMBLOCK */
> > =20
> > --=20
> > 2.7.4
> >=20
>=20
> Thanks
>=20
> Best Regards
> Oscar Salvador
> =
