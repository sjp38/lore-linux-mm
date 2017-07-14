Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47C9C4408E5
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 03:53:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v26so80356096pfa.0
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 00:53:33 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.124])
        by mx.google.com with ESMTPS id c76si5967676pfl.274.2017.07.14.00.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 00:53:32 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH] zsmalloc: zs_page_migrate: not check inuse if migrate_mode is not MIGRATE_ASYNC
Date: Fri, 14 Jul 2017 15:51:07 +0800
Message-ID: <1500018667-30175-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

Got some -EBUSY from zs_page_migrate that will make migration
slow (retry) or fail (zs_page_putback will schedule_work free_work,
but it cannot ensure the success).

And I didn't find anything that make zs_page_migrate cannot work with
a ZS_EMPTY zspage.
So make the patch to not check inuse if migrate_mode is not
MIGRATE_ASYNC.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 66 +++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 37 insertions(+), 29 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index d41edd2..c298e5c 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1982,6 +1982,7 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	unsigned long old_obj, new_obj;
 	unsigned int obj_idx;
 	int ret = -EAGAIN;
+	int inuse;
 
 	VM_BUG_ON_PAGE(!PageMovable(page), page);
 	VM_BUG_ON_PAGE(!PageIsolated(page), page);
@@ -1996,21 +1997,24 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	offset = get_first_obj_offset(page);
 
 	spin_lock(&class->lock);
-	if (!get_zspage_inuse(zspage)) {
+	inuse = get_zspage_inuse(zspage);
+	if (mode == MIGRATE_ASYNC && !inuse) {
 		ret = -EBUSY;
 		goto unlock_class;
 	}
 
 	pos = offset;
 	s_addr = kmap_atomic(page);
-	while (pos < PAGE_SIZE) {
-		head = obj_to_head(page, s_addr + pos);
-		if (head & OBJ_ALLOCATED_TAG) {
-			handle = head & ~OBJ_ALLOCATED_TAG;
-			if (!trypin_tag(handle))
-				goto unpin_objects;
+	if (inuse) {
+		while (pos < PAGE_SIZE) {
+			head = obj_to_head(page, s_addr + pos);
+			if (head & OBJ_ALLOCATED_TAG) {
+				handle = head & ~OBJ_ALLOCATED_TAG;
+				if (!trypin_tag(handle))
+					goto unpin_objects;
+			}
+			pos += class->size;
 		}
-		pos += class->size;
 	}
 
 	/*
@@ -2020,20 +2024,22 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	memcpy(d_addr, s_addr, PAGE_SIZE);
 	kunmap_atomic(d_addr);
 
-	for (addr = s_addr + offset; addr < s_addr + pos;
-					addr += class->size) {
-		head = obj_to_head(page, addr);
-		if (head & OBJ_ALLOCATED_TAG) {
-			handle = head & ~OBJ_ALLOCATED_TAG;
-			if (!testpin_tag(handle))
-				BUG();
-
-			old_obj = handle_to_obj(handle);
-			obj_to_location(old_obj, &dummy, &obj_idx);
-			new_obj = (unsigned long)location_to_obj(newpage,
-								obj_idx);
-			new_obj |= BIT(HANDLE_PIN_BIT);
-			record_obj(handle, new_obj);
+	if (inuse) {
+		for (addr = s_addr + offset; addr < s_addr + pos;
+						addr += class->size) {
+			head = obj_to_head(page, addr);
+			if (head & OBJ_ALLOCATED_TAG) {
+				handle = head & ~OBJ_ALLOCATED_TAG;
+				if (!testpin_tag(handle))
+					BUG();
+
+				old_obj = handle_to_obj(handle);
+				obj_to_location(old_obj, &dummy, &obj_idx);
+				new_obj = (unsigned long)
+					location_to_obj(newpage, obj_idx);
+				new_obj |= BIT(HANDLE_PIN_BIT);
+				record_obj(handle, new_obj);
+			}
 		}
 	}
 
@@ -2055,14 +2061,16 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 
 	ret = MIGRATEPAGE_SUCCESS;
 unpin_objects:
-	for (addr = s_addr + offset; addr < s_addr + pos;
+	if (inuse) {
+		for (addr = s_addr + offset; addr < s_addr + pos;
 						addr += class->size) {
-		head = obj_to_head(page, addr);
-		if (head & OBJ_ALLOCATED_TAG) {
-			handle = head & ~OBJ_ALLOCATED_TAG;
-			if (!testpin_tag(handle))
-				BUG();
-			unpin_tag(handle);
+			head = obj_to_head(page, addr);
+			if (head & OBJ_ALLOCATED_TAG) {
+				handle = head & ~OBJ_ALLOCATED_TAG;
+				if (!testpin_tag(handle))
+					BUG();
+				unpin_tag(handle);
+			}
 		}
 	}
 	kunmap_atomic(s_addr);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
