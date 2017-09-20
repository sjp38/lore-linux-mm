Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A535F6B02A2
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:46:18 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m30so7401512pgn.2
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:46:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v3sor1325606plb.111.2017.09.20.13.46.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:46:17 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 30/31] usercopy: Restrict non-usercopy caches to size 0
Date: Wed, 20 Sep 2017 13:45:36 -0700
Message-Id: <1505940337-79069-31-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

With all known usercopied cache whitelists now defined in the
kernel, switch the default usercopy region of kmem_cache_create()
to size 0. Any new caches with usercopy regions will now need to use
kmem_cache_create_usercopy() instead of kmem_cache_create().

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Cc: David Windsor <dave@nullcore.net>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index d4e6442f9bbc..0ac45ba6685e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -515,7 +515,7 @@ struct kmem_cache *
 kmem_cache_create(const char *name, size_t size, size_t align,
 		unsigned long flags, void (*ctor)(void *))
 {
-	return kmem_cache_create_usercopy(name, size, align, flags, 0, size,
+	return kmem_cache_create_usercopy(name, size, align, flags, 0, 0,
 					  ctor);
 }
 EXPORT_SYMBOL(kmem_cache_create);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
