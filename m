Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id DFEF16B0258
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:15:59 -0400 (EDT)
Received: by ykll84 with SMTP id l84so136684756ykl.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 15:15:59 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id d205si7674194ykf.169.2015.08.24.15.15.55
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 15:15:56 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 09/10] mm: make frontswap.c explicitly non-modular
Date: Mon, 24 Aug 2015 18:14:41 -0400
Message-ID: <1440454482-12250-10-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

The Kconfig currently controlling compilation of this code is:

config FRONTSWAP
    bool "Enable frontswap to cache swap pages if tmem is present"

...meaning that it currently is not being built as a module by anyone.

Lets remove the couple traces of modularity so that when reading the
driver there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.  However
one could argue that subsys_initcall might make more sense here.

Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/frontswap.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 27a9924caf61..b36409766831 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -15,7 +15,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/security.h>
-#include <linux/module.h>
+#include <linux/init.h>
 #include <linux/debugfs.h>
 #include <linux/frontswap.h>
 #include <linux/swapfile.h>
@@ -500,5 +500,4 @@ static int __init init_frontswap(void)
 #endif
 	return 0;
 }
-
-module_init(init_frontswap);
+device_initcall(init_frontswap);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
