Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE9EA6B03A1
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:43:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s74so115336660pfe.10
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:43:19 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id q3si2811613plb.507.2017.06.19.16.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:43:19 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id c73so665183pfk.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:43:19 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 21/23] usercopy: Restrict non-usercopy caches to size 0
Date: Mon, 19 Jun 2017 16:36:35 -0700
Message-Id: <1497915397-93805-22-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

With all known usercopied cache whitelists now defined in the kernel, switch
the default usercopy region of kmem_cache_create() to size 0. Any new caches
with usercopy regions will now need to use kmem_cache_create_usercopy()
instead of kmem_cache_create().

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: David Windsor <dave@nullcore.net>
---
 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 685321a0d355..2365dd21623d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -512,7 +512,7 @@ struct kmem_cache *
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
