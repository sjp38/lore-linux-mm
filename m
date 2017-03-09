Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF566B03E8
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 22:44:21 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 77so87933815pgc.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 19:44:21 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id f12si5149046pgn.102.2017.03.08.19.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 19:44:20 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id v190so5798384pfb.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 19:44:20 -0800 (PST)
Date: Thu, 9 Mar 2017 11:44:15 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/2] mm/memblock: use NUMA_NO_NODE instead of
 MAX_NUMNODES as default node_id
Message-ID: <20170309034415.GA16588@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170127015922.36249-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="FL5UXtIhxfXey3p5"
Content-Disposition: inline
In-Reply-To: <20170127015922.36249-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello, everyone,

By deeper thinking, I am willing to split these two patches into two patch
set, since they are trying to address two different things.

The first one [Patch 1] is trying to use NUMA_NO_NODE as the default node_i=
d in
memblock_region.

Current implementation use MAX_NUMNODES as the default nid in several
situations:

    * when it adds a range from e820 to memblock=20
    * when it returns an allocated range, it sets nid to MAX_NUMNODES=20
    * on x86 before initialize the numa info, it set all nid to MAX_NUMNODES

The usage of MAX_NUMNODES here is not accurate, and NUMA_NO_NODE should be
used here.

When looking at the allocation procedure of memblock, it translate
MAX_NUMNODES to NUMA_NO_NODE and mentioned MAX_NUMNODES is deprecated. So I
think it is reasonable to do this refactor here.

The second one [Patch 2] is trying to address similar issue in
for_each_mem_pfn_range(). The patch here is the first step. I have searched
out all related functions and relpaces MAX_NUMNODES with NUMA_NO_NODE. While
the warning here will still be seen when just this patch applies. While aft=
er
all patches applied, we won't see the warning again.

Hmm... it looks like some dirty work, while I still think it worth the effo=
rts
to use the correct macro.

Willing to get some feedback :-)


