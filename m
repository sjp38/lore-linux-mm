Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65E176B0287
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:09:44 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id z12so1708428pgv.6
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:09:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j126sor3648488pgc.31.2018.01.10.18.09.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:09:43 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 37/38] usercopy: Restrict non-usercopy caches to size 0
Date: Wed, 10 Jan 2018 18:03:09 -0800
Message-Id: <1515636190-24061-38-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

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
index 8ac2a6320a6c..d00cd3f0f8ac 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -532,7 +532,7 @@ struct kmem_cache *
 kmem_cache_create(const char *name, size_t size, size_t align,
 		slab_flags_t flags, void (*ctor)(void *))
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
