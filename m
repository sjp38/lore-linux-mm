Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 58C7782F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 08:07:21 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so6741237wic.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 05:07:20 -0700 (PDT)
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com. [195.75.94.101])
        by mx.google.com with ESMTPS id td12si4741134wic.52.2015.10.16.05.07.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Oct 2015 05:07:20 -0700 (PDT)
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Oct 2015 13:07:19 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id CBBA617D8056
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 13:07:23 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9GC7HDE33751198
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 12:07:17 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9GC7DHO009913
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 06:07:16 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 2/3] mm: clear_soft_dirty_pmd requires THP
Date: Fri, 16 Oct 2015 14:07:07 +0200
Message-Id: <c56e0cee475c34bda846ffbf1cc0e541ccb6b9b4.1444995096.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, xemul@parallels.com, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulus@samba.org
Cc: criu@openvz.org

Don't build clear_soft_dirty_pmd() if the transparent huge pages are
not enabled.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
CC: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/proc/task_mmu.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c9454ee39b28..fa847a982a9f 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -762,7 +762,14 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 		set_pte_at(vma->vm_mm, addr, pte, ptent);
 	}
 }
+#else
+static inline void clear_soft_dirty(struct vm_area_struct *vma,
+		unsigned long addr, pte_t *pte)
+{
+}
+#endif
 
+#if defined(CONFIG_MEM_SOFT_DIRTY) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 		unsigned long addr, pmd_t *pmdp)
 {
@@ -776,14 +783,7 @@ static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 
 	set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
 }
-
 #else
-
-static inline void clear_soft_dirty(struct vm_area_struct *vma,
-		unsigned long addr, pte_t *pte)
-{
-}
-
 static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 		unsigned long addr, pmd_t *pmdp)
 {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
