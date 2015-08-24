Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 01DA36B0257
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:15:56 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so33313915pac.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 15:15:55 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id fl4si29664489pdb.129.2015.08.24.15.15.53
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 15:15:53 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 05/10] mm: make page_alloc.c explicitly non-modular
Date: Mon, 24 Aug 2015 18:14:37 -0400
Message-ID: <1440454482-12250-6-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>

The Makefile currently controlling compilation of this code is obj-y
meaning that it currently is not being built as a module by anyone.

Lets remove the couple traces of modularity so that when reading the
driver there is no doubt it is builtin-only.  We have to leave the
module.h include though, as the file uses print_modules().

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.  However
one could argue that subsys_initcall() would make more sense.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c1024db4ac5f..b02c511320fa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6327,7 +6327,7 @@ int __meminit init_per_zone_wmark_min(void)
 	setup_per_zone_inactive_ratio();
 	return 0;
 }
-module_init(init_per_zone_wmark_min)
+device_initcall(init_per_zone_wmark_min)
 
 /*
  * min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
