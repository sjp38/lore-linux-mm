Date: Wed, 16 Nov 2005 23:00:23 +0000
Subject: [PATCH 3/3] sparse provide pfn_to_nid
Message-ID: <20051116230023.GA16493@shadowen.org>
References: <exportbomb.1132181992@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Anton Blanchard <anton@samba.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Before SPARSEMEM is initialised we cannot provide an efficient
pfn_to_nid() implmentation; before initialisation is complete we use
early_pfn_to_nid() to provide location information.  Until recently
there was no non-init user of this functionality.  Provide a post
init pfn_to_nid() implementation.

Note that this implmentation assumes that the pfn passed has
been validated with pfn_valid().  The current single user of this
function already has this check.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mmzone.h |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)
diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
--- reference/include/linux/mmzone.h
+++ current/include/linux/mmzone.h
@@ -598,14 +598,11 @@ static inline int pfn_valid(unsigned lon
 	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
 
-/*
- * These are _only_ used during initialisation, therefore they
- * can use __initdata ...  They could have names to indicate
- * this restriction.
- */
-#ifdef CONFIG_NUMA
-#define pfn_to_nid		early_pfn_to_nid
-#endif
+#define pfn_to_nid(pfn)							\
+({									\
+ 	unsigned long __pfn = (pfn);                                    \
+	page_to_nid(pfn_to_page(pfn));					\
+})
 
 #define early_pfn_valid(pfn)	pfn_valid(pfn)
 void sparse_init(void);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
