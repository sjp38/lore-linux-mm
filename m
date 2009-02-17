Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6E46B00B3
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:44:06 -0500 (EST)
Message-Id: <20090217184136.258819597@cmpxchg.org>
Date: Tue, 17 Feb 2009 19:26:22 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 7/7] ecryptfs: use kzfree()
References: <20090217182615.897042724@cmpxchg.org>
Content-Disposition: inline; filename=ecryptfs-use-kzfree.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tyler Hicks <tyhicks@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Use kzfree() instead of memset() + kfree().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
Acked-by: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
---
 fs/ecryptfs/keystore.c  |    3 +--
 fs/ecryptfs/messaging.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

--- a/fs/ecryptfs/keystore.c
+++ b/fs/ecryptfs/keystore.c
@@ -740,8 +740,7 @@ ecryptfs_write_tag_70_packet(char *dest,
 out_release_free_unlock:
 	crypto_free_hash(s->hash_desc.tfm);
 out_free_unlock:
-	memset(s->block_aligned_filename, 0, s->block_aligned_filename_size);
-	kfree(s->block_aligned_filename);
+	kzfree(s->block_aligned_filename);
 out_unlock:
 	mutex_unlock(s->tfm_mutex);
 out:
--- a/fs/ecryptfs/messaging.c
+++ b/fs/ecryptfs/messaging.c
@@ -291,8 +291,7 @@ int ecryptfs_exorcise_daemon(struct ecry
 	if (daemon->user_ns)
 		put_user_ns(daemon->user_ns);
 	mutex_unlock(&daemon->mux);
-	memset(daemon, 0, sizeof(*daemon));
-	kfree(daemon);
+	kzfree(daemon);
 out:
 	return rc;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
