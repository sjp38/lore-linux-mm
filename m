Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0BEF66B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 05:21:32 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so427861pab.35
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 02:21:31 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id do6si19059862pdb.34.2014.12.05.02.21.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 02:21:30 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 5 Dec 2014 18:21:17 +0800
Subject: [RFC V2] mm:add KPF_ZERO_PAGE flag for /proc/kpageflags
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313F1@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'n-horiguchi@ah.jp.nec.com'" <n-horiguchi@ah.jp.nec.com>'Konstantin Khlebnikov' <koct9i@gmail.com>

This patch add KPF_ZERO_PAGE flag for zero_page,
so that userspace process can notice zero_page from
/proc/kpageflags, and then do memory analysis more accurately.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 fs/proc/page.c                         | 14 +++++++++++---
 include/linux/huge_mm.h                | 12 ++++++++++++
 include/uapi/linux/kernel-page-flags.h |  1 +
 mm/huge_memory.c                       |  7 +------
 4 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 1e3187d..dbe5630 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -5,6 +5,7 @@
 #include <linux/ksm.h>
 #include <linux/mm.h>
 #include <linux/mmzone.h>
+#include <linux/huge_mm.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/hugetlb.h>
@@ -121,9 +122,16 @@ u64 stable_page_flags(struct page *page)
 	 * just checks PG_head/PG_tail, so we need to check PageLRU/PageAnon
 	 * to make sure a given page is a thp, not a non-huge compound page.
 	 */
-	else if (PageTransCompound(page) && (PageLRU(compound_head(page)) ||
-					     PageAnon(compound_head(page))))
-		u |=3D 1 << KPF_THP;
+	else if (PageTransCompound(page)) {
+		struct page *head =3D compound_head(page);
+
+		if (PageLRU(head) || PageAnon(head))
+			u |=3D 1 << KPF_THP;
+		else if (is_huge_zero_page(head))
+			u |=3D 1 << KPF_ZERO_PAGE;
+	} else if (is_zero_pfn(page_to_pfn(page)))
+		u |=3D 1 << KPF_ZERO_PAGE;
+
=20
 	/*
 	 * Caveats on high order pages: page->_count will only be set
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ad9051b..f10b20f 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -157,6 +157,13 @@ static inline int hpage_nr_pages(struct page *page)
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_stru=
ct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
=20
+extern struct page *huge_zero_page;
+
+static inline bool is_huge_zero_page(struct page *page)
+{
+	return ACCESS_ONCE(huge_zero_page) =3D=3D page;
+}
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -206,6 +213,11 @@ static inline int do_huge_pmd_numa_page(struct mm_stru=
ct *mm, struct vm_area_str
 	return 0;
 }
=20
+static inline bool is_huge_zero_page(struct page *page)
+{
+	return false;
+}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
=20
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/ke=
rnel-page-flags.h
index 2f96d23..a6c4962 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -32,6 +32,7 @@
 #define KPF_KSM			21
 #define KPF_THP			22
 #define KPF_BALLOON		23
+#define KPF_ZERO_PAGE		24
=20
=20
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index de98415..d7bc7a5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -171,12 +171,7 @@ static int start_khugepaged(void)
 }
=20
 static atomic_t huge_zero_refcount;
-static struct page *huge_zero_page __read_mostly;
-
-static inline bool is_huge_zero_page(struct page *page)
-{
-	return ACCESS_ONCE(huge_zero_page) =3D=3D page;
-}
+struct page *huge_zero_page __read_mostly;
=20
 static inline bool is_huge_zero_pmd(pmd_t pmd)
 {
--=20
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
