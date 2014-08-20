Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4890C6B0038
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 11:05:04 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so12203882pab.33
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:05:01 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id fk8si21120758pdb.143.2014.08.20.08.04.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 20 Aug 2014 08:04:57 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAM006KJ20T2560@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 20 Aug 2014 16:07:41 +0100 (BST)
Subject: [PATCH 3/7] mm/balloon_compaction: isolate balloon pages without
 lru_lock
From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Date: Wed, 20 Aug 2014 19:04:46 +0400
Message-id: <20140820150446.4194.5716.stgit@buzz>
In-reply-to: <20140820150435.4194.28003.stgit@buzz>
References: <20140820150435.4194.28003.stgit@buzz>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rafael Aquini <aquini@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

LRU-lock isn't required for balloon page isolation. This check makes migration
of some ballooned pages mostly impossible because isolate_migratepages_range()
drops LRU lock periodically.

Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: stable <stable@vger.kernel.org> # v3.8
---
 mm/compaction.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 21bf292..0653f5f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -597,7 +597,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
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
