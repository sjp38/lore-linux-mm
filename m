Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6FA56B0006
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 21:08:12 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s19-v6so6224012iog.0
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 18:08:12 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 11-v6si514937ito.81.2018.06.14.18.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 18:08:11 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2] x86/e820: put !E820_TYPE_RAM regions into
 memblock.reserved
Date: Fri, 15 Jun 2018 00:58:54 +0000
Message-ID: <20180615005853.GA1196@hori1.linux.bs1.fc.nec.co.jp>
References: <20180607065940.GA7334@techadventures.net>
 <20180607094921.GA8545@techadventures.net>
 <20180607100256.GA9129@hori1.linux.bs1.fc.nec.co.jp>
 <20180613054107.GA5329@hori1.linux.bs1.fc.nec.co.jp>
 <20180613090700.GG13364@dhcp22.suse.cz>
 <20180614051618.GB17860@hori1.linux.bs1.fc.nec.co.jp>
 <20180614053859.GA9863@techadventures.net>
 <20180614063454.GA32419@hori1.linux.bs1.fc.nec.co.jp>
 <20180614072103.GA10582@techadventures.net>
 <20180614112437.GA12511@techadventures.net>
In-Reply-To: <20180614112437.GA12511@techadventures.net>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <832FF00820ABBF449D3736DB80D8C7A0@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Matthew Wilcox <willy@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "mingo@kernel.org" <mingo@kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>

