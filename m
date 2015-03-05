Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA336B007D
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:19:19 -0500 (EST)
Received: by widem10 with SMTP id em10so40326259wid.1
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:19:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e18si13927616wjx.62.2015.03.05.09.19.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:19:05 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 06/21] userfaultfd: add VM_UFFD_MISSING and VM_UFFD_WP
Date: Thu,  5 Mar 2015 18:17:49 +0100
Message-Id: <1425575884-2574-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

These two flags gets set in vma->vm_flags to tell the VM common code
if the userfaultfd is armed and in which mode (only tracking missing
faults, only tracking wrprotect faults or both). If neither flags is
set it means the userfaultfd is not armed on the vma.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h | 2 ++
 kernel/fork.c      | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a9392..762ef9d 100644
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
index cb215c0..cfab6e9 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -423,7 +423,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
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
