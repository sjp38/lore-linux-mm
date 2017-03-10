Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA253280909
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 23:38:02 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 190so69150179pgg.3
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 20:38:02 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id o1si1764982pgn.177.2017.03.09.20.38.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 20:38:02 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id b5so8958708pgg.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 20:38:01 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/sparse: refine usemap_size() a little
Date: Fri, 10 Mar 2017 12:37:13 +0800
Message-Id: <20170310043713.96871-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

Current implementation calculates usemap_size in two steps:
    * calculate number of bytes to cover these bits
    * calculate number of "unsigned long" to cover these bytes

It would be more clear by:
    * calculate number of "unsigned long" to cover these bits
    * multiple it with sizeof(unsigned long)

This patch refine usemap_size() a little to make it more easy to
understand.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/sparse.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index a0792526adfa..faa36ef9f9bd 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -249,10 +249,7 @@ static int __meminit sparse_init_one_section(struct mem_section *ms,
 
 unsigned long usemap_size(void)
 {
-	unsigned long size_bytes;
-	size_bytes = roundup(SECTION_BLOCKFLAGS_BITS, 8) / 8;
-	size_bytes = roundup(size_bytes, sizeof(unsigned long));
-	return size_bytes;
+	return BITS_TO_LONGS(SECTION_BLOCKFLAGS_BITS) * sizeof(unsigned long);
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
