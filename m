Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE4C76B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 18:06:20 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id t184so142912839pgt.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 15:06:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h12si11813221plk.250.2017.03.03.15.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 15:06:20 -0800 (PST)
Date: Fri, 3 Mar 2017 15:06:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: use is_migrate_highatomic() to simplify the
 code
Message-Id: <20170303150619.4011826c7e645c0725efd6ae@linux-foundation.org>
In-Reply-To: <20170303131808.GH31499@dhcp22.suse.cz>
References: <58B94F15.6060606@huawei.com>
	<20170303131808.GH31499@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 3 Mar 2017 14:18:08 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 03-03-17 19:10:13, Xishi Qiu wrote:
> > Introduce two helpers, is_migrate_highatomic() and is_migrate_highatomic_page().
> > Simplify the code, no functional changes.
> 
> static inline helpers would be nicer than macros

Always.

We made a big dependency mess in mmzone.h.  internal.h works.

--- a/include/linux/mmzone.h~mm-use-is_migrate_highatomic-to-simplify-the-code-fix
+++ a/include/linux/mmzone.h
@@ -35,7 +35,7 @@
  */
 #define PAGE_ALLOC_COSTLY_ORDER 3
 
-enum {
+enum migratetype {
 	MIGRATE_UNMOVABLE,
 	MIGRATE_MOVABLE,
 	MIGRATE_RECLAIMABLE,
@@ -66,11 +66,6 @@ enum {
 /* In mm/page_alloc.c; keep in sync also with show_migration_types() there */
 extern char * const migratetype_names[MIGRATE_TYPES];
 
-#define is_migrate_highatomic(migratetype)				\
-	(migratetype == MIGRATE_HIGHATOMIC)
-#define is_migrate_highatomic_page(_page)				\
-	(get_pageblock_migratetype(_page) == MIGRATE_HIGHATOMIC)
-
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
 #  define is_migrate_cma_page(_page) (get_pageblock_migratetype(_page) == MIGRATE_CMA)
diff -puN mm/page_alloc.c~mm-use-is_migrate_highatomic-to-simplify-the-code-fix mm/page_alloc.c
diff -puN mm/internal.h~mm-use-is_migrate_highatomic-to-simplify-the-code-fix mm/internal.h
--- a/mm/internal.h~mm-use-is_migrate_highatomic-to-simplify-the-code-fix
+++ a/mm/internal.h
@@ -503,4 +503,14 @@ extern const struct trace_print_flags pa
 extern const struct trace_print_flags vmaflag_names[];
 extern const struct trace_print_flags gfpflag_names[];
 
+static inline bool is_migrate_highatomic(enum migratetype migratetype)
+{
+	return migratetype == MIGRATE_HIGHATOMIC;
+}
+
+static inline bool is_migrate_highatomic_page(struct page *page)
+{
+	return get_pageblock_migratetype(page) == MIGRATE_HIGHATOMIC;
+}
+
 #endif	/* __MM_INTERNAL_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
