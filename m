Subject: [PATCH] alloc uid cleanup
Message-Id: <E1FVZH8-0004f1-8s@blr-eng3.blr.corp.google.com>
From: Prasanna Meda <mlp@google.com>
Date: Tue, 18 Apr 2006 00:50:42 +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Cleanup: Release the lock before key_put methods. They call 
schedule_work etc. They block interrupts now, so it is not bug fix.

Signed-off-by: Prasanna Meda

--- a/kernel/user.c	2006-04-17 23:02:54.000000000 +0530
+++ b/kernel/user.c	2006-04-17 23:06:01.000000000 +0530
@@ -160,15 +160,15 @@ struct user_struct * alloc_uid(uid_t uid
 		spin_lock_irq(&uidhash_lock);
 		up = uid_hash_find(uid, hashent);
 		if (up) {
+			spin_unlock_irq(&uidhash_lock);
 			key_put(new->uid_keyring);
 			key_put(new->session_keyring);
 			kmem_cache_free(uid_cachep, new);
 		} else {
 			uid_hash_insert(new, hashent);
 			up = new;
+			spin_unlock_irq (&uidhash_lock);
 		}
-		spin_unlock_irq(&uidhash_lock);
-
 	}
 	return up;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