On Fri, Jan 27, 2017 at 09:59:21AM +0800, Wei Yang wrote:
>According to commit <b115423357e0> ('mm/memblock: switch to use
>NUMA_NO_NODE instead of MAX_NUMNODES'), MAX_NUMNODES is not preferred as an
>node_id indicator.
>
>This patch use NUMA_NO_NODE as the default node_id for memblock.
>
>Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>---
> arch/x86/mm/numa.c | 6 +++---
> mm/memblock.c      | 8 ++++----
> 2 files changed, 7 insertions(+), 7 deletions(-)
>
>diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
>index 3f35b48d1d9d..4366242356c5 100644
>--- a/arch/x86/mm/numa.c
>+++ b/arch/x86/mm/numa.c
>@@ -506,7 +506,7 @@ static void __init numa_clear_kernel_node_hotplug(void)
> 	 *   reserve specific pages for Sandy Bridge graphics. ]
> 	 */
> 	for_each_memblock(reserved, mb_region) {
>-		if (mb_region->nid !=3D MAX_NUMNODES)
>+		if (mb_region->nid !=3D NUMA_NO_NODE)
> 			node_set(mb_region->nid, reserved_nodemask);
> 	}
>=20
>@@ -633,9 +633,9 @@ static int __init numa_init(int (*init_func)(void))
> 	nodes_clear(node_online_map);
> 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
> 	WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.memory,
>-				  MAX_NUMNODES));
>+				  NUMA_NO_NODE));
> 	WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.reserved,
>-				  MAX_NUMNODES));
>+				  NUMA_NO_NODE));
> 	/* In case that parsing SRAT failed. */
> 	WARN_ON(memblock_clear_hotplug(0, ULLONG_MAX));
> 	numa_reset_distance();
>diff --git a/mm/memblock.c b/mm/memblock.c
>index d0f2c9632187..7d27566cee11 100644
>--- a/mm/memblock.c
>+++ b/mm/memblock.c
>@@ -292,7 +292,7 @@ static void __init_memblock memblock_remove_region(str=
uct memblock_type *type, u
> 		type->regions[0].base =3D 0;
> 		type->regions[0].size =3D 0;
> 		type->regions[0].flags =3D 0;
>-		memblock_set_region_node(&type->regions[0], MAX_NUMNODES);
>+		memblock_set_region_node(&type->regions[0], NUMA_NO_NODE);
> 	}
> }
>=20
>@@ -616,7 +616,7 @@ int __init_memblock memblock_add(phys_addr_t base, phy=
s_addr_t size)
> 		     (unsigned long long)base + size - 1,
> 		     0UL, (void *)_RET_IP_);
>=20
>-	return memblock_add_range(&memblock.memory, base, size, MAX_NUMNODES, 0);
>+	return memblock_add_range(&memblock.memory, base, size, NUMA_NO_NODE, 0);
> }
>=20
> /**
>@@ -734,7 +734,7 @@ int __init_memblock memblock_reserve(phys_addr_t base,=
 phys_addr_t size)
> 		     (unsigned long long)base + size - 1,
> 		     0UL, (void *)_RET_IP_);
>=20
>-	return memblock_add_range(&memblock.reserved, base, size, MAX_NUMNODES, =
0);
>+	return memblock_add_range(&memblock.reserved, base, size, NUMA_NO_NODE, =
0);
> }
>=20
> /**
>@@ -1684,7 +1684,7 @@ static void __init_memblock memblock_dump(struct mem=
block_type *type, char *name
> 		size =3D rgn->size;
> 		flags =3D rgn->flags;
> #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>-		if (memblock_get_region_node(rgn) !=3D MAX_NUMNODES)
>+		if (memblock_get_region_node(rgn) !=3D NUMA_NO_NODE)
> 			snprintf(nid_buf, sizeof(nid_buf), " on node %d",
> 				 memblock_get_region_node(rgn));
> #endif
>--=20
>2.11.0

--=20
Wei Yang
Help you, Help me

--FL5UXtIhxfXey3p5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYwM+PAAoJEKcLNpZP5cTdcfUP/jUj/c0zNdSaLhdE6Ph1rueA
E4CHx2UC36PeQsvd4jGSV7bf3dcYVIfUNoi5QL4yn5gXgETD3gn16GQ2gXLBvXtc
fQHCOdeEOEnz5SKh2wboYCeGN7jrg1Q8MHkYLlhH/K/VVDqFGqrzdP2TPNL4cpJR
Z8RHhU7R1V8s1UcqrL+zePS33neU1FV0/C6qDy7jLQwu33KOVotSsMSwKyJrmZp5
xNG+E9FNI3WuA4v4pC5DKX8bAr5xdKXw5PanD6fsIuyg6bLBuU8AxDGWsVpBQg7H
FILtROLu5lJHpvhfDX7ecnLPGjzZwYY5dBBEb5PMQLHPvq5M/qwrBg6FvFhkbkpm
4VUWw2rvuJWhCAi8R1j8VgXLM8I7FxgD8g5DLPexweExKelN8jwn87/2m0EibXEV
4iY0IByt1Rb2uPimkzvWx4LyUWO2RjpJ1X4GTpNfa72gNudZlC7DSxif11W5b4Tf
CW7OyNFRN2lXaPHUoowrqWSBeGcky95tnce63u2I2xkbWqoat1hGiEm0/dNrOBGj
PXyMC3bFowd8/U1GTanjbYX7w+XWopuRLWotS9LL0FWEgPc1zdxCJtCk9VI+wzD7
3EHIIzPRsTFZLV876HVAcT4nee62UkfEWw6RHjxhKlJhyOCbz7BA3p+PWbExVAvu
vuspjMxvyoGha930Ifpx
=Hy0Y
-----END PGP SIGNATURE-----

--FL5UXtIhxfXey3p5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
