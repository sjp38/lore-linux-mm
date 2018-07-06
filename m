Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F82B6B000A
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 09:14:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o1-v6so6939391wmc.6
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 06:14:38 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id 52-v6si8100234wrb.354.2018.07.06.06.14.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 06:14:37 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] zmalloc: hide unused lock_zspage
Date: Fri,  6 Jul 2018 15:09:02 +0200
Message-Id: <20180706130924.3891230-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Colin Ian King <colin.king@canonical.com>, Arnd Bergmann <arnd@arndb.de>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Desaulniers <nick.desaulniers@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Making lock_zspage() static revealed that it is unused in some confiurations:

mm/zsmalloc.c:931:13: error: 'lock_zspage' defined but not used [-Werror=unused-function]

I considered moving it into the same #ifdef that hides its user, but
it seems better to keep it close to trylock_zspage() etc, so this
marks it __maybe_unused() to let the compiler drop it without warning
about it.

Fixes: 0de664ada6b6 ("mm/zsmalloc.c: make several functions and a struct static")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/zsmalloc.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 900bea99452a..58886d40786b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -924,19 +924,6 @@ static void reset_page(struct page *page)
 	page->freelist = NULL;
 }
 
-/*
- * To prevent zspage destroy during migration, zspage freeing should
- * hold locks of all pages in the zspage.
- */
-static void lock_zspage(struct zspage *zspage)
-{
-	struct page *page = get_first_page(zspage);
-
-	do {
-		lock_page(page);
-	} while ((page = get_next_page(page)) != NULL);
-}
-
 static int trylock_zspage(struct zspage *zspage)
 {
 	struct page *cursor, *fail;
@@ -1814,6 +1801,19 @@ static enum fullness_group putback_zspage(struct size_class *class,
 }
 
 #ifdef CONFIG_COMPACTION
+/*
+ * To prevent zspage destroy during migration, zspage freeing should
+ * hold locks of all pages in the zspage.
+ */
+static void lock_zspage(struct zspage *zspage)
+{
+	struct page *page = get_first_page(zspage);
+
+	do {
+		lock_page(page);
+	} while ((page = get_next_page(page)) != NULL);
+}
+
 static struct dentry *zs_mount(struct file_system_type *fs_type,
 			       int flags, const char *dev_name,
 			       void *data, size_t data_size)
-- 
2.9.0
