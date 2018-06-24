Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3D786B0010
	for <linux-mm@kvack.org>; Sun, 24 Jun 2018 17:33:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q8-v6so3244167wmc.2
        for <linux-mm@kvack.org>; Sun, 24 Jun 2018 14:33:26 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id p196-v6si1843825wmg.96.2018.06.24.14.33.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 24 Jun 2018 14:33:25 -0700 (PDT)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mm/zsmalloc: make several functions and a struct static
Date: Sun, 24 Jun 2018 22:33:22 +0100
Message-Id: <20180624213322.13776-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The functions zs_page_isolate, zs_page_migrate, zs_page_putback,
lock_zspage, trylock_zspage and structure zsmalloc_aops are local to
source and do not need to be in global scope, so make them static.

Cleans up sparse warnings:
symbol 'zs_page_isolate' was not declared. Should it be static?
symbol 'zs_page_migrate' was not declared. Should it be static?
symbol 'zs_page_putback' was not declared. Should it be static?
symbol 'zsmalloc_aops' was not declared. Should it be static?
symbol 'lock_zspage' was not declared. Should it be static?
symbol 'trylock_zspage' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/zsmalloc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index a1a9debb6fc8..900bea99452a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -928,7 +928,7 @@ static void reset_page(struct page *page)
  * To prevent zspage destroy during migration, zspage freeing should
  * hold locks of all pages in the zspage.
  */
-void lock_zspage(struct zspage *zspage)
+static void lock_zspage(struct zspage *zspage)
 {
 	struct page *page = get_first_page(zspage);
 
@@ -937,7 +937,7 @@ void lock_zspage(struct zspage *zspage)
 	} while ((page = get_next_page(page)) != NULL);
 }
 
-int trylock_zspage(struct zspage *zspage)
+static int trylock_zspage(struct zspage *zspage)
 {
 	struct page *cursor, *fail;
 
@@ -1906,7 +1906,7 @@ static void replace_sub_page(struct size_class *class, struct zspage *zspage,
 	__SetPageMovable(newpage, page_mapping(oldpage));
 }
 
-bool zs_page_isolate(struct page *page, isolate_mode_t mode)
+static bool zs_page_isolate(struct page *page, isolate_mode_t mode)
 {
 	struct zs_pool *pool;
 	struct size_class *class;
@@ -1961,7 +1961,7 @@ bool zs_page_isolate(struct page *page, isolate_mode_t mode)
 	return true;
 }
 
-int zs_page_migrate(struct address_space *mapping, struct page *newpage,
+static int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 		struct page *page, enum migrate_mode mode)
 {
 	struct zs_pool *pool;
@@ -2077,7 +2077,7 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	return ret;
 }
 
-void zs_page_putback(struct page *page)
+static void zs_page_putback(struct page *page)
 {
 	struct zs_pool *pool;
 	struct size_class *class;
@@ -2109,7 +2109,7 @@ void zs_page_putback(struct page *page)
 	spin_unlock(&class->lock);
 }
 
-const struct address_space_operations zsmalloc_aops = {
+static const struct address_space_operations zsmalloc_aops = {
 	.isolate_page = zs_page_isolate,
 	.migratepage = zs_page_migrate,
 	.putback_page = zs_page_putback,
-- 
2.17.0
