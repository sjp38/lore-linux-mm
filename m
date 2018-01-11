Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82E0E6B025E
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:03:25 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a9so1661212pgf.12
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:03:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w63sor5038572pfd.3.2018.01.10.18.03.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:03:24 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 02/38] usercopy: Enhance and rename report_usercopy()
Date: Wed, 10 Jan 2018 18:02:34 -0800
Message-Id: <1515636190-24061-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

In preparation for refactoring the usercopy checks to pass offset to
the hardened usercopy report, this renames report_usercopy() to the
more accurate usercopy_abort(), marks it as noreturn because it is,
adds a hopefully helpful comment for anyone investigating such reports,
makes the function available to the slab allocators, and adds new "detail"
and "offset" arguments.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/slab.h             |  6 ++++++
 mm/usercopy.c         | 24 +++++++++++++++++++-----
 tools/objtool/check.c |  1 +
 3 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index ad657ffa44e5..7d29e69ac310 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -526,4 +526,10 @@ static inline int cache_random_seq_create(struct kmem_cache *cachep,
 static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
 #endif /* CONFIG_SLAB_FREELIST_RANDOM */
 
+#ifdef CONFIG_HARDENED_USERCOPY
+void __noreturn usercopy_abort(const char *name, const char *detail,
+			       bool to_user, unsigned long offset,
+			       unsigned long len);
+#endif
+
 #endif /* MM_SLAB_H */
diff --git a/mm/usercopy.c b/mm/usercopy.c
index 5df1e68d4585..8006baa4caac 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -58,11 +58,25 @@ static noinline int check_stack_object(const void *obj, unsigned long len)
 	return GOOD_STACK;
 }
 
-static void report_usercopy(unsigned long len, bool to_user, const char *type)
+/*
+ * If this function is reached, then CONFIG_HARDENED_USERCOPY has found an
+ * unexpected state during a copy_from_user() or copy_to_user() call.
+ * There are several checks being performed on the buffer by the
+ * __check_object_size() function. Normal stack buffer usage should never
+ * trip the checks, and kernel text addressing will always trip the check.
+ * For cache objects, copies must be within the object size.
+ */
+void __noreturn usercopy_abort(const char *name, const char *detail,
+			       bool to_user, unsigned long offset,
+			       unsigned long len)
 {
-	pr_emerg("kernel memory %s attempt detected %s '%s' (%lu bytes)\n",
-		to_user ? "exposure" : "overwrite",
-		to_user ? "from" : "to", type ? : "unknown", len);
+	pr_emerg("Kernel memory %s attempt detected %s %s%s%s%s (offset %lu, size %lu)!\n",
+		 to_user ? "exposure" : "overwrite",
+		 to_user ? "from" : "to",
+		 name ? : "unknown?!",
+		 detail ? " '" : "", detail ? : "", detail ? "'" : "",
+		 offset, len);
+
 	/*
 	 * For greater effect, it would be nice to do do_group_exit(),
 	 * but BUG() actually hooks all the lock-breaking and per-arch
@@ -260,6 +274,6 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 		return;
 
 report:
-	report_usercopy(n, to_user, err);
+	usercopy_abort(err, NULL, to_user, 0, n);
 }
 EXPORT_SYMBOL(__check_object_size);
diff --git a/tools/objtool/check.c b/tools/objtool/check.c
index 9b341584eb1b..ae39444896d4 100644
--- a/tools/objtool/check.c
+++ b/tools/objtool/check.c
@@ -138,6 +138,7 @@ static int __dead_end_function(struct objtool_file *file, struct symbol *func,
 		"__reiserfs_panic",
 		"lbug_with_loc",
 		"fortify_panic",
+		"usercopy_abort",
 	};
 
 	if (func->bind == STB_WEAK)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
