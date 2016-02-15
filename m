Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id AD2326B0256
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 13:44:33 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id y9so117620547qgd.3
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 10:44:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e2si24726765qhc.117.2016.02.15.10.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 10:44:33 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCHv2 2/4] slub: Fix/clean free_debug_processing return paths
Date: Mon, 15 Feb 2016 10:44:22 -0800
Message-Id: <1455561864-4217-3-git-send-email-labbott@fedoraproject.org>
In-Reply-To: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
References: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>


Since 19c7ff9ecd89 ("slub: Take node lock during object free checks")
check_object has been incorrectly returning success as it follows
the out label which just returns the node. Thanks to refactoring,
the out and fail paths are now basically the same. Combine the two
into one and just use a single label.

Credit to Mathias Krause for the original work which inspired this series

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
If there is interest, I can split this off as a separate patch for stable
---
 mm/slub.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 2d5a774..189c330 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1077,24 +1077,25 @@ static noinline int free_debug_processing(
 	void *object = head;
 	int cnt = 0;
 	unsigned long uninitialized_var(flags);
+	int ret = 0;
 
 	spin_lock_irqsave(&n->list_lock, flags);
 	slab_lock(page);
 
 	if (!check_slab(s, page))
-		goto fail;
+		goto out;
 
 next_object:
 	cnt++;
 
 	if (!check_valid_pointer(s, page, object)) {
 		slab_err(s, page, "Invalid object pointer 0x%p", object);
-		goto fail;
+		goto out;
 	}
 
 	if (on_freelist(s, page, object)) {
 		object_err(s, page, object, "Object already free");
-		goto fail;
+		goto out;
 	}
 
 	if (!check_object(s, page, object, SLUB_RED_ACTIVE))
@@ -1111,7 +1112,7 @@ next_object:
 		} else
 			object_err(s, page, object,
 					"page slab pointer corrupt.");
-		goto fail;
+		goto out;
 	}
 
 	if (s->flags & SLAB_STORE_USER)
@@ -1125,6 +1126,8 @@ next_object:
 		object = get_freepointer(s, object);
 		goto next_object;
 	}
+	ret = 1;
+
 out:
 	if (cnt != bulk_cnt)
 		slab_err(s, page, "Bulk freelist count(%d) invalid(%d)\n",
@@ -1132,13 +1135,9 @@ out:
 
 	slab_unlock(page);
 	spin_unlock_irqrestore(&n->list_lock, flags);
-	return 1;
-
-fail:
-	slab_unlock(page);
-	spin_unlock_irqrestore(&n->list_lock, flags);
-	slab_fix(s, "Object at 0x%p not freed", object);
-	return 0;
+	if (!ret)
+		slab_fix(s, "Object at 0x%p not freed", object);
+	return ret;
 }
 
 static int __init setup_slub_debug(char *str)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
