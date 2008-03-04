From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 02/10] Pageflags: Introduce macros to generate page flag functions
Date: Mon, 03 Mar 2008 16:04:54 -0800
Message-ID: <20080304000732.535399640@sgi.com>
References: <20080304000452.514878384@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762974AbYCDAKO@vger.kernel.org>
Content-Disposition: inline; filename=pageflags-add-macros
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Introduce a set of macros that generate functions to handle page flags.


A page flag function group typically starts with either

	SETPAGEFLAG(<part of function name>,<part of PG_ flagname>)

to create a set of page flag operations that are atomic. Or

	__SETPAGEFLAG(<part of function name>,<part of PG_ flagname)

to create a set of page flag operations that are not atomic.


Then additional operations can be added using the following macros

TESTSCFLAG		Create additional atomic test-and-set and
			test-and-clear functions

TESTSETFLAG		Create additional test and set function
TESTCLEARFLAG		Create additional test and clear function
SETPAGEFLAG		Create additional atomic set function
CLEARPAGEFLAG		Create additional atomic clear function
__TESTPAGEFLAG		Create additional non atomic set function
__SETPAGEFLAG		Create additional non atomic clear function

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/page-flags.h |   41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2008-03-03 15:45:20.895497292 -0800
+++ linux-2.6/include/linux/page-flags.h	2008-03-03 15:45:56.827992817 -0800
@@ -105,6 +105,47 @@ enum pageflags {
 };
 
 /*
+ * Macros to create function definitions for page flags
+ */
+#define TESTPAGEFLAG(uname, lname)					\
+static inline int Page##uname(struct page *page) 			\
+			{ return test_bit(PG_##lname, page); }
+
+#define SETPAGEFLAG(uname, lname)					\
+static inline void SetPage##uname(struct page *page)			\
+			{ set_bit(PG_##lname, page); }
+
+#define CLEARPAGEFLAG(uname, lname)					\
+static inline void ClearPage##uname(struct page *page)			\
+			{ clear_bit(PG_##lname, page); }
+
+#define __SETPAGEFLAG(uname, lname)					\
+static inline void __SetPage##uname(struct page *page)			\
+			{ __set_bit(PG_##lname, page); }
+
+#define __CLEARPAGEFLAG(uname, lname)					\
+static inline void __ClearPage##uname(struct page *page)		\
+			{ __clear_bit(PG_##lname, page); }
+
+#define TESTSETFLAG(uname, lname)					\
+static inline int TestSetPage##uname(struct page *page)			\
+		{ return test_and_set_bit(PG_##lname, &page->flags); }
+
+#define TESTCLEARFLAG(uname, lname)					\
+static inline int TestClearPage##uname(struct page *page)		\
+		{ return test_and_clear_bit(PG_##lname, &page->flags); }
+
+
+#define PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
+	SETPAGEFLAG(uname, lname) CLEARPAGEFLAG(uname, lname)
+
+#define __PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
+	__SETPAGEFLAG(uname, lname)  __CLEARPAGEFLAG(uname, lname)
+
+#define TESTSCFLAG(uname, lname)					\
+	TESTSETFLAG(uname, lname) TESTCLEARFLAG(uname, lname)
+
+/*
  * Manipulation of page state flags
  */
 #define PageLocked(page)		\

-- 
