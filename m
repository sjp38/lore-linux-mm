Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id CE636828DF
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 19:30:39 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id bc4so43354982lbc.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 16:30:39 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id v199si311085lfd.235.2016.03.03.16.30.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 16:30:37 -0800 (PST)
Subject: [PATCH] tmpfs: shmem_fallocate must return ERESTARTSYS
From: Maxim Patlasov <mpatlasov@virtuozzo.com>
Date: Thu, 03 Mar 2016 16:30:33 -0800
Message-ID: <20160304002954.19844.52266.stgit@maxim-thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

shmem_fallocate() is restartable, so it can return ERESTARTSYS if
signal_pending(). Although fallocate(2) manpage permits EINTR,
the more places use ERESTARTSYS the better.

Signed-off-by: Maxim Patlasov <mpatlasov@virtuozzo.com>
---
 mm/shmem.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 440e2a7..60e9c8a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2229,11 +2229,13 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		struct page *page;
 
 		/*
-		 * Good, the fallocate(2) manpage permits EINTR: we may have
-		 * been interrupted because we are using up too much memory.
+		 * Although fallocate(2) manpage permits EINTR, the more
+		 * places use ERESTARTSYS the better. If we have been
+		 * interrupted because we are using up too much memory,
+		 * oom-killer used fatal signal and we will die anyway.
 		 */
 		if (signal_pending(current))
-			error = -EINTR;
+			error = -ERESTARTSYS;
 		else if (shmem_falloc.nr_unswapped > shmem_falloc.nr_falloced)
 			error = -ENOMEM;
 		else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
