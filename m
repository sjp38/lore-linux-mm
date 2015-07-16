Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4DF2802E6
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 22:34:22 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so35336892pdr.2
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:34:21 -0700 (PDT)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id we5si10427385pac.177.2015.07.15.19.34.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Jul 2015 19:34:21 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Thu, 16 Jul 2015 08:04:17 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 778141258044
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 08:07:08 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6G2YCem45809904
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 08:04:12 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6G1HP6x022697
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 06:47:25 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH V2] mm/memblock: WARN_ON when flags differs from overlap region
Date: Thu, 16 Jul 2015 10:34:09 +0800
Message-Id: <1437014050-15891-1-git-send-email-weiyang@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.10.1507151719230.9230@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1507151719230.9230@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, akpm@linux-foundation.org, tj@kernel.org
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>

Each memblock_region has flags to indicates the type of this range. For
the overlap case, memblock_add_range() inserts the lower part and leave the
upper part as indicated in the overlapped region.

If the flags of the new range differs from the overlapped region, the
information recorded is not correct.

This patch adds a WARN_ON when the flags of the new range differs from the
overlapped region.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

---
v2:
    * change the commit log to be more accurate.
---
 mm/memblock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index 95ce68c..bde61e8 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -569,6 +569,7 @@ repeat:
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 			WARN_ON(nid != memblock_get_region_node(rgn));
 #endif
+			WARN_ON(flags != rgn->flags);
 			nr_new++;
 			if (insert)
 				memblock_insert_region(type, i++, base,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
