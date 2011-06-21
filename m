Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA3416B0131
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 20:31:30 -0400 (EDT)
From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Mon, 20 Jun 2011 19:31:26 -0500
Subject: RE: [Q] mm/memblock.c: cast truncates bits from RED_INACTIVE
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F38227BF35@AUSP01VMBX24.collaborationhost.net>
References: <ADE657CA350FB648AAC2C43247A983F001F382220E0F@AUSP01VMBX24.collaborationhost.net>
 <20110620170249.d5cd98b1.akpm@linux-foundation.org>
In-Reply-To: <20110620170249.d5cd98b1.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "yinghai@kernel.org" <yinghai@kernel.org>, "hpa@linux.intel.com" <hpa@linux.intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Monday, June 20, 2011 5:03 PM, Andrew Morton wrote:
> On Tue, 14 Jun 2011 19:47:19 -0500 H Hartley Sweeten wrote:
>
>> Hello all,
>>=20
>> Sparse is reporting a couple warnings in mm/memblock.c:
>>=20
>> 	warning: cast truncates bits from constant value (9f911029d74e35b becom=
es 9d74e35b)
>>=20
>> The warnings are due to the cast of RED_INACTIVE in memblock_analyze():
>>=20
>> 	/* Check marker in the unused last array entry */
>> 	WARN_ON(memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS].base
>> 		!=3D (phys_addr_t)RED_INACTIVE);
>> 	WARN_ON(memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS].base
>> 		!=3D (phys_addr_t)RED_INACTIVE);
>>=20
>> And in memblock_init():
>>=20
>> 	/* Write a marker in the unused last array entry */
>> 	memblock.memory.regions[INIT_MEMBLOCK_REGIONS].base =3D (phys_addr_t)RE=
D_INACTIVE;
>> 	memblock.reserved.regions[INIT_MEMBLOCK_REGIONS].base =3D (phys_addr_t)=
RED_INACTIVE;
>>=20
>> Could this cause any problems?  If not, is there anyway to quiet the spa=
rse noise?
>>=20
>
> It's all just a debugging check and that check will continue to work OK
> despite this bug.
>
> But yes, it's ugly and should be fixed.
>
> I don't think that mm/memblock.c should have reused RED_INACTIVE.=20
> That's a slab thing and wedging it into a phys_addr_t was
> inappropriate.
>
> In fact I don't think RED_INACTIVE should exist.  It's just inviting
> other subsystems to (ab)use it.  It should be replaced by a
> slab-specific SLAB_RED_INACTIVE, as slub did with SLUB_RED_INACTIVE.
>
>
> I'd suggest something like the below, which I didn't test.  Feel free to
> send it back at me, or ignore it ;)
>
>
> diff -puN include/linux/poison.h~a include/linux/poison.h
> --- a/include/linux/poison.h~a
> +++ a/include/linux/poison.h
> @@ -40,6 +40,12 @@
>  #define	RED_INACTIVE	0x09F911029D74E35BULL	/* when obj is inactive */
>  #define	RED_ACTIVE	0xD84156C5635688C0ULL	/* when obj is active */
> =20
> +#ifdef CONFIG_PHYS_ADDR_T_64BIT
> +#define MEMBLOCK_INACTIVE	0x3a84fb0144c9e71bULL
> +#else
> +#define MEMBLOCK_INACTIVE	0x44c9e71bUL
> +#endif
> +
>  #define SLUB_RED_INACTIVE	0xbb
>  #define SLUB_RED_ACTIVE		0xcc
> =20
> diff -puN mm/memblock.c~a mm/memblock.c
> --- a/mm/memblock.c~a
> +++ a/mm/memblock.c
> @@ -758,9 +758,9 @@ void __init memblock_analyze(void)
> =20
>  	/* Check marker in the unused last array entry */
>  	WARN_ON(memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS].base
> -		!=3D (phys_addr_t)RED_INACTIVE);
> +		!=3D MEMBLOCK_INACTIVE);
>  	WARN_ON(memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS].base
> -		!=3D (phys_addr_t)RED_INACTIVE);
> +		!=3D MEMBLOCK_INACTIVE);
> =20
>  	memblock.memory_size =3D 0;
> =20
> @@ -786,8 +786,8 @@ void __init memblock_init(void)
>  	memblock.reserved.max	=3D INIT_MEMBLOCK_REGIONS;
> =20
>  	/* Write a marker in the unused last array entry */
> -	memblock.memory.regions[INIT_MEMBLOCK_REGIONS].base =3D (phys_addr_t)RE=
D_INACTIVE;
> -	memblock.reserved.regions[INIT_MEMBLOCK_REGIONS].base =3D (phys_addr_t)=
RED_INACTIVE;
> +	memblock.memory.regions[INIT_MEMBLOCK_REGIONS].base =3D MEMBLOCK_INACTI=
VE;
> +	memblock.reserved.regions[INIT_MEMBLOCK_REGIONS].base =3D MEMBLOCK_INAC=
TIVE;
> =20
>  	/* Create a dummy zero size MEMBLOCK which will get coalesced away late=
r.
>  	 * This simplifies the memblock_add() code below...

FWIW, your patch above quiet's the sparse warnings on my system (arm ep93xx=
) and
the system boots and runs fine.

If you want it..

Tested-by: H Hartley Sweeten <hsweeten@visionengravers.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
