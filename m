Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 90F516B0253
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 00:19:59 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so177758475pac.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 21:19:59 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id ca15si17493439pdb.31.2015.07.10.21.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jul 2015 21:19:58 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Sat, 11 Jul 2015 09:49:55 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 6A773394005E
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 09:49:52 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6B4Jqns11599974
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 09:49:52 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6B4JpXL020323
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 09:49:51 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] mm/memblock: WARN_ON when flags differs from overlap region
Date: Sat, 11 Jul 2015 12:19:36 +0800
Message-Id: <1436588376-25808-1-git-send-email-weiyang@linux.vnet.ibm.com>
In-Reply-To: <1436342488-19851-1-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1436342488-19851-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, akpm@linux-foundation.org, tj@kernel.org
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>

Each memblock_region has flags to indicates the Node ID of this range. For
the overlap case, memblock_add_range() inserts the lower part and leave the
upper part as indicated in the overlapped region.

If the flags of the new range differs from the overlapped region, the
information recorded is not correct.

This patch adds a WARN_ON when the flags of the new range differs from the
overlapped region.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
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
