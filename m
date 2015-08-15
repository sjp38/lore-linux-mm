Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8786B6B0253
	for <linux-mm@kvack.org>; Sat, 15 Aug 2015 14:27:10 -0400 (EDT)
Received: by labd1 with SMTP id d1so59495995lab.1
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 11:27:09 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id 7si8404952lak.53.2015.08.15.11.27.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Aug 2015 11:27:08 -0700 (PDT)
Received: by lalv9 with SMTP id v9so59157716lal.0
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 11:27:07 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: check memblock_reserve on fail in memblock_virt_alloc_internal
Date: Sun, 16 Aug 2015 00:26:46 +0600
Message-Id: <1439663206-15484-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Robin Holt <holt@sgi.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

This patch adds a check for memblock_reserve() call in the
memblock_virt_alloc_internal() function, because memblock_reserve()
can return -errno on fail.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 87108e7..73427546 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1298,7 +1298,9 @@ again:
 
 	return NULL;
 done:
-	memblock_reserve(alloc, size);
+	if (memblock_reserve(alloc, size))
+		return NULL;
+
 	ptr = phys_to_virt(alloc);
 	memset(ptr, 0, size);
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
