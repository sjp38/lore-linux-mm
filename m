Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id A3FD36B0039
	for <linux-mm@kvack.org>; Sat, 30 Aug 2014 12:41:22 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id 10so4094167lbg.3
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:41:22 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id jj4si4785034lbc.39.2014.08.30.09.41.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 30 Aug 2014 09:41:21 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id v6so4009005lbi.37
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:41:20 -0700 (PDT)
Subject: [PATCH v2 1/6] mm/balloon_compaction: ignore anonymous pages
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 30 Aug 2014 20:41:09 +0400
Message-ID: <20140830164109.29066.46373.stgit@zurg>
In-Reply-To: <20140830163834.29066.98205.stgit@zurg>
References: <20140830163834.29066.98205.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>

Sasha Levin reported KASAN splash inside isolate_migratepages_range().
Problem is in function __is_movable_balloon_page() which tests AS_BALLOON_MAP
in page->mapping->flags. This function has no protection against anonymous
pages. As result it tried to check address space flags in inside anon-vma.

Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Link: http://lkml.kernel.org/p/53E6CEAA.9020105@oracle.com
Cc: stable <stable@vger.kernel.org> # v3.8
---
 include/linux/balloon_compaction.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 089743a..53d482e 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -128,7 +128,7 @@ static inline bool page_flags_cleared(struct page *page)
 static inline bool __is_movable_balloon_page(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
-	return mapping_balloon(mapping);
+	return !PageAnon(page) && mapping_balloon(mapping);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
