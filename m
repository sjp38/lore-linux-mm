Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 89B19828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 02:39:23 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id mw1so5551209igb.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 23:39:23 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id rs3si3023679igb.23.2016.01.14.23.39.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 23:39:22 -0800 (PST)
From: Junil Lee <junil0814.lee@lge.com>
Subject: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
Date: Fri, 15 Jan 2016 16:39:11 +0900
Message-ID: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Junil Lee <junil0814.lee@lge.com>

To prevent unlock at the not correct situation, tagging the new obj to
assure lock in migrate_zspage() before right unlock path.

Two functions are in race condition by tag which set 1 on last bit of
obj, however unlock succrently when update new obj to handle before call
unpin_tag() which is right unlock path.

summarize this problem by call flow as below:

		CPU0								CPU1
migrate_zspage
find_alloced_obj()
	trypin_tag() -- obj |= HANDLE_PIN_BIT
obj_malloc() -- new obj is not set			zs_free
record_obj() -- unlock and break sync		pin_tag() -- get lock
unpin_tag()

Before code make crash as below:
	Unable to handle kernel NULL pointer dereference at virtual address 00000000
	CPU: 0 PID: 19001 Comm: CookieMonsterCl Tainted:
	PC is at get_zspage_mapping+0x0/0x24
	LR is at obj_free.isra.22+0x64/0x128
	Call trace:
		[<ffffffc0001a3aa8>] get_zspage_mapping+0x0/0x24
		[<ffffffc0001a4918>] zs_free+0x88/0x114
		[<ffffffc00053ae54>] zram_free_page+0x64/0xcc
		[<ffffffc00053af4c>] zram_slot_free_notify+0x90/0x108
		[<ffffffc000196638>] swap_entry_free+0x278/0x294
		[<ffffffc000199008>] free_swap_and_cache+0x38/0x11c
		[<ffffffc0001837ac>] unmap_single_vma+0x480/0x5c8
		[<ffffffc000184350>] unmap_vmas+0x44/0x60
		[<ffffffc00018a53c>] exit_mmap+0x50/0x110
		[<ffffffc00009e408>] mmput+0x58/0xe0
		[<ffffffc0000a2854>] do_exit+0x320/0x8dc
		[<ffffffc0000a3cb4>] do_group_exit+0x44/0xa8
		[<ffffffc0000ae1bc>] get_signal+0x538/0x580
		[<ffffffc000087e44>] do_signal+0x98/0x4b8
		[<ffffffc00008843c>] do_notify_resume+0x14/0x5c

and for test, print obj value after pin_tag() in zs_free().
Sometimes obj is even number means break synchronization.

After patched, crash is not occurred and obj is only odd number in same
situation.

Signed-off-by: Junil Lee <junil0814.lee@lge.com>
---
 mm/zsmalloc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e7414ce..a24ccb1 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1635,6 +1635,8 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		free_obj = obj_malloc(d_page, class, handle);
 		zs_object_copy(free_obj, used_obj, class);
 		index++;
+		/* Must not unlock before unpin_tag() */
+		free_obj |= BIT(HANDLE_PIN_BIT);
 		record_obj(handle, free_obj);
 		unpin_tag(handle);
 		obj_free(pool, class, used_obj);
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
