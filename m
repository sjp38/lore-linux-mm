Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4940B6B003B
	for <linux-mm@kvack.org>; Sat, 30 Aug 2014 12:41:29 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id z11so4067379lbi.36
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:41:28 -0700 (PDT)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id o7si4749228lbi.59.2014.08.30.09.41.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 30 Aug 2014 09:41:27 -0700 (PDT)
Received: by mail-lb0-f171.google.com with SMTP id n15so3984753lbi.2
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:41:27 -0700 (PDT)
Subject: [PATCH v2 3/6] mm/balloon_compaction: isolate balloon pages without
 lru_lock
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 30 Aug 2014 20:41:17 +0400
Message-ID: <20140830164117.29066.18189.stgit@zurg>
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

LRU-lock isn't required for balloon page isolation. This check makes migration
of some ballooned pages mostly impossible because isolate_migratepages_range()
drops LRU lock periodically.

Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: stable <stable@vger.kernel.org> # v3.8
---
 mm/compaction.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 73466e1..ad58f73 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -643,7 +643,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		if (!PageLRU(page)) {
 			if (unlikely(balloon_page_movable(page))) {
-				if (locked && balloon_page_isolate(page)) {
+				if (balloon_page_isolate(page)) {
 					/* Successfully isolated */
 					goto isolate_success;
 				}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
