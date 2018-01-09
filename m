Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D54246B0283
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:22 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d199so7577169pfd.9
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v3sor2018915pfd.140.2018.01.09.12.57.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:57:21 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 06/36] usercopy: Mark kmalloc caches as usercopy caches
Date: Tue,  9 Jan 2018 12:55:35 -0800
Message-Id: <1515531365-37423-7-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

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
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-xfs@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/slab.c        |  3 ++-
 mm/slab.h        |  3 ++-
 mm/slab_common.c | 10 ++++++----
 3 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d9939828f8e4..6488066e718a 100644
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
index 8f3030788e01..1f013f7795c6 100644
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
index fc3e66bdce75..6c9e945907b6 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -929,14 +929,15 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t siz
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
@@ -1090,7 +1091,8 @@ void __init setup_kmalloc_cache_index_table(void)
 static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
 {
 	kmalloc_caches[idx] = create_kmalloc_cache(kmalloc_info[idx].name,
-					kmalloc_info[idx].size, flags);
+					kmalloc_info[idx].size, flags, 0,
+					kmalloc_info[idx].size);
 }
 
 /*
@@ -1131,7 +1133,7 @@ void __init create_kmalloc_caches(slab_flags_t flags)
 
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
