Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8694D6B0037
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 11:05:02 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so12418787pad.23
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:05:02 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id zh3si3795346pbc.157.2014.08.20.08.04.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 20 Aug 2014 08:04:58 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAM0059P1VOXQ30@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 20 Aug 2014 16:04:36 +0100 (BST)
Subject: [PATCH 2/7] mm/balloon_compaction: keep ballooned pages away from
 normal migration path
From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Date: Wed, 20 Aug 2014 19:04:40 +0400
Message-id: <20140820150440.4194.70267.stgit@buzz>
In-reply-to: <20140820150435.4194.28003.stgit@buzz>
References: <20140820150435.4194.28003.stgit@buzz>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rafael Aquini <aquini@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

Proper testing shows yet another problem in balloon migration: it works only
once for each page. balloon_page_movable() check page flags and page_count.
In __unmap_and_move page is locked, reference counter is elevated, so
balloon_page_movable() _always_ fails here. As result in __unmap_and_move()
migration goes to the normal migration path.

Balloon ->migratepage() is so special, it returns MIGRATEPAGE_BALLOON_SUCCESS
instead of MIGRATEPAGE_SUCCESS. After that in move_to_new_page() successfully
migrated page got NULL into its mapping pointer and loses connectivity with
balloon and ability for further migration.

It's safe to use __is_movable_balloon_page here: page is isolated and pinned.

Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: stable <stable@vger.kernel.org> # v3.8
---
 mm/migrate.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index f78ec9b..161d044 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -873,7 +873,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
-	if (unlikely(balloon_page_movable(page))) {
+	if (unlikely(__is_movable_balloon_page(page))) {
 		/*
 		 * A ballooned page does not need any special attention from
 		 * physical to virtual reverse mapping procedures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
