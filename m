Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 0C9F16B0070
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 17:00:47 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] thp: avoid atomic64_read in pmd_read_atomic for 32bit PAE
Date: Thu,  7 Jun 2012 23:00:33 +0200
Message-Id: <1339102833-12358-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <20120607190414.GF21339@redhat.com>
References: <20120607190414.GF21339@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>
Cc: 676360@bugs.debian.org, xen-devel@lists.xensource.com, Jonathan Nieder <jrnieder@gmail.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>, stable@vger.kernel.org, alan@lxorguk.ukuu.org.uk, Ulrich Obergfell <uobergfe@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Petr Matousek <pmatouse@redhat.com>, Rik van Riel <riel@redhat.com>, Jan Beulich <jbeulich@suse.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

In the x86 32bit PAE CONFIG_TRANSPARENT_HUGEPAGE=y case while holding
the mmap_sem for reading, cmpxchg8b cannot be used to read pmd
contents under Xen.

So instead of dealing only with "consistent" pmdvals in
pmd_none_or_trans_huge_or_clear_bad() (which would be conceptually
simpler) we let pmd_none_or_trans_huge_or_clear_bad() deal with pmdvals
where the low 32bit and high 32bit could be inconsistent (to avoid
having to use cmpxchg8b).

The only guarantee we get from pmd_read_atomic is that if the low part
of the pmd was found null, the high part will be null too (so the pmd
will be considered unstable). And if the low part of the pmd is found
"stable" later, then it means the whole pmd was read atomically
(because after a pmd is stable, neither MADV_DONTNEED nor page faults
can alter it anymore, and we read the high part after the low part).

In the 32bit PAE x86 case, it is enough to read the low part of the
pmdval atomically to declare the pmd as "stable" and that's true for
THP and no THP, furthermore in the THP case we also have a barrier()
that will prevent any inconsistent pmdvals to be cached by a later
re-read of the *pmd.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/include/asm/pgtable-3level.h |   30 +++++++++++++++++-------------
 include/asm-generic/pgtable.h         |   10 ++++++++++
 2 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index 43876f1..cb00ccc 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -47,16 +47,26 @@ static inline void native_set_pte(pte_t *ptep, pte_t pte)
  * they can run pmd_offset_map_lock or pmd_trans_huge or other pmd
  * operations.
  *
- * Without THP if the mmap_sem is hold for reading, the
- * pmd can only transition from null to not null while pmd_read_atomic runs.
- * So there's no need of literally reading it atomically.
+ * Without THP if the mmap_sem is hold for reading, the pmd can only
+ * transition from null to not null while pmd_read_atomic runs. So
+ * we can always return atomic pmd values with this function.
  *
  * With THP if the mmap_sem is hold for reading, the pmd can become
- * THP or null or point to a pte (and in turn become "stable") at any
- * time under pmd_read_atomic, so it's mandatory to read it atomically
- * with cmpxchg8b.
+ * trans_huge or none or point to a pte (and in turn become "stable")
+ * at any time under pmd_read_atomic. We could read it really
+ * atomically here with a atomic64_read for the THP enabled case (and
+ * it would be a whole lot simpler), but to avoid using cmpxchg8b we
+ * only return an atomic pmdval if the low part of the pmdval is later
+ * found stable (i.e. pointing to a pte). And we're returning a none
+ * pmdval if the low part of the pmd is none. In some cases the high
+ * and low part of the pmdval returned may not be consistent if THP is
+ * enabled (the low part may point to previously mapped hugepage,
+ * while the high part may point to a more recently mapped hugepage),
+ * but pmd_none_or_trans_huge_or_clear_bad() only needs the low part
+ * of the pmd to be read atomically to decide if the pmd is unstable
+ * or not, with the only exception of when the low part of the pmd is
+ * zero in which case we return a none pmd.
  */
-#ifndef CONFIG_TRANSPARENT_HUGEPAGE
 static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
 {
 	pmdval_t ret;
@@ -74,12 +84,6 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
 
 	return (pmd_t) { ret };
 }
-#else /* CONFIG_TRANSPARENT_HUGEPAGE */
-static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
-{
-	return (pmd_t) { atomic64_read((atomic64_t *)pmdp) };
-}
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 static inline void native_set_pte_atomic(pte_t *ptep, pte_t pte)
 {
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index ae39c4b..0ff87ec 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -484,6 +484,16 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
 	/*
 	 * The barrier will stabilize the pmdval in a register or on
 	 * the stack so that it will stop changing under the code.
+	 *
+	 * When CONFIG_TRANSPARENT_HUGEPAGE=y on x86 32bit PAE,
+	 * pmd_read_atomic is allowed to return a not atomic pmdval
+	 * (for example pointing to an hugepage that has never been
+	 * mapped in the pmd). The below checks will only care about
+	 * the low part of the pmd with 32bit PAE x86 anyway, with the
+	 * exception of pmd_none(). So the important thing is that if
+	 * the low part of the pmd is found null, the high part will
+	 * be also null or the pmd_none() check below would be
+	 * confused.
 	 */
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	barrier();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
