Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 57F106B0260
	for <linux-mm@kvack.org>; Sun, 27 Mar 2016 15:47:54 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id fl4so82541999pad.0
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 12:47:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 16si18201993pfo.244.2016.03.27.12.47.48
        for <linux-mm@kvack.org>;
        Sun, 27 Mar 2016 12:47:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/4] page-flags: generate page-flags helpers with script
Date: Sun, 27 Mar 2016 22:47:37 +0300
Message-Id: <1459108060-69891-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160327194649.GA9638@node.shutemov.name>
References: <20160327194649.GA9638@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

scripts/mkpageflags.sh generates include/generated/page-flags.h using
directive in mm/page-flags.tlb.

Format of the mm/page-flags.tlb: lines not started with capital letter,
just copied. Lines which starts with capital letter are rules to
generate page-flags helper:

<uname>	<lname>	<policy> <required-helpers>

Result of generation is set of helper macros, not functions. It's
required for future extension.

Type safety is controlled with __builtin_types_compatible_p() check.

Not-yet-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Kbuild                     |  30 +++++--
 include/linux/page-flags.h | 217 +--------------------------------------------
 mm/page-flags.tbl          | 102 +++++++++++++++++++++
 scripts/mkpageflags.sh     | 151 +++++++++++++++++++++++++++++++
 4 files changed, 279 insertions(+), 221 deletions(-)
 create mode 100644 mm/page-flags.tbl
 create mode 100755 scripts/mkpageflags.sh

diff --git a/Kbuild b/Kbuild
index f55cefd9bf29..405c7145af95 100644
--- a/Kbuild
+++ b/Kbuild
@@ -3,8 +3,9 @@
 # This file takes care of the following:
 # 1) Generate bounds.h
 # 2) Generate timeconst.h
-# 3) Generate asm-offsets.h (may need bounds.h and timeconst.h)
-# 4) Check for missing system calls
+# 3) Generate page-flags.h
+# 4) Generate asm-offsets.h (may need bounds.h, timeconst.h and page-flags.h)
+# 5) Check for missing system calls
 
 # Default sed regexp - multiline due to syntax constraints
 define sed-y
@@ -66,7 +67,25 @@ $(obj)/$(timeconst-file): kernel/time/timeconst.bc FORCE
 	$(call filechk,gentimeconst)
 
 #####
-# 3) Generate asm-offsets.h
+# 3) Generate page-flags.h
+
+pageflags-file := include/generated/page-flags.h
+
+targets += $(pageflags-file)
+
+quiet_cmd_genpageflags = GEN     $@
+define cmd_genpageflags
+	$(srctree)/scripts/mkpageflags.sh <$< >$@
+endef
+define filechk_genpageflags
+	$(srctree)/scripts/mkpageflags.sh <$<
+endef
+
+$(obj)/$(pageflags-file): mm/page-flags.tbl FORCE
+	$(call filechk,genpageflags)
+
+#####
+# 4) Generate asm-offsets.h
 #
 
 offsets-file := include/generated/asm-offsets.h
@@ -76,7 +95,8 @@ targets += arch/$(SRCARCH)/kernel/asm-offsets.s
 
 # We use internal kbuild rules to avoid the "is up to date" message from make
 arch/$(SRCARCH)/kernel/asm-offsets.s: arch/$(SRCARCH)/kernel/asm-offsets.c \
-                                      $(obj)/$(timeconst-file) $(obj)/$(bounds-file) FORCE
+                                      $(obj)/$(timeconst-file) $(obj)/$(bounds-file) \
+                                      $(obj)/$(pageflags-file) FORCE
 	$(Q)mkdir -p $(dir $@)
 	$(call if_changed_dep,cc_s_c)
 
@@ -84,7 +104,7 @@ $(obj)/$(offsets-file): arch/$(SRCARCH)/kernel/asm-offsets.s FORCE
 	$(call filechk,offsets,__ASM_OFFSETS_H__)
 
 #####
