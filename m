Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by relay2.corp.sgi.com (Postfix) with ESMTP id 2F3A430406A
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:14 -0800 (PST)
Received: from clameter by schroedinger.engr.sgi.com with local (Exim 3.36 #1 (Debian))
	id 1JVJ1C-0004VN-00
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:14 -0800
Message-Id: <20080301040813.835000741@sgi.com>
References: <20080301040755.268426038@sgi.com>
Date: Fri, 29 Feb 2008 20:07:57 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 02/10] Pageflags: Introduce macros to generate page flag functions
Content-Disposition: inline; filename=pageflags-add-macros
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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
TESTPAGEFLAG		Create additional atomic set function
SETPAGEFLAG		Create additional atomic clear function
__TESTPAGEFLAG		Create additional atomic set function
__SETPAGEFLAG		Create additional atomic clear function

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/page-flags.h |   41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2008-02-29 19:14:30.000000000 -0800
+++ linux-2.6/include/linux/page-flags.h	2008-02-29 19:15:28.000000000 -0800
@@ -103,6 +103,47 @@ enum pageflags {
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
+			TESTSETFLAG(uname, lname) TESTCLEARFLAG(uname, lname)
+
+/*
  * Manipulation of page state flags
  */
 #define PageLocked(page)		\

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
