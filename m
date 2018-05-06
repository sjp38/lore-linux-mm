Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 761636B0010
	for <linux-mm@kvack.org>; Sun,  6 May 2018 12:17:26 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f20-v6so24785488ioc.8
        for <linux-mm@kvack.org>; Sun, 06 May 2018 09:17:26 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.16])
        by mx.google.com with ESMTPS id c188-v6si5733445ite.22.2018.05.06.09.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 May 2018 09:17:24 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [PATCH 2/3] include/linux/gfp.h: use unsigned int
 in gfp_zone
Date: Sun, 6 May 2018 16:17:06 +0000
Message-ID: <HK2PR03MB168447008C658172FFDA402992840@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525416729-108201-1-git-send-email-yehs1@lenovo.com>
 <1525416729-108201-3-git-send-email-yehs1@lenovo.com>
 <20180504133533.GR4535@dhcp22.suse.cz>
 <20180504154004.GB29829@bombadil.infradead.org>
 <HK2PR03MB168459A1C4FB2B7D3E1F6A4A92840@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180506134814.GB7362@bombadil.infradead.org>
In-Reply-To: <20180506134814.GB7362@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Matthew Wilcox
> Sent: Sunday, May 06, 2018 9:48 PM
> To: Huaisheng HS1 Ye <yehs1@lenovo.com>
> Cc: Michal Hocko <mhocko@kernel.org>; akpm@linux-foundation.org;
> linux-mm@kvack.org; vbabka@suse.cz; mgorman@techsingularity.net;
> pasha.tatashin@oracle.com; alexander.levin@verizon.com;
> hannes@cmpxchg.org; penguin-kernel@I-love.SAKURA.ne.jp; colyli@suse.de;
> NingTing Cheng <chengnt@lenovo.com>; linux-kernel@vger.kernel.org
> Subject: Re: [External] Re: [PATCH 2/3] include/linux/gfp.h: use unsigned=
 int in
> gfp_zone
>=20
> On Sun, May 06, 2018 at 09:32:15AM +0000, Huaisheng HS1 Ye wrote:
> > This idea is great, we can replace GFP_ZONE_TABLE and GFP_ZONE_BAD with
> it.
> > I have realized it preliminarily based on your code and tested it on a =
2 sockets
> platform. Fortunately, we got a positive test result.
>=20
> Great!
>=20
> > I made some adjustments for __GFP_HIGHMEM, this flag is special than
> others, because the return result of gfp_zone has two possibilities, whic=
h
> depend on ___GFP_MOVABLE has been enabled or disabled.
> > When ___GFP_MOVABLE has been enabled, ZONE_MOVABLE shall be
> returned. When disabled, OPT_ZONE_HIGHMEM shall be used.
> >
> > #define __GFP_DMA	((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
> > #define __GFP_HIGHMEM	((__force gfp_t)ZONE_MOVABLE ^
> ZONE_NORMAL)
>=20
> I'm not sure this is right ... Let me think about this a little.

Upload my current patch and testing platform info for reference. This patch=
 has been tested=20
