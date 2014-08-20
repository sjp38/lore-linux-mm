Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3A75C6B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 11:04:57 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so12623539pad.10
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:04:56 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id fk8si21120758pdb.143.2014.08.20.08.04.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 20 Aug 2014 08:04:52 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAM006KF20I2K60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 20 Aug 2014 16:07:30 +0100 (BST)
Subject: [PATCH 1/7] mm/balloon_compaction: ignore anonymous pages
From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Date: Wed, 20 Aug 2014 19:04:35 +0400
Message-id: <20140820150435.4194.28003.stgit@buzz>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rafael Aquini <aquini@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

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
