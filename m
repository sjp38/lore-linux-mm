Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5B07082F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 10:27:25 -0500 (EST)
Received: by igbhv6 with SMTP id hv6so14700845igb.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 07:27:25 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id t100si21063684ioe.171.2015.11.03.07.27.24
        for <linux-mm@kvack.org>;
        Tue, 03 Nov 2015 07:27:24 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/4] mm: do not crash on PageDoubleMap() for non-head pages
Date: Tue,  3 Nov 2015 17:26:12 +0200
Message-Id: <1446564375-72143-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We usually don't call PageDoubleMap() on small or tail pages, but during
read from /proc/kpageflags we don't protect the page from being freed under
us and it can lead to VM_BUG_ON_PAGE() in PageDoubleMap():

 page:ffffea00033e0000 count:0 mapcount:0 mapping:          (null) index:0x700000200
 flags: 0x4000000000000000()
 page dumped because: VM_BUG_ON_PAGE(!PageHead(page))
 page->mem_cgroup:ffff88021588cc00
 ------------[ cut here ]------------
 kernel BUG at /src/linux-dev/include/linux/page-flags.h:552!
 invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
 Modules linked in: cfg80211 rfkill crc32c_intel virtio_balloon serio_raw i2c_piix4 virtio_blk virtio_net ata_generic pata_acpi
 CPU: 0 PID: 1183 Comm: page-types Not tainted 4.2.0-mmotm-2015-10-21-14-41-151027-1418-00014-41+ #179
 Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 task: ffff880214a08bc0 ti: ffff880213e2c000 task.ti: ffff880213e2c000
 RIP: 0010:[<ffffffff812434b6>]  [<ffffffff812434b6>] stable_page_flags+0x336/0x340
 RSP: 0018:ffff880213e2fda8  EFLAGS: 00010292
 RAX: 0000000000000021 RBX: ffff8802150a39c0 RCX: 0000000000000000
 RDX: ffff88021ec0ff38 RSI: ffff88021ec0d658 RDI: ffff88021ec0d658
 RBP: ffff880213e2fdc8 R08: 000000000000000a R09: 000000000000132f
 R10: 0000000000000000 R11: 000000000000132f R12: 4000000000000000
 R13: ffffea00033e6340 R14: 00007fff8449e430 R15: ffffea00033e6340
 FS:  00007ff7f9525700(0000) GS:ffff88021ec00000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 000000000063b800 CR3: 00000000d9e71000 CR4: 00000000000006f0
 Stack:
  ffff8800db82df80 ffff8802150a39c0 0000000000000008 00000000000cf98d
  ffff880213e2fe18 ffffffff81243588 00007fff8449e430 ffff880213e2ff20
  000000000063b800 ffff8802150a39c0 fffffffffffffffb ffff880213e2ff20
 Call Trace:
  [<ffffffff81243588>] kpageflags_read+0xc8/0x130
  [<ffffffff81235848>] proc_reg_read+0x48/0x70
  [<ffffffff811d6b08>] __vfs_read+0x28/0xd0
  [<ffffffff812ee43e>] ? security_file_permission+0xae/0xc0
  [<ffffffff811d6f53>] ? rw_verify_area+0x53/0xf0
  [<ffffffff811d707a>] vfs_read+0x8a/0x130
  [<ffffffff811d7bf7>] SyS_pread64+0x77/0x90
  [<ffffffff81648117>] entry_SYSCALL_64_fastpath+0x12/0x6a
 Code: ca 00 00 40 01 48 39 c1 48 0f 44 da e9 a2 fd ff ff 48 c7 c6 50 a6 a1 8 1 e8 58 ab f4 ff 0f 0b 48 c7 c6 90 a2 a1 81 e8 4a ab f4 ff <0f> 0b 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 41 57
 RIP  [<ffffffff812434b6>] stable_page_flags+0x336/0x340
  RSP <ffff880213e2fda8>
 ---[ end trace e5d18553088c026a ]---

Let's drop the VM_BUG_ON_PAGE() from PageDoubleMap() and return false for
non-head pages.

The patch can be folded into
	"mm: rework mapcount accounting to enable 4k mapping of THPs"

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/page-flags.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 72356fbc3f2d..26cc7a068126 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -549,8 +549,7 @@ static inline int PageTransTail(struct page *page)
  */
 static inline int PageDoubleMap(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHead(page), page);
-	return test_bit(PG_double_map, &page[1].flags);
+	return PageHead(page) && test_bit(PG_double_map, &page[1].flags);
 }
 
 static inline int TestSetPageDoubleMap(struct page *page)
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
