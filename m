Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DECF56B0279
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 23:18:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p1so155288404pfl.2
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 20:18:38 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 38si8173921pld.96.2017.07.16.20.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 20:18:37 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id a11so1700632pfj.3
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 20:18:37 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [PATCH] mm/hmm: Fix calcuation of start address for unaddressable memory
Date: Mon, 17 Jul 2017 12:22:23 +1000
Message-Id: <20170717022223.23603-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>

The code used iomem_resource.end which is an odd number and hence
the calculation then moves on to addr - size + 1. When the minimum
is (1ULL << MAX_PHYSMEM_BITS), the calculation of start is broken.
This patch changes the calculation so that addr is on the start
of a PA_SECTION_SIZE boundary

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 mm/hmm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 34e1325..cc6d25c 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1022,7 +1022,8 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 		goto error_devm_add_action;
 
 	size = ALIGN(size, PA_SECTION_SIZE);
-	addr = min((unsigned long)iomem_resource.end, 1UL << MAX_PHYSMEM_BITS);
+	addr = min((unsigned long)iomem_resource.end,
+					(1UL << MAX_PHYSMEM_BITS) - 1);
 	addr = addr - size + 1UL;
 
 	/*
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
