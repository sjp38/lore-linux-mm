Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id A6B1E6B0074
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 12:33:22 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id c11so818024lbj.31
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 09:33:22 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id p2si744097laf.135.2014.06.24.09.33.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jun 2014 09:33:20 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 3/3] page-cgroup: fix flags definition
Date: Tue, 24 Jun 2014 20:33:06 +0400
Message-ID: <aacc50fb60eeb9cbe14e07235310fb9295b2658b.1403626729.git.vdavydov@parallels.com>
In-Reply-To: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
References: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since commit a9ce315aaec1f ("mm: memcontrol: rewrite uncharge API"),
PCG_* flags are used as bit masks, but they are still defined in a enum
as bit numbers. Fix it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/page_cgroup.h |   12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index fb60e4a466c0..9065a61345a1 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -1,12 +1,10 @@
 #ifndef __LINUX_PAGE_CGROUP_H
 #define __LINUX_PAGE_CGROUP_H
 
-enum {
-	/* flags for mem_cgroup */
-	PCG_USED,	/* This page is charged to a memcg */
-	PCG_MEM,	/* This page holds a memory charge */
-	PCG_MEMSW,	/* This page holds a memory+swap charge */
-};
+/* flags for mem_cgroup */
+#define PCG_USED	0x01	/* This page is charged to a memcg */
+#define PCG_MEM		0x02	/* This page holds a memory charge */
+#define PCG_MEMSW	0x04	/* This page holds a memory+swap charge */
 
 struct pglist_data;
 
@@ -44,7 +42,7 @@ struct page *lookup_cgroup_page(struct page_cgroup *pc);
 
 static inline int PageCgroupUsed(struct page_cgroup *pc)
 {
-	return test_bit(PCG_USED, &pc->flags);
+	return !!(pc->flags & PCG_USED);
 }
 #else /* !CONFIG_MEMCG */
 struct page_cgroup;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
