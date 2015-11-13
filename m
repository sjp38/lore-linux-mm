Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8F26B0256
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 19:44:35 -0500 (EST)
Received: by padhx2 with SMTP id hx2so81341272pad.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 16:44:35 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id z4si23297262par.49.2015.11.12.16.44.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 16:44:34 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so81208604pac.3
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 16:44:34 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: fix mapcount mismatch in hugepage migration
Date: Fri, 13 Nov 2015 09:44:29 +0900
Message-Id: <1447375469-9298-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

try_to_unmap_one() should be able to handle hugetlb, but page_remove_rmap()
in that function takes false as a compound flag, which breaks hugepage migration
with the following message.

  Soft offlining page 0x1d4a00 at 0x7ff634a00000
  soft offline: 0x1d4a00: migration failed 1, type 60000000000401c
  BUG: Bad page state in process sysctl  pfn:1d4a00
  page:ffffea0007528000 count:0 mapcount:0 mapping:          (null) index:0x0 compound_mapcount: 10
  flags: 0x600000000004008(uptodate|head)
  page dumped because: nonzero mapcount
  Modules linked in: cfg80211 rfkill crc32c_intel virtio_balloon serio_raw i2c_piix4 virtio_blk virtio_net ata_generic pata_acpi
  CPU: 3 PID: 11882 Comm: sysctl Tainted: G        W       4.3.0-mmotm-2015-11-10-15-53-151112-1812-00015-53+ #240
  Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
   ffffffff81a1a124 ffff8800da047bd0 ffffffff81340adf ffffea0007528000
   ffff8800da047bf8 ffffffff8116e206 0000000000000009 ffffffff81f72538
   ffffea0007528000 ffff8800da047c48 ffffffff8116e6d6 0000020000000000
  Call Trace:
   [<ffffffff81340adf>] dump_stack+0x44/0x55
   [<ffffffff8116e206>] bad_page+0xc6/0x110
   [<ffffffff8116e6d6>] free_pages_prepare+0x486/0x500
   [<ffffffff81170f9a>] __free_pages_ok+0x1a/0xb0
   [<ffffffff81171af1>] __free_pages+0x21/0x40
   [<ffffffff811b5d79>] update_and_free_page+0xa9/0x230
   [<ffffffff811b6641>] free_pool_huge_page+0xc1/0xe0
   [<ffffffff811b6d02>] set_max_huge_pages+0x382/0x4d0
   [<ffffffff811b7002>] hugetlb_sysctl_handler_common+0xa2/0xd0
   [<ffffffff811b823e>] hugetlb_sysctl_handler+0x1e/0x20
   [<ffffffff812535fe>] proc_sys_call_handler+0xae/0xc0
   [<ffffffff81253624>] proc_sys_write+0x14/0x20
   [<ffffffff811e8758>] __vfs_write+0x28/0xe0
   [<ffffffff810d1864>] ? percpu_down_read+0x14/0x60
   [<ffffffff811e8d29>] vfs_write+0xa9/0x190
   [<ffffffff811e9646>] SyS_write+0x46/0xb0
   [<ffffffff8163d797>] entry_SYSCALL_64_fastpath+0x12/0x6a

This patch simply fixes this by giving the compound flag via PageHuge.
---
# This patch is against mmotm-2015-11-10-15-53 as a fix for "rmap: add argument
# to charge compound page".

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/rmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git mmotm-2015-11-10-15-53/mm/rmap.c mmotm-2015-11-10-15-53_patched/mm/rmap.c
index e90b81f..e045fea 100644
--- mmotm-2015-11-10-15-53/mm/rmap.c
+++ mmotm-2015-11-10-15-53_patched/mm/rmap.c
@@ -1508,7 +1508,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	} else
 		dec_mm_counter(mm, MM_FILEPAGES);
 
-	page_remove_rmap(page, false);
+	page_remove_rmap(page, PageHuge(page));
 	page_cache_release(page);
 
 out_unmap:
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