on a two sockets platform.
Here is dmesg log about zones,

 397 [    0.000000] Zone ranges:
 398 [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
 399 [    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
 400 [    0.000000]   Normal   [mem 0x0000000100000000-0x000000277fffffff]
 401 [    0.000000]   Device   empty
 402 [    0.000000] Movable zone start for each node
 403 [    0.000000] Early memory node ranges
 404 [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009ffff]
 405 [    0.000000]   node   0: [mem 0x0000000000100000-0x00000000a69c2fff]
 406 [    0.000000]   node   0: [mem 0x00000000a7654000-0x00000000a85eefff]
 407 [    0.000000]   node   0: [mem 0x00000000ab399000-0x00000000af3f6fff]
 408 [    0.000000]   node   0: [mem 0x00000000af429000-0x00000000af7fffff]
 409 [    0.000000]   node   0: [mem 0x0000000100000000-0x000000043fffffff]
 410 [    0.000000]   node   1: [mem 0x0000002380000000-0x000000277fffffff]

 416 [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x00000004=
3fffffff]
 417 [    0.000000] On node 0 totalpages: 4111666
 418 [    0.000000]   DMA zone: 64 pages used for memmap
 419 [    0.000000]   DMA zone: 23 pages reserved
 420 [    0.000000]   DMA zone: 3999 pages, LIFO batch:0
 421 [    0.000000] mminit::memmap_init Initialising map node 0 zone 0 pfns=
 1 -> 4096
 422 [    0.000000]   DMA32 zone: 10935 pages used for memmap
 423 [    0.000000]   DMA32 zone: 699795 pages, LIFO batch:31
 424 [    0.000000] mminit::memmap_init Initialising map node 0 zone 1 pfns=
 4096 -> 1048576
 425 [    0.000000]   Normal zone: 53248 pages used for memmap
 426 [    0.000000]   Normal zone: 3407872 pages, LIFO batch:31
 427 [    0.000000] mminit::memmap_init Initialising map node 0 zone 2 pfns=
 1048576 -> 4456448
 428 [    0.000000] Initmem setup node 1 [mem 0x0000002380000000-0x00000027=
7fffffff]
 429 [    0.000000] On node 1 totalpages: 4194304
 430 [    0.000000]   Normal zone: 65536 pages used for memmap
 431 [    0.000000]   Normal zone: 4194304 pages, LIFO batch:31
 432 [    0.000000] mminit::memmap_init Initialising map node 1 zone 2 pfns=
 37224448 -> 41418752

 986 [    0.000000] mminit::zonelist general 0:DMA =3D 0:DMA
 987 [    0.000000] mminit::zonelist general 0:DMA32 =3D 0:DMA32 0:DMA
 988 [    0.000000] mminit::zonelist general 0:Normal =3D 0:Normal 0:DMA32 =
0:DMA 1:Normal
 989 [    0.000000] mminit::zonelist thisnode 0:DMA =3D 0:DMA
 990 [    0.000000] mminit::zonelist thisnode 0:DMA32 =3D 0:DMA32 0:DMA
 991 [    0.000000] mminit::zonelist thisnode 0:Normal =3D 0:Normal 0:DMA32=
 0:DMA
 992 [    0.000000] mminit::zonelist general 1:Normal =3D 1:Normal 0:Normal=
 0:DMA32 0:DMA
 993 [    0.000000] mminit::zonelist thisnode 1:Normal =3D 1:Normal
 994 [    0.000000] Built 2 zonelists, mobility grouping on.  Total pages: =
8176164

Here is some information of ZONE_NORMAL which comes from /proc/zoneinfo
1131 Node 0, zone   Normal
1132   pages free     3171428
1133         min      9249
1134         low      12584
1135         high     15919
1136         spanned  3407872
1137         present  3407872
1138         managed  3335769
1139         protection: (0, 0, 0, 0, 0)
1140       nr_free_pages 3171428
1141       nr_zone_inactive_anon 12
1142       nr_zone_active_anon 13585
1143       nr_zone_inactive_file 37028
1144       nr_zone_active_file 12104
1145       nr_zone_unevictable 0
1146       nr_zone_write_pending 7
1147       nr_mlock     0
1148       nr_page_table_pages 1026
1149       nr_kernel_stack 10920
1150       nr_bounce    0
1151       nr_zspages   0
1152       nr_free_cma  0
1153       numa_hit     792300
1154       numa_miss    0
1155       numa_foreign 0
1156       numa_interleave 26268
1157       numa_local   768300
1158       numa_other   24000

1718 Node 1, zone   Normal
1747   pages free     3856001
1748         min      11405
1749         low      15518
1750         high     19631
1751         spanned  4194304
1752         present  4194304
1753         managed  4114482
1754         protection: (0, 0, 0, 0, 0)
1755       nr_free_pages 3856001
1756       nr_zone_inactive_anon 424
1757       nr_zone_active_anon 10679
1758       nr_zone_inactive_file 35274
1759       nr_zone_active_file 22189
1760       nr_zone_unevictable 0
1761       nr_zone_write_pending 0
1762       nr_mlock     0
1763       nr_page_table_pages 800
1764       nr_kernel_stack 9848
1765       nr_bounce    0
1766       nr_zspages   0
1767       nr_free_cma  0
1768       numa_hit     757099
1769       numa_miss    0
1770       numa_foreign 0
1771       numa_interleave 26314
1772       numa_local   712341
1773       numa_other   44758

Subject: [RFC PATCH v0.1] include/linux/gfp.h: Replace GFP_ZONE_TABLE with =
bit
 encoding

It works, but some drivers or subsystem shall be modified to fit
these new type __GFP flags.
They use these flags directly to realize bit manipulations like this
below.

eg.
swiotlb-xen.c (drivers\xen):    flags &=3D ~(__GFP_DMA | __GFP_HIGHMEM);
extent_io.c (fs\btrfs):         mask &=3D ~(__GFP_DMA32|__GFP_HIGHMEM);

Because of these flags have been encoded within this patch, the
above operations can cause problem.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
---
 include/linux/gfp.h | 49 ++++++++++---------------------------------------
 1 file changed, 10 insertions(+), 39 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1a4582b..1647385 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -16,9 +16,7 @@
  */

 /* Plain integer GFP bitmasks. Do not use this directly. */
-#define ___GFP_DMA             0x01u
-#define ___GFP_HIGHMEM         0x02u
-#define ___GFP_DMA32           0x04u
+#define ___GFP_ZONE_MASK       0x07u
 #define ___GFP_MOVABLE         0x08u
 #define ___GFP_RECLAIMABLE     0x10u
 #define ___GFP_HIGH            0x20u
@@ -53,11 +51,11 @@
* without the underscores and use them consistently. The definitions here m=
ay
  * be used in bit comparisons.
  */
-#define __GFP_DMA      ((__force gfp_t)___GFP_DMA)
-#define __GFP_HIGHMEM  ((__force gfp_t)___GFP_HIGHMEM)
-#define __GFP_DMA32    ((__force gfp_t)___GFP_DMA32)
+#define __GFP_DMA      ((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
+#define __GFP_HIGHMEM  ((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL)
+#define __GFP_DMA32    ((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)
 #define __GFP_MOVABLE  ((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE al=
lowed */
-#define GFP_ZONEMASK   (__GFP_DMA|__GFP_HIGHMEM|__GFP_DMA32|__GFP_MOVABLE)
+#define GFP_ZONEMASK   ((__force gfp_t)___GFP_ZONE_MASK | ___GFP_MOVABLE)

 /*
  * Page mobility and placement hints
@@ -370,42 +368,15 @@ static inline bool gfpflags_allow_blocking(const gfp_=
t gfp_flags)
 #error GFP_ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
 #endif

-#define GFP_ZONE_TABLE ( \
-       (ZONE_NORMAL << 0 * GFP_ZONES_SHIFT)                               =
    \
-       | (OPT_ZONE_DMA << ___GFP_DMA * GFP_ZONES_SHIFT)                   =
    \
-       | (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * GFP_ZONES_SHIFT)           =
    \
-       | (OPT_ZONE_DMA32 << ___GFP_DMA32 * GFP_ZONES_SHIFT)               =
    \
-       | (ZONE_NORMAL << ___GFP_MOVABLE * GFP_ZONES_SHIFT)                =
    \
-       | (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * GFP_ZONES_SHIFT)=
    \
-       | (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * GFP_ZONES_SH=
IFT)\
-       | (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * GFP_ZONES_SH=
IFT)\
-)
-
-/*
- * GFP_ZONE_BAD is a bitmap for all combinations of __GFP_DMA, __GFP_DMA32
- * __GFP_HIGHMEM and __GFP_MOVABLE that are not permitted. One flag per
- * entry starting with bit 0. Bit is set if the combination is not
- * allowed.
- */
-#define GFP_ZONE_BAD ( \
-       1 << (___GFP_DMA | ___GFP_HIGHMEM)                                 =
   \
-       | 1 << (___GFP_DMA | ___GFP_DMA32)                                 =
   \
-       | 1 << (___GFP_DMA32 | ___GFP_HIGHMEM)                             =
   \
-       | 1 << (___GFP_DMA | ___GFP_DMA32 | ___GFP_HIGHMEM)                =
   \
-       | 1 << (___GFP_MOVABLE | ___GFP_HIGHMEM | ___GFP_DMA)              =
   \
-       | 1 << (___GFP_MOVABLE | ___GFP_DMA32 | ___GFP_DMA)                =
   \
-       | 1 << (___GFP_MOVABLE | ___GFP_DMA32 | ___GFP_HIGHMEM)            =
   \
-       | 1 << (___GFP_MOVABLE | ___GFP_DMA32 | ___GFP_DMA | ___GFP_HIGHMEM=
)  \
-)
-
 static inline enum zone_type gfp_zone(gfp_t flags)
{
        enum zone_type z;
-       int bit =3D (__force int) (flags & GFP_ZONEMASK);
+       z =3D ((__force unsigned int)flags & ___GFP_ZONE_MASK) ^ ZONE_NORMA=
L;

-       z =3D (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
-                                        ((1 << GFP_ZONES_SHIFT) - 1);
-       VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
+       if (z > OPT_ZONE_HIGHMEM) {
+               z =3D OPT_ZONE_HIGHMEM +
+                       !!((__force unsigned int)flags & ___GFP_MOVABLE);
+       }
        return z;
 }

--=20
1.8.3.1
