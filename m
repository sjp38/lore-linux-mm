Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1B426B2FDB
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:12:39 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id t18-v6so1151521ljb.6
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:12:39 -0700 (PDT)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id q21-v6si3442525ljh.146.2018.08.24.06.12.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 06:12:38 -0700 (PDT)
From: Vincent Whitchurch <vincent.whitchurch@axis.com>
Subject: [PATCH] kmemleak: Always register debugfs file
Date: Fri, 24 Aug 2018 15:12:20 +0200
Message-Id: <20180824131220.19176-1-vincent.whitchurch@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vincent Whitchurch <rabinv@axis.com>

If kmemleak built in to the kernel, but is disabled by default, the
debugfs file is never registered.  Because of this, it is not possible
to find out if the kernel is built with kmemleak support by checking for
the presence of this file.  To allow this, always register the file.

After this patch, if the file doesn't exist, kmemleak is not available
in the kernel.  If writing "scan" or any other value than "clear" to
this file results in EBUSY, then kmemleak is available but is disabled
by default and can be activated via the kernel command line.

Signed-off-by: Vincent Whitchurch <vincent.whitchurch@axis.com>
---
 mm/kmemleak.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 9a085d525bbc..17dd883198ae 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -2097,6 +2097,11 @@ static int __init kmemleak_late_init(void)
 
 	kmemleak_initialized = 1;
 
+	dentry = debugfs_create_file("kmemleak", 0644, NULL, NULL,
+				     &kmemleak_fops);
+	if (!dentry)
+		pr_warn("Failed to create the debugfs kmemleak file\n");
+
 	if (kmemleak_error) {
 		/*
 		 * Some error occurred and kmemleak was disabled. There is a
@@ -2108,10 +2113,6 @@ static int __init kmemleak_late_init(void)
 		return -ENOMEM;
 	}
 
-	dentry = debugfs_create_file("kmemleak", 0644, NULL, NULL,
-				     &kmemleak_fops);
-	if (!dentry)
-		pr_warn("Failed to create the debugfs kmemleak file\n");
 	mutex_lock(&scan_mutex);
 	start_scan_thread();
 	mutex_unlock(&scan_mutex);
-- 
2.11.0
