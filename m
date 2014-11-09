Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 80B056B00CE
	for <linux-mm@kvack.org>; Sun,  9 Nov 2014 06:22:42 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so6039178pdb.39
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 03:22:42 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id kj8si13777934pdb.175.2014.11.09.03.22.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 09 Nov 2014 03:22:41 -0800 (PST)
Received: by mail-pa0-f66.google.com with SMTP id rd3so3577695pab.1
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 03:22:40 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/zswap: unregister zswap_cpu_notifier_block in cleanup procedure
Date: Sun,  9 Nov 2014 19:22:23 +0800
Message-Id: <1415532143-4409-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjennings@variantweb.net, minchan@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

In zswap_cpu_init(), the code does not unregister *zswap_cpu_notifier_block*
during the cleanup procedure.

This patch fix this issue.

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
---
 mm/zswap.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/zswap.c b/mm/zswap.c
index ea064c1..51a2c45 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -404,6 +404,7 @@ static int zswap_cpu_init(void)
 cleanup:
 	for_each_online_cpu(cpu)
 		__zswap_cpu_notifier(CPU_UP_CANCELED, cpu);
+	__unregister_cpu_notifier(&zswap_cpu_notifier_block);
 	cpu_notifier_register_done();
 	return -ENOMEM;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
