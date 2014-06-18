Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 514CA6B0085
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 02:39:00 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so403815pab.31
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 23:39:00 -0700 (PDT)
Received: from fgwmail.fujitsu.co.jp (fgwmail.fujitsu.co.jp. [164.71.1.133])
        by mx.google.com with ESMTPS id td4si1111331pac.62.2014.06.17.23.38.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 23:38:59 -0700 (PDT)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail.fujitsu.co.jp (Postfix) with ESMTP id 286163EE0B6
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 15:38:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.nic.fujitsu.com [10.0.50.92])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 26902AC044E
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 15:38:57 +0900 (JST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B3FB61DB8038
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 15:38:56 +0900 (JST)
Message-ID: <53A133ED.2090005@jp.fujitsu.com>
Date: Wed, 18 Jun 2014 15:38:37 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] x86,mem-hotplug: modify PGD entry when removing memory
References: <53A132E2.9000605@jp.fujitsu.com>
In-Reply-To: <53A132E2.9000605@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: tangchen@cn.fujitsu.com, toshi.kani@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, guz.fnst@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com

When hot-adding/removing memory, sync_global_pgds() is called for
synchronizing PGD to PGD entries of all processes MM. But when
hot-removing memory, sync_global_pgds() does not work correctly.

At first, sync_global_pgds() checks whether target PGD is none or not.
And if PGD is none, the PGD is skipped. But when hot-removing memory,
PGD may be none since PGD may be cleared by free_pud_table(). So
when sync_global_pgds() is called after hot-removing memory,
sync_global_pgds() should not skip PGD even if the PGD is none.
And sync_global_pgds() must clear PGD entries of all processes MM.

Currently sync_global_pgds() does not clear PGD entries of all processes
MM when hot-removing memory. So when hot adding memory which is same memory
range as removed memory after hot-removing memory, following call traces
are shown:

kernel BUG at arch/x86/mm/init_64.c:206!
...
 [<ffffffff815e0c80>] kernel_physical_mapping_init+0x1b2/0x1d2
 [<ffffffff815ced94>] init_memory_mapping+0x1d4/0x380
 [<ffffffff8104aebd>] arch_add_memory+0x3d/0xd0
 [<ffffffff815d03d9>] add_memory+0xb9/0x1b0
 [<ffffffff81352415>] acpi_memory_device_add+0x1af/0x28e
 [<ffffffff81325dc4>] acpi_bus_device_attach+0x8c/0xf0
 [<ffffffff813413b9>] acpi_ns_walk_namespace+0xc8/0x17f
 [<ffffffff81325d38>] ? acpi_bus_type_and_status+0xb7/0xb7
 [<ffffffff81325d38>] ? acpi_bus_type_and_status+0xb7/0xb7
 [<ffffffff813418ed>] acpi_walk_namespace+0x95/0xc5
 [<ffffffff81326b4c>] acpi_bus_scan+0x9a/0xc2
 [<ffffffff81326bff>] acpi_scan_bus_device_check+0x8b/0x12e
 [<ffffffff81326cb5>] acpi_scan_device_check+0x13/0x15
 [<ffffffff81320122>] acpi_os_execute_deferred+0x25/0x32
 [<ffffffff8107e02b>] process_one_work+0x17b/0x460
 [<ffffffff8107edfb>] worker_thread+0x11b/0x400
 [<ffffffff8107ece0>] ? rescuer_thread+0x400/0x400
 [<ffffffff81085aef>] kthread+0xcf/0xe0
 [<ffffffff81085a20>] ? kthread_create_on_node+0x140/0x140
 [<ffffffff815fc76c>] ret_from_fork+0x7c/0xb0
 [<ffffffff81085a20>] ? kthread_create_on_node+0x140/0x140

This patch clears PGD entries of all processes MM when sync_global_pgds()
is called after hot-removing memory

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/x86/include/asm/pgtable_64.h |  3 ++-
 arch/x86/mm/fault.c               |  2 +-
 arch/x86/mm/init_64.c             | 27 +++++++++++++++++++--------
 3 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 5be9063..809abb3 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -115,7 +115,8 @@ static inline void native_pgd_clear(pgd_t *pgd)
 	native_set_pgd(pgd, native_make_pgd(0));
 }

-extern void sync_global_pgds(unsigned long start, unsigned long end);
+extern void sync_global_pgds(unsigned long start, unsigned long end,
+			     int removed);

 /*
  * Conversion functions: convert a page and protection to a page entry,
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 3664279..0193a32 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -350,7 +350,7 @@ out:

 void vmalloc_sync_all(void)
 {
-	sync_global_pgds(VMALLOC_START & PGDIR_MASK, VMALLOC_END);
+	sync_global_pgds(VMALLOC_START & PGDIR_MASK, VMALLOC_END, 0);
 }

 /*
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index a5b245d..8f68032 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -178,7 +178,7 @@ __setup("noexec32=", nonx32_setup);
  * When memory was added/removed make sure all the processes MM have
  * suitable PGD entries in the local PGD level page.
  */
-void sync_global_pgds(unsigned long start, unsigned long end)
+void sync_global_pgds(unsigned long start, unsigned long end, int removed)
 {
 	unsigned long address;

@@ -186,7 +186,12 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 		const pgd_t *pgd_ref = pgd_offset_k(address);
 		struct page *page;

-		if (pgd_none(*pgd_ref))
+		/*
+		 * When it is called after memory hot remove, pgd_none()
+		 * returns true. In this case (removed == 1), we must clear
+		 * the PGD entries in the local PGD level page.
+		 */
+		if (pgd_none(*pgd_ref) && !removed)
 			continue;

 		spin_lock(&pgd_lock);
@@ -199,12 +204,18 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
 			spin_lock(pgt_lock);

-			if (pgd_none(*pgd))
-				set_pgd(pgd, *pgd_ref);
-			else
+			if (!pgd_none(*pgd_ref) && !pgd_none(*pgd))
 				BUG_ON(pgd_page_vaddr(*pgd)
 				       != pgd_page_vaddr(*pgd_ref));

+			if (removed) {
+				if (pgd_none(*pgd_ref) && !pgd_none(*pgd))
+					pgd_clear(pgd);
+			} else {
+				if (pgd_none(*pgd))
+					set_pgd(pgd, *pgd_ref);
+			}
+
 			spin_unlock(pgt_lock);
 		}
 		spin_unlock(&pgd_lock);
@@ -633,7 +644,7 @@ kernel_physical_mapping_init(unsigned long start,
 	}

 	if (pgd_changed)
-		sync_global_pgds(addr, end - 1);
+		sync_global_pgds(addr, end - 1, 0);

 	__flush_tlb_all();

@@ -994,7 +1005,7 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 	}

 	if (pgd_changed)
-		sync_global_pgds(start, end - 1);
+		sync_global_pgds(start, end - 1, 1);

 	flush_tlb_all();
 }
@@ -1341,7 +1352,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 	else
 		err = vmemmap_populate_basepages(start, end, node);
 	if (!err)
-		sync_global_pgds(start, end - 1);
+		sync_global_pgds(start, end - 1, 0);
 	return err;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
