Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD226B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 00:21:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r70so27926262pfb.7
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 21:21:04 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id t1si910986plj.443.2017.06.15.21.21.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 21:21:02 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id f127so3734383pgc.2
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 21:21:02 -0700 (PDT)
Date: Fri, 16 Jun 2017 12:20:58 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 11/14] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
Message-ID: <20170616042058.GA3976@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-12-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="n8g4imXOkfNTN/H1"
Content-Disposition: inline
In-Reply-To: <20170515085827.16474-12-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 15, 2017 at 10:58:24AM +0200, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
>The current memory hotplug implementation relies on having all the
>struct pages associate with a zone/node during the physical hotplug phase
>(arch_add_memory->__add_pages->__add_section->__add_zone). In the vast
>majority of cases this means that they are added to ZONE_NORMAL. This
>has been so since 9d99aaa31f59 ("[PATCH] x86_64: Support memory hotadd
>without sparsemem") and it wasn't a big deal back then because movable
>onlining didn't exist yet.
>
>Much later memory hotplug wanted to (ab)use ZONE_MOVABLE for movable
>onlining 511c2aba8f07 ("mm, memory-hotplug: dynamic configure movable
>memory and portion memory") and then things got more complicated. Rather
>than reconsidering the zone association which was no longer needed
>(because the memory hotplug already depended on SPARSEMEM) a convoluted
>semantic of zone shifting has been developed. Only the currently last
>memblock or the one adjacent to the zone_movable can be onlined movable.
>This essentially means that the online type changes as the new memblocks
>are added.
>
>Let's simulate memory hot online manually
>$ echo 0x100000000 > /sys/devices/system/memory/probe
>$ grep . /sys/devices/system/memory/memory32/valid_zones
>Normal Movable
>
>$ echo $((0x100000000+(128<<20))) > /sys/devices/system/memory/probe
>$ grep . /sys/devices/system/memory/memory3?/valid_zones
>/sys/devices/system/memory/memory32/valid_zones:Normal
>/sys/devices/system/memory/memory33/valid_zones:Normal Movable
>
>$ echo $((0x100000000+2*(128<<20))) > /sys/devices/system/memory/probe
>$ grep . /sys/devices/system/memory/memory3?/valid_zones
>/sys/devices/system/memory/memory32/valid_zones:Normal
>/sys/devices/system/memory/memory33/valid_zones:Normal
>/sys/devices/system/memory/memory34/valid_zones:Normal Movable
>
>$ echo online_movable > /sys/devices/system/memory/memory34/state
>$ grep . /sys/devices/system/memory/memory3?/valid_zones
>/sys/devices/system/memory/memory32/valid_zones:Normal
>/sys/devices/system/memory/memory33/valid_zones:Normal Movable
>/sys/devices/system/memory/memory34/valid_zones:Movable Normal
>
>This is an awkward semantic because an udev event is sent as soon as the
>block is onlined and an udev handler might want to online it based on
>some policy (e.g. association with a node) but it will inherently race
>with new blocks showing up.
>
>This patch changes the physical online phase to not associate pages
>with any zone at all. All the pages are just marked reserved and wait
>for the onlining phase to be associated with the zone as per the online
>request. There are only two requirements
>	- existing ZONE_NORMAL and ZONE_MOVABLE cannot overlap
>	- ZONE_NORMAL precedes ZONE_MOVABLE in physical addresses
>the later on is not an inherent requirement and can be changed in the
>future. It preserves the current behavior and made the code slightly
>simpler. This is subject to change in future.
>
>This means that the same physical online steps as above will lead to the
>following state:
>Normal Movable
>
>/sys/devices/system/memory/memory32/valid_zones:Normal Movable
>/sys/devices/system/memory/memory33/valid_zones:Normal Movable
>
>/sys/devices/system/memory/memory32/valid_zones:Normal Movable
>/sys/devices/system/memory/memory33/valid_zones:Normal Movable
>/sys/devices/system/memory/memory34/valid_zones:Normal Movable
>
>/sys/devices/system/memory/memory32/valid_zones:Normal Movable
>/sys/devices/system/memory/memory33/valid_zones:Normal Movable
>/sys/devices/system/memory/memory34/valid_zones:Movable
>
>Implementation:
>The current move_pfn_range is reimplemented to check the above
>requirements (allow_online_pfn_range) and then updates the respective
>zone (move_pfn_range_to_zone), the pgdat and links all the pages in the
>pfn range with the zone/node. __add_pages is updated to not require the
>zone and only initializes sections in the range. This allowed to
>simplify the arch_add_memory code (s390 could get rid of quite some
>of code).
>
>devm_memremap_pages is the only user of arch_add_memory which relies
>on the zone association because it only hooks into the memory hotplug
>only half way. It uses it to associate the new memory with ZONE_DEVICE
>but doesn't allow it to be {on,off}lined via sysfs. This means that this
>particular code path has to call move_pfn_range_to_zone explicitly.
>
>The original zone shifting code is kept in place and will be removed in
>the follow up patch for an easier review.
>
>Please note that this patch also changes the original behavior when
>offlining a memory block adjacent to another zone (Normal vs. Movable)
>used to allow to change its movable type. This will be handled later.
>
>Changes since v1
>- we have to associate the page with the node early (in __add_section),
>  because pfn_to_node depends on struct page containing this
>  information - based on testing by Reza Arbab
>- resize_{zone,pgdat}_range has to check whether they are popoulated -
>  Reza Arbab
>- fix devm_memremap_pages to use pfn rather than physical address -
>  J=E9r=F4me Glisse
>- move_pfn_range has to check for intersection with zone_movable rather
>  than to rely on allow_online_pfn_range(MMOP_ONLINE_MOVABLE) for
>  MMOP_ONLINE_KEEP
>
>Changes since v2
>- fix show_valid_zones nr_pages calculation
>- allow_online_pfn_range has to check managed pages rather than present
>- zone_intersects fix bogus check
>- fix zone_intersects + few nits as per Vlastimil
>
>Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>Cc: linux-arch@vger.kernel.org
>Tested-by: Dan Williams <dan.j.williams@intel.com>
>Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # For s390 bits
>Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>
>Signed-off-by: Michal Hocko <mhocko@suse.com>
>---
> arch/ia64/mm/init.c            |   9 +-
> arch/powerpc/mm/mem.c          |  10 +-
> arch/s390/mm/init.c            |  30 +-----
> arch/sh/mm/init.c              |   8 +-
> arch/x86/mm/init_32.c          |   5 +-
> arch/x86/mm/init_64.c          |   9 +-
> drivers/base/memory.c          |  52 ++++++-----
> include/linux/memory_hotplug.h |  13 +--
> include/linux/mmzone.h         |  20 ++++
> kernel/memremap.c              |   4 +
> mm/memory_hotplug.c            | 204 +++++++++++++++++++++++++-----------=
-----
> mm/sparse.c                    |   3 +-
> 12 files changed, 193 insertions(+), 174 deletions(-)
>
>diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
>index 39e2aeb4669d..80db57d063d0 100644
>--- a/arch/ia64/mm/init.c
>+++ b/arch/ia64/mm/init.c
>@@ -648,18 +648,11 @@ mem_init (void)
> #ifdef CONFIG_MEMORY_HOTPLUG
> int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> {
>-	pg_data_t *pgdat;
>-	struct zone *zone;
> 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
> 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
> 	int ret;
>=20
>-	pgdat =3D NODE_DATA(nid);
>-
>-	zone =3D pgdat->node_zones +
>-		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
>-	ret =3D __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
>-
>+	ret =3D __add_pages(nid, start_pfn, nr_pages, !for_device);
> 	if (ret)
> 		printk("%s: Problem encountered in __add_pages() as ret=3D%d\n",
> 		       __func__,  ret);
>diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
>index e6b2e6618b6c..72c46eb53215 100644
>--- a/arch/powerpc/mm/mem.c
>+++ b/arch/powerpc/mm/mem.c
>@@ -128,16 +128,12 @@ int __weak remove_section_mapping(unsigned long star=
t, unsigned long end)
>=20
> int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> {
>-	struct pglist_data *pgdata;
>-	struct zone *zone;
> 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
> 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
> 	int rc;
>=20
> 	resize_hpt_for_hotplug(memblock_phys_mem_size());
>=20
>-	pgdata =3D NODE_DATA(nid);
>-
> 	start =3D (unsigned long)__va(start);
> 	rc =3D create_section_mapping(start, start + size);
> 	if (rc) {
>@@ -147,11 +143,7 @@ int arch_add_memory(int nid, u64 start, u64 size, boo=
l for_device)
> 		return -EFAULT;
> 	}
>=20
>-	/* this should work for most non-highmem platforms */
>-	zone =3D pgdata->node_zones +
>-		zone_for_memory(nid, start, size, 0, for_device);
>-
>-	return __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
>+	return __add_pages(nid, start_pfn, nr_pages, !for_device);
> }
>=20
> #ifdef CONFIG_MEMORY_HOTREMOVE
>diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
>index 893cf88cf02d..862824924ba6 100644
>--- a/arch/s390/mm/init.c
>+++ b/arch/s390/mm/init.c
>@@ -164,41 +164,15 @@ unsigned long memory_block_size_bytes(void)
> #ifdef CONFIG_MEMORY_HOTPLUG
> int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> {
>-	unsigned long zone_start_pfn, zone_end_pfn, nr_pages;
> 	unsigned long start_pfn =3D PFN_DOWN(start);
> 	unsigned long size_pages =3D PFN_DOWN(size);
>-	pg_data_t *pgdat =3D NODE_DATA(nid);
>-	struct zone *zone;
>-	int rc, i;
>+	int rc;
>=20
> 	rc =3D vmem_add_mapping(start, size);
> 	if (rc)
> 		return rc;
>=20
>-	for (i =3D 0; i < MAX_NR_ZONES; i++) {
>-		zone =3D pgdat->node_zones + i;
>-		if (zone_idx(zone) !=3D ZONE_MOVABLE) {
>-			/* Add range within existing zone limits, if possible */
>-			zone_start_pfn =3D zone->zone_start_pfn;
>-			zone_end_pfn =3D zone->zone_start_pfn +
>-				       zone->spanned_pages;
>-		} else {
>-			/* Add remaining range to ZONE_MOVABLE */
>-			zone_start_pfn =3D start_pfn;
>-			zone_end_pfn =3D start_pfn + size_pages;
>-		}
>-		if (start_pfn < zone_start_pfn || start_pfn >=3D zone_end_pfn)
>-			continue;
>-		nr_pages =3D (start_pfn + size_pages > zone_end_pfn) ?
>-			   zone_end_pfn - start_pfn : size_pages;
>-		rc =3D __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
>-		if (rc)
>-			break;
>-		start_pfn +=3D nr_pages;
>-		size_pages -=3D nr_pages;
>-		if (!size_pages)
>-			break;
>-	}
>+	rc =3D __add_pages(nid, start_pfn, size_pages, !for_device);
> 	if (rc)
> 		vmem_remove_mapping(start, size);
> 	return rc;
>diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
>index a9d57f75ae8c..3813a610a2bb 100644
>--- a/arch/sh/mm/init.c
>+++ b/arch/sh/mm/init.c
>@@ -487,18 +487,12 @@ void free_initrd_mem(unsigned long start, unsigned l=
ong end)
> #ifdef CONFIG_MEMORY_HOTPLUG
> int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> {
>-	pg_data_t *pgdat;
> 	unsigned long start_pfn =3D PFN_DOWN(start);
> 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
> 	int ret;
>=20
>-	pgdat =3D NODE_DATA(nid);
>-
> 	/* We only have ZONE_NORMAL, so this is easy.. */
>-	ret =3D __add_pages(nid, pgdat->node_zones +
>-			zone_for_memory(nid, start, size, ZONE_NORMAL,
>-			for_device),
>-			start_pfn, nr_pages, !for_device);
>+	ret =3D __add_pages(nid, start_pfn, nr_pages, !for_device);
> 	if (unlikely(ret))
> 		printk("%s: Failed, __add_pages() =3D=3D %d\n", __func__, ret);
>=20
>diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
>index 94594b889144..a424066d0552 100644
>--- a/arch/x86/mm/init_32.c
>+++ b/arch/x86/mm/init_32.c
>@@ -825,13 +825,10 @@ void __init mem_init(void)
> #ifdef CONFIG_MEMORY_HOTPLUG
> int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> {
>-	struct pglist_data *pgdata =3D NODE_DATA(nid);
>-	struct zone *zone =3D pgdata->node_zones +
>-		zone_for_memory(nid, start, size, ZONE_HIGHMEM, for_device);
> 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
> 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
>=20
>-	return __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
>+	return __add_pages(nid, start_pfn, nr_pages, !for_device);
> }
>=20
> #ifdef CONFIG_MEMORY_HOTREMOVE
>diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>index 2e004364a373..884c1d0a57b3 100644
>--- a/arch/x86/mm/init_64.c
>+++ b/arch/x86/mm/init_64.c
>@@ -682,22 +682,15 @@ static void  update_end_of_memory_vars(u64 start, u6=
4 size)
> 	}
> }
>=20
>-/*
>- * Memory is added always to NORMAL zone. This means you will never get
>- * additional DMA/DMA32 memory.
>- */
> int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> {
>-	struct pglist_data *pgdat =3D NODE_DATA(nid);
>-	struct zone *zone =3D pgdat->node_zones +
>-		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
> 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
> 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
> 	int ret;
>=20
> 	init_memory_mapping(start, start + size);
>=20
>-	ret =3D __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
>+	ret =3D __add_pages(nid, start_pfn, nr_pages, !for_device);
> 	WARN_ON_ONCE(ret);
>=20
> 	/* update max_pfn, max_low_pfn and high_memory */
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index 1e884d82af6f..b86fda30ce62 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -392,39 +392,43 @@ static ssize_t show_valid_zones(struct device *dev,
> 				struct device_attribute *attr, char *buf)
> {
> 	struct memory_block *mem =3D to_memory_block(dev);
>-	unsigned long start_pfn, end_pfn;
>-	unsigned long valid_start, valid_end, valid_pages;
>+	unsigned long start_pfn =3D section_nr_to_pfn(mem->start_section_nr);
> 	unsigned long nr_pages =3D PAGES_PER_SECTION * sections_per_block;
>-	struct zone *zone;
>-	int zone_shift =3D 0;
>+	unsigned long valid_start_pfn, valid_end_pfn;
>+	bool append =3D false;
>+	int nid;
>=20
>-	start_pfn =3D section_nr_to_pfn(mem->start_section_nr);
>-	end_pfn =3D start_pfn + nr_pages;
>-
>-	/* The block contains more than one zone can not be offlined. */
>-	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start, &valid_end))
>+	/*
>+	 * The block contains more than one zone can not be offlined.
>+	 * This can happen e.g. for ZONE_DMA and ZONE_DMA32
>+	 */
>+	if (!test_pages_in_a_zone(start_pfn, start_pfn + nr_pages, &valid_start_=
pfn, &valid_end_pfn))
> 		return sprintf(buf, "none\n");
>=20
>-	zone =3D page_zone(pfn_to_page(valid_start));
>-	valid_pages =3D valid_end - valid_start;
>-
>-	/* MMOP_ONLINE_KEEP */
>-	sprintf(buf, "%s", zone->name);
>+	start_pfn =3D valid_start_pfn;
>+	nr_pages =3D valid_end_pfn - start_pfn;
>=20
>-	/* MMOP_ONLINE_KERNEL */
>-	zone_can_shift(valid_start, valid_pages, ZONE_NORMAL, &zone_shift);
>-	if (zone_shift) {
>-		strcat(buf, " ");
>-		strcat(buf, (zone + zone_shift)->name);
>+	/*
>+	 * Check the existing zone. Make sure that we do that only on the
>+	 * online nodes otherwise the page_zone is not reliable
>+	 */
>+	if (mem->state =3D=3D MEM_ONLINE) {
>+		strcat(buf, page_zone(pfn_to_page(start_pfn))->name);
>+		goto out;
> 	}
>=20
>-	/* MMOP_ONLINE_MOVABLE */
>-	zone_can_shift(valid_start, valid_pages, ZONE_MOVABLE, &zone_shift);
>-	if (zone_shift) {
>-		strcat(buf, " ");
>-		strcat(buf, (zone + zone_shift)->name);
>+	nid =3D pfn_to_nid(start_pfn);
>+	if (allow_online_pfn_range(nid, start_pfn, nr_pages, MMOP_ONLINE_KERNEL)=
) {
>+		strcat(buf, NODE_DATA(nid)->node_zones[ZONE_NORMAL].name);
>+		append =3D true;
> 	}
>=20
>+	if (allow_online_pfn_range(nid, start_pfn, nr_pages, MMOP_ONLINE_MOVABLE=
)) {
>+		if (append)
>+			strcat(buf, " ");
>+		strcat(buf, NODE_DATA(nid)->node_zones[ZONE_MOVABLE].name);
>+	}
>+out:
> 	strcat(buf, "\n");
>=20
> 	return strlen(buf);
>diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug=
=2Eh
>index fc1c873504eb..9cd76ff7b0c5 100644
>--- a/include/linux/memory_hotplug.h
>+++ b/include/linux/memory_hotplug.h
>@@ -122,8 +122,8 @@ extern int __remove_pages(struct zone *zone, unsigned =
long start_pfn,
> 	unsigned long nr_pages);
> #endif /* CONFIG_MEMORY_HOTREMOVE */
>=20
>-/* reasonably generic interface to expand the physical pages in a zone  */
>-extern int __add_pages(int nid, struct zone *zone, unsigned long start_pf=
n,
>+/* reasonably generic interface to expand the physical pages */
>+extern int __add_pages(int nid, unsigned long start_pfn,
> 	unsigned long nr_pages, bool want_memblock);
>=20
> #ifdef CONFIG_NUMA
>@@ -298,15 +298,16 @@ extern int add_memory_resource(int nid, struct resou=
rce *resource, bool online);
> extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
> 		bool for_device);
> extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
>+extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start=
_pfn,
>+		unsigned long nr_pages);
> extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
> extern bool is_memblock_offlined(struct memory_block *mem);
> extern void remove_memory(int nid, u64 start, u64 size);
>-extern int sparse_add_one_section(struct zone *zone, unsigned long start_=
pfn);
>+extern int sparse_add_one_section(struct pglist_data *pgdat, unsigned lon=
g start_pfn);
> extern void sparse_remove_one_section(struct zone *zone, struct mem_secti=
on *ms,
> 		unsigned long map_offset);
> extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
> 					  unsigned long pnum);
>-extern bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
>-			  enum zone_type target, int *zone_shift);
>-
>+extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned l=
ong nr_pages,
>+		int online_type);
> #endif /* __LINUX_MEMORY_HOTPLUG_H */
>diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>index 927ad95a4552..f887fccb6ef0 100644
>--- a/include/linux/mmzone.h
>+++ b/include/linux/mmzone.h
>@@ -533,6 +533,26 @@ static inline bool zone_is_empty(struct zone *zone)
> }
>=20
> /*
>+ * Return true if [start_pfn, start_pfn + nr_pages) range has a non-empty
>+ * intersection with the given zone
>+ */
>+static inline bool zone_intersects(struct zone *zone,
>+		unsigned long start_pfn, unsigned long nr_pages)
>+{
>+	if (zone_is_empty(zone))
>+		return false;
>+	if (start_pfn >=3D zone_end_pfn(zone))
>+		return false;
>+
>+	if (zone->zone_start_pfn <=3D start_pfn)
>+		return true;
>+	if (start_pfn + nr_pages > zone->zone_start_pfn)
>+		return true;
>+
>+	return false;
>+}

