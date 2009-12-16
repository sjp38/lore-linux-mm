Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9FC876B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:18:31 -0500 (EST)
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nBGHITH5011895
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:18:30 -0500
Received: from redhat.com (ovpn01.gateway.prod.ext.phx2.redhat.com [10.5.9.1])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id nBGHIS3A017081
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:18:29 -0500
From: David Howells <dhowells@redhat.com>
Subject: KSM broken in the CONFIG_MMU=n case
Date: Wed, 16 Dec 2009 16:38:35 +0000
Message-ID: <19082.1260981515@redhat.com>
Resent-To: linux-mm@kvack.org
Resent-Message-ID: <20746.1260983907@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: dhowells@redhat.com, aarcange@redhat.com, torvalds@osdl.org, akpm@linux-foundation.org, linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Hi Hugh,

The KSM code is broken in the CONFIG_MMU=n case as enum ttu_flags is required,
but not defined.  Simply predeclaring it doesn't help as the argument isn't a
pointer to a value of that type.

I've attached a patch below to deal with it; it's a bit messy, though, as the
fallback ksm_exit() is required in both the NOMMU and no-KSM cases.

David
---
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NOMMU: Fix KSM in the CONFIG_MMU=n case

Fix KSM in the CONFIG_MMU=n case:

In file included from kernel/fork.c:52:
include/linux/ksm.h:129: warning: 'enum ttu_flags' declared inside parameter list
include/linux/ksm.h:129: warning: its scope is only this definition or declaration, which is probably not what you want
include/linux/ksm.h:129: error: parameter 2 ('flags') has incomplete type

by making most of linux/ksm.h contingent on CONFIG_MMU=y.  The fallback
version of ksm_exit() requires special handling as that is also used in the
MMU=y, KSM=n case.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/ksm.h |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)


diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index bed5f16..7f1e1f0 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -16,6 +16,7 @@
 struct stable_node;
 struct mem_cgroup;
 
+#ifdef CONFIG_MMU
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags);
@@ -105,10 +106,6 @@ static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 	return 0;
 }
 
-static inline void ksm_exit(struct mm_struct *mm)
-{
-}
-
 static inline int PageKsm(struct page *page)
 {
 	return 0;
@@ -141,5 +138,12 @@ static inline void ksm_migrate_page(struct page *newpage, struct page *oldpage)
 {
 }
 #endif /* !CONFIG_KSM */
+#endif /* CONFIG_MMU */
+
+#if !defined(CONFIG_MMU) || !defined(CONFIG_KSM)
+static inline void ksm_exit(struct mm_struct *mm)
+{
+}
+#endif
 
 #endif /* __LINUX_KSM_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
