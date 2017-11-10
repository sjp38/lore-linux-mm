Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 09FE7440D2B
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:44 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 190so5146628pgh.16
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:44 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a33si9361761pla.691.2017.11.10.11.31.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:42 -0800 (PST)
Subject: [PATCH 09/30] x86, kaiser: only populate shadow page tables for userspace
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:13 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193113.E35BC3BF@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

KAISER has two copies of the page tables: one for the kernel and
one for when running in userspace.  There is also a kernel
portion of each of the page tables: the part that *maps* the
kernel.

The kernel portion is relatively static and uses pre-populated
PGDs.  Nobody ever calls set_pgd() on the kernel portion during
normal operation.

The userspace portion of the page tables is updated frequently as
userspace pages are mapped and page table pages are allocated.
These updates of the userspace *portion* of the tables need to be
reflected into both the kernel and user/shadow copies.

The original KAISER patches did this by effectively looking at
the address that is being updated.  If it is <PAGE_OFFSET,
it is considered to be doing an update for the userspace portion of the page
tables and must make an entry in the shadow.

However, this has a wrinkle: there are a few places where low
addresses are used in supervisor (kernel) mode.  When EFI calls
are made, they use what are traditionally user addresses in
supervisor mode and trip over these checks.  The trampoline code
that used for booting secondary CPUs has a similar issue.

Remember, there are two things that KAISER needs performed on a
userspace PGD:

 1. Populate the shadow itself
 2. Poison the kernel PGD so it can not be used by userspace.

This patch only performs these actions when dealing with a user
address *and* the PGD has _PAGE_USER set.  That way, in-kernel
users of low addresses typically used by userspace are not
accidentally poisoned.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/pgtable_64.h |   94 +++++++++++++++++++++++-------------
 1 file changed, 61 insertions(+), 33 deletions(-)

diff -puN arch/x86/include/asm/pgtable_64.h~kaiser-set-pgd-careful-plus-NX arch/x86/include/asm/pgtable_64.h
--- a/arch/x86/include/asm/pgtable_64.h~kaiser-set-pgd-careful-plus-NX	2017-11-10 11:22:09.932244947 -0800
+++ b/arch/x86/include/asm/pgtable_64.h	2017-11-10 11:22:09.935244947 -0800
@@ -177,38 +177,76 @@ static inline p4d_t *native_get_normal_p
 /*
  * Page table pages are page-aligned.  The lower half of the top
  * level is used for userspace and the top half for the kernel.
- * This returns true for user pages that need to get copied into
- * both the user and kernel copies of the page tables, and false
- * for kernel pages that should only be in the kernel copy.
+ *
+ * Returns true for parts of the PGD that map userspace and
+ * false for the parts that map the kernel.
  */
-static inline bool is_userspace_pgd(void *__ptr)
+static inline bool pgdp_maps_userspace(void *__ptr)
 {
 	unsigned long ptr = (unsigned long)__ptr;
 
 	return ((ptr % PAGE_SIZE) < (PAGE_SIZE / 2));
 }
 
+/*
+ * Does this PGD allow access via userspace?
+ */
+static inline bool pgd_userspace_access(pgd_t pgd)
+{
+	return (pgd.pgd & _PAGE_USER);
+}
+
+/*
+ * Returns the pgd_t that the kernel should use in its page tables.
+ */
+static inline pgd_t kaiser_set_shadow_pgd(pgd_t *pgdp, pgd_t pgd)
+{
+#ifdef CONFIG_KAISER
+	if (pgd_userspace_access(pgd)) {
+		if (pgdp_maps_userspace(pgdp)) {
+			/*
+			 * The user/shadow page tables get the full
+			 * PGD, accessible to userspace:
+			 */
+			native_get_shadow_pgd(pgdp)->pgd = pgd.pgd;
+			/*
+			 * For the copy of the pgd that the kernel
+			 * uses, make it unusable to userspace.  This
+			 * ensures if we get out to userspace with the
+			 * wrong CR3 value, userspace will crash
+			 * instead of running.
+			 */
+			pgd.pgd |= _PAGE_NX;
+		}
+	} else if (!pgd.pgd) {
+		/*
+		 * We are clearing the PGD and can not check  _PAGE_USER
+		 * in the zero'd PGD.  We never do this on the
+		 * pre-populated kernel PGDs, except for pgd_bad().
+		 */
+		if (pgdp_maps_userspace(pgdp)) {
+			native_get_shadow_pgd(pgdp)->pgd = pgd.pgd;
+		} else {
+			/*
+			 * Uh, we are very confused.  We have been
+			 * asked to clear a PGD that is in the kernel
+			 * part of the address space.  We preallocated
+			 * all the KAISER PGDs, so this should never
+			 * happen.
+			 */
+			WARN_ON_ONCE(1);
+		}
+	}
+#endif
+	/* return the copy of the PGD we want the kernel to use: */
+	return pgd;
+}
+
+
 static inline void native_set_p4d(p4d_t *p4dp, p4d_t p4d)
 {
 #if defined(CONFIG_KAISER) && !defined(CONFIG_X86_5LEVEL)
-	/*
-	 * set_pgd() does not get called when we are running
-	 * CONFIG_X86_5LEVEL=y.  So, just hack around it.  We
-	 * know here that we have a p4d but that it is really at
-	 * the top level of the page tables; it is really just a
-	 * pgd.
-	 */
-	/* Do we need to also populate the shadow p4d? */
-	if (is_userspace_pgd(p4dp))
-		native_get_shadow_p4d(p4dp)->pgd = p4d.pgd;
-	/*
-	 * Even if the entry is *mapping* userspace, ensure
-	 * that userspace can not use it.  This way, if we
-	 * get out to userspace with the wrong CR3 value,
-	 * userspace will crash instead of running.
-	 */
-	if (!p4d.pgd.pgd)
-		p4dp->pgd.pgd = p4d.pgd.pgd | _PAGE_NX;
+	p4dp->pgd = kaiser_set_shadow_pgd(&p4dp->pgd, p4d.pgd);
 #else /* CONFIG_KAISER */
 	*p4dp = p4d;
 #endif
@@ -226,17 +264,7 @@ static inline void native_p4d_clear(p4d_
 static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
 #ifdef CONFIG_KAISER
-	/* Do we need to also populate the shadow pgd? */
-	if (is_userspace_pgd(pgdp))
-		native_get_shadow_pgd(pgdp)->pgd = pgd.pgd;
-	/*
-	 * Even if the entry is mapping userspace, ensure
-	 * that it is unusable for userspace.  This way,
-	 * if we get out to userspace with the wrong CR3
-	 * value, userspace will crash instead of running.
-	 */
-	if (!pgd_none(pgd))
-		pgdp->pgd = pgd.pgd | _PAGE_NX;
+	*pgdp = kaiser_set_shadow_pgd(pgdp, pgd);
 #else /* CONFIG_KAISER */
 	*pgdp = pgd;
 #endif
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