On Thu, Jun 14, 2018 at 01:24:37PM +0200, Oscar Salvador wrote:
> On Thu, Jun 14, 2018 at 09:21:03AM +0200, Oscar Salvador wrote:
> > On Thu, Jun 14, 2018 at 06:34:55AM +0000, Naoya Horiguchi wrote:
> > > On Thu, Jun 14, 2018 at 07:38:59AM +0200, Oscar Salvador wrote:
> > > > On Thu, Jun 14, 2018 at 05:16:18AM +0000, Naoya Horiguchi wrote:
> > > ...
> > > > >=20
> > > > > My concern is that there are a few E820 memory types rather than
> > > > > E820_TYPE_RAM and E820_TYPE_RESERVED, and I'm not sure that putti=
ng them
> > > > > all into memblock.reserved is really acceptable.
> > > >=20
> > > > Hi Naoya,
> > > >=20
> > > > Maybe you could just add to memblock.reserved, all unavailable rang=
es within
> > > > E820_TYPE_RAM.
> > > > Actually, in your original patch, you are walking memblock.memory, =
which should
> > > > only contain E820_TYPE_RAM ranges (talking about x86).
> > > >=20
> > > > So I think the below would to the trick as well?
> > > >=20
> > > > @@ -1248,6 +1276,7 @@ void __init e820__memblock_setup(void)
> > > >  {
> > > >         int i;
> > > >         u64 end;
> > > > +       u64 next =3D 0;
> > > > =20
> > > >         /*
> > > >          * The bootstrap memblock region count maximum is 128 entri=
es
> > > > =20
> > > > @@ -1269,6 +1299,14 @@ void __init e820__memblock_setup(void)
> > > > =20
> > > >                 if (entry->type !=3D E820_TYPE_RAM && entry->type !=
=3D E820_TYPE_RESERVED_KERN)
> > > >                         continue;
> > > >
> > > > +      =20
> > > > +               if (entry->type =3D=3D E820_TYPE_RAM)
> > > > +                       if (next < entry->addr) {
> > > > +                       	memblock_reserve (next, next + (entry->add=
r - next));
> > > > +                        	next =3D end;
> > > > +                	}
> > > >=20
> > > > With the above patch, I can no longer see the issues either.
> > >=20
> > > I double-checked and this change looks good to me.
> > >=20
> > > >=20
> > > > Although, there is a difference between this and your original patc=
h.
> > > > In your original patch, you are just zeroing the pages, while with =
this one (or with your second patch),
> > > > we will zero the page in reserve_bootmem_region(), but that functio=
n also init
> > > > some other fields of the struct page:
> > > >=20
> > > > mm_zero_struct_page(page);
> > > > set_page_links(page, zone, nid, pfn);
> > > > init_page_count(page);
> > > > page_mapcount_reset(page);
> > > > page_cpupid_reset_last(page);
> > > >=20
> > > > So I am not sure we want to bother doing that for pages that are re=
ally unreachable.
> > >=20
> > > I think that considering that /proc/kpageflags can check them, some d=
ata
> > > (even if it's trivial) might be better than just zeros.
> > >=20
> > > Here's the updated patch.
> > > Thanks for the suggestion and testing!
> > >=20
> > > ---
> > > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Date: Thu, 14 Jun 2018 14:44:36 +0900
> > > Subject: [PATCH] x86/e820: put !E820_TYPE_RAM regions into memblock.r=
eserved
> > >=20
> > > There is a kernel panic that is triggered when reading /proc/kpagefla=
gs
> > > on the kernel booted with kernel parameter 'memmap=3Dnn[KMG]!ss[KMG]'=
:
> > >=20
> > >   BUG: unable to handle kernel paging request at fffffffffffffffe
> > >   PGD 9b20e067 P4D 9b20e067 PUD 9b210067 PMD 0
> > >   Oops: 0000 [#1] SMP PTI
> > >   CPU: 2 PID: 1728 Comm: page-types Not tainted 4.17.0-rc6-mm1-v4.17-=
rc6-180605-0816-00236-g2dfb086ef02c+ #160
> > >   Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-=
2.fc28 04/01/2014
> > >   RIP: 0010:stable_page_flags+0x27/0x3c0
> > >   Code: 00 00 00 0f 1f 44 00 00 48 85 ff 0f 84 a0 03 00 00 41 54 55 4=
9 89 fc 53 48 8b 57 08 48 8b 2f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48> 8b 00=
 f6 c4 01 0f 84 10 03 00 00 31 db 49 8b 54 24 08 4c 89 e7
> > >   RSP: 0018:ffffbbd44111fde0 EFLAGS: 00010202
> > >   RAX: fffffffffffffffe RBX: 00007fffffffeff9 RCX: 0000000000000000
> > >   RDX: 0000000000000001 RSI: 0000000000000202 RDI: ffffed1182fff5c0
> > >   RBP: ffffffffffffffff R08: 0000000000000001 R09: 0000000000000001
> > >   R10: ffffbbd44111fed8 R11: 0000000000000000 R12: ffffed1182fff5c0
> > >   R13: 00000000000bffd7 R14: 0000000002fff5c0 R15: ffffbbd44111ff10
> > >   FS:  00007efc4335a500(0000) GS:ffff93a5bfc00000(0000) knlGS:0000000=
000000000
> > >   CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > >   CR2: fffffffffffffffe CR3: 00000000b2a58000 CR4: 00000000001406e0
> > >   Call Trace:
> > >    kpageflags_read+0xc7/0x120
> > >    proc_reg_read+0x3c/0x60
> > >    __vfs_read+0x36/0x170
> > >    vfs_read+0x89/0x130
> > >    ksys_pread64+0x71/0x90
> > >    do_syscall_64+0x5b/0x160
> > >    entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > >   RIP: 0033:0x7efc42e75e23
> > >   Code: 09 00 ba 9f 01 00 00 e8 ab 81 f4 ff 66 2e 0f 1f 84 00 00 00 0=
0 00 90 83 3d 29 0a 2d 00 00 75 13 49 89 ca b8 11 00 00 00 0f 05 <48> 3d 01=
 f0 ff ff 73 34 c3 48 83 ec 08 e8 db d3 01 00 48 89 04 24
> > >=20
> > > According to kernel bisection, this problem became visible due to com=
mit
> > > f7f99100d8d9 which changes how struct pages are initialized.
> > >=20
> > > Memblock layout affects the pfn ranges covered by node/zone. Consider
> > > that we have a VM with 2 NUMA nodes and each node has 4GB memory, and
> > > the default (no memmap=3D given) memblock layout is like below:
> > >=20
> > >   MEMBLOCK configuration:
> > >    memory size =3D 0x00000001fff75c00 reserved size =3D 0x00000000030=
0c000
> > >    memory.cnt  =3D 0x4
> > >    memory[0x0]     [0x0000000000001000-0x000000000009efff], 0x0000000=
00009e000 bytes on node 0 flags: 0x0
> > >    memory[0x1]     [0x0000000000100000-0x00000000bffd6fff], 0x0000000=
0bfed7000 bytes on node 0 flags: 0x0
> > >    memory[0x2]     [0x0000000100000000-0x000000013fffffff], 0x0000000=
040000000 bytes on node 0 flags: 0x0
> > >    memory[0x3]     [0x0000000140000000-0x000000023fffffff], 0x0000000=
100000000 bytes on node 1 flags: 0x0
> > >    ...
> > >=20
> > > If you give memmap=3D1G!4G (so it just covers memory[0x2]),
> > > the range [0x100000000-0x13fffffff] is gone:
> > >=20
> > >   MEMBLOCK configuration:
> > >    memory size =3D 0x00000001bff75c00 reserved size =3D 0x00000000030=
0c000
> > >    memory.cnt  =3D 0x3
> > >    memory[0x0]     [0x0000000000001000-0x000000000009efff], 0x0000000=
00009e000 bytes on node 0 flags: 0x0
> > >    memory[0x1]     [0x0000000000100000-0x00000000bffd6fff], 0x0000000=
0bfed7000 bytes on node 0 flags: 0x0
> > >    memory[0x2]     [0x0000000140000000-0x000000023fffffff], 0x0000000=
100000000 bytes on node 1 flags: 0x0
> > >    ...
> > >=20
> > > This causes shrinking node 0's pfn range because it is calculated by
> > > the address range of memblock.memory. So some of struct pages in the
> > > gap range are left uninitialized.
> > >=20
> > > We have a function zero_resv_unavail() which does zeroing the struct
> > > pages within the reserved unavailable range (i.e. memblock.memory &&
> > > !memblock.reserved). This patch utilizes it to cover all unavailable
> > > ranges by putting them into memblock.reserved.
>=20
> I just spotted this.
> It seems that the changelog has not been updated.
> It still refers to zero_resv_unavail(), while this patch takes
> a different approach.

Actually I updated this paragraph a little. v1 changes zero_resv_unavail()
itself to do zeroing every range outside memblock.memory!.
And v2 keeps zero_resv_unavail() as is, but by newly putting some ranges
into memblock.reserved, the ranges become to be handled by zero_resv_unavai=
l(),
so I still mention this function.

It seems that with current patch we zero twice in zero_resv_unavail() and
reserve_bootmem_region(), so there might be a room of improvement to remove
the duplicate.

Thanks,
Naoya Horiguchi

>=20
> > >=20
> > > Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vm=
emmap")
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Suggested-by: Oscar Salvador <osalvador@techadventures.net>
> > > Tested-by: Oscar Salvador <osalvador@techadventures.net>
> > > ---
> > >  arch/x86/kernel/e820.c | 12 ++++++++++++
> > >  1 file changed, 12 insertions(+)
> > >=20
> > > diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> > > index d1f25c831447..d15ef47ea354 100644
> > > --- a/arch/x86/kernel/e820.c
> > > +++ b/arch/x86/kernel/e820.c
> > > @@ -1248,6 +1248,7 @@ void __init e820__memblock_setup(void)
> > >  {
> > >  	int i;
> > >  	u64 end;
> > > +	u64 next =3D 0;
> > > =20
> > >  	/*
> > >  	 * The bootstrap memblock region count maximum is 128 entries
> > > @@ -1270,6 +1271,17 @@ void __init e820__memblock_setup(void)
> > >  		if (entry->type !=3D E820_TYPE_RAM && entry->type !=3D E820_TYPE_R=
ESERVED_KERN)
> > >  			continue;
> > > =20
> > > +		/*
> > > +		 * Ranges unavailable in E820_TYPE_RAM are put into
> > > +		 * memblock.reserved, to make sure that struct pages in such
> > > +		 * regions are not left uninitialized after bootup.
> > > +		 */
> > > +		if (entry->type =3D=3D E820_TYPE_RAM)
> > > +			if (next < entry->addr) {
> > > +				memblock_reserve (next, next + (entry->addr - next));
> > > +				next =3D end;
> > > +			}
> > > +
> > >  		memblock_add(entry->addr, entry->size);
> > >  	}
> >=20
> > Thanks Naoya!
> >=20
> > Andrew: In case you consider to take this patch instead of the first on=
e,
> > could you please replace "osalvador@techadventures.net" with "osalvador=
@suse.de"?
> >=20
> > Thanks
> >=20
> > Best Regards
> > Oscar Salvador
> >=20
>=20
> Best Regards
> Oscar Salvador
> =
