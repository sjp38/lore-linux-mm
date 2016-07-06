Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8328D828E4
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 18:26:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g62so604360pfb.3
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 15:26:02 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id zw4si1397224pac.130.2016.07.06.15.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 15:25:47 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id h14so132507pfe.1
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 15:25:47 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 9/9] mm: SLUB hardened usercopy support
Date: Wed,  6 Jul 2016 15:25:28 -0700
Message-Id: <1467843928-29351-10-git-send-email-keescook@chromium.org>
In-Reply-To: <1467843928-29351-1-git-send-email-keescook@chromium.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Under CONFIG_HARDENED_USERCOPY, this adds object size checking to the
SLUB allocator to catch any copies that may span objects.

Based on code from PaX and grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 init/Kconfig |  1 +
 mm/slub.c    | 27 +++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/init/Kconfig b/init/Kconfig
index 798c2020ee7c..1c4711819dfd 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1765,6 +1765,7 @@ config SLAB
 
 config SLUB
 	bool "SLUB (Unqueued Allocator)"
+	select HAVE_HARDENED_USERCOPY_ALLOCATOR
 	help
 	   SLUB is a slab allocator that minimizes cache line usage
 	   instead of managing queues of cached objects (SLAB approach).
diff --git a/mm/slub.c b/mm/slub.c
index 825ff4505336..0c8ace04f075 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3614,6 +3614,33 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
 
+#ifdef CONFIG_HARDENED_USERCOPY
+/*
+ * Rejects objects that are incorrectly sized.
+ *
+ * Returns NULL if check passes, otherwise const char * to name of cache
+ * to indicate an error.
+ */
+const char *__check_heap_object(const void *ptr, unsigned long n,
+				struct page *page)
+{
+	struct kmem_cache *s;
+	unsigned long offset;
+
+	/* Find object. */
+	s = page->slab_cache;
+
+	/* Find offset within object. */
+	offset = (ptr - page_address(page)) % s->size;
+
+	/* Allow address range falling entirely within object size. */
+	if (offset <= s->object_size && n <= s->object_size - offset)
+		return NULL;
+
+	return s->name;
+}
+#endif /* CONFIG_HARDENED_USERCOPY */
+
 static size_t __ksize(const void *object)
 {
 	struct page *page;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
