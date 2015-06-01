Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 317926B006C
	for <linux-mm@kvack.org>; Sun, 31 May 2015 20:54:49 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so50006736igb.0
        for <linux-mm@kvack.org>; Sun, 31 May 2015 17:54:49 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id n138si9883283ion.99.2015.05.31.17.54.48
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 31 May 2015 17:54:48 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 09/11] mm/page_owner.c: use late_initcall to hook in enabling
Date: Sun, 31 May 2015 20:54:10 -0400
Message-ID: <1433120052-18281-10-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1433120052-18281-1-git-send-email-paul.gortmaker@windriver.com>
References: <1433120052-18281-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

This was using module_init, but there is no way this code can
be modular.  In the non-modular case, a module_init becomes a
device_initcall, but this really isn't a device.   So we should
choose a more appropriate initcall bucket to put it in.

In order of execution, our close choices are:

 fs_initcall(fn)
 rootfs_initcall(fn)
 device_initcall(fn)
 late_initcall(fn)

..and since the initcall here goes after debugfs, we really
should be post-rootfs, which means late_initcall makes the
most sense here.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/page_owner.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 0993f5f36b01..bd5f842b56d2 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -310,4 +310,4 @@ static int __init pageowner_init(void)
 
 	return 0;
 }
-module_init(pageowner_init)
+late_initcall(pageowner_init)
-- 
2.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
