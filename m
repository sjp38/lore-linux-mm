Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF436B006C
	for <linux-mm@kvack.org>; Thu, 14 May 2015 06:41:27 -0400 (EDT)
Received: by obcus9 with SMTP id us9so49904173obc.2
        for <linux-mm@kvack.org>; Thu, 14 May 2015 03:41:27 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id i6si3469034obw.90.2015.05.14.03.41.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 14 May 2015 03:41:24 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 3/4] mm: soft-offline: don't free target page in
 successful page migration
Date: Thu, 14 May 2015 10:39:13 +0000
Message-ID: <1431599951-32545-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1431599951-32545-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1431599951-32545-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Stress testing showed that soft offline events for a process iterating
"mmap-pagefault-munmap" loop can trigger VM_BUG_ON(PAGE_FLAGS_CHECK_AT_PREP=
)
in __free_one_page():

  [   14.025761] Soft offlining page 0x70fe1 at 0x70100008d000
  [   14.029400] Soft offlining page 0x705fb at 0x70300008d000
  [   14.030208] page:ffffea0001c3f840 count:0 mapcount:0 mapping:         =
 (null) index:0x2
  [   14.031186] flags: 0x1fffff80800000(hwpoison)
  [   14.031186] page dumped because: VM_BUG_ON_PAGE(page->flags & ((1 << 2=
5) - 1))
  [   14.031186] ------------[ cut here ]------------
  [   14.031186] kernel BUG at /src/linux-dev/mm/page_alloc.c:585!
  [   14.031186] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
  [   14.031186] Modules linked in: cfg80211 rfkill crc32c_intel microcode =
ppdev parport_pc pcspkr serio_raw virtio_balloon parport i2c_piix4 virtio_b=
lk virtio_net ata_generic pata_acpi floppy
  [   14.031186] CPU: 3 PID: 1779 Comm: test_base_madv_ Not tainted 4.0.0-v=
4.0-150511-1451-00009-g82360a3730e6 #139
  [   14.031186] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
  [   14.031186] task: ffff88007d33bae0 ti: ffff88007a114000 task.ti: ffff8=
8007a114000
  [   14.031186] RIP: 0010:[<ffffffff811a806a>]  [<ffffffff811a806a>] free_=
pcppages_bulk+0x52a/0x6f0
  [   14.031186] RSP: 0018:ffff88007a117d28  EFLAGS: 00010096
  [   14.031186] RAX: 0000000000000042 RBX: ffffea0001c3f860 RCX: 000000000=
0000006
  [   14.031186] RDX: 0000000000000007 RSI: 0000000000000000 RDI: ffff88011=
f50d3d0
  [   14.031186] RBP: ffff88007a117da8 R08: 000000000000000a R09: 00000000f=
ffffffe
  [   14.031186] R10: 0000000000001d3e R11: 0000000000000002 R12: 000000000=
0070fe1
  [   14.031186] R13: 0000000000000000 R14: 0000000000000000 R15: ffffea000=
1c3f840
  [   14.031186] FS:  00007f8a8e3e1740(0000) GS:ffff88011f500000(0000) knlG=
S:0000000000000000
  [   14.031186] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
  [   14.031186] CR2: 00007f78c7341258 CR3: 000000007bb08000 CR4: 000000000=
00007e0
  [   14.031186] Stack:
  [   14.031186]  ffff88011f5189c8 ffff88011f5189b8 ffffea0001c3f840 ffff88=
011f518998
  [   14.031186]  ffffea0001d30cc0 0000001200000002 0000000200000012 000000=
0000000003
  [   14.031186]  ffff88007ffda6c0 000000000000000a ffff88007a117dd8 ffff88=
011f518998
  [   14.031186] Call Trace:
  [   14.031186]  [<ffffffff811a8380>] ? page_alloc_cpu_notify+0x50/0x50
  [   14.031186]  [<ffffffff811a82bd>] drain_pages_zone+0x3d/0x50
  [   14.031186]  [<ffffffff811a839d>] drain_local_pages+0x1d/0x30
  [   14.031186]  [<ffffffff81122a96>] on_each_cpu_mask+0x46/0x80
  [   14.031186]  [<ffffffff811a5e8b>] drain_all_pages+0x14b/0x1e0
  [   14.031186]  [<ffffffff812151a2>] soft_offline_page+0x432/0x6e0
  [   14.031186]  [<ffffffff811e2dac>] SyS_madvise+0x73c/0x780
  [   14.031186]  [<ffffffff810dcb3f>] ? put_prev_task_fair+0x2f/0x50
  [   14.031186]  [<ffffffff81143f74>] ? __audit_syscall_entry+0xc4/0x120
  [   14.031186]  [<ffffffff8105bdac>] ? do_audit_syscall_entry+0x6c/0x70
  [   14.031186]  [<ffffffff8105cc63>] ? syscall_trace_enter_phase1+0x103/0=
x170
  [   14.031186]  [<ffffffff816f908e>] ? int_check_syscall_exit_work+0x34/0=
x3d
  [   14.031186]  [<ffffffff816f8e72>] system_call_fastpath+0x12/0x17
  [   14.031186] Code: ff 89 45 b4 48 8b 45 c0 48 83 b8 a8 00 00 00 00 0f 8=
