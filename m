Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 841D49000BD
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 17:34:35 -0400 (EDT)
Date: Thu, 15 Sep 2011 14:33:25 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V10 1/6] mm: frontswap: add frontswap header file
Message-ID: <20110915213325.GA26333@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V10 1/6] mm: frontswap: add frontswap header file

(Note: Following three paragraphs repeated for git commit log.)

Frontswap is the alter ego of cleancache, the "yang" to cleancache's
"yin"... and more precisely frontswap is the provider of anonymous
pages to transcendent memory to nicely complement cleancache's providing
of clean pagecache pages to transcendent memory.  For optimal use
of transcendent memory, both are necessary... because a kernel
under memory pressure first reclaims clean pagecache pages and,
when under more memory pressure, starts swapping anonymous pages.

Frontswap and cleancache (which was merged at 3.0) are the only
necessary changes to the core kernel for transcendent memory; all
other supporting code is implemented as drivers.  See "Transcendent
memory in a nutshell" for a current (Aug 2011) and detailed overview of
frontswap and related kernel parts: https://lwn.net/Articles/454795/

Frontswap code was first posted publicly in January 2009 and on LKML
in May 2009, and has remained very stable for over two years now.
It is barely invasive, touching only the swap subsystem and adds only
about 100 lines of code to existing swap subsystem code files.
It has improved syntactically substantially between V1 and this posting
of V10, thanks to the review of a few kernel developers, and has adapted
easily to at least one major swap subsystem change.  As of 3.1, there are
two in-tree users of frontswap patiently waiting for this patchset and for
CONFIG_FRONTSWAP to be enabled: zcache (staging driver merged at
2.6.39) and Xen tmem (merged at 3.0 and 3.1).  V5 of the frontswap
patchset has been in linux-next since next-110603 (and this V10
will be there shortly).  Earlier versions of frontswap already appear
in some leading-edge distros.

This first patch of six in this frontswap series provides the header
file for the core code for frontswap that interfaces between the hooks
in the swap subsystem and a frontswap backend via frontswap_ops.
(Note to earlier reviewers:  This patchset has been reorganized due to
feedback from Kame Hiroyuki and Andrew Morton. This patch contains part
of patch 3of4 from the previous series.)

New file added: include/linux/frontswap.h

[v10: no change]
[v9: akpm@linux-foundation.org: change "flush" to "invalidate", part 1]
[v8: rebase to 3.0-rc4]
[v7: rebase to 3.0-rc3]
[v7: JBeulich@novell.com: new static inlines resolve to no-ops if not config'd]
[v7: JBeulich@novell.com: avoid redundant shifts/divides for *_bit lib calls]
[v6: rebase to 3.1-rc1]
[v5: no change from v4]
[v4: rebase to 2.6.39]
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Jan Beulich <JBeulich@novell.com>
Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Chris Mason <chris.mason@oracle.com>
Cc: Rik Riel <riel@redhat.com>

--- linux/include/linux/frontswap.h	1969-12-31 17:00:00.000000000 -0700
+++ frontswap-v10/include/linux/frontswap.h	2011-09-15 11:40:53.585807413 -0600
@@ -0,0 +1,131 @@
+#ifndef _LINUX_FRONTSWAP_H
+#define _LINUX_FRONTSWAP_H
+
+#include <linux/swap.h>
+#include <linux/mm.h>
+#include <linux/bitops.h>
+
+struct frontswap_ops {
+	void (*init)(unsigned);
+	int (*put_page)(unsigned, pgoff_t, struct page *);
+	int (*get_page)(unsigned, pgoff_t, struct page *);
+	/*
+	 * NOTE: per akpm, flush_page and flush_area will be renamed to
+	 * invalidate_page and invalidate_area in a later commit in which
+	 * all dependencies (i.e. Xen, zcache) will be renamed simultaneously
+	 */
+	void (*flush_page)(unsigned, pgoff_t);
+	void (*flush_area)(unsigned);
+};
+
+extern int frontswap_enabled;
+extern struct frontswap_ops
+	frontswap_register_ops(struct frontswap_ops *ops);
+extern void frontswap_shrink(unsigned long);
+extern unsigned long frontswap_curr_pages(void);
+
+extern void __frontswap_init(unsigned type);
+extern int __frontswap_put_page(struct page *page);
+extern int __frontswap_get_page(struct page *page);
+extern void __frontswap_invalidate_page(unsigned, pgoff_t);
+extern void __frontswap_invalidate_area(unsigned);
+
+#ifdef CONFIG_FRONTSWAP
+
+static inline int frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
+{
+	int ret = 0;
+
+	if (frontswap_enabled && sis->frontswap_map)
+		ret = test_bit(offset, sis->frontswap_map);
+	return ret;
+}
+
+static inline void frontswap_set(struct swap_info_struct *sis, pgoff_t offset)
+{
+	if (frontswap_enabled && sis->frontswap_map)
+		set_bit(offset, sis->frontswap_map);
+}
+
+static inline void frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
+{
+	if (frontswap_enabled && sis->frontswap_map)
+		clear_bit(offset, sis->frontswap_map);
+}
+
+static inline void frontswap_map_set(struct swap_info_struct *p,
+				     unsigned long *map)
+{
+	p->frontswap_map = map;
+}
+
+static inline unsigned long *frontswap_map_get(struct swap_info_struct *p)
+{
+	return p->frontswap_map;
+}
+#else
+/* all inline routines become no-ops and all externs are ignored */
+
+#define frontswap_enabled (0)
+
+static inline int frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
+{
+	return 0;
+}
+
+static inline void frontswap_set(struct swap_info_struct *sis, pgoff_t offset)
+{
+}
+
+static inline void frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
+{
+}
+
+static inline void frontswap_map_set(struct swap_info_struct *p,
+				     unsigned long *map)
+{
+}
+
+static inline unsigned long *frontswap_map_get(struct swap_info_struct *p)
+{
+	return NULL;
+}
+#endif
+
+static inline int frontswap_put_page(struct page *page)
+{
+	int ret = -1;
+
+	if (frontswap_enabled)
+		ret = __frontswap_put_page(page);
+	return ret;
+}
+
+static inline int frontswap_get_page(struct page *page)
+{
+	int ret = -1;
+
+	if (frontswap_enabled)
+		ret = __frontswap_get_page(page);
+	return ret;
+}
+
+static inline void frontswap_invalidate_page(unsigned type, pgoff_t offset)
+{
+	if (frontswap_enabled)
+		__frontswap_invalidate_page(type, offset);
+}
+
+static inline void frontswap_invalidate_area(unsigned type)
+{
+	if (frontswap_enabled)
+		__frontswap_invalidate_area(type);
+}
+
+static inline void frontswap_init(unsigned type)
+{
+	if (frontswap_enabled)
+		__frontswap_init(type);
+}
+
+#endif /* _LINUX_FRONTSWAP_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
