Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id F2E946B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:15:46 -0400 (EDT)
Received: by ykll84 with SMTP id l84so136680067ykl.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 15:15:46 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id p6si11293981yka.42.2015.08.24.15.15.45
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 15:15:45 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 01/10] mm: make cleancache.c explicitly non-modular
Date: Mon, 24 Aug 2015 18:14:33 -0400
Message-ID: <1440454482-12250-2-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

The Kconfig currently controlling compilation of this code is:

config CLEANCACHE
        bool "Enable cleancache driver to cache clean pages if tmem is present"

...meaning that it currently is not being built as a module by anyone.

Lets remove the couple traces of modularity so that when reading the
driver there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.

Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/cleancache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/cleancache.c b/mm/cleancache.c
index 8fc50811119b..ee0646d1c2fa 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -11,7 +11,7 @@
  * This work is licensed under the terms of the GNU GPL, version 2.
  */
 
-#include <linux/module.h>
+#include <linux/init.h>
 #include <linux/fs.h>
 #include <linux/exportfs.h>
 #include <linux/mm.h>
@@ -316,4 +316,4 @@ static int __init init_cleancache(void)
 #endif
 	return 0;
 }
-module_init(init_cleancache)
+device_initcall(init_cleancache)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
