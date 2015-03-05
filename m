Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6EEA06B0071
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:33:27 -0500 (EST)
Received: by wibbs8 with SMTP id bs8so8849756wib.0
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:33:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id yr2si14016553wjc.56.2015.03.05.09.33.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:33:26 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 05/21] userfaultfd: add vm_userfaultfd_ctx to the vm_area_struct
Date: Thu,  5 Mar 2015 18:17:48 +0100
Message-Id: <1425575884-2574-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

This adds the vm_userfaultfd_ctx to the vm_area_struct.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm_types.h | 11 +++++++++++
 kernel/fork.c            |  1 +
 2 files changed, 12 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 199a03a..fbf21f5 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -247,6 +247,16 @@ struct vm_region {
 						* this region */
 };
 
+#ifdef CONFIG_USERFAULTFD
+#define NULL_VM_UFFD_CTX ((struct vm_userfaultfd_ctx) { NULL, })
+struct vm_userfaultfd_ctx {
+	struct userfaultfd_ctx *ctx;
+};
+#else /* CONFIG_USERFAULTFD */
+#define NULL_VM_UFFD_CTX ((struct vm_userfaultfd_ctx) {})
+struct vm_userfaultfd_ctx {};
+#endif /* CONFIG_USERFAULTFD */
+
 /*
  * This struct defines a memory VMM memory area. There is one of these
  * per VM-area/task.  A VM area is any part of the process virtual memory
@@ -313,6 +323,7 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
 };
 
 struct core_thread {
diff --git a/kernel/fork.c b/kernel/fork.c
index cf65139..cb215c0 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -425,6 +425,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 			goto fail_nomem_anon_vma_fork;
 		tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_next = tmp->vm_prev = NULL;
+		tmp->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 		file = tmp->vm_file;
 		if (file) {
 			struct inode *inode = file_inode(file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
