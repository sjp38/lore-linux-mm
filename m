Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 01B4C6B0038
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 23:41:34 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e200so140212754oig.4
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 20:41:33 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 38si4132423otn.283.2016.10.12.20.41.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 20:41:33 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] z3fold: fix the potential encode bug in encod_handle
Date: Thu, 13 Oct 2016 11:33:05 +0800
Message-ID: <1476329585-15428-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vitalywool@gmail.com, david@fromorbit.com, sjenning@redhat.com, ddstreet@ieee.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

At present, zhdr->first_num plus bud can exceed the BUDDY_MASK
in encode_handle, it will lead to the the caller handle_to_buddy
return the error value.

The patch fix the issue by changing the BUDDY_MASK to PAGE_MASK,
it will be consistent with handle_to_z3fold_header. At the same time,
The code will much comprehensible to change the BUDDY_MASK to
BUDDIES_MAX in handle_to_buddy.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/z3fold.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 8f9e89c..5884b9e 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -169,7 +169,7 @@ static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
 
 	handle = (unsigned long)zhdr;
 	if (bud != HEADLESS)
-		handle += (bud + zhdr->first_num) & BUDDY_MASK;
+		handle += (bud + zhdr->first_num) & PAGE_MASK;
 	return handle;
 }
 
@@ -183,7 +183,7 @@ static struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
 static enum buddy handle_to_buddy(unsigned long handle)
 {
 	struct z3fold_header *zhdr = handle_to_z3fold_header(handle);
-	return (handle - zhdr->first_num) & BUDDY_MASK;
+	return (handle - zhdr->first_num) & BUDDIES_MAX;
 }
 
 /*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
