Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3716B0256
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:15:54 -0400 (EDT)
Received: by igcse8 with SMTP id se8so59268638igc.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 15:15:53 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id j3si8478511igx.42.2015.08.24.15.15.53
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 15:15:53 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 07/10] mm: make workingset.c explicitly non-modular
Date: Mon, 24 Aug 2015 18:14:39 -0400
Message-ID: <1440454482-12250-8-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Vladimir Davydov <vdavydov@parallels.com>

The Makefile currently controlling compilation of this code is obj-y
meaning that it currently is not being built as a module by anyone.

Lets remove the couple traces of modularity so that when reading the
code there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.  However
one could argue that subsys_initcall might make more sense here.

Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/workingset.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index aa017133744b..c2c59f599610 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -8,7 +8,7 @@
 #include <linux/writeback.h>
 #include <linux/pagemap.h>
 #include <linux/atomic.h>
-#include <linux/module.h>
+#include <linux/init.h>
 #include <linux/swap.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
@@ -412,4 +412,4 @@ err_list_lru:
 err:
 	return ret;
 }
-module_init(workingset_init);
+device_initcall(workingset_init);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
