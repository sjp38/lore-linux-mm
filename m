Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29D5C6B036A
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 22:32:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y62so3473338pfa.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 19:32:47 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id e4si129142pgc.317.2017.06.21.19.32.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 19:32:46 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id e187so578684pgc.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 19:32:46 -0700 (PDT)
Date: Thu, 22 Jun 2017 10:32:43 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: do not assume ZONE_NORMAL is
 default kernel zone
Message-ID: <20170622023243.GA1242@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170601083746.4924-1-mhocko@kernel.org>
 <20170601083746.4924-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="AqsLC8rIMeq19msA"
Content-Disposition: inline
In-Reply-To: <20170601083746.4924-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 01, 2017 at 10:37:46AM +0200, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
>Heiko Carstens has noticed that he can generate overlapping zones for
>ZONE_DMA and ZONE_NORMAL:
>DMA      [mem 0x0000000000000000-0x000000007fffffff]
>Normal   [mem 0x0000000080000000-0x000000017fffffff]
>
>$ cat /sys/devices/system/memory/block_size_bytes
>10000000
>$ cat /sys/devices/system/memory/memory5/valid_zones
>DMA
>$ echo 0 > /sys/devices/system/memory/memory5/online
>$ cat /sys/devices/system/memory/memory5/valid_zones
>Normal
>$ echo 1 > /sys/devices/system/memory/memory5/online
>Normal
>
>$ cat /proc/zoneinfo
>Node 0, zone      DMA
>spanned  524288        <-----
>present  458752
>managed  455078
>start_pfn:           0 <-----
>
>Node 0, zone   Normal
>spanned  720896
>present  589824
>managed  571648
>start_pfn:           327680 <-----
>
>The reason is that we assume that the default zone for kernel onlining
>is ZONE_NORMAL. This was a simplification introduced by the memory
>hotplug rework and it is easily fixable by checking the range overlap in
>the zone order and considering the first matching zone as the default
>one. If there is no such zone then assume ZONE_NORMAL as we have been
>doing so far.
>
>Fixes: "mm, memory_hotplug: do not associate hotadded memory to zones unti=
l online"
>Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
>Tested-by: Heiko Carstens <heiko.carstens@de.ibm.com>
>Signed-off-by: Michal Hocko <mhocko@suse.com>
>---
> drivers/base/memory.c          |  2 +-
> include/linux/memory_hotplug.h |  2 ++
> mm/memory_hotplug.c            | 27 ++++++++++++++++++++++++---
> 3 files changed, 27 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index b86fda30ce62..c7c4e0325cdb 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -419,7 +419,7 @@ static ssize_t show_valid_zones(struct device *dev,
>=20
> 	nid =3D pfn_to_nid(start_pfn);
> 	if (allow_online_pfn_range(nid, start_pfn, nr_pages, MMOP_ONLINE_KERNEL)=
) {
>-		strcat(buf, NODE_DATA(nid)->node_zones[ZONE_NORMAL].name);
>+		strcat(buf, default_zone_for_pfn(nid, start_pfn, nr_pages)->name);
> 		append =3D true;
> 	}
>=20
>diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug=
=2Eh
>index 9e0249d0f5e4..ed167541e4fc 100644
>--- a/include/linux/memory_hotplug.h
>+++ b/include/linux/memory_hotplug.h
>@@ -309,4 +309,6 @@ extern struct page *sparse_decode_mem_map(unsigned lon=
g coded_mem_map,
> 					  unsigned long pnum);
> extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned l=
ong nr_pages,
> 		int online_type);
>+extern struct zone *default_zone_for_pfn(int nid, unsigned long pfn,
>+		unsigned long nr_pages);
> #endif /* __LINUX_MEMORY_HOTPLUG_H */
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index b3895fd609f4..a0348de3e18c 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -858,7 +858,7 @@ bool allow_online_pfn_range(int nid, unsigned long pfn=
, unsigned long nr_pages,
> {
> 	struct pglist_data *pgdat =3D NODE_DATA(nid);
> 	struct zone *movable_zone =3D &pgdat->node_zones[ZONE_MOVABLE];
>-	struct zone *normal_zone =3D  &pgdat->node_zones[ZONE_NORMAL];
>+	struct zone *default_zone =3D default_zone_for_pfn(nid, pfn, nr_pages);
>=20
> 	/*
> 	 * TODO there shouldn't be any inherent reason to have ZONE_NORMAL
>@@ -872,7 +872,7 @@ bool allow_online_pfn_range(int nid, unsigned long pfn=
, unsigned long nr_pages,
> 			return true;
> 		return movable_zone->zone_start_pfn >=3D pfn + nr_pages;
> 	} else if (online_type =3D=3D MMOP_ONLINE_MOVABLE) {
>-		return zone_end_pfn(normal_zone) <=3D pfn;
>+		return zone_end_pfn(default_zone) <=3D pfn;
> 	}
>=20
> 	/* MMOP_ONLINE_KEEP will always succeed and inherits the current zone */
>@@ -938,6 +938,27 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
> }
>=20
> /*
>+ * Returns a default kernel memory zone for the given pfn range.
>+ * If no kernel zone covers this pfn range it will automatically go
>+ * to the ZONE_NORMAL.
>+ */
>+struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
>+		unsigned long nr_pages)
>+{
>+	struct pglist_data *pgdat =3D NODE_DATA(nid);
>+	int zid;
>+
>+	for (zid =3D 0; zid <=3D ZONE_NORMAL; zid++) {
>+		struct zone *zone =3D &pgdat->node_zones[zid];
>+
>+		if (zone_intersects(zone, start_pfn, nr_pages))
>+			return zone;
>+	}
>+
>+	return &pgdat->node_zones[ZONE_NORMAL];
>+}

