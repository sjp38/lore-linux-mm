Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29B26828E4
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 17:44:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so241850674pfx.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:44:56 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id fd2si11088478pac.234.2016.07.15.14.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 14:44:39 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id c2so44973728pfa.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:44:39 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 11/11] mm: SLUB hardened usercopy support
Date: Fri, 15 Jul 2016 14:44:25 -0700
Message-Id: <1468619065-3222-12-git-send-email-keescook@chromium.org>
In-Reply-To: <1468619065-3222-1-git-send-email-keescook@chromium.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Under CONFIG_HARDENED_USERCOPY, this adds object size checking to the
SLUB allocator to catch any copies that may span objects. Includes a
redzone handling fix discovered by Michael Ellerman.

Based on code from PaX and grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
Tested-by: Michael Ellerman <mpe@ellerman.id.au>
---
 init/Kconfig |  1 +
 mm/slub.c    | 36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

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
index 825ff4505336..7dee3d9a5843 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3614,6 +3614,42 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
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
+	size_t object_size;
+
+	/* Find object and usable object size. */
+	s = page->slab_cache;
+	object_size = slab_ksize(s);
+
+	/* Find offset within object. */
+	offset = (ptr - page_address(page)) % s->size;
+
+	/* Adjust for redzone and reject if within the redzone. */
+	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE) {
+		if (offset < s->red_left_pad)
+			return s->name;
+		offset -= s->red_left_pad;
+	}
+
+	/* Allow address range falling entirely within object size. */
+	if (offset <= object_size && n <= object_size - offset)
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
