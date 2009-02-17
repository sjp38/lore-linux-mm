Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 241186B00B4
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:44:17 -0500 (EST)
Message-Id: <20090217184136.172339807@cmpxchg.org>
Date: Tue, 17 Feb 2009 19:26:21 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/7] cifs: use kzfree()
References: <20090217182615.897042724@cmpxchg.org>
Content-Disposition: inline; filename=cifs-use-kzfree.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve French <sfrench@samba.org>
List-ID: <linux-mm.kvack.org>

Use kzfree() instead of memset() + kfree().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
Acked-by: Steve French <sfrench@samba.org>
---
 fs/cifs/connect.c |    6 +-----
 fs/cifs/misc.c    |   10 ++--------
 2 files changed, 3 insertions(+), 13 deletions(-)

--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -2433,11 +2433,7 @@ mount_fail_check:
 out:
 	/* zero out password before freeing */
 	if (volume_info) {
-		if (volume_info->password != NULL) {
-			memset(volume_info->password, 0,
-				strlen(volume_info->password));
-			kfree(volume_info->password);
-		}
+		kzfree(volume_info->password);
 		kfree(volume_info->UNC);
 		kfree(volume_info->prepath);
 		kfree(volume_info);
--- a/fs/cifs/misc.c
+++ b/fs/cifs/misc.c
@@ -97,10 +97,7 @@ sesInfoFree(struct cifsSesInfo *buf_to_f
 	kfree(buf_to_free->serverOS);
 	kfree(buf_to_free->serverDomain);
 	kfree(buf_to_free->serverNOS);
-	if (buf_to_free->password) {
-		memset(buf_to_free->password, 0, strlen(buf_to_free->password));
-		kfree(buf_to_free->password);
-	}
+	kzfree(buf_to_free->password);
 	kfree(buf_to_free->domainName);
 	kfree(buf_to_free);
 }
@@ -132,10 +129,7 @@ tconInfoFree(struct cifsTconInfo *buf_to
 	}
 	atomic_dec(&tconInfoAllocCount);
 	kfree(buf_to_free->nativeFileSystem);
-	if (buf_to_free->password) {
-		memset(buf_to_free->password, 0, strlen(buf_to_free->password));
-		kfree(buf_to_free->password);
-	}
+	kzfree(buf_to_free->password);
 	kfree(buf_to_free);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
