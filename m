Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D58C0800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 02:03:13 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a2so7917861pgn.7
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 23:03:13 -0800 (PST)
Received: from relay1.mentorg.com (relay1.mentorg.com. [192.94.38.131])
        by mx.google.com with ESMTPS id k27si15026113pfh.225.2018.01.21.23.03.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jan 2018 23:03:12 -0800 (PST)
Received: from nat-ies.mentorg.com ([192.94.31.2] helo=svr-ies-mbx-02.mgc.mentorg.com)
	by relay1.mentorg.com with esmtps (TLSv1.2:ECDHE-RSA-AES256-SHA384:256)
	id 1edW8O-0005tr-H8  
	for linux-mm@kvack.org; Sun, 21 Jan 2018 23:03:12 -0800
From: Balasubramani Vivekanandan <balasubramani_vivekanandan@mentor.com>
Subject: [PATCH] mm/slub.c: Fix wrong address during slab padding restoration
Date: Mon, 22 Jan 2018 12:32:58 +0530
Message-ID: <1516604578-4577-1-git-send-email-balasubramani_vivekanandan@mentor.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: balasubramani_vivekanandan@mentor.com

From: Balasubramani Vivekanandan <balasubramani_vivekanandan@mentor.com>

Start address calculated for slab padding restoration was wrong.
Wrong address would point to some section before padding and
could cause corruption

Signed-off-by: Balasubramani Vivekanandan <balasubramani_vivekanandan@mentor.com>
---
 mm/slub.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index cfd56e5..733ba32 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -838,6 +838,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 	u8 *start;
 	u8 *fault;
 	u8 *end;
+	u8 *pad;
 	int length;
 	int remainder;
 
@@ -851,8 +852,9 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 	if (!remainder)
 		return 1;
 
+	pad = end - remainder;
 	metadata_access_enable();
-	fault = memchr_inv(end - remainder, POISON_INUSE, remainder);
+	fault = memchr_inv(pad, POISON_INUSE, remainder);
 	metadata_access_disable();
 	if (!fault)
 		return 1;
@@ -860,9 +862,9 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 		end--;
 
 	slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, end - 1);
-	print_section(KERN_ERR, "Padding ", end - remainder, remainder);
+	print_section(KERN_ERR, "Padding ", pad, remainder);
 
-	restore_bytes(s, "slab padding", POISON_INUSE, end - remainder, end);
+	restore_bytes(s, "slab padding", POISON_INUSE, fault, end);
 	return 0;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
