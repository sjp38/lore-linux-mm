Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFF096B0261
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 16:04:23 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e26so9353177pgv.16
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 13:04:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor3069163pgn.234.2018.01.09.13.04.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 13:04:22 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 34/36] usercopy: Allow strict enforcement of whitelists
Date: Tue,  9 Jan 2018 12:56:03 -0800
Message-Id: <1515531365-37423-35-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

This introduces CONFIG_HARDENED_USERCOPY_FALLBACK to control the
behavior of hardened usercopy whitelist violations. By default, whitelist
violations will continue to WARN() so that any bad or missing usercopy
whitelists can be discovered without being too disruptive.

If this config is disabled at build time or a system is booted with
"slab_common.usercopy_fallback=0", usercopy whitelists will BUG() instead
of WARN(). This is useful for admins that want to use usercopy whitelists
immediately.

Suggested-by: Matthew Garrett <mjg59@google.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/slab.h |  2 ++
 mm/slab.c            |  3 ++-
 mm/slab_common.c     |  8 ++++++++
 mm/slub.c            |  3 ++-
 security/Kconfig     | 14 ++++++++++++++
 5 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 518f72bf565e..4bef1ed1daa1 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -135,6 +135,8 @@ struct mem_cgroup;
 void __init kmem_cache_init(void);
 bool slab_is_available(void);
 
+extern bool usercopy_fallback;
+
 struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 			size_t align, slab_flags_t flags,
 			void (*ctor)(void *));
diff --git a/mm/slab.c b/mm/slab.c
index 6488066e718a..50539a76a46a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4425,7 +4425,8 @@ int __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 		 * to be a temporary method to find any missing usercopy
 		 * whitelists.
 		 */
-		if (offset <= cachep->object_size &&
+		if (usercopy_fallback &&
+		    offset <= cachep->object_size &&
 		    n <= cachep->object_size - offset) {
 			WARN_ONCE(1, "unexpected usercopy %s with bad or missing whitelist with SLAB object '%s' (offset %lu, size %lu)",
 				  to_user ? "exposure" : "overwrite",
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 6c9e945907b6..8ac2a6320a6c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -31,6 +31,14 @@ LIST_HEAD(slab_caches);
 DEFINE_MUTEX(slab_mutex);
 struct kmem_cache *kmem_cache;
 
+#ifdef CONFIG_HARDENED_USERCOPY
+bool usercopy_fallback __ro_after_init =
+		IS_ENABLED(CONFIG_HARDENED_USERCOPY_FALLBACK);
+module_param(usercopy_fallback, bool, 0400);
+MODULE_PARM_DESC(usercopy_fallback,
+		"WARN instead of reject usercopy whitelist violations");
+#endif
+
 static LIST_HEAD(slab_caches_to_rcu_destroy);
 static void slab_caches_to_rcu_destroy_workfn(struct work_struct *work);
 static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
diff --git a/mm/slub.c b/mm/slub.c
index 2aa4972a2058..1c0ff635d408 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3858,7 +3858,8 @@ int __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 		 * whitelists.
 		 */
 		object_size = slab_ksize(s);
-		if ((offset <= object_size && n <= object_size - offset)) {
+		if (usercopy_fallback &&
+		    (offset <= object_size && n <= object_size - offset)) {
 			WARN_ONCE(1, "unexpected usercopy %s with bad or missing whitelist with SLUB object '%s' (offset %lu size %lu)",
 				  to_user ? "exposure" : "overwrite",
 				  s->name, offset, n);
diff --git a/security/Kconfig b/security/Kconfig
index e8e449444e65..ae457b018da5 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -152,6 +152,20 @@ config HARDENED_USERCOPY
 	  or are part of the kernel text. This kills entire classes
 	  of heap overflow exploits and similar kernel memory exposures.
 
+config HARDENED_USERCOPY_FALLBACK
+	bool "Allow usercopy whitelist violations to fallback to object size"
+	depends on HARDENED_USERCOPY
+	default y
+	help
+	  This is a temporary option that allows missing usercopy whitelists
+	  to be discovered via a WARN() to the kernel log, instead of
+	  rejecting the copy, falling back to non-whitelisted hardened
+	  usercopy that checks the slab allocation size instead of the
+	  whitelist size. This option will be removed once it seems like
+	  all missing usercopy whitelists have been identified and fixed.
+	  Booting with "slab_common.usercopy_fallback=Y/N" can change
+	  this setting.
+
 config HARDENED_USERCOPY_PAGESPAN
 	bool "Refuse to copy allocations that span multiple pages"
 	depends on HARDENED_USERCOPY
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
