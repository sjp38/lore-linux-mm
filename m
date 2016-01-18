Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 86AC46B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 04:55:09 -0500 (EST)
Received: by mail-io0-f180.google.com with SMTP id 1so497366534ion.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 01:55:09 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id k20si28381875iok.56.2016.01.18.01.55.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Jan 2016 01:55:08 -0800 (PST)
From: Junil Lee <junil0814.lee@lge.com>
Subject: [PATCH v4] zsmalloc: fix migrate_zspage-zs_free race condition
Date: Mon, 18 Jan 2016 18:55:03 +0900
Message-ID: <1453110903-11394-1-git-send-email-junil0814.lee@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, vbabka@suse.cz, Junil Lee <junil0814.lee@lge.com>

record_obj() in migrate_zspage() does not preserve handle's
HANDLE_PIN_BIT, set by find_aloced_obj()->trypin_tag(), and implicitly
(accidentally) un-pins the handle, while migrate_zspage() still performs
an explicit unpin_tag() on the that handle.
This additional explicit unpin_tag() introduces a race condition with
zs_free(), which can pin that handle by this time, so the handle becomes
un-pinned.

Schematically, it goes like this:

CPU0					CPU1
migrate_zspage
  find_alloced_obj
    trypin_tag
      set HANDLE_PIN_BIT			zs_free()
						  pin_tag()
  obj_malloc() -- new object, no tag
  record_obj() -- remove HANDLE_PIN_BIT	    set HANDLE_PIN_BIT
  unpin_tag()  -- remove zs_free's HANDLE_PIN_BIT

The race condition may result in a NULL pointer dereference:
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

Fix the race by removing explicit unpin_tag() from migrate_zspage().

Signed-off-by: Junil Lee <junil0814.lee@lge.com>
---
 mm/zsmalloc.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e7414ce..cb54ce3 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -307,9 +307,24 @@ static void free_handle(struct zs_pool *pool, unsigned long handle)
 	kmem_cache_free(pool->handle_cachep, (void *)handle);
 }
 
+
+/*
+ * record_obj updates handle's value to free_obj and it shouldn't
+ * invalidate lock bit(ie, HANDLE_PIN_BIT) of handle, otherwise
+ * it breaks synchronization using pin_tag(e,g, zs_free) so let's
+ * keep the lock bit.
+ */
 static void record_obj(unsigned long handle, unsigned long obj)
 {
-	*(unsigned long *)handle = obj;
+	int locked = (*(unsigned long *)handle) & (1 << HANDLE_PIN_BIT);
+	unsigned long val = obj | locked;
+
+	/*
+	 * WRITE_ONCE could prevent store tearing like below
+	 * *(unsigned long *)handle = free_obj
+	 * *(unsigned long *)handle |= locked;
+	 */
+	WRITE_ONCE(*(unsigned long *)handle, val);
 }
 
 /* zpool driver */
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
