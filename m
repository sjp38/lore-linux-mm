Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 78AF46B009D
	for <linux-mm@kvack.org>; Wed, 20 May 2009 14:52:16 -0400 (EDT)
Date: Wed, 20 May 2009 11:52:36 -0700
From: "Larry H." <research@subreption.com>
Subject: [patch 4/5] Apply the PG_sensitive flag to the AF_KEY
	implementation
Message-ID: <20090520185236.GD10756@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, davem@redhat.com
List-ID: <linux-mm.kvack.org>

This patch deploys the use of the PG_sensitive page allocator flag
within the AF_KEY implementation.

Since AF_KEY's main purpose is credential management for network
stacks, it is desirable to mark the memory used to store such data
as sensitive and assure sanitization upon release.

Signed-off-by: Larry H. <research@subreption.com>

---
 net/key/af_key.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6/net/key/af_key.c
===================================================================
--- linux-2.6.orig/net/key/af_key.c
+++ linux-2.6/net/key/af_key.c
@@ -480,7 +480,7 @@ static inline struct xfrm_user_sec_ctx *
 	struct xfrm_user_sec_ctx *uctx = NULL;
 	int ctx_size = sec_ctx->sadb_x_ctx_len;
 
-	uctx = kmalloc((sizeof(*uctx)+ctx_size), GFP_KERNEL);
+	uctx = kmalloc((sizeof(*uctx)+ctx_size), GFP_KERNEL | GFP_SENSITIVE);
 
 	if (!uctx)
 		return NULL;
@@ -1184,7 +1184,7 @@ static struct xfrm_state * pfkey_msg2xfr
 		}
 		if (key)
 			keysize = (key->sadb_key_bits + 7) / 8;
-		x->aalg = kmalloc(sizeof(*x->aalg) + keysize, GFP_KERNEL);
+		x->aalg = kmalloc(sizeof(*x->aalg) + keysize, GFP_KERNEL | GFP_SENSITIVE);
 		if (!x->aalg)
 			goto out;
 		strcpy(x->aalg->alg_name, a->name);
@@ -1203,7 +1203,7 @@ static struct xfrm_state * pfkey_msg2xfr
 				err = -ENOSYS;
 				goto out;
 			}
-			x->calg = kmalloc(sizeof(*x->calg), GFP_KERNEL);
+			x->calg = kmalloc(sizeof(*x->calg), GFP_KERNEL | GFP_SENSITIVE);
 			if (!x->calg)
 				goto out;
 			strcpy(x->calg->alg_name, a->name);
@@ -1218,7 +1218,7 @@ static struct xfrm_state * pfkey_msg2xfr
 			key = (struct sadb_key*) ext_hdrs[SADB_EXT_KEY_ENCRYPT-1];
 			if (key)
 				keysize = (key->sadb_key_bits + 7) / 8;
-			x->ealg = kmalloc(sizeof(*x->ealg) + keysize, GFP_KERNEL);
+			x->ealg = kmalloc(sizeof(*x->ealg) + keysize, GFP_KERNEL | GFP_SENSITIVE);
 			if (!x->ealg)
 				goto out;
 			strcpy(x->ealg->alg_name, a->name);
@@ -1267,7 +1267,7 @@ static struct xfrm_state * pfkey_msg2xfr
 		struct sadb_x_nat_t_type* n_type;
 		struct xfrm_encap_tmpl *natt;
 
-		x->encap = kmalloc(sizeof(*x->encap), GFP_KERNEL);
+		x->encap = kmalloc(sizeof(*x->encap), GFP_KERNEL | GFP_SENSITIVE);
 		if (!x->encap)
 			goto out;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
