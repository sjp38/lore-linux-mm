Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E08386B0261
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 01:45:13 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r65so143092293qkd.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 22:45:13 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id i100si404763qkh.314.2016.07.13.22.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 22:45:13 -0700 (PDT)
From: Dennis Chen <dennis.chen@arm.com>
Subject: [PATCH v6 1/2] mm:memblock Add new infrastructure to address the mem limit issue
Date: Thu, 14 Jul 2016 13:43:55 +0800
Message-ID: <1468475036-5852-2-git-send-email-dennis.chen@arm.com>
In-Reply-To: <1468475036-5852-1-git-send-email-dennis.chen@arm.com>
References: <1468475036-5852-1-git-send-email-dennis.chen@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: nd@arm.com, steve.capper@arm.com, dennis.chen@arm.com, catalin.marinas@arm.com, ard.biesheuvel@linaro.org, akpm@linux-foundation.org, penberg@kernel.org, mgorman@techsingularity.net, tangchen@cn.fujitsu.com, tony.luck@intel.com, mingo@kernel.org, rafael@kernel.org, will.deacon@arm.com, mark.rutland@arm.com, matt@codeblueprint.co.uk, kaly.xin@arm.com, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-efi@vger.kernel.org

In some cases, memblock is queried by kernel to determine whether a
specified address is RAM or not. For example, the ACPI core needs this
information to determine which attributes to use when mapping ACPI
regions(acpi_os_ioremap). Use of incorrect memory types can result in
faults, data corruption, or other issues.

Removing memory with memblock_enforce_memory_limit() throws away this
information, and so a kernel booted with 'mem=3D' may suffers from the
issues described above. To avoid this, we need to keep those NOMAP
regions instead of removing all above the limit, which preserves the
information we need while preventing other use of those regions.

This patch adds new infrastructure to retain all NOMAP memblock regions
while removing others, to cater for this.

Acked-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Dennis Chen <dennis.chen@arm.com>

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Rafael J. Wysocki <rafael@kernel.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Kaly Xin <kaly.xin@arm.com>
Cc: linux-mm@kvack.org
Cc: linux-acpi@vger.kernel.org
Cc: linux-efi@vger.kernel.org
---
 include/linux/memblock.h |  1 +
 mm/memblock.c            | 57 +++++++++++++++++++++++++++++++++++++++++++-=
----
 2 files changed, 53 insertions(+), 5 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 6c14b61..2925da2 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -332,6 +332,7 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
 phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
+void memblock_mem_limit_remove_map(phys_addr_t limit);
 bool memblock_is_memory(phys_addr_t addr);
 int memblock_is_map_memory(phys_addr_t addr);
 int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index 0fc0fa1..02b68eb 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1465,15 +1465,16 @@ phys_addr_t __init_memblock memblock_end_of_DRAM(vo=
id)
 =09return (memblock.memory.regions[idx].base + memblock.memory.regions[idx=
].size);
 }
=20
-void __init memblock_enforce_memory_limit(phys_addr_t limit)
+static phys_addr_t __init_memblock __find_max_addr(phys_addr_t limit)
 {
 =09phys_addr_t max_addr =3D (phys_addr_t)ULLONG_MAX;
 =09struct memblock_region *r;
=20
-=09if (!limit)
-=09=09return;
-
-=09/* find out max address */
+=09/*
+=09 * translate the memory @limit size into the max address within one of
+=09 * the memory memblock regions, if the @limit exceeds the total size
+=09 * of those regions, max_addr will keep original value ULLONG_MAX
+=09 */
 =09for_each_memblock(memory, r) {
 =09=09if (limit <=3D r->size) {
 =09=09=09max_addr =3D r->base + limit;
@@ -1482,6 +1483,22 @@ void __init memblock_enforce_memory_limit(phys_addr_=
t limit)
 =09=09limit -=3D r->size;
 =09}
=20
+=09return max_addr;
+}
+
+void __init memblock_enforce_memory_limit(phys_addr_t limit)
+{
+=09phys_addr_t max_addr =3D (phys_addr_t)ULLONG_MAX;
+
+=09if (!limit)
+=09=09return;
+
+=09max_addr =3D __find_max_addr(limit);
+
+=09/* @limit exceeds the total size of the memory, do nothing */
+=09if (max_addr =3D=3D (phys_addr_t)ULLONG_MAX)
+=09=09return;
+
 =09/* truncate both memory and reserved regions */
 =09memblock_remove_range(&memblock.memory, max_addr,
 =09=09=09      (phys_addr_t)ULLONG_MAX);
@@ -1489,6 +1506,36 @@ void __init memblock_enforce_memory_limit(phys_addr_=
t limit)
 =09=09=09      (phys_addr_t)ULLONG_MAX);
 }
=20
+void __init memblock_mem_limit_remove_map(phys_addr_t limit)
+{
+=09struct memblock_type *type =3D &memblock.memory;
+=09phys_addr_t max_addr;
+=09int i, ret, start_rgn, end_rgn;
+
+=09if (!limit)
+=09=09return;
+
+=09max_addr =3D __find_max_addr(limit);
+
+=09/* @limit exceeds the total size of the memory, do nothing */
+=09if (max_addr =3D=3D (phys_addr_t)ULLONG_MAX)
+=09=09return;
+
+=09ret =3D memblock_isolate_range(type, max_addr, (phys_addr_t)ULLONG_MAX,
+=09=09=09=09&start_rgn, &end_rgn);
+=09if (ret)
+=09=09return;
+
+=09/* remove all the MAP regions above the limit */
+=09for (i =3D end_rgn - 1; i >=3D start_rgn; i--) {
+=09=09if (!memblock_is_nomap(&type->regions[i]))
+=09=09=09memblock_remove_region(type, i);
+=09}
+=09/* truncate the reserved regions */
+=09memblock_remove_range(&memblock.reserved, max_addr,
+=09=09=09      (phys_addr_t)ULLONG_MAX);
+}
+
 static int __init_memblock memblock_search(struct memblock_type *type, phy=
s_addr_t addr)
 {
 =09unsigned int left =3D 0, right =3D type->cnt;
--=20
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
