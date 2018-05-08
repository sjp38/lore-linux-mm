Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 27E516B000A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 22:30:41 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m15-v6so8450590qti.16
        for <linux-mm@kvack.org>; Mon, 07 May 2018 19:30:41 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.206])
        by mx.google.com with ESMTPS id g16-v6si9804141qtp.109.2018.05.07.19.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 19:30:40 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  [RFC PATCH v1 1/6] mm/memblock: Expand definition of
 flags to support NVDIMM
Date: Tue, 8 May 2018 02:30:23 +0000
Message-ID: <HK2PR03MB1684FC46E0F2F70F9EF1F6D1929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
 <1525746628-114136-2-git-send-email-yehs1@lenovo.com>
In-Reply-To: <1525746628-114136-2-git-send-email-yehs1@lenovo.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

This patch makes mm to have capability to get special regions
from memblock.

During boot process, memblock marks NVDIMM regions with flag
MEMBLOCK_NVDIMM, also expands the interface of functions and
macros with flags.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Signed-off-by: Ocean He <hehy1@lenovo.com>
---
 include/linux/memblock.h | 19 +++++++++++++++++++
 mm/memblock.c            | 46 +++++++++++++++++++++++++++++++++++++++++---=
--
 2 files changed, 60 insertions(+), 5 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f92ea77..cade5c8d 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -26,6 +26,8 @@ enum {
 	MEMBLOCK_HOTPLUG	=3D 0x1,	/* hotpluggable region */
 	MEMBLOCK_MIRROR		=3D 0x2,	/* mirrored region */
 	MEMBLOCK_NOMAP		=3D 0x4,	/* don't add to kernel direct mapping */
+	MEMBLOCK_NVDIMM		=3D 0x8,	/* NVDIMM region */
+	MEMBLOCK_MAX_TYPE	=3D 0x10	/* all regions */
 };
