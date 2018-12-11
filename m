Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEE78E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 11:57:51 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 4so10993082plc.5
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 08:57:51 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m10si12344780plt.295.2018.12.11.08.57.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 08:57:49 -0800 (PST)
Date: Tue, 11 Dec 2018 09:55:18 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCHv2 02/12] acpi/hmat: Parse and report heterogeneous memory
Message-ID: <20181211165518.GB8101@localhost.localdomain>
References: <20181211010310.8551-1-keith.busch@intel.com>
 <20181211010310.8551-3-keith.busch@intel.com>
 <CAPcyv4gEpxigPqc0PgDE0YCL3Ot+wPfvChAZqUTtdYR2WDxaJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gEpxigPqc0PgDE0YCL3Ot+wPfvChAZqUTtdYR2WDxaJg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

On Mon, Dec 10, 2018 at 10:03:40PM -0800, Dan Williams wrote:
> I have a use case to detect the presence of a memory-side-cache early
> at init time [1]. To me this means that hmat_init() needs to happen as
> a part of acpi_numa_init(). Subsequently I think that also means that
> the sysfs portion needs to be broken out to its own init path that can
> probably run at module_init() priority.
> 
> Perhaps we should split this patch set into two? The table parsing
> with an in-kernel user is a bit easier to reason about and can go in
> first. Towards that end can I steal / refllow patches 1 & 2 into the
> memory randomization series? Other ideas how to handle this?
> 
> [1]: https://lkml.org/lkml/2018/10/12/309

To that end, will something like the following work for you? This just
needs to happen after patch 1.

---
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index f5e09c39ff22..03ef3c8ba4ea 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -40,6 +40,8 @@ static int pxm_to_node_map[MAX_PXM_DOMAINS]
 static int node_to_pxm_map[MAX_NUMNODES]
 			= { [0 ... MAX_NUMNODES - 1] = PXM_INVAL };
 
+static unsigned long node_side_cached[BITS_TO_LONGS(MAX_PXM_DOMAINS)];
+
 unsigned char acpi_srat_revision __initdata;
 int acpi_numa __initdata;
 
@@ -262,6 +264,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	u64 start, end;
 	u32 hotpluggable;
 	int node, pxm;
+	bool side_cached;
 
 	if (srat_disabled())
 		goto out_err;
@@ -308,6 +311,11 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 		pr_warn("SRAT: Failed to mark hotplug range [mem %#010Lx-%#010Lx] in memblock\n",
 			(unsigned long long)start, (unsigned long long)end - 1);
 
+	side_cached = test_bit(pxm, node_side_cached);
+	if (side_cached && memblock_mark_sidecached(start, ma->length))
+		pr_warn("SRAT: Failed to mark side cached range [mem %#010Lx-%#010Lx] in memblock\n",
+			(unsigned long long)start, (unsigned long long)end - 1);
+
 	max_possible_pfn = max(max_possible_pfn, PFN_UP(end - 1));
 
 	return 0;
@@ -411,6 +419,19 @@ acpi_parse_memory_affinity(union acpi_subtable_headers * header,
 	return 0;
 }
 
+static int __init
+acpi_parse_cache(union acpi_subtable_headers *header, const unsigned long end)
+{
+	struct acpi_hmat_cache *cache = (void *)header;
+	u32 attrs;
+
+	attrs = cache->cache_attributes;
+	if (((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) ==
+						ACPI_HMAT_CA_DIRECT_MAPPED)
+		set_bit(cache->memory_PD, node_side_cached);
+	return 0;
+}
+
 static int __init acpi_parse_srat(struct acpi_table_header *table)
 {
 	struct acpi_table_srat *srat = (struct acpi_table_srat *)table;
@@ -422,6 +443,11 @@ static int __init acpi_parse_srat(struct acpi_table_header *table)
 	return 0;
 }
 
+static __init int acpi_parse_hmat(struct acpi_table_header *table)
+{
+	return 0;
+}
+
 static int __init
 acpi_table_parse_srat(enum acpi_srat_type id,
 		      acpi_tbl_entry_handler handler, unsigned int max_entries)
@@ -460,6 +486,16 @@ int __init acpi_numa_init(void)
 					sizeof(struct acpi_table_srat),
 					srat_proc, ARRAY_SIZE(srat_proc), 0);
 
+		if (!acpi_table_parse(ACPI_SIG_HMAT, acpi_parse_hmat)) {
+			struct acpi_subtable_proc hmat_proc;
+
+			memset(&hmat_proc, 0, sizeof(hmat_proc));
+			hmat_proc.handler = acpi_parse_cache;
+			hmat_proc.id = ACPI_HMAT_TYPE_CACHE;
+			acpi_table_parse_entries_array(ACPI_SIG_HMAT,
+						sizeof(struct acpi_table_hmat),
+						&hmat_proc, 1, 0);
+		}
 		cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
 					    acpi_parse_memory_affinity, 0);
 	}
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index aee299a6aa76..a24c918a4496 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -44,6 +44,7 @@ enum memblock_flags {
 	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
 	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
 	MEMBLOCK_NOMAP		= 0x4,	/* don't add to kernel direct mapping */
+	MEMBLOCK_SIDECACHED	= 0x8,  /* System side caches memory access */
 };
 
 /**
@@ -130,6 +131,7 @@ int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
 int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
 int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
+int memblock_mark_sidecached(phys_addr_t base, phys_addr_t size);
 enum memblock_flags choose_memblock_flags(void);
 
 unsigned long memblock_free_all(void);
@@ -227,6 +229,11 @@ static inline bool memblock_is_nomap(struct memblock_region *m)
 	return m->flags & MEMBLOCK_NOMAP;
 }
 
+static inline bool memblock_is_sidecached(struct memblock_region *m)
+{
+	return m->flags & MEMBLOCK_SIDECACHED;
+}
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
 			    unsigned long  *end_pfn);
diff --git a/mm/memblock.c b/mm/memblock.c
index 9a2d5ae81ae1..827b709afdcd 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -865,6 +865,11 @@ int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
 	return memblock_setclr_flag(base, size, 1, MEMBLOCK_HOTPLUG);
 }
 
+int __init_memblock memblock_mark_sidecached(phys_addr_t base, phys_addr_t size)
+{
+	return memblock_setclr_flag(base, size, 1, MEMBLOCK_SIDECACHED);
+}
+
 /**
  * memblock_clear_hotplug - Clear flag MEMBLOCK_HOTPLUG for a specified region.
  * @base: the base phys addr of the region
--
