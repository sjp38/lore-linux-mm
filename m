Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 412136B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 23:29:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h21so1869917pfk.13
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 20:29:31 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id 9si908650pld.517.2017.06.14.20.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 20:29:30 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id s66so362192pfs.2
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 20:29:30 -0700 (PDT)
Date: Thu, 15 Jun 2017 11:29:27 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170615032927.GA17971@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170608122318.31598-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Content-Disposition: inline
In-Reply-To: <20170608122318.31598-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
>movable_node kernel parameter allows to make hotplugable NUMA
>nodes to put all the hotplugable memory into movable zone which
>allows more or less reliable memory hotremove.  At least this
>is the case for the NUMA nodes present during the boot (see
>find_zone_movable_pfns_for_nodes).
>
>This is not the case for the memory hotplug, though.
>
>	echo online > /sys/devices/system/memory/memoryXYZ/status
>
>will default to a kernel zone (usually ZONE_NORMAL) unless the
>particular memblock is already in the movable zone range which is not
>the case normally when onlining the memory from the udev rule context
>for a freshly hotadded NUMA node. The only option currently is to have a
>special udev rule to echo online_movable to all memblocks belonging to
>such a node which is rather clumsy. Not the mention this is inconsistent
>as well because what ended up in the movable zone during the boot will
>end up in a kernel zone after hotremove & hotadd without special care.
>
>It would be nice to reuse memblock_is_hotpluggable but the runtime
>hotplug doesn't have that information available because the boot and
>hotplug paths are not shared and it would be really non trivial to
>make them use the same code path because the runtime hotplug doesn't
>play with the memblock allocator at all.
>
>Teach move_pfn_range that MMOP_ONLINE_KEEP can use the movable zone if
>movable_node is enabled and the range doesn't overlap with the existing
>normal zone. This should provide a reasonable default onlining strategy.
>
>Strictly speaking the semantic is not identical with the boot time
>initialization because find_zone_movable_pfns_for_nodes covers only the
>hotplugable range as described by the BIOS/FW. From my experience this
>is usually a full node though (except for Node0 which is special and
>never goes away completely). If this turns out to be a problem in the
>real life we can tweak the code to store hotplug flag into memblocks
>but let's keep this simple now.
>
>Signed-off-by: Michal Hocko <mhocko@suse.com>
>---
>
>Hi Andrew,
>I've posted this as an RFC previously [1] and there haven't been any
>objections to the approach so I've dropped the RFC and sending it for
>inclusion. The only change since the last time is the update of the
>documentation to clarify the semantic as suggested by Reza Arbab.
>
>[1] http://lkml.kernel.org/r/20170601122004.32732-1-mhocko@kernel.org
>
> Documentation/memory-hotplug.txt | 12 +++++++++---
> mm/memory_hotplug.c              | 19 ++++++++++++++++---
> 2 files changed, 25 insertions(+), 6 deletions(-)
>
>diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotpl=
ug.txt
>index 670f3ded0802..5c628e19d6cd 100644
>--- a/Documentation/memory-hotplug.txt
>+++ b/Documentation/memory-hotplug.txt
>@@ -282,20 +282,26 @@ offlined it is possible to change the individual blo=
ck's state by writing to the
> % echo online > /sys/devices/system/memory/memoryXXX/state
>=20
> This onlining will not change the ZONE type of the target memory block,
>-If the memory block is in ZONE_NORMAL, you can change it to ZONE_MOVABLE:
>+If the memory block doesn't belong to any zone an appropriate kernel zone
>+(usually ZONE_NORMAL) will be used unless movable_node kernel command line
>+option is specified when ZONE_MOVABLE will be used.
>+
>+You can explicitly request to associate it with ZONE_MOVABLE by
>=20
> % echo online_movable > /sys/devices/system/memory/memoryXXX/state
> (NOTE: current limit: this memory block must be adjacent to ZONE_MOVABLE)
>=20
>-And if the memory block is in ZONE_MOVABLE, you can change it to ZONE_NOR=
MAL:
>+Or you can explicitly request a kernel zone (usually ZONE_NORMAL) by:
>=20
> % echo online_kernel > /sys/devices/system/memory/memoryXXX/state
> (NOTE: current limit: this memory block must be adjacent to ZONE_NORMAL)
>=20
>+An explicit zone onlining can fail (e.g. when the range is already within
>+and existing and incompatible zone already).
>+
> After this, memory block XXX's state will be 'online' and the amount of
> available memory will be increased.
>=20
>-Currently, newly added memory is added as ZONE_NORMAL (for powerpc, ZONE_=
DMA).
> This may be changed in future.
>=20
>=20
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index b98fb0b3ae11..74d75583736c 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -943,6 +943,19 @@ struct zone *default_zone_for_pfn(int nid, unsigned l=
ong start_pfn,
> 	return &pgdat->node_zones[ZONE_NORMAL];
> }
>=20
>+static inline bool movable_pfn_range(int nid, struct zone *default_zone,
>+		unsigned long start_pfn, unsigned long nr_pages)
>+{
>+	if (!allow_online_pfn_range(nid, start_pfn, nr_pages,
>+				MMOP_ONLINE_KERNEL))
>+		return true;
>+
>+	if (!movable_node_is_enabled())
>+		return false;
>+
>+	return !zone_intersects(default_zone, start_pfn, nr_pages);
>+}
>+

