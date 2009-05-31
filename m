Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 783F55F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 22:00:30 -0400 (EDT)
Date: Sat, 30 May 2009 18:58:01 -0700
From: "Larry H." <research@subreption.com>
Subject: [PATCH] Use kzfree in mac80211 key handling to enforce data
	sanitization
Message-ID: <20090531015801.GB8941@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, pageexec@freemail.hu, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

[PATCH] Use kzfree in mac80211 key handling to enforce data sanitization

This patch replaces the kfree() calls within the mac80211 WEP RC4 key
handling and ieee80211 management APIs with kzfree(), to enforce
sanitization of the key buffer contents.

This prevents the keys from persisting on memory, potentially
leaking to other kernel users after re-allocation of the memory by
the LIFO allocators, or in coldboot attack scenarios. Information can be
leaked as well due to use of uninitialized variables, or other bugs.

This patch doesn't affect fastpaths.

Signed-off-by: Larry Highsmith <research@subreption.com>

Index: linux-2.6/net/mac80211/key.c
===================================================================
--- linux-2.6.orig/net/mac80211/key.c
+++ linux-2.6/net/mac80211/key.c
@@ -304,7 +304,7 @@ struct ieee80211_key *ieee80211_key_allo
 		 */
 		key->u.ccmp.tfm = ieee80211_aes_key_setup_encrypt(key_data);
 		if (!key->u.ccmp.tfm) {
-			kfree(key);
+			kzfree(key);
 			return NULL;
 		}
 	}
@@ -404,7 +404,7 @@ void ieee80211_key_free(struct ieee80211
 		 * and don't Oops */
 		if (key->conf.alg == ALG_CCMP)
 			ieee80211_aes_key_free(key->u.ccmp.tfm);
-		kfree(key);
+		kzfree(key);
 		return;
 	}
 
@@ -464,7 +464,7 @@ static void __ieee80211_key_destroy(stru
 		ieee80211_aes_key_free(key->u.ccmp.tfm);
 	ieee80211_debugfs_key_remove(key);
 
-	kfree(key);
+	kzfree(key);
 }
 
 static void __ieee80211_key_todo(void)
Index: linux-2.6/net/mac80211/wep.c
===================================================================
--- linux-2.6.orig/net/mac80211/wep.c
+++ linux-2.6/net/mac80211/wep.c
@@ -161,7 +161,7 @@ int ieee80211_wep_encrypt(struct ieee802
 
 	iv = ieee80211_wep_add_iv(local, skb, key);
 	if (!iv) {
-		kfree(rc4key);
+		kzfree(rc4key);
 		return -1;
 	}
 
@@ -179,7 +179,7 @@ int ieee80211_wep_encrypt(struct ieee802
 	ieee80211_wep_encrypt_data(local->wep_tx_tfm, rc4key, klen,
 				   iv + WEP_IV_LEN, len);
 
-	kfree(rc4key);
+	kzfree(rc4key);
 
 	return 0;
 }
@@ -258,7 +258,7 @@ int ieee80211_wep_decrypt(struct ieee802
 				       len))
 		ret = -1;
 
-	kfree(rc4key);
+	kzfree(rc4key);
 
 	/* Trim ICV */
 	skb_trim(skb, skb->len - WEP_ICV_LEN);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
