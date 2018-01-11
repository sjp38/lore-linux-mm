Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5230B6B0268
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:03:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d72so1679327pga.7
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:03:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3sor6085861pld.11.2018.01.10.18.03.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:03:28 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 08/38] usercopy: Allow strict enforcement of whitelists
Date: Wed, 10 Jan 2018 18:02:40 -0800
Message-Id: <1515636190-24061-9-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
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
index 8bf14d9762ec..231abc8976c5 100644
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
index 1c02f6e94235..b9b0df620bb9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4426,7 +4426,8 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 	 * to be a temporary method to find any missing usercopy
 	 * whitelists.
 	 */
-	if (offset <= cachep->object_size &&
+	if (usercopy_fallback &&
+	    offset <= cachep->object_size &&
 	    n <= cachep->object_size - offset) {
 		usercopy_warn("SLAB object", cachep->name, to_user, offset, n);
 		return;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index fc3e66bdce75..a51f65408637 100644
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
index 6d9b1e7d3226..862d835b3042 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3859,7 +3859,8 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 	 * whitelists.
 	 */
 	object_size = slab_ksize(s);
-	if (offset <= object_size && n <= object_size - offset) {
+	if (usercopy_fallback &&
+	    offset <= object_size && n <= object_size - offset) {
 		usercopy_warn("SLUB object", s->name, to_user, offset, n);
 		return;
 	}
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