To be honest, I don't understand this clearly.

move_pfn_range() will choose and move the range to a zone based on the
online_type, where we have two cases:
1. ONLINE_MOVABLE -> ZONE_MOVABLE will be chosen
2. ONLINE_KEEP    -> ZONE_NORMAL is the default while ZONE_MOVABLE will be
chosen in case movable_pfn_range() returns true.

There are three conditions in movable_pfn_range():
1. Not allowed in kernel_zone, returns true
2. Movable_node not enabled, return false=20
3. Range [start_pfn, start_pfn + nr_pages) doesn't intersect with
default_zone, return true

The first one is inherited from original code, so lets look at the other tw=
o.

Number 3 is easy to understand, if the hot-added range is already part of
ZONE_NORMAL, use it.

Number 2 makes me confused. If movable_node is not enabled, ZONE_NORMAL will
be chosen. If movable_node is enabled, it still depends on other two
condition. So how a memory_block is onlined to ZONE_MOVABLE because
movable_node is enabled? What I see is you would forbid a memory_block to be
onlined to ZONE_MOVABLE when movable_node is not enabled. Instead of you wo=
uld
online a memory_block to ZONE_MOVABLE when movable_node is enabled, which is
implied in your change log.

BTW, would you mind giving me these two information?
1. Which branch your code is based on? I have cloned your
git(//git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git), while still s=
ee
some difference.
2. Any example or test case I could try your patch and see the difference? =
It
would be better if it could run in qemu+kvm.

> /*
>  * Associates the given pfn range with the given node and the zone approp=
riate
>  * for the given online type.
>@@ -958,10 +971,10 @@ static struct zone * __meminit move_pfn_range(int on=
line_type, int nid,
> 		/*
> 		 * MMOP_ONLINE_KEEP defaults to MMOP_ONLINE_KERNEL but use
> 		 * movable zone if that is not possible (e.g. we are within
>-		 * or past the existing movable zone)
>+		 * or past the existing movable zone). movable_node overrides
>+		 * this default and defaults to movable zone
> 		 */
>-		if (!allow_online_pfn_range(nid, start_pfn, nr_pages,
>-					MMOP_ONLINE_KERNEL))
>+		if (movable_pfn_range(nid, zone, start_pfn, nr_pages))
> 			zone =3D movable_zone;
> 	} else if (online_type =3D=3D MMOP_ONLINE_MOVABLE) {
> 		zone =3D &pgdat->node_zones[ZONE_MOVABLE];
>--=20
>2.11.0

--=20
Wei Yang
Help you, Help me

--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQf8XAAoJEKcLNpZP5cTdViwP/RTalTg0bdCKOuTe6wNSBJfE
gmYHDvjQ0zTO3KOHVXTpa6bwGej0NRF1c6lOVI2EwXu5mck/UHWAhrmAAwCYK9FZ
JR3BqzkxNYKo+Y9EGxDir4Rw7YtE9FtuDWhIYog+NFdYjTkJAAj+ewnUpLYytS9n
ruiE63qTrqnUhZXnaskV0Wg4BnMPnRVlnVeaS9stkXY+EmVc+ZkaYdjKvx/yLfjg
WDQBCgIk5GCECLXC+dMBkx3awOYvydHnIMuvuupaurJyijBl3dpStEMfRwTgQOSB
c3B5IVBTR4GPnPgPP1nLy60kTUWfqds0nw7Th990FH9lGxGNCy8Bpqq9vHI4tArj
lGeWhwd5NCJQ4QEeWCj3WVyOH+3mhm2D75p5ddlMJXFsaqM8zDDjiuCfSCFoqHbm
BtFiuISaWUvE6sTxI+PxIskgDQnc/f+XnKGaoeG7cejZ3w949PaMJ6zc2Zy2pKEQ
phvqyAkJ4mVu1ku3kwLQhZrCSE9l7bISzRnyC4miCecubRBfRrKJr3ZYcPxnSRvC
hARdqQGpaCvoQ+gyQ8F1dZHvSaf81Nf2uDfi7TUR9o1N77HypocQ1N4/RJ7cKvHn
xljhLbmVAtxIlYmwJ42pqSwzhShFmTrWxr53IVOgSKQhcP5TysU9nmuNzBlfy/8o
9o64zrVBesqY130GYxOc
=a6hU
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
