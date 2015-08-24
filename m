Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id EE9466B0258
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:15:57 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so106387003pac.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 15:15:57 -0700 (PDT)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id j7si29624442pdn.248.2015.08.24.15.15.55
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 15:15:55 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 06/10] mm: make vmstat.c explicitly non-modular
Date: Mon, 24 Aug 2015 18:14:38 -0400
Message-ID: <1440454482-12250-7-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Davidlohr Bueso <dave@stgolabs.net>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

The Makefile currently controlling compilation of this code is obj-y
meaning that it currently is not being built as a module by anyone.

Lets remove the couple traces of modularity so that when reading the
code there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit. However
one could argue that subsys_initcall might make more sense here.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/vmstat.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1fd0886a389f..e6cd18cc4d75 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -12,7 +12,7 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/err.h>
-#include <linux/module.h>
+#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/cpu.h>
 #include <linux/cpumask.h>
@@ -1536,7 +1536,7 @@ static int __init setup_vmstat(void)
 #endif
 	return 0;
 }
-module_init(setup_vmstat)
+device_initcall(setup_vmstat)
 
 #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
 
@@ -1695,6 +1695,5 @@ fail:
 	debugfs_remove_recursive(extfrag_debug_root);
 	return -ENOMEM;
 }
-
-module_init(extfrag_debug_init);
+device_initcall(extfrag_debug_init);
 #endif
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
