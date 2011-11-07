Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6CB6B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 23:22:08 -0500 (EST)
Received: by ywa17 with SMTP id 17so6355348ywa.14
        for <linux-mm@kvack.org>; Sun, 06 Nov 2011 20:22:06 -0800 (PST)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: [PATCH] mremap: skip page table lookup for non-faulted anonymous VMAs
Date: Mon, 7 Nov 2011 12:21:35 +0800
MIME-Version: 1.0
Message-Id: <201111071221.35403.nai.xia@gmail.com>
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

If an anonymous vma has not yet been faulted, move_page_tables() in move_vma()
is not necessary for it.

Signed-off-by: Nai Xia <nai.xia@gmail.com>
---
diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -200,6 +200,10 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	if (!new_vma)
 		return -ENOMEM;
 
+	/* An anonymous vma has not been faulted, no pagetables lookup. */
+	if (!vma->vm_file && !vma->anon_vma)
+		goto page_tables_ok;
+
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len);
 	if (moved_len < old_len) {
 		/*
@@ -213,6 +217,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		old_addr = new_addr;
 		new_addr = -ENOMEM;
 	}
+page_tables_ok:
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
 	if (vm_flags & VM_ACCOUNT) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