Hmm... a corner case jumped into my mind which may invalidate this
calculation.

The case is:


       Zone:         | DMA   | DMA32      | NORMAL       |
                     v       v            v              v
      =20
       Phy mem:      [           ]     [                  ]
      =20
                     ^           ^     ^                  ^
       Node:         |   Node0   |     |      Node1       |
                             A   B     C  D


The key point is
1. There is a hole between Node0 and Node1
2. The hole sits in a non-normal zone

Let's mark the boundary as A, B, C, D. Then we would have
node0->zone[dma21] =3D [A, B]
node1->zone[dma32] =3D [C, D]

If we want to hotplug a range in [B, C] on node0, it looks not that bad. Wh=
ile
if we want to hotplug a range in [B, C] on node1, it will introduce the
overlapped zone. Because the range [B, C] intersects none of the existing
zones on node1.

Do you think this is possible?

>+
>+/*
>  * Associates the given pfn range with the given node and the zone approp=
riate
>  * for the given online type.
>  */
>@@ -945,7 +966,7 @@ static struct zone * __meminit move_pfn_range(int onli=
ne_type, int nid,
> 		unsigned long start_pfn, unsigned long nr_pages)
> {
> 	struct pglist_data *pgdat =3D NODE_DATA(nid);
>-	struct zone *zone =3D &pgdat->node_zones[ZONE_NORMAL];
>+	struct zone *zone =3D default_zone_for_pfn(nid, start_pfn, nr_pages);
>=20
> 	if (online_type =3D=3D MMOP_ONLINE_KEEP) {
> 		struct zone *movable_zone =3D &pgdat->node_zones[ZONE_MOVABLE];
>--=20
>2.11.0

--=20
Wei Yang
Help you, Help me

--AqsLC8rIMeq19msA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZSyxLAAoJEKcLNpZP5cTdVqoQAIHi4v7vzFRe/byJ2M+lvhUD
Hz6c+xRLcv/FQzT6hTnIVohXQI9FE2na4UJXwgyvcyIwz8Tr3M28bjdYiF/mo3ba
cT1uh9gKIYuKyciCkKu5uQDhXpFKAXvqRSkJi6ddA8rEuFKGvC33i/+y5Wjw7b4w
U5j+4gD4EASAa9apFj0FvsarXxJwq8Ybybg5igZjg0A52vfT46pdhkF17gv8H08H
hEcZ3PP2xQJr5SXQO8phPAEJwAvRvNZ9dv7wN8/02DFO4g7U5A+RdIrou60tRe+f
aDPUiCivmESVw9UhdwE574WYksW9FyiDhjwfNRRY6AZnzKVWMU46L+gh0TUP9YcN
qgtS1QX8toDJpAG/kfR1KRKpUIqHyx8zJTB7D/AOobResxLLEuCN/Z2nJ3vNLhMW
OvGktMEMo6tBzablKqp3x0KziKJiQJS3KJXq1mOyoImNFY1zk7ZqM6SvsrNMGJf1
CYBeXgKSusAzxJ3Tz3hNBz8NbHhu7QjRb4VKqPMI3BLM0epcq7tbD0SHHjhH134T
Mg2QGDF84jtwQMjQugjhhnU1K/wDV1IE5cfqlb0yby2Z8kniHQCp8hXe6ZHm/Qpb
RjmE0Gd+d5g4TF1J6H52Yr9njNb/TBt078cqFaLmdrWWFa2Pz6AO4zz/lF1B6ne7
xjP8Lt4la6jssxaVnaCq
=hexA
-----END PGP SIGNATURE-----

--AqsLC8rIMeq19msA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
