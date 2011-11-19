Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E32CC6B0069
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 06:50:22 -0500 (EST)
Received: by wwf25 with SMTP id 25so2385951wwf.2
        for <linux-mm@kvack.org>; Sat, 19 Nov 2011 03:50:19 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 19 Nov 2011 19:50:19 +0800
Message-ID: <CAJd=RBDP_z68Ewvw_O_dMxOnE0=weXqt+1FQy85_n76HAEdFHg@mail.gmail.com>
Subject: [PATCH] ksm: use FAULT_FLAG_ALLOW_RETRY in breaking COW
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

The flag, FAULT_FLAG_ALLOW_RETRY, was introduced by the patch,

	mm: retry page fault when blocking on disk transfer
	commit: d065bd810b6deb67d4897a14bfe21f8eb526ba99

for reducing mmap_sem hold times that are caused by waiting for disk
transfers when accessing file mapped VMAs.

To break COW, handle_mm_fault() is repeated with mmap_sem held, where
the introduced flag could be used again.

The straight way is to add changes in break_ksm(), but the function could be
under write-mode mmap_sem, so it has to be dupilcated.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/ksm.c	Sat Nov 19 16:08:10 2011
+++ b/mm/ksm.c	Sat Nov 19 19:33:49 2011
@@ -394,7 +394,31 @@ static void break_cow(struct rmap_item *
 		goto out;
 	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
 		goto out;
-	break_ksm(vma, addr);
+	for (;;) {
+		struct page *page;
+		int ret;
+
+		page = follow_page(vma, addr, FOLL_GET);
+		if (IS_ERR_OR_NULL(page))
+			break;
+
+		if (PageKsm(page))
+			ret = handle_mm_fault(mm, vma, addr,
+				FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_WRITE);
+		else
+			ret = VM_FAULT_WRITE;
+
+		put_page(page);
+
+		if (!(ret & (VM_FAULT_WRITE|VM_FAULT_SIGBUS|VM_FAULT_OOM))) {
+			if (ret & VM_FAULT_RETRY)
+				down_read(&mm->mmap_sem);
+		} else {
+			if (ret & VM_FAULT_RETRY)
+				return;
+			break;
+		}
+	}
 out:
 	up_read(&mm->mmap_sem);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
