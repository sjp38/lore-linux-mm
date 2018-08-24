Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14D406B2CC0
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 20:05:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 191-v6so1679070pgb.23
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 17:05:28 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id m11-v6si5616512pgk.468.2018.08.23.17.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 17:05:26 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] Revert "x86/e820: put !E820_TYPE_RAM regions into
 memblock.reserved"
Date: Fri, 24 Aug 2018 00:03:25 +0000
Message-ID: <20180824000325.GA20143@hori1.linux.bs1.fc.nec.co.jp>
References: <20180823182513.8801-1-msys.mizuma@gmail.com>
In-Reply-To: <20180823182513.8801-1-msys.mizuma@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4ACE734EF426E548A9644DAC9290E1B2@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "osalvador@techadventures.net" <osalvador@techadventures.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "mhocko@kernel.org" <mhocko@kernel.org>

(CCed related people)

Hi Mizuma-san,

Thank you for the report.
The mentioned patch was created based on feedbacks from reviewers/maintaine=
rs,
so I'd like to hear from them about how we should handle the issue.

And one note is that there is a follow-up patch for "x86/e820: put !E820_TY=
PE_RAM
regions into memblock.reserved" which might be affected by your changes.

> commit e181ae0c5db9544de9c53239eb22bc012ce75033
> Author: Pavel Tatashin <pasha.tatashin@oracle.com>
> Date:   Sat Jul 14 09:15:07 2018 -0400
>=20
>     mm: zero unavailable pages before memmap init

Thanks,
Naoya Horiguchi

On Thu, Aug 23, 2018 at 02:25:12PM -0400, Masayoshi Mizuma wrote:
> From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
>=20
> commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into
> memblock.reserved") breaks movable_node kernel option because it
> changed the memory gap range to reserved memblock. So, the node
> is marked as Normal zone even if the SRAT has Hot plaggable affinity.
>=20
>     =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>     kernel: BIOS-e820: [mem 0x0000180000000000-0x0000180fffffffff] usable
>     kernel: BIOS-e820: [mem 0x00001c0000000000-0x00001c0fffffffff] usable
>     ...
>     kernel: reserved[0x12]#011[0x0000181000000000-0x00001bffffffffff], 0x=
000003f000000000 bytes flags: 0x0
>     ...
>     kernel: ACPI: SRAT: Node 2 PXM 6 [mem 0x180000000000-0x1bffffffffff] =
hotplug
>     kernel: ACPI: SRAT: Node 3 PXM 7 [mem 0x1c0000000000-0x1fffffffffff] =
hotplug
>     ...
>     kernel: Movable zone start for each node
>     kernel:  Node 3: 0x00001c0000000000
>     kernel: Early memory node ranges
>     ...
>     =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> Naoya's v1 patch [*] fixes the original issue and this movable_node
> issue doesn't occur.
> Let's revert commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM
> regions into memblock.reserved") and apply the v1 patch.
>=20
> [*] https://lkml.org/lkml/2018/6/13/27
>=20
> Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> ---
>  arch/x86/kernel/e820.c | 15 +++------------
>  1 file changed, 3 insertions(+), 12 deletions(-)
>=20
> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> index c88c23c658c1..d1f25c831447 100644
> --- a/arch/x86/kernel/e820.c
> +++ b/arch/x86/kernel/e820.c
> @@ -1248,7 +1248,6 @@ void __init e820__memblock_setup(void)
>  {
>  	int i;
>  	u64 end;
> -	u64 addr =3D 0;
> =20
>  	/*
>  	 * The bootstrap memblock region count maximum is 128 entries
> @@ -1265,21 +1264,13 @@ void __init e820__memblock_setup(void)
>  		struct e820_entry *entry =3D &e820_table->entries[i];
> =20
>  		end =3D entry->addr + entry->size;
> -		if (addr < entry->addr)
> -			memblock_reserve(addr, entry->addr - addr);
> -		addr =3D end;
>  		if (end !=3D (resource_size_t)end)
>  			continue;
> =20
> -		/*
> -		 * all !E820_TYPE_RAM ranges (including gap ranges) are put
> -		 * into memblock.reserved to make sure that struct pages in
> -		 * such regions are not left uninitialized after bootup.
> -		 */
>  		if (entry->type !=3D E820_TYPE_RAM && entry->type !=3D E820_TYPE_RESER=
VED_KERN)
> -			memblock_reserve(entry->addr, entry->size);
> -		else
> -			memblock_add(entry->addr, entry->size);
> +			continue;
> +
> +		memblock_add(entry->addr, entry->size);
>  	}
> =20
>  	/* Throw away partial pages: */
> --=20
> 2.18.0
>=20
> =
