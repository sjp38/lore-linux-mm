Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5C6776B0083
	for <linux-mm@kvack.org>; Thu, 24 May 2012 04:32:58 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M4I000UAQDVVKJ0@mailout1.samsung.com> for
 linux-mm@kvack.org; Thu, 24 May 2012 17:32:56 +0900 (KST)
Received: from DOPULLIPCHO05 ([12.23.118.196])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M4I007QPQEWMHQ1@mmp1.samsung.com> for linux-mm@kvack.org;
 Thu, 24 May 2012 17:32:56 +0900 (KST)
From: KyongHo <pullip.cho@samsung.com>
Subject: mm: fix faulty initialization in vmalloc_init()
Date: Thu, 24 May 2012 17:32:56 +0900
Message-id: <001c01cd3987$d1a71a50$74f54ef0$%cho@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org

vmalloc_init() adds 'vmap_area's for early 'vm_struct's.
This patch fixes vmalloc_init() to correctly initialize
vmap_area for the given vm_struct.

Signed-off-by: KyongHo Cho <pullip.cho@samsung.com>
---
 mm/vmalloc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 94dff88..1196c77 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1185,9 +1185,10 @@ void __init vmalloc_init(void)
 	/* Import existing vmlist entries. */
 	for (tmp = vmlist; tmp; tmp = tmp->next) {
 		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
-		va->flags = tmp->flags | VM_VM_AREA;
+		va->flags = VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
+		va->vm = tmp;
 		__insert_vmap_area(va);
 	}
 
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