I think this could be simplified as:

static inline bool zone_intersects(struct zone *zone,
		unsigned long start_pfn, unsigned long nr_pages)
{
	if (zone_is_empty(zone))
		return false;

	if (start_pfn >=3D zone_end_pfn(zone) ||
	    start_pfn + nr_pages <=3D zone->zone_start_pfn)
		return false;

	return true;
}

>+
>+/*
>  * The "priority" of VM scanning is how much of the queues we will scan i=
n one
>  * go. A value of 12 for DEF_PRIORITY implies that we will scan 1/4096th =
of the
>  * queues ("queue_length >> 12") during an aging round.
>diff --git a/kernel/memremap.c b/kernel/memremap.c
>index 23a6483c3666..281eb478856a 100644
>--- a/kernel/memremap.c
>+++ b/kernel/memremap.c
>@@ -359,6 +359,10 @@ void *devm_memremap_pages(struct device *dev, struct =
resource *res,
>=20
> 	mem_hotplug_begin();
> 	error =3D arch_add_memory(nid, align_start, align_size, true);
>+	if (!error)
>+		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
>+					align_start >> PAGE_SHIFT,
>+					align_size >> PAGE_SHIFT);
> 	mem_hotplug_done();
> 	if (error)
> 		goto err_add_memory;
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index c3a146028ba6..dc363370e9d8 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -433,25 +433,6 @@ static int __meminit move_pfn_range_right(struct zone=
 *z1, struct zone *z2,
> 	return -1;
> }
>=20
>-static struct zone * __meminit move_pfn_range(int zone_shift,
>-		unsigned long start_pfn, unsigned long end_pfn)
>-{
>-	struct zone *zone =3D page_zone(pfn_to_page(start_pfn));
>-	int ret =3D 0;
>-
>-	if (zone_shift < 0)
>-		ret =3D move_pfn_range_left(zone + zone_shift, zone,
>-					  start_pfn, end_pfn);
>-	else if (zone_shift)
>-		ret =3D move_pfn_range_right(zone, zone + zone_shift,
>-					   start_pfn, end_pfn);
>-
>-	if (ret)
>-		return NULL;
>-
>-	return zone + zone_shift;
>-}
>-
> static void __meminit grow_pgdat_span(struct pglist_data *pgdat, unsigned=
 long start_pfn,
> 				      unsigned long end_pfn)
> {
>@@ -493,23 +474,35 @@ static int __meminit __add_zone(struct zone *zone, u=
nsigned long phys_start_pfn)
> 	return 0;
> }
>=20
>-static int __meminit __add_section(int nid, struct zone *zone,
>-		unsigned long phys_start_pfn, bool want_memblock)
>+static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>+		bool want_memblock)
> {
> 	int ret;
>+	int i;
>=20
> 	if (pfn_valid(phys_start_pfn))
> 		return -EEXIST;
>=20
>-	ret =3D sparse_add_one_section(zone, phys_start_pfn);
>-
>+	ret =3D sparse_add_one_section(NODE_DATA(nid), phys_start_pfn);
> 	if (ret < 0)
> 		return ret;
>=20
>-	ret =3D __add_zone(zone, phys_start_pfn);
>+	/*
>+	 * Make all the pages reserved so that nobody will stumble over half
>+	 * initialized state.
>+	 * FIXME: We also have to associate it with a node because pfn_to_node
>+	 * relies on having page with the proper node.
>+	 */
>+	for (i =3D 0; i < PAGES_PER_SECTION; i++) {
>+		unsigned long pfn =3D phys_start_pfn + i;
>+		struct page *page;
>+		if (!pfn_valid(pfn))
>+			continue;
>=20
>-	if (ret < 0)
>-		return ret;
>+		page =3D pfn_to_page(pfn);
>+		set_page_node(page, nid);
>+		SetPageReserved(page);
>+	}
>=20
> 	if (!want_memblock)
> 		return 0;
>@@ -523,7 +516,7 @@ static int __meminit __add_section(int nid, struct zon=
e *zone,
>  * call this function after deciding the zone to which to
>  * add the new pages.
>  */
>-int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_star=
t_pfn,
>+int __ref __add_pages(int nid, unsigned long phys_start_pfn,
> 			unsigned long nr_pages, bool want_memblock)
> {
> 	unsigned long i;
>@@ -531,8 +524,6 @@ int __ref __add_pages(int nid, struct zone *zone, unsi=
gned long phys_start_pfn,
> 	int start_sec, end_sec;
> 	struct vmem_altmap *altmap;
>=20
>-	clear_zone_contiguous(zone);
>-
> 	/* during initialize mem_map, align hot-added range to section */
> 	start_sec =3D pfn_to_section_nr(phys_start_pfn);
> 	end_sec =3D pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
>@@ -552,7 +543,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsi=
gned long phys_start_pfn,
> 	}
>=20
> 	for (i =3D start_sec; i <=3D end_sec; i++) {
>-		err =3D __add_section(nid, zone, section_nr_to_pfn(i), want_memblock);
>+		err =3D __add_section(nid, section_nr_to_pfn(i), want_memblock);
>=20
> 		/*
> 		 * EEXIST is finally dealt with by ioresource collision
>@@ -565,7 +556,6 @@ int __ref __add_pages(int nid, struct zone *zone, unsi=
gned long phys_start_pfn,
> 	}
> 	vmemmap_populate_print_last();
> out:
>-	set_zone_contiguous(zone);
> 	return err;
> }
> EXPORT_SYMBOL_GPL(__add_pages);
>@@ -1037,39 +1027,114 @@ static void node_states_set_node(int node, struct=
 memory_notify *arg)
> 	node_set_state(node, N_MEMORY);
> }
>=20
>-bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
>-		   enum zone_type target, int *zone_shift)
>+bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_=
pages, int online_type)
> {
>-	struct zone *zone =3D page_zone(pfn_to_page(pfn));
>-	enum zone_type idx =3D zone_idx(zone);
>-	int i;
>+	struct pglist_data *pgdat =3D NODE_DATA(nid);
>+	struct zone *movable_zone =3D &pgdat->node_zones[ZONE_MOVABLE];
>+	struct zone *normal_zone =3D  &pgdat->node_zones[ZONE_NORMAL];
>=20
>-	*zone_shift =3D 0;
>+	/*
>+	 * TODO there shouldn't be any inherent reason to have ZONE_NORMAL
>+	 * physically before ZONE_MOVABLE. All we need is they do not
>+	 * overlap. Historically we didn't allow ZONE_NORMAL after ZONE_MOVABLE
>+	 * though so let's stick with it for simplicity for now.
>+	 * TODO make sure we do not overlap with ZONE_DEVICE
>+	 */
>+	if (online_type =3D=3D MMOP_ONLINE_KERNEL) {
>+		if (zone_is_empty(movable_zone))
>+			return true;
>+		return movable_zone->zone_start_pfn >=3D pfn + nr_pages;
>+	} else if (online_type =3D=3D MMOP_ONLINE_MOVABLE) {
>+		return zone_end_pfn(normal_zone) <=3D pfn;
>+	}
>=20
>-	if (idx < target) {
>-		/* pages must be at end of current zone */
>-		if (pfn + nr_pages !=3D zone_end_pfn(zone))
>-			return false;
>+	/* MMOP_ONLINE_KEEP will always succeed and inherits the current zone */
>+	return online_type =3D=3D MMOP_ONLINE_KEEP;
>+}
>+
>+static void __meminit resize_zone_range(struct zone *zone, unsigned long =
start_pfn,
>+		unsigned long nr_pages)
>+{
>+	unsigned long old_end_pfn =3D zone_end_pfn(zone);
>+
>+	if (zone_is_empty(zone) || start_pfn < zone->zone_start_pfn)
>+		zone->zone_start_pfn =3D start_pfn;
>+
>+	zone->spanned_pages =3D max(start_pfn + nr_pages, old_end_pfn) - zone->z=
one_start_pfn;
>+}
>+
>+static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsig=
ned long start_pfn,
>+                                     unsigned long nr_pages)
>+{
>+	unsigned long old_end_pfn =3D pgdat_end_pfn(pgdat);
>=20
>-		/* no zones in use between current zone and target */
>-		for (i =3D idx + 1; i < target; i++)
>-			if (zone_is_initialized(zone - idx + i))
>-				return false;
>+	if (!pgdat->node_spanned_pages || start_pfn < pgdat->node_start_pfn)
>+		pgdat->node_start_pfn =3D start_pfn;
>+
>+	pgdat->node_spanned_pages =3D max(start_pfn + nr_pages, old_end_pfn) - p=
gdat->node_start_pfn;
>+}
>+
>+void move_pfn_range_to_zone(struct zone *zone,
>+		unsigned long start_pfn, unsigned long nr_pages)
>+{
>+	struct pglist_data *pgdat =3D zone->zone_pgdat;
>+	int nid =3D pgdat->node_id;
>+	unsigned long flags;
>+	unsigned long i;
>+
>+	if (zone_is_empty(zone))
>+		init_currently_empty_zone(zone, start_pfn, nr_pages);
>+
>+	clear_zone_contiguous(zone);
>+
>+	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that =
before */
>+	pgdat_resize_lock(pgdat, &flags);
>+	zone_span_writelock(zone);
>+	resize_zone_range(zone, start_pfn, nr_pages);
>+	zone_span_writeunlock(zone);
>+	resize_pgdat_range(pgdat, start_pfn, nr_pages);
>+	pgdat_resize_unlock(pgdat, &flags);
>+
>+	/*
>+	 * TODO now we have a visible range of pages which are not associated
>+	 * with their zone properly. Not nice but set_pfnblock_flags_mask
>+	 * expects the zone spans the pfn range. All the pages in the range
>+	 * are reserved so nobody should be touching them so we should be safe
>+	 */
>+	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn, MEMMAP_HOTPLU=
G);
>+	for (i =3D 0; i < nr_pages; i++) {
>+		unsigned long pfn =3D start_pfn + i;
>+		set_page_links(pfn_to_page(pfn), zone_idx(zone), nid, pfn);
> 	}
>=20
>-	if (target < idx) {
>-		/* pages must be at beginning of current zone */
>-		if (pfn !=3D zone->zone_start_pfn)
>-			return false;
>+	set_zone_contiguous(zone);
>+}
>+
>+/*
>+ * Associates the given pfn range with the given node and the zone approp=
riate
>+ * for the given online type.
>+ */
>+static struct zone * __meminit move_pfn_range(int online_type, int nid,
>+		unsigned long start_pfn, unsigned long nr_pages)
>+{
>+	struct pglist_data *pgdat =3D NODE_DATA(nid);
>+	struct zone *zone =3D &pgdat->node_zones[ZONE_NORMAL];
>=20
>-		/* no zones in use between current zone and target */
>-		for (i =3D target + 1; i < idx; i++)
>-			if (zone_is_initialized(zone - idx + i))
>-				return false;
>+	if (online_type =3D=3D MMOP_ONLINE_KEEP) {
>+		struct zone *movable_zone =3D &pgdat->node_zones[ZONE_MOVABLE];
>+		/*
>+		 * MMOP_ONLINE_KEEP inherits the current zone which is
>+		 * ZONE_NORMAL by default but we might be within ZONE_MOVABLE
>+		 * already.
>+		 */
>+		if (zone_intersects(movable_zone, start_pfn, nr_pages))
>+			zone =3D movable_zone;
>+	} else if (online_type =3D=3D MMOP_ONLINE_MOVABLE) {
>+		zone =3D &pgdat->node_zones[ZONE_MOVABLE];
> 	}
>=20
>-	*zone_shift =3D target - idx;
>-	return true;
>+	move_pfn_range_to_zone(zone, start_pfn, nr_pages);
>+	return zone;
> }
>=20
> /* Must be protected by mem_hotplug_begin() */
>@@ -1082,38 +1147,21 @@ int __ref online_pages(unsigned long pfn, unsigned=
 long nr_pages, int online_typ
> 	int nid;
> 	int ret;
> 	struct memory_notify arg;
>-	int zone_shift =3D 0;
>=20
>-	/*
>-	 * This doesn't need a lock to do pfn_to_page().
>-	 * The section can't be removed here because of the
>-	 * memory_block->state_mutex.
>-	 */
>-	zone =3D page_zone(pfn_to_page(pfn));
>-
>-	if ((zone_idx(zone) > ZONE_NORMAL ||
>-	    online_type =3D=3D MMOP_ONLINE_MOVABLE) &&
>-	    !can_online_high_movable(pfn_to_nid(pfn)))
>+	nid =3D pfn_to_nid(pfn);
>+	if (!allow_online_pfn_range(nid, pfn, nr_pages, online_type))
> 		return -EINVAL;
>=20
>-	if (online_type =3D=3D MMOP_ONLINE_KERNEL) {
>-		if (!zone_can_shift(pfn, nr_pages, ZONE_NORMAL, &zone_shift))
>-			return -EINVAL;
>-	} else if (online_type =3D=3D MMOP_ONLINE_MOVABLE) {
>-		if (!zone_can_shift(pfn, nr_pages, ZONE_MOVABLE, &zone_shift))
>-			return -EINVAL;
>-	}
>-
>-	zone =3D move_pfn_range(zone_shift, pfn, pfn + nr_pages);
>-	if (!zone)
>+	if (online_type =3D=3D MMOP_ONLINE_MOVABLE && !can_online_high_movable(n=
id))
> 		return -EINVAL;
>=20
>+	/* associate pfn range with the zone */
>+	zone =3D move_pfn_range(online_type, nid, pfn, nr_pages);
>+
> 	arg.start_pfn =3D pfn;
> 	arg.nr_pages =3D nr_pages;
> 	node_states_check_changes_online(nr_pages, zone, &arg);
>=20
>-	nid =3D zone_to_nid(zone);
>-
> 	ret =3D memory_notify(MEM_GOING_ONLINE, &arg);
> 	ret =3D notifier_to_errno(ret);
> 	if (ret)
>diff --git a/mm/sparse.c b/mm/sparse.c
>index 9d7fd666015e..7b4be3fd5cac 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -761,10 +761,9 @@ static void free_map_bootmem(struct page *memmap)
>  * set.  If this is <=3D0, then that means that the passed-in
>  * map was not consumed and must be freed.
>  */
>-int __meminit sparse_add_one_section(struct zone *zone, unsigned long sta=
rt_pfn)
>+int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned =
long start_pfn)
> {
> 	unsigned long section_nr =3D pfn_to_section_nr(start_pfn);
>-	struct pglist_data *pgdat =3D zone->zone_pgdat;
> 	struct mem_section *ms;
> 	struct page *memmap;
> 	unsigned long *usemap;
>--=20
>2.11.0

--=20
Wei Yang
Help you, Help me

--n8g4imXOkfNTN/H1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQ1yqAAoJEKcLNpZP5cTdDjAP/iVTyePatIqzPsFJNcE70shm
Dz8edaNVSPtf1fEwpMlfiHCtWggGPEYTbp0dJiPN6ASme1w1dt6JBL2fUFis9kcm
FzChRITqefUT3Xl5Zn66KKsmLJH1wLBW07UvZLklqh7i7vDqNP1R9HrWB5JXWrMK
vi1z/Uy/sCbV+O+6jYSindzN0LY35e6loGIbkDjWy0MEODZyC27D3vjesqj1+516
65rdk+eyPBYH+IhLP7k8KIQ5Ok1p9KIKu+d8mVRJDpcY3SKJv1igC6RtJv8F7Fhf
mKu472tAx0VKX06pOJ3hojZ5cslWI+7gD5Rrr1z/v7OvftbLHM6JOFKxeEDyp/jG
iEupiZAYByNiYR9hDhW1uJBtrXfkCOgyWWRV+IG+f+B4Cc0O13b0P2vkMsa/KcGH
K1ELjj70s020BKdTXeR0bEyZ46oztmXwyhxDsOTvi83XhpjmiBVGAJi9xsNd8Ibo
a5Vf7FDwQ8hXRgSFkroavFMEiaTJm21AmbKJrAQA2jPnqR6xReYSjbVS/ssgHS1P
aO7BdqiaeQATP3rs0QXn8OGKhivGsOREh2ybnvjXUqEtWfCk3OP8vYVVbzY+WM2J
nyb6HJUPPdZRvRkk4cZ1eZK7d9h0rItjH7ku0+2jrZ6BWdol+8PPSFIm6qpzlYRq
S8zsZjP+Q4xmkpNsooYp
=c1yX
-----END PGP SIGNATURE-----

--n8g4imXOkfNTN/H1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
