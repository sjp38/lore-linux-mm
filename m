Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2E26B0092
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:43 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so102936379wic.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fb7si1139587wid.20.2015.05.14.10.31.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:41 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 06/23] userfaultfd: add VM_UFFD_MISSING and VM_UFFD_WP
Date: Thu, 14 May 2015 19:31:03 +0200
Message-Id: <1431624680-20153-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

These two flags gets set in vma->vm_flags to tell the VM common code
if the userfaultfd is armed and in which mode (only tracking missing
faults, only tracking wrprotect faults or both). If neither flags is
set it means the userfaultfd is not armed on the vma.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/proc/task_mmu.c | 2 ++
 include/linux/mm.h | 2 ++
 kernel/fork.c      | 2 +-
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 6dee68d..58be92e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -597,6 +597,8 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_HUGEPAGE)]	= "hg",
 		[ilog2(VM_NOHUGEPAGE)]	= "nh",
 		[ilog2(VM_MERGEABLE)]	= "mg",
+		[ilog2(VM_UFFD_MISSING)]= "um",
+		[ilog2(VM_UFFD_WP)]	= "uw",
 	};
 	size_t i;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2923a51..7fccd22 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -123,8 +123,10 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_MAYSHARE	0x00000080
 
 #define VM_GROWSDOWN	0x00000100	/* general info on the segment */
+#define VM_UFFD_MISSING	0x00000200	/* missing pages tracking */
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
+#define VM_UFFD_WP	0x00001000	/* wrprotect pages tracking */
 
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
diff --git a/kernel/fork.c b/kernel/fork.c
index 430141b..56d1ddf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -449,7 +449,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		tmp->vm_mm = mm;
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
-		tmp->vm_flags &= ~VM_LOCKED;
+		tmp->vm_flags &= ~(VM_LOCKED|VM_UFFD_MISSING|VM_UFFD_WP);
 		tmp->vm_next = tmp->vm_prev = NULL;
 		tmp->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 		file = tmp->vm_file;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
