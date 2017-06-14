Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2870E6B02C3
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 01:46:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a82so93911372pfc.8
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 22:46:12 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id m23si225151pli.191.2017.06.13.22.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 22:46:11 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id w12so15077397pfk.0
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 22:46:11 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RESEND PATCH] base/memory: pass the base_section in add_memory_block
Date: Wed, 14 Jun 2017 13:45:50 +0800
Message-Id: <20170614054550.14469-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Based on Greg's comment, cc it to mm list.
The original thread could be found https://lkml.org/lkml/2017/6/7/202

The second parameter of init_memory_block() is used to calculate the
start_section_nr of this block, which means any section in the same block
would get the same start_section_nr.

This patch passes the base_section to init_memory_block(), so that to
reduce a local variable and a check in every loop.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 drivers/base/memory.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index cc4f1d0cbffe..1e903aba2aa1 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -664,21 +664,20 @@ static int init_memory_block(struct memory_block **memory,
 static int add_memory_block(int base_section_nr)
 {
 	struct memory_block *mem;
-	int i, ret, section_count = 0, section_nr;
+	int i, ret, section_count = 0;
 
 	for (i = base_section_nr;
 	     (i < base_section_nr + sections_per_block) && i < NR_MEM_SECTIONS;
 	     i++) {
 		if (!present_section_nr(i))
 			continue;
-		if (section_count == 0)
-			section_nr = i;
 		section_count++;
 	}
 
 	if (section_count == 0)
 		return 0;
-	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
+	ret = init_memory_block(&mem, __nr_to_section(base_section_nr),
+				MEM_ONLINE);
 	if (ret)
 		return ret;
 	mem->section_count = section_count;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
