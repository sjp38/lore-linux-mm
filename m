Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 99D1E6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:02:29 -0400 (EDT)
Received: by oibn4 with SMTP id n4so52743911oib.3
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:02:29 -0700 (PDT)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id m64si13823872oif.44.2015.07.27.08.02.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 08:02:28 -0700 (PDT)
From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next] mm: Fix build breakage seen if MMU_NOTIFIER is not configured
Date: Mon, 27 Jul 2015 08:02:23 -0700
Message-Id: <1438009343-25468-1-git-send-email-linux@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Andres Lagar-Cavilla <andreslc@google.com>, Vladimir Davydov <vdavydov@parallels.com>

Commit 65525488fa86 ("proc: add kpageidle file") introduces code
which depends on MMU_NOTIFIER, yet the newly introduced configuration
flag does not declare that dependency. This results in the following
build failures seen if IDLE_PAGE_TRACKING is configured but MMU_NOTIFIER
is not.

fs/proc/page.c: In function 'kpageidle_clear_pte_refs_one':
fs/proc/page.c:341:4: error:
	implicit declaration of function 'pmdp_clear_young_notify'
fs/proc/page.c:347:4: error:
	implicit declaration of function 'ptep_clear_young_notify'

Fixes: 65525488fa86 ("proc: add kpageidle file")
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 7e9ccb438985..b73b41c3217b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -651,6 +651,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 
 config IDLE_PAGE_TRACKING
 	bool "Enable idle page tracking"
+	depends on MMU_NOTIFIER
 	select PROC_PAGE_MONITOR
 	select PAGE_EXTENSION if !64BIT
 	help
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
