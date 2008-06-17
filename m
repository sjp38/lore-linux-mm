Date: Tue, 17 Jun 2008 16:35:01 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH][RFC] fix kernel BUG at mm/migrate.c:719! in 2.6.26-rc5-mm3
Message-Id: <20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi.

I got this bug while migrating pages only a few times
via memory_migrate of cpuset.

Unfortunately, even if this patch is applied,
I got bad_page problem after hundreds times of page migration
(I'll report it in another mail).
But I believe something like this patch is needed anyway.

------------[ cut here ]------------
kernel BUG at mm/migrate.c:719!
invalid opcode: 0000 [1] SMP
last sysfs file: /sys/devices/system/cpu/cpu3/cache/index1/shared_cpu_map
CPU 0
Modules linked in: ipv6 autofs4 hidp rfcomm l2cap bluetooth sunrpc dm_mirror dm_log dm_multipath dm_mod sbs sbshc button battery acpi_memhotplug ac parport_pc lp parport floppy serio_raw rtc_cmos rtc_core rtc_lib 8139too pcspkr 8139cp mii ata_piix libata sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd [last unloaded: microcode]
Pid: 3096, comm: switch.sh Not tainted 2.6.26-rc5-mm3 #1
RIP: 0010:[<ffffffff8029bb85>]  [<ffffffff8029bb85>] migrate_pages+0x33e/0x49f
RSP: 0018:ffff81002f463bb8  EFLAGS: 00010202
RAX: 0000000000000000 RBX: ffffe20000c17500 RCX: 0000000000000034
RDX: ffffe20000c17500 RSI: ffffe200010003c0 RDI: ffffe20000c17528
RBP: ffffe200010003c0 R08: 8000000000000000 R09: 304605894800282f
R10: 282f87058b480028 R11: 0028304005894800 R12: ffff81003f90a5d8
R13: 0000000000000000 R14: ffffe20000bf4cc0 R15: ffff81002f463c88
FS:  00007ff9386576f0(0000) GS:ffffffff8061d800(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007ff938669000 CR3: 000000002f458000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process switch.sh (pid: 3096, threadinfo ffff81002f462000, task ffff81003e99cf10)
Stack:  0000000000000001 ffffffff80290777 0000000000000000 0000000000000000
 ffff81002f463c88 ffff81000000ea18 ffff81002f463c88 000000000000000c
 ffff81002f463ca8 00007ffffffff000 00007fff649f6000 0000000000000004
Call Trace:
 [<ffffffff80290777>] ? new_node_page+0x0/0x2f
 [<ffffffff80291611>] ? do_migrate_pages+0x19b/0x1e7
 [<ffffffff802315c7>] ? set_cpus_allowed_ptr+0xe6/0xf3
 [<ffffffff8025c827>] ? cpuset_migrate_mm+0x58/0x8f
 [<ffffffff8025d0fd>] ? cpuset_attach+0x8b/0x9e
 [<ffffffff8025a3e1>] ? cgroup_attach_task+0x3a3/0x3f5
 [<ffffffff80276cb5>] ? __alloc_pages_internal+0xe2/0x3d1
 [<ffffffff8025af06>] ? cgroup_common_file_write+0x150/0x1dd
 [<ffffffff8025aaf4>] ? cgroup_file_write+0x54/0x150
 [<ffffffff8029f839>] ? vfs_write+0xad/0x136
 [<ffffffff8029fd76>] ? sys_write+0x45/0x6e
 [<ffffffff8020bef2>] ? tracesys+0xd5/0xda


Code: 4c 48 8d 7b 28 e8 cc 87 09 00 48 83 7b 18 00 75 30 48 8b 03 48 89 da 25 00 40 00 00 48 85 c0 74 04 48 8b 53 10 83 7a 08 01 74 04 <0f> 0b eb fe 48 89 df e8 5e 50 fd ff 48 89 df e8 7d d6 fd ff eb
RIP  [<ffffffff8029bb85>] migrate_pages+0x33e/0x49f
 RSP <ffff81002f463bb8>
Clocksource tsc unstable (delta = 438246251 ns)
---[ end trace ce4e6053f7b9bba1 ]---


This bug is caused by VM_BUG_ON() in unmap_and_move().

unmap_and_move()
    710         if (rc != -EAGAIN) {
    711                 /*
    712                  * A page that has been migrated has all references
    713                  * removed and will be freed. A page that has not been
    714                  * migrated will have kepts its references and be
    715                  * restored.
    716                  */
    717                 list_del(&page->lru);
    718                 if (!page->mapping) {
    719                         VM_BUG_ON(page_count(page) != 1);
    720                         unlock_page(page);
    721                         put_page(page);         /* just free the old page */
    722                         goto end_migration;
    723                 } else
    724                         unlock = putback_lru_page(page);
    725         }

I think the page count is not necessarily 1 here, because
migration_entry_wait increases page count and waits for the
page to be unlocked.
So, if the old page is accessed between migrate_page_move_mapping,
which checks the page count, and remove_migration_ptes, page count
would not be 1 here.

Actually, just commenting out get/put_page from migration_entry_wait
works well in my environment(succeeded in hundreds times of page migration),
but modifying migration_entry_wait this way is not good, I think.


This patch depends on Lee Schermerhorn's fix for double unlock_page.

This patch also fixes a race between migrate_entry_wait and
page_freeze_refs in migrate_page_move_mapping.


Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

---
diff -uprN linux-2.6.26-rc5-mm3/mm/migrate.c linux-2.6.26-rc5-mm3-test/mm/migrate.c
--- linux-2.6.26-rc5-mm3/mm/migrate.c	2008-06-17 15:31:23.000000000 +0900
+++ linux-2.6.26-rc5-mm3-test/mm/migrate.c	2008-06-17 13:59:15.000000000 +0900
@@ -232,6 +232,7 @@ void migration_entry_wait(struct mm_stru
 	swp_entry_t entry;
 	struct page *page;
 
+retry:
 	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
 	pte = *ptep;
 	if (!is_swap_pte(pte))
@@ -243,11 +244,20 @@ void migration_entry_wait(struct mm_stru
 
 	page = migration_entry_to_page(entry);
 
-	get_page(page);
-	pte_unmap_unlock(ptep, ptl);
-	wait_on_page_locked(page);
-	put_page(page);
-	return;
+	/*
+	 * page count might be set to zero by page_freeze_refs()
+	 * in migrate_page_move_mapping().
+	 */
+	if (get_page_unless_zero(page)) {
+		pte_unmap_unlock(ptep, ptl);
+		wait_on_page_locked(page);
+		put_page(page);
+		return;
+	} else {
+		pte_unmap_unlock(ptep, ptl);
+		goto retry;
+	}
+
 out:
 	pte_unmap_unlock(ptep, ptl);
 }
@@ -715,13 +725,7 @@ unlock:
  		 * restored.
  		 */
  		list_del(&page->lru);
-		if (!page->mapping) {
-			VM_BUG_ON(page_count(page) != 1);
-			unlock_page(page);
-			put_page(page);		/* just free the old page */
-			goto end_migration;
-		} else
-			unlock = putback_lru_page(page);
+		unlock = putback_lru_page(page);
 	}
 
 	if (unlock)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
