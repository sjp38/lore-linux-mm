Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8089B6B025E
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 05:46:32 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so8376309lfa.1
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 02:46:32 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id f7si33399144wjp.233.2016.06.28.02.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Jun 2016 02:46:30 -0700 (PDT)
From: Dennis Chen <dennis.chen@arm.com>
Subject: [PATCH v4 2/3] mm: memblock Add some new functions to address the mem limit issue
Date: Tue, 28 Jun 2016 17:45:36 +0800
Message-ID: <1467107137-29631-2-git-send-email-dennis.chen@arm.com>
In-Reply-To: <1467107137-29631-1-git-send-email-dennis.chen@arm.com>
References: <1467107137-29631-1-git-send-email-dennis.chen@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: nd@arm.com, Dennis Chen <dennis.chen@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Ard
 Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-efi@vger.kernel.org

In some cases, memblock is queried to determine whether a physical
address corresponds to memory present in a system even if unused by
the OS for the linear mapping, highmem, etc. For example, the ACPI
core needs this information to determine which attributes to use when
mapping ACPI regions. Use of incorrect memory types can result in
faults, data corruption, or other issues.

Removing memory with memblock_enforce_memory_limit throws away this
information, and so a kernel booted with 'mem=3D' may suffers from the
issues described above. To avoid this, we need to kept those nomap
regions instead of removing all above limit, which preserves the
information we need while preventing other use of the regions.

This patch adds new insfrastructure to kept all nomap memblock regions
while removing others, to cater for this.

Signed-off-by: Dennis Chen <dennis.chen@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Steve Capper <steve.capper@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
Cc: linux-mm@kvack.org
Cc: linux-acpi@vger.kernel.org
Cc: linux-efi@vger.kernel.org
---
Change history
v1->v2: Mark all regions above the limit as NOMAP per Mark's suggestion
v2->v3: Only keep the NOMAP regions above limit while removing all
ohters according to the proposal from Ard's
v3->v4: Incorporate some review comments from Mark Rutland.

 include/linux/memblock.h |  1 +
 mm/memblock.c            | 54 +++++++++++++++++++++++++++++++++++++++++++-=
----
 2 files changed, 50 insertions(+), 5 deletions(-)

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
index 0fc0fa1..993f597 100644
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
@@ -1482,6 +1483,23 @@ void __init memblock_enforce_memory_limit(phys_addr_=
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
+=09struct memblock_region *r;
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
@@ -1489,6 +1507,32 @@ void __init memblock_enforce_memory_limit(phys_addr_=
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
+=09for (i =3D end_rgn - 1; i >=3D start_rgn; i--) {
+=09=09if (!memblock_is_nomap(&type->regions[i]))
+=09=09=09memblock_remove_region(type, i);
+=09}
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
