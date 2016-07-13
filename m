Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id F01C76B026A
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 17:56:34 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id q2so102397147pap.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 14:56:34 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id hx8si4240351pac.110.2016.07.13.14.56.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 14:56:19 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id dx3so21507344pab.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 14:56:19 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 10/11] mm: SLAB hardened usercopy support
Date: Wed, 13 Jul 2016 14:56:03 -0700
Message-Id: <1468446964-22213-11-git-send-email-keescook@chromium.org>
In-Reply-To: <1468446964-22213-1-git-send-email-keescook@chromium.org>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Under CONFIG_HARDENED_USERCOPY, this adds object size checking to the
SLAB allocator to catch any copies that may span objects.

Based on code from PaX and grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 init/Kconfig |  1 +
 mm/slab.c    | 30 ++++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/init/Kconfig b/init/Kconfig
index f755a602d4a1..798c2020ee7c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1757,6 +1757,7 @@ choice
 
 config SLAB
 	bool "SLAB"
+	select HAVE_HARDENED_USERCOPY_ALLOCATOR
 	help
 	  The regular slab allocator that is established and known to work
 	  well in all environments. It organizes cache hot objects in
diff --git a/mm/slab.c b/mm/slab.c
index cc8bbc1e6bc9..5e2d5f349aca 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4477,6 +4477,36 @@ static int __init slab_proc_init(void)
 module_init(slab_proc_init);
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
+	struct kmem_cache *cachep;
+	unsigned int objnr;
+	unsigned long offset;
+
+	/* Find and validate object. */
+	cachep = page->slab_cache;
+	objnr = obj_to_index(cachep, page, (void *)ptr);
+	BUG_ON(objnr >= cachep->num);
+
+	/* Find offset within object. */
+	offset = ptr - index_to_obj(cachep, page, objnr) - obj_offset(cachep);
+
+	/* Allow address range falling entirely within object size. */
+	if (offset <= cachep->object_size && n <= cachep->object_size - offset)
+		return NULL;
+
+	return cachep->name;
+}
+#endif /* CONFIG_HARDENED_USERCOPY */
+
 /**
  * ksize - get the actual amount of memory allocated for a given object
  * @objp: Pointer to the object
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
