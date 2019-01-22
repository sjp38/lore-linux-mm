Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 657448E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:22:12 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v11so15633284ply.4
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:22:12 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o3si15026155pgi.388.2019.01.22.07.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 07:22:11 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH] mm: kmemleak: no need to check return value of debugfs_create functions
Date: Tue, 22 Jan 2019 16:21:12 +0100
Message-Id: <20190122152151.16139-13-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org

When calling debugfs functions, there is no need to ever check the
return value.  The function can work or not, but the code logic should
never do something different based on this.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 mm/kmemleak.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f9d9dc250428..d45bc65db5fb 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -2124,14 +2124,9 @@ void __init kmemleak_init(void)
  */
 static int __init kmemleak_late_init(void)
 {
-	struct dentry *dentry;
-
 	kmemleak_initialized = 1;
 
-	dentry = debugfs_create_file("kmemleak", 0644, NULL, NULL,
-				     &kmemleak_fops);
-	if (!dentry)
-		pr_warn("Failed to create the debugfs kmemleak file\n");
+	debugfs_create_file("kmemleak", 0644, NULL, NULL, &kmemleak_fops);
 
 	if (kmemleak_error) {
 		/*
-- 
2.20.1
