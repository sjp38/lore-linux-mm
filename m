Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 527DF6B026B
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:03:31 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z12so1681478pgv.6
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:03:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5sor3719412pgp.344.2018.01.10.18.03.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:03:29 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 09/38] usercopy: Mark kmalloc caches as usercopy caches
Date: Wed, 10 Jan 2018 18:02:41 -0800
Message-Id: <1515636190-24061-10-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

Mark the kmalloc slab caches as entirely whitelisted. These caches
are frequently used to fulfill kernel allocations that contain data
to be copied to/from userspace. Internal-only uses are also common,
but are scattered in the kernel. For now, mark all the kmalloc caches
as whitelisted.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: merged in moved kmalloc hunks, adjust commit log]
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-xfs@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |  3 ++-
 mm/slab.h        |  3 ++-
 mm/slab_common.c | 10 ++++++----
 3 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b9b0df620bb9..dd367fe17a4e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1291,7 +1291,8 @@ void __init kmem_cache_init(void)
 	 */
 	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache(
 				kmalloc_info[INDEX_NODE].name,
-				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
+				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS,
+				0, kmalloc_size(INDEX_NODE));
 	slab_state = PARTIAL_NODE;
 	setup_kmalloc_cache_index_table();
 
diff --git a/mm/slab.h b/mm/slab.h
index b476c435680f..98c5bcc45d8b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -97,7 +97,8 @@ struct kmem_cache *kmalloc_slab(size_t, gfp_t);
 int __kmem_cache_create(struct kmem_cache *, slab_flags_t flags);
 
 extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
-			slab_flags_t flags);
+			slab_flags_t flags, size_t useroffset,
+			size_t usersize);
 extern void create_boot_cache(struct kmem_cache *, const char *name,
 			size_t size, slab_flags_t flags, size_t useroffset,
 			size_t usersize);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index a51f65408637..8ac2a6320a6c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -937,14 +937,15 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t siz
 }
 
 struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
-				slab_flags_t flags)
+				slab_flags_t flags, size_t useroffset,
+				size_t usersize)
 {
 	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 
 	if (!s)
 		panic("Out of memory when creating slab %s\n", name);
 
-	create_boot_cache(s, name, size, flags, 0, size);
+	create_boot_cache(s, name, size, flags, useroffset, usersize);
 	list_add(&s->list, &slab_caches);
 	memcg_link_cache(s);
 	s->refcount = 1;
@@ -1098,7 +1099,8 @@ void __init setup_kmalloc_cache_index_table(void)
 static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
 {
 	kmalloc_caches[idx] = create_kmalloc_cache(kmalloc_info[idx].name,
-					kmalloc_info[idx].size, flags);
+					kmalloc_info[idx].size, flags, 0,
+					kmalloc_info[idx].size);
 }
 
 /*
@@ -1139,7 +1141,7 @@ void __init create_kmalloc_caches(slab_flags_t flags)
 
 			BUG_ON(!n);
 			kmalloc_dma_caches[i] = create_kmalloc_cache(n,
-				size, SLAB_CACHE_DMA | flags);
+				size, SLAB_CACHE_DMA | flags, 0, 0);
 		}
 	}
 #endif
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
