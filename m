Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 13ED26B0254
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 14:33:00 -0400 (EDT)
Received: by qgeh99 with SMTP id h99so72368512qge.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:32:59 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id n81si17427040qki.6.2015.08.26.11.32.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 11:32:59 -0700 (PDT)
Received: by qgeg42 with SMTP id g42so132431912qge.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:32:59 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 1/2] module: export param_free_charp()
Date: Wed, 26 Aug 2015 14:32:49 -0400
Message-Id: <1440613970-23913-2-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1440613970-23913-1-git-send-email-ddstreet@ieee.org>
References: <1440613970-23913-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dan Streetman <ddstreet@ieee.org>

Change the param_free_charp() function from static to exported.

It is used by zswap in the next patch.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 include/linux/moduleparam.h | 1 +
 kernel/params.c             | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/moduleparam.h b/include/linux/moduleparam.h
index c12f214..52666d9 100644
--- a/include/linux/moduleparam.h
+++ b/include/linux/moduleparam.h
@@ -386,6 +386,7 @@ extern int param_get_ullong(char *buffer, const struct kernel_param *kp);
 extern const struct kernel_param_ops param_ops_charp;
 extern int param_set_charp(const char *val, const struct kernel_param *kp);
 extern int param_get_charp(char *buffer, const struct kernel_param *kp);
+extern void param_free_charp(void *arg);
 #define param_check_charp(name, p) __param_check(name, p, char *)
 
 /* We used to allow int as well as bool.  We're taking that away! */
diff --git a/kernel/params.c b/kernel/params.c
index b6554aa..93a380a 100644
--- a/kernel/params.c
+++ b/kernel/params.c
@@ -325,10 +325,11 @@ int param_get_charp(char *buffer, const struct kernel_param *kp)
 }
 EXPORT_SYMBOL(param_get_charp);
 
-static void param_free_charp(void *arg)
+void param_free_charp(void *arg)
 {
 	maybe_kfree_parameter(*((char **)arg));
 }
+EXPORT_SYMBOL(param_free_charp);
 
 const struct kernel_param_ops param_ops_charp = {
 	.set = param_set_charp,
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