=20
 struct memblock_region {
@@ -89,6 +91,8 @@ bool memblock_overlaps_region(struct memblock_type *type,
 int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
 int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
 int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
+int memblock_mark_nvdimm(phys_addr_t base, phys_addr_t size);
+int memblock_clear_nvdimm(phys_addr_t base, phys_addr_t size);
 ulong choose_memblock_flags(void);
=20
 /* Low level functions */
@@ -167,6 +171,11 @@ void __next_reserved_mem_region(u64 *idx, phys_addr_t =
*out_start,
 	     i !=3D (u64)ULLONG_MAX;					\
 	     __next_reserved_mem_region(&i, p_start, p_end))
=20
+static inline bool memblock_is_nvdimm(struct memblock_region *m)
+{
+	return m->flags & MEMBLOCK_NVDIMM;
+}
+
 static inline bool memblock_is_hotpluggable(struct memblock_region *m)
 {
 	return m->flags & MEMBLOCK_HOTPLUG;
@@ -187,6 +196,11 @@ int memblock_search_pfn_nid(unsigned long pfn, unsigne=
d long *start_pfn,
 			    unsigned long  *end_pfn);
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
+void __next_mem_pfn_range_with_flags(int *idx, int nid,
+				     unsigned long *out_start_pfn,
+				     unsigned long *out_end_pfn,
+				     int *out_nid,
+				     unsigned long flags);
=20
 /**
  * for_each_mem_pfn_range - early memory pfn range iterator
@@ -201,6 +215,11 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned =
long *out_start_pfn,
 #define for_each_mem_pfn_range(i, nid, p_start, p_end, p_nid)		\
 	for (i =3D -1, __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid); \
 	     i >=3D 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
+
+#define for_each_mem_pfn_range_with_flags(i, nid, p_start, p_end, p_nid, f=
lags) \
+	for (i =3D -1, __next_mem_pfn_range_with_flags(&i, nid, p_start, p_end, p=
_nid, flags);\
+	     i >=3D 0; __next_mem_pfn_range_with_flags(&i, nid, p_start, p_end, p=
_nid, flags))
+
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
=20
 /**
diff --git a/mm/memblock.c b/mm/memblock.c
index 48376bd..7699637 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -771,6 +771,16 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t=
 base, phys_addr_t size)
 	return memblock_setclr_flag(base, size, 0, MEMBLOCK_HOTPLUG);
 }
=20
+int __init_memblock memblock_mark_nvdimm(phys_addr_t base, phys_addr_t siz=
e)
+{
+	return memblock_setclr_flag(base, size, 1, MEMBLOCK_NVDIMM);
+}
+
+int __init_memblock memblock_clear_nvdimm(phys_addr_t base, phys_addr_t si=
ze)
+{
+	return memblock_setclr_flag(base, size, 0, MEMBLOCK_NVDIMM);
+}
+
 /**
  * memblock_mark_mirror - Mark mirrored memory with flag MEMBLOCK_MIRROR.
  * @base: the base phys addr of the region
@@ -891,6 +901,10 @@ void __init_memblock __next_mem_range(u64 *idx, int ni=
d, ulong flags,
 		if (nid !=3D NUMA_NO_NODE && nid !=3D m_nid)
 			continue;
=20
+		/* skip nvdimm memory regions if needed */
+		if (!(flags & MEMBLOCK_NVDIMM) && memblock_is_nvdimm(m))
+			continue;
+
 		/* skip hotpluggable memory regions if needed */
 		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
 			continue;
@@ -1007,6 +1021,10 @@ void __init_memblock __next_mem_range_rev(u64 *idx, =
int nid, ulong flags,
 		if (nid !=3D NUMA_NO_NODE && nid !=3D m_nid)
 			continue;
=20
+		/* skip nvdimm memory regions if needed */
+		if (!(flags & MEMBLOCK_NVDIMM) && memblock_is_nvdimm(m))
+			continue;
+
 		/* skip hotpluggable memory regions if needed */
 		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
 			continue;
@@ -1070,12 +1088,9 @@ void __init_memblock __next_mem_range_rev(u64 *idx, =
int nid, ulong flags,
 }
=20
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-/*
- * Common iterator interface used to define for_each_mem_range().
- */
-void __init_memblock __next_mem_pfn_range(int *idx, int nid,
+void __init_memblock __next_mem_pfn_range_with_flags(int *idx, int nid,
 				unsigned long *out_start_pfn,
-				unsigned long *out_end_pfn, int *out_nid)
+				unsigned long *out_end_pfn, int *out_nid, unsigned long flags)
 {
 	struct memblock_type *type =3D &memblock.memory;
 	struct memblock_region *r;
@@ -1085,6 +1100,16 @@ void __init_memblock __next_mem_pfn_range(int *idx, =
int nid,
=20
 		if (PFN_UP(r->base) >=3D PFN_DOWN(r->base + r->size))
 			continue;
+
+		/*
+		 *  Use "flags & r->flags " to find region with multi-flags
+		 *  Use "flags =3D=3D r->flags" to include region flags of MEMBLOCK_NONE
+		 *  Set flags =3D MEMBLOCK_MAX_TYPE to ignore to check flags
+		 */
+
+		if ((flags !=3D MEMBLOCK_MAX_TYPE) && (flags !=3D r->flags) && !(flags &=
 r->flags))
+			continue;
+
 		if (nid =3D=3D MAX_NUMNODES || nid =3D=3D r->nid)
 			break;
 	}
@@ -1101,6 +1126,17 @@ void __init_memblock __next_mem_pfn_range(int *idx, =
int nid,
 		*out_nid =3D r->nid;
 }
=20
+/*
+ * Common iterator interface used to define for_each_mem_range().
+ */
+void __init_memblock __next_mem_pfn_range(int *idx, int nid,
+				unsigned long *out_start_pfn,
+				unsigned long *out_end_pfn, int *out_nid)
+{
+	__next_mem_pfn_range_with_flags(idx, nid, out_start_pfn, out_end_pfn,
+						out_nid, MEMBLOCK_MAX_TYPE);
+}
+
 /**
  * memblock_set_node - set node ID on memblock regions
  * @base: base of area to set node ID for
--=20
1.8.3.1
