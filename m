Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D2EF06B009E
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:05:12 -0500 (EST)
Message-Id: <20090216144725.976425091@cmpxchg.org>
Date: Mon, 16 Feb 2009 15:29:32 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/8] cifs: use kzfree()
References: <20090216142926.440561506@cmpxchg.org>
Content-Disposition: inline; filename=cifs-use-kzfree.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve French <sfrench@samba.org>
List-ID: <linux-mm.kvack.org>

Use kzfree() instead of memset() + kfree().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Steve French <sfrench@samba.org>
---
 fs/cifs/connect.c |    7 ++-----
 fs/cifs/misc.c    |   12 ++++--------
 2 files changed, 6 insertions(+), 13 deletions(-)

--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -2433,11 +2433,8 @@ mount_fail_check:
 out:
 	/* zero out password before freeing */
 	if (volume_info) {
-		if (volume_info->password != NULL) {
-			memset(volume_info->password, 0,
-				strlen(volume_info->password));
-			kfree(volume_info->password);
-		}
+		if (volume_info->password != NULL)
+			kzfree(volume_info->password);
 		kfree(volume_info->UNC);
 		kfree(volume_info->prepath);
 		kfree(volume_info);
--- a/fs/cifs/misc.c
+++ b/fs/cifs/misc.c
@@ -97,10 +97,8 @@ sesInfoFree(struct cifsSesInfo *buf_to_f
 	kfree(buf_to_free->serverOS);
 	kfree(buf_to_free->serverDomain);
 	kfree(buf_to_free->serverNOS);
-	if (buf_to_free->password) {
-		memset(buf_to_free->password, 0, strlen(buf_to_free->password));
-		kfree(buf_to_free->password);
-	}
+	if (buf_to_free->password)
+		kzfree(buf_to_free->password);
 	kfree(buf_to_free->domainName);
 	kfree(buf_to_free);
 }
@@ -132,10 +130,8 @@ tconInfoFree(struct cifsTconInfo *buf_to
 	}
 	atomic_dec(&tconInfoAllocCount);
 	kfree(buf_to_free->nativeFileSystem);
-	if (buf_to_free->password) {
-		memset(buf_to_free->password, 0, strlen(buf_to_free->password));
-		kfree(buf_to_free->password);
-	}
+	if (buf_to_free->password)
+		kzfree(buf_to_free->password);
 	kfree(buf_to_free);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
