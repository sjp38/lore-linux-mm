Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 54D836B00B1
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 11:45:43 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id fp1so10087262pdb.29
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:45:43 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id e2si22184606pdd.207.2014.11.24.08.45.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 08:45:42 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so9772779pab.6
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:45:41 -0800 (PST)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] mm, gfp: escalatedly define GFP_HIGHUSER and GFP_HIGHUSER_MOVABLE
Date: Tue, 25 Nov 2014 00:43:47 +0800
Message-Id: <1416847427-2550-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, sasha.levin@oracle.com, n-horiguchi@ah.jp.nec.com, andriy.shevchenko@linux.intel.com, rientjes@google.com, hannes@cmpxchg.org, nasa4836@gmail.com, vdavydov@parallels.com, fabf@skynet.be
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jianyu Zhan <jianyu.zhan@emc.com>

GFP_USER, GFP_HIGHUSER and GFP_HIGHUSER_MOVABLE are escalatedly
confined defined, also implied by their names:

GFP_USER                                  = GFP_USER
GFP_USER + __GFP_HIGHMEM                  = GFP_HIGHUSER
GFP_USER + __GFP_HIGHMEM + __GFP_MOVABLE  = GFP_HIGHUSER_MOVABLE

So just make GFP_HIGHUSER and GFP_HIGHUSER_MOVABLE escalatedly defined
to reflect this fact. It also makes the definition clear and texturally
warn on any furture break-up of this escalated relastionship.

Signed-off-by: Jianyu Zhan <jianyu.zhan@emc.com>
---
 include/linux/gfp.h | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 41b30fd..f7c74c8 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -110,11 +110,8 @@ struct vm_area_struct;
 #define GFP_TEMPORARY	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 			 __GFP_RECLAIMABLE)
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
-#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
-			 __GFP_HIGHMEM)
-#define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
-				 __GFP_HARDWALL | __GFP_HIGHMEM | \
-				 __GFP_MOVABLE)
+#define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
+#define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
 #define GFP_IOFS	(__GFP_IO | __GFP_FS)
 #define GFP_TRANSHUGE	(GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
 			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN | \
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
