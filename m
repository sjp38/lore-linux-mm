Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3493D6B049E
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:43:55 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t3so2581222pgt.8
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:55 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id u12si994709plm.712.2017.08.28.14.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:43:54 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id z87so4714717pfi.3
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:54 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 30/30] usercopy: Restrict non-usercopy caches to size 0
Date: Mon, 28 Aug 2017 14:35:11 -0700
Message-Id: <1503956111-36652-31-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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
index f662f4e2fa29..d51c0a36d58b 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -511,7 +511,7 @@ struct kmem_cache *
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