-# 4) Check for missing system calls
+# 5) Check for missing system calls
 #
 
 always += missing-syscalls
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index f4ed4f1b0c77..d111caad2a22 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -154,202 +154,7 @@ static __always_inline int PageCompound(struct page *page)
 	return test_bit(PG_head, &page->flags) || PageTail(page);
 }
 
-/*
- * Page flags policies wrt compound pages
- *
- * PF_ANY:
- *     the page flag is relevant for small, head and tail pages.
- *
- * PF_HEAD:
- *     for compound page all operations related to the page flag applied to
- *     head page.
- *
- * PF_NO_TAIL:
- *     modifications of the page flag must be done on small or head pages,
- *     checks can be done on tail pages too.
- *
- * PF_NO_COMPOUND:
- *     the page flag is not relevant for compound pages.
- */
-#define PF_ANY(page, enforce)	page
-#define PF_HEAD(page, enforce)	compound_head(page)
-#define PF_NO_TAIL(page, enforce) ({					\
-		VM_BUG_ON_PGFLAGS(enforce && PageTail(page), page);	\
-		compound_head(page);})
-#define PF_NO_COMPOUND(page, enforce) ({				\
-		VM_BUG_ON_PGFLAGS(enforce && PageCompound(page), page);	\
-		page;})
-
-/*
- * Macros to create function definitions for page flags
- */
-#define TESTPAGEFLAG(uname, lname, policy)				\
-static __always_inline int Page##uname(struct page *page)		\
-	{ return test_bit(PG_##lname, &policy(page, 0)->flags); }
-
-#define SETPAGEFLAG(uname, lname, policy)				\
-static __always_inline void SetPage##uname(struct page *page)		\
-	{ set_bit(PG_##lname, &policy(page, 1)->flags); }
-
-#define CLEARPAGEFLAG(uname, lname, policy)				\
-static __always_inline void ClearPage##uname(struct page *page)		\
-	{ clear_bit(PG_##lname, &policy(page, 1)->flags); }
-
-#define __SETPAGEFLAG(uname, lname, policy)				\
-static __always_inline void __SetPage##uname(struct page *page)		\
-	{ __set_bit(PG_##lname, &policy(page, 1)->flags); }
-
-#define __CLEARPAGEFLAG(uname, lname, policy)				\
-static __always_inline void __ClearPage##uname(struct page *page)	\
-	{ __clear_bit(PG_##lname, &policy(page, 1)->flags); }
-
-#define TESTSETFLAG(uname, lname, policy)				\
-static __always_inline int TestSetPage##uname(struct page *page)	\
-	{ return test_and_set_bit(PG_##lname, &policy(page, 1)->flags); }
-
-#define TESTCLEARFLAG(uname, lname, policy)				\
-static __always_inline int TestClearPage##uname(struct page *page)	\
-	{ return test_and_clear_bit(PG_##lname, &policy(page, 1)->flags); }
-
-#define PAGEFLAG(uname, lname, policy)					\
-	TESTPAGEFLAG(uname, lname, policy)				\
-	SETPAGEFLAG(uname, lname, policy)				\
-	CLEARPAGEFLAG(uname, lname, policy)
-
-#define __PAGEFLAG(uname, lname, policy)				\
-	TESTPAGEFLAG(uname, lname, policy)				\
-	__SETPAGEFLAG(uname, lname, policy)				\
-	__CLEARPAGEFLAG(uname, lname, policy)
-
-#define TESTSCFLAG(uname, lname, policy)				\
-	TESTSETFLAG(uname, lname, policy)				\
-	TESTCLEARFLAG(uname, lname, policy)
-
-#define TESTPAGEFLAG_FALSE(uname)					\
-static inline int Page##uname(const struct page *page) { return 0; }
-
-#define SETPAGEFLAG_NOOP(uname)						\
-static inline void SetPage##uname(struct page *page) {  }
-
-#define CLEARPAGEFLAG_NOOP(uname)					\
-static inline void ClearPage##uname(struct page *page) {  }
-
-#define __CLEARPAGEFLAG_NOOP(uname)					\
-static inline void __ClearPage##uname(struct page *page) {  }
-
-#define TESTSETFLAG_FALSE(uname)					\
-static inline int TestSetPage##uname(struct page *page) { return 0; }
-
-#define TESTCLEARFLAG_FALSE(uname)					\
-static inline int TestClearPage##uname(struct page *page) { return 0; }
-
-#define PAGEFLAG_FALSE(uname) TESTPAGEFLAG_FALSE(uname)			\
-	SETPAGEFLAG_NOOP(uname) CLEARPAGEFLAG_NOOP(uname)
-
-#define TESTSCFLAG_FALSE(uname)						\
-	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
-
-__PAGEFLAG(Locked, locked, PF_NO_TAIL)
-PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
-PAGEFLAG(Referenced, referenced, PF_HEAD)
-	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
-	__SETPAGEFLAG(Referenced, referenced, PF_HEAD)
-PAGEFLAG(Dirty, dirty, PF_HEAD) TESTSCFLAG(Dirty, dirty, PF_HEAD)
-	__CLEARPAGEFLAG(Dirty, dirty, PF_HEAD)
-PAGEFLAG(LRU, lru, PF_HEAD) __CLEARPAGEFLAG(LRU, lru, PF_HEAD)
-PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
-	TESTCLEARFLAG(Active, active, PF_HEAD)
-__PAGEFLAG(Slab, slab, PF_NO_TAIL)
-__PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
-PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
-
-/* Xen */
-PAGEFLAG(Pinned, pinned, PF_NO_COMPOUND)
-	TESTSCFLAG(Pinned, pinned, PF_NO_COMPOUND)
-PAGEFLAG(SavePinned, savepinned, PF_NO_COMPOUND);
-PAGEFLAG(Foreign, foreign, PF_NO_COMPOUND);
-
-PAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
-	__CLEARPAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
-PAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
-	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
-	__SETPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
-
-/*
- * Private page markings that may be used by the filesystem that owns the page
- * for its own purposes.
- * - PG_private and PG_private_2 cause releasepage() and co to be invoked
- */
-PAGEFLAG(Private, private, PF_ANY) __SETPAGEFLAG(Private, private, PF_ANY)
-	__CLEARPAGEFLAG(Private, private, PF_ANY)
-PAGEFLAG(Private2, private_2, PF_ANY) TESTSCFLAG(Private2, private_2, PF_ANY)
-PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
-	TESTCLEARFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
-
-/*
- * Only test-and-set exist for PG_writeback.  The unconditional operators are
- * risky: they bypass page accounting.
- */
-TESTPAGEFLAG(Writeback, writeback, PF_NO_COMPOUND)
-	TESTSCFLAG(Writeback, writeback, PF_NO_COMPOUND)
-PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_COMPOUND)
-
-/* PG_readahead is only used for reads; PG_reclaim is only for writes */
-PAGEFLAG(Reclaim, reclaim, PF_NO_COMPOUND)
-	TESTCLEARFLAG(Reclaim, reclaim, PF_NO_COMPOUND)
-PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
-	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
-
-#ifdef CONFIG_HIGHMEM
-/*
- * Must use a macro here due to header dependency issues. page_zone() is not
- * available at this point.
- */
-#define PageHighMem(__p) is_highmem_idx(page_zonenum(__p))
-#else
-PAGEFLAG_FALSE(HighMem)
-#endif
-
-#ifdef CONFIG_SWAP
-PAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
-#else
-PAGEFLAG_FALSE(SwapCache)
-#endif
-
-PAGEFLAG(Unevictable, unevictable, PF_HEAD)
-	__CLEARPAGEFLAG(Unevictable, unevictable, PF_HEAD)
-	TESTCLEARFLAG(Unevictable, unevictable, PF_HEAD)
-
-#ifdef CONFIG_MMU
-PAGEFLAG(Mlocked, mlocked, PF_NO_TAIL)
-	__CLEARPAGEFLAG(Mlocked, mlocked, PF_NO_TAIL)
-	TESTSCFLAG(Mlocked, mlocked, PF_NO_TAIL)
-#else
-PAGEFLAG_FALSE(Mlocked) __CLEARPAGEFLAG_NOOP(Mlocked)
-	TESTSCFLAG_FALSE(Mlocked)
-#endif
-
-#ifdef CONFIG_ARCH_USES_PG_UNCACHED
-PAGEFLAG(Uncached, uncached, PF_NO_COMPOUND)
-#else
-PAGEFLAG_FALSE(Uncached)
-#endif
-
-#ifdef CONFIG_MEMORY_FAILURE
-PAGEFLAG(HWPoison, hwpoison, PF_ANY)
-TESTSCFLAG(HWPoison, hwpoison, PF_ANY)
-#define __PG_HWPOISON (1UL << PG_hwpoison)
-#else
-PAGEFLAG_FALSE(HWPoison)
-#define __PG_HWPOISON 0
-#endif
-
-#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
-TESTPAGEFLAG(Young, young, PF_ANY)
-SETPAGEFLAG(Young, young, PF_ANY)
-TESTCLEARFLAG(Young, young, PF_ANY)
-PAGEFLAG(Idle, idle, PF_ANY)
-#endif
+#include <generated/page-flags.h>
 
 /*
  * On an anonymous page mapped into a user virtual memory area,
@@ -390,8 +195,6 @@ static __always_inline int PageKsm(struct page *page)
 	return ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) ==
 				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
 }
-#else
-TESTPAGEFLAG_FALSE(Ksm)
 #endif
 
 u64 stable_page_flags(struct page *page);
@@ -434,8 +237,6 @@ static __always_inline void SetPageUptodate(struct page *page)
 	set_bit(PG_uptodate, &page->flags);
 }
 
-CLEARPAGEFLAG(Uptodate, uptodate, PF_NO_TAIL)
-
 int test_clear_page_writeback(struct page *page);
 int __test_set_page_writeback(struct page *page, bool keep_write);
 
@@ -454,8 +255,6 @@ static inline void set_page_writeback_keepwrite(struct page *page)
 	test_set_page_writeback_keepwrite(page);
 }
 
-__PAGEFLAG(Head, head, PF_ANY) CLEARPAGEFLAG(Head, head, PF_ANY)
-
 static __always_inline void set_compound_head(struct page *page, struct page *head)
 {
 	WRITE_ONCE(page->compound_head, (unsigned long)head + 1);
@@ -481,8 +280,6 @@ int PageHuge(struct page *page);
 int PageHeadHuge(struct page *page);
 bool page_huge_active(struct page *page);
 #else
-TESTPAGEFLAG_FALSE(Huge)
-TESTPAGEFLAG_FALSE(HeadHuge)
 
 static inline bool page_huge_active(struct page *page)
 {
@@ -555,14 +352,6 @@ static inline int TestClearPageDoubleMap(struct page *page)
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	return test_and_clear_bit(PG_double_map, &page[1].flags);
 }
-
-#else
-TESTPAGEFLAG_FALSE(TransHuge)
-TESTPAGEFLAG_FALSE(TransCompound)
-TESTPAGEFLAG_FALSE(TransTail)
-TESTPAGEFLAG_FALSE(DoubleMap)
-	TESTSETFLAG_FALSE(DoubleMap)
-	TESTCLEARFLAG_FALSE(DoubleMap)
 #endif
 
 /*
@@ -684,10 +473,6 @@ static inline int page_has_private(struct page *page)
 	return !!(page->flags & PAGE_FLAGS_PRIVATE);
 }
 
-#undef PF_ANY
-#undef PF_HEAD
-#undef PF_NO_TAIL
-#undef PF_NO_COMPOUND
 #endif /* !__GENERATING_BOUNDS_H */
 
 #endif	/* PAGE_FLAGS_H */
diff --git a/mm/page-flags.tbl b/mm/page-flags.tbl
new file mode 100644
index 000000000000..1eb2f90f487a
--- /dev/null
+++ b/mm/page-flags.tbl
@@ -0,0 +1,102 @@
+Locked		locked		no_tail		test __set __clear
+Error		error		no_compound	test set clear testclear
+Referenced	referenced	head		test set clear testclear __set
+Dirty		dirty		head		test set clear testset testclear __clear
+LRU		lru		head		test set clear __clear
+Active		active		head		test set clear testclear __clear
+Slab		slab		no_tail		test __set __clear
+SlobFree	slob_free	no_tail		test __set __clear
+
+/* Used by some filesystems */
+Checked		checked		no_compound	test set clear
+
+/* Xen */
+Pinned		pinned		no_compound	test set clear testset testclear
+SavePinned	savepinned	no_compound	test set clear
+Foreign		foreign		no_compound	test set clear
+
+Reserved	reserved	no_compound	test set clear __clear
+SwapBacked	swapbacked	no_tail		test set clear __set __clear
+
+/*
+ * Private page markings that may be used by the filesystem that owns the page
+ * for its own purposes.
+ * - PG_private and PG_private_2 cause releasepage() and co to be invoked
+ */
+
+Private		private		any		test set clear __set __clear
+Private2	private_2	any		test set clear testset testclear
+
+/*
+ * Only test-and-set exist for PG_writeback.  The unconditional operators are
+ * risky: they bypass page accounting.
+ */
+Writeback	writeback	no_compound	test testset testclear
+MappedToDisk	mappedtodisk	no_compound	test set clear
+
+/* PG_readahead is only used for reads; PG_reclaim is only for writes */
+Reclaim		reclaim		no_compound	test set clear testclear
+Readahead	reclaim		no_compound	test set clear testclear
+
+#ifdef CONFIG_HIGHMEM
+/*
+ * Must use a macro here due to header dependency issues. page_zone() is not
+ * available at this point.
+ */
+#define PageHighMem(__p) is_highmem_idx(page_zonenum(__p))
+#else
+HighMem		null		any		testfalse setnoop clearnoop
+#endif
+
+#ifdef CONFIG_SWAP
+SwapCache	swapcache	no_compound	test set clear
+#else
+SwapCache	null		any		testfalse setnoop clearnoop
+#endif
+
+Unevictable	unevictable	head		test set clear testclear __clear
+
+#ifdef CONFIG_MMU
+Mlocked		mlocked		no_tail		test set clear testset testclear __clear
+#else
+Mlocked		null		any		testfalse setnoop clearnoop testsetfalse testclearfalse __clearnoop
+#endif
+
+#ifdef CONFIG_ARCH_USES_PG_UNCACHED
+Uncached	uncached	no_compound	test set clear
+#else
+Uncached	uncached	any		testfalse setnoop clearnoop
+#endif
+
+#ifdef CONFIG_MEMORY_FAILURE
+HWPoison	hwpoison	any		test set clear testset testclear
+#define __PG_HWPOISON (1UL << PG_hwpoison)
+#else
+HWPoison	hwpoison	any		testfalse setnoop clearnoop
+#define __PG_HWPOISON 0
+#endif
+
+#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
+Young		young		any		test set testclear
+Idle		idle		any		test set clear
+#endif
+
+#ifndef CONFIG_KSM
+Ksm		null		any		testfalse
+#endif
+
+Uptodate	uptodate	no_tail		clear
+
+Head		head		any		test clear __set __clear
+
+#ifndef CONFIG_HUGETLB_PAGE
+Huge		null		any		testfalse
+HeadHuge	null		any		testfalse
+#endif
+
+#ifndef CONFIG_TRANSPARENT_HUGEPAGE
+TransHuge	null		any		testfalse
+TransCompound	null		any		testfalse
+TransTail	null		any		testfalse
+DoubleMap	null		any		testfalse testsetfalse testclearfalse
+#endif
diff --git a/scripts/mkpageflags.sh b/scripts/mkpageflags.sh
new file mode 100755
index 000000000000..29d46bccaea4
--- /dev/null
+++ b/scripts/mkpageflags.sh
@@ -0,0 +1,151 @@
+#!/bin/sh -efu
+
+fatal() {
+	echo "$@" >&2
+	exit 1
+}
+
+any() {
+	echo "(__p)"
+}
+
+head() {
+	echo "compound_head(__p)"
+}
+
+no_tail() {
+	local enforce="${1:+VM_BUG_ON_PGFLAGS(PageTail(__p), __p);}"
+
+	echo "({$enforce compound_head(__p);})"
+}
+
+no_compound() {
+	local enforce="${1:+VM_BUG_ON_PGFLAGS(PageCompound(__p), __p);}"
+
+	echo "({$enforce __p;})"
+}
+
+generate_test() {
+	local op="$1"; shift
+	local uname="$1"; shift
+	local lname="$1"; shift
+	local page="$1"; shift
+
+	cat <<EOF
+#define $uname(__p) ({								\\
+	int ret;								\\
+	if (__builtin_types_compatible_p(typeof(*(__p)), struct page))		\\
+		ret = $op(PG_$lname, &$page->flags);				\\
+	else									\\
+		BUILD_BUG();							\\
+	ret;									\\
+})
+
+EOF
+}
+
+generate_mod() {
+	local op="$1"; shift
+	local uname="$1"; shift
+	local lname="$1"; shift
+	local page="$1"; shift
+
+	cat <<EOF
+#define $uname(__p) do {							\\
+	if (__builtin_types_compatible_p(typeof(*(__p)), struct page))		\\
+		$op(PG_$lname, &$page->flags);					\\
+	else									\\
+		BUILD_BUG();							\\
+} while (0)
+
+EOF
+}
+
+generate_false() {
+	local uname="$1"; shift
+
+	cat <<EOF
+#define $uname(__p) 0
+
+EOF
+}
+
+generate_noop() {
+	local uname="$1"; shift
+
+	cat <<EOF
+#define $uname(__p) do { } while (0)
+
+EOF
+}
+
+generate_helper() {
+	local helper="$1"; shift
+	local uname="$1"; shift
+	local lname="$1"; shift
+	local policy="$1"; shift
+
+	case "$helper" in
+		test)
+			generate_test 'test_bit' "Page$uname" "$lname" "$($policy)"
+			;;
+		set)
+			generate_mod 'set_bit' "SetPage$uname" "$lname" "$($policy)"
+			;;
+		clear)
+			generate_mod 'clear_bit' "ClearPage$uname" "$lname" "$($policy)"
+			;;
+		testset)
+			generate_test 'test_and_set_bit' "TestSetPage$uname" "$lname" "$($policy 1)"
+			;;
+		testclear)
+			generate_test 'test_and_clear_bit' "TestClearPage$uname" "$lname" "$($policy 1)"
+			;;
+		__set)
+			generate_mod '__set_bit' "__SetPage$uname" "$lname" "$($policy)"
+			;;
+		__clear)
+			generate_mod '__clear_bit' "__ClearPage$uname" "$lname" "$($policy)"
+			;;
+		testfalse)
+			generate_false "Page$uname"
+			;;
+		setnoop)
+			generate_noop "SetPage$uname"
+			;;
+		clearnoop)
+			generate_noop "ClearPage$uname"
+			;;
+		testsetfalse)
+			generate_false "TestSetPage$uname"
+			;;
+		testclearfalse)
+			generate_false "TestClearPage$uname"
+			;;
+		__clearnoop)
+			generate_noop "__ClearPage$uname"
+			;;
+		*)
+			fatal "$helper: unknown helper"
+			;;
+	esac
+}
+
+generate_helpers() {
+	while read uname lname policy helpers; do
+		for helper in $helpers; do
+			generate_helper "$helper" "$uname" "$lname" "$policy"
+		done
+	done
+}
+
+while read l; do
+	case "$l" in
+		[A-Z]*)
+			echo "$l" | generate_helpers
+			;;
+		*)
+			echo "$l"
+			;;
+	esac
+done
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
