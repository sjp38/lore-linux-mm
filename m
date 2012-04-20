Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id D4B406B00EC
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 17:49:27 -0400 (EDT)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 1/6] mm: frontswap: add frontswap header file
Date: Fri, 20 Apr 2012 17:44:10 -0400
Message-Id: <1334958255-6612-2-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
References: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, ngupta@vflare.org, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, aarcange@redhat.com, dhowells@redhat.com, riel@redhat.com, JBeulich@novell.com
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <matthew@wil.cx>, Chris Mason <chris.mason@oracle.com>

From: Dan Magenheimer <dan.magenheimer@oracle.com>

Frontswap is the alter ego of cleancache, the "yang" to cleancache's
"yin"... and more precisely frontswap is the provider of anonymous
pages to transcendent memory to nicely complement cleancache's providing
of clean pagecache pages to transcendent memory.  For optimal use
of transcendent memory, both are necessary... because a kernel
under memory pressure first reclaims clean pagecache pages and,
when under more memory pressure, starts swapping anonymous pages.

Frontswap and cleancache (which was merged at 3.0) are the "frontends"
and the only necessary changes to the core kernel for transcendent memory;
all other supporting code -- the "backends" -- is implemented as drivers.
See the LWN.net article "Transcendent memory in a nutshell" for a detailed
overview of frontswap and related kernel parts:
https://lwn.net/Articles/454795/

Frontswap code was first posted publicly in January 2009 and on LKML in
May 2009, and has remained functionally stable for nearly three years now.
It is barely invasive, touching only the swap subsystem and adds less
than 100 lines of code to existing swap subsystem code files.
It has improved syntactically substantially between V1 and this posting
of V14, thanks to the review of a few kernel developers, and has adapted
easily to at least one major swap subsystem change.  As of 3.4, there are
three in-tree users of frontswap patiently waiting for this patchset and
for CONFIG_FRONTSWAP to be enabled: zcache (staging driver merged at
2.6.39), Xen tmem (merged at 3.0 and 3.1) and RAMster (staging driver
merged at 3.4).  In addition, a RFC has been posted for a KVM backend.
The frontswap patchset has been in linux-next since next-110603.  Earlier
versions of frontswap already ship in the Oracle Unbreakable Enterprise Kernel
and SuSE SLES.

This patch, 1of4, provides the header file for the core code for frontswap
that interfaces between the hooks in the swap subsystem and a frontswap
backend via frontswap_ops.
---
New file added: include/linux/frontswap.h

[v14: add support for writethrough, per suggestion by aarcange@redhat.com]
[v14: rebase to 3.4-rc2]
[v11: konrad.wilk@oracle.com: squashed s/flush/invalidate/ in]
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
[v15: int/bool on some functions]
Signed-off-by: Konrad Wilk <konrad.wilk@oracle.com>
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
---
 include/linux/frontswap.h |  127 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 127 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/frontswap.h

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
new file mode 100644
index 0000000..68ff7af
--- /dev/null
+++ b/include/linux/frontswap.h
@@ -0,0 +1,127 @@
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
+	void (*invalidate_page)(unsigned, pgoff_t);
+	void (*invalidate_area)(unsigned);
+};
+
+extern bool frontswap_enabled;
+extern struct frontswap_ops
+	frontswap_register_ops(struct frontswap_ops *ops);
+extern void frontswap_shrink(unsigned long);
+extern unsigned long frontswap_curr_pages(void);
+extern void frontswap_writethrough(bool);
+
+extern void __frontswap_init(unsigned type);
+extern int __frontswap_put_page(struct page *page);
+extern int __frontswap_get_page(struct page *page);
+extern void __frontswap_invalidate_page(unsigned, pgoff_t);
+extern void __frontswap_invalidate_area(unsigned);
+
+#ifdef CONFIG_FRONTSWAP
+
+static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
+{
+	bool ret = false;
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
+static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
+{
+	return false;
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
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