5 e3 fb ff ff 0f 1f 00 0f 0b 48 8b 7d 90 48 c7 c6 e8 95 a6 81 e8 e6 32 02 0=
0 <0f> 0b 8b 45 cc 49 89 47 30 41 8b 47 18 83 f8 ff 0f 85 10 ff ff
  [   14.031186] RIP  [<ffffffff811a806a>] free_pcppages_bulk+0x52a/0x6f0
  [   14.031186]  RSP <ffff88007a117d28>
  [   14.031186] ---[ end trace 53926436e76d1f35 ]---

When soft offline successfully migrates page, the source page is supposed t=
o
be freed. But there is a race condition where a source page looks isolated
(i.e. the refcount is 0 and the PageHWPoison is set) but somewhat linked to
pcplist. Then another soft offline event calls drain_all_pages() and tries =
to
free such hwpoisoned page, which is forbidden.

This odd page state seems to happen due to the race between put_page() in
putback_lru_page() and __pagevec_lru_add_fn(). But I don't want to play wit=
h
tweaking drain code as done in commit 9ab3b598d2df "mm: hwpoison: drop
lru_add_drain_all() in __soft_offline_page()", or to change page freeing co=
de
for this soft offline's purpose.

Instead, let's think about the difference between hard offline and soft off=
line.
There is an interesting difference in how to isolate the in-use page betwee=
n
these, that is, hard offline marks PageHWPoison of the target page at first=
, and
doesn't free it by keeping its refcount 1. OTOH, soft offline tries to free
the target page then marks PageHWPoison. This difference might be the sourc=
e
of complexity and result in bugs like the above. So making soft offline iso=
late
with keeping refcount can be a solution for this problem.

We can pass to page migration code the "reason" which shows the caller, so
let's use this more to avoid calling putback_lru_page() when called from so=
ft
offline, which effectively does the isolation for soft offline. With this
change, target pages of soft offline never be reused without changing
migratetype, so this patch also removes the related code.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 22 ----------------------
 mm/migrate.c        |  9 ++++++---
 2 files changed, 6 insertions(+), 25 deletions(-)

diff --git v4.1-rc3.orig/mm/memory-failure.c v4.1-rc3/mm/memory-failure.c
index c9d788eed974..5e7795079c58 100644
--- v4.1-rc3.orig/mm/memory-failure.c
+++ v4.1-rc3/mm/memory-failure.c
@@ -1665,20 +1665,7 @@ static int __soft_offline_page(struct page *page, in=
t flags)
 			if (ret > 0)
 				ret =3D -EIO;
 		} else {
-			/*
-			 * After page migration succeeds, the source page can
-			 * be trapped in pagevec and actual freeing is delayed.
-			 * Freeing code works differently based on PG_hwpoison,
-			 * so there's a race. We need to make sure that the
-			 * source page should be freed back to buddy before
-			 * setting PG_hwpoison.
-			 */
-			if (!is_free_buddy_page(page))
-				drain_all_pages(page_zone(page));
 			SetPageHWPoison(page);
-			if (!is_free_buddy_page(page))
-				pr_info("soft offline: %#lx: page leaked\n",
-					pfn);
 			atomic_long_inc(&num_poisoned_pages);
 		}
 	} else {
@@ -1730,14 +1717,6 @@ int soft_offline_page(struct page *page, int flags)
=20
 	get_online_mems();
=20
-	/*
-	 * Isolate the page, so that it doesn't get reallocated if it
-	 * was free. This flag should be kept set until the source page
-	 * is freed and PG_hwpoison on it is set.
-	 */
-	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
-		set_migratetype_isolate(page, true);
-
 	ret =3D get_any_page(page, pfn, flags);
 	put_online_mems();
 	if (ret > 0) { /* for in-use pages */
@@ -1756,6 +1735,5 @@ int soft_offline_page(struct page *page, int flags)
 				atomic_long_inc(&num_poisoned_pages);
 		}
 	}
-	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
 	return ret;
 }
diff --git v4.1-rc3.orig/mm/migrate.c v4.1-rc3/mm/migrate.c
index f53838fe3dfe..d4fe1f94120b 100644
--- v4.1-rc3.orig/mm/migrate.c
+++ v4.1-rc3/mm/migrate.c
@@ -918,7 +918,8 @@ static int __unmap_and_move(struct page *page, struct p=
age *newpage,
 static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 				   free_page_t put_new_page,
 				   unsigned long private, struct page *page,
-				   int force, enum migrate_mode mode)
+				   int force, enum migrate_mode mode,
+				   enum migrate_reason reason)
 {
 	int rc =3D 0;
 	int *result =3D NULL;
@@ -949,7 +950,8 @@ static ICE_noinline int unmap_and_move(new_page_t get_n=
ew_page,
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		putback_lru_page(page);
+		if (reason !=3D MR_MEMORY_FAILURE)
+			putback_lru_page(page);
 	}
=20
 	/*
@@ -1122,7 +1124,8 @@ int migrate_pages(struct list_head *from, new_page_t =
get_new_page,
 						pass > 2, mode);
 			else
 				rc =3D unmap_and_move(get_new_page, put_new_page,
-						private, page, pass > 2, mode);
+						private, page, pass > 2, mode,
+						reason);
=20
 			switch(rc) {
 			case -ENOMEM:
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
