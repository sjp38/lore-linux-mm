Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6C96B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 20:44:49 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p4A0ik8b000724
	for <linux-mm@kvack.org>; Mon, 9 May 2011 17:44:46 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz13.hot.corp.google.com with ESMTP id p4A0ieD0016290
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 9 May 2011 17:44:45 -0700
Received: by pzk37 with SMTP id 37so2964674pzk.29
        for <linux-mm@kvack.org>; Mon, 09 May 2011 17:44:40 -0700 (PDT)
Date: Mon, 9 May 2011 17:44:42 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] vm: fix vm_pgoff wrap in upward expansion
Message-ID: <alpine.LSU.2.00.1105091739140.7047@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Robert Swiecki <robert@swiecki.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org

Commit a626ca6a6564 ("vm: fix vm_pgoff wrap in stack expansion") fixed
the case of an expanding mapping causing vm_pgoff wrapping when you had
downward stack expansion.  But there was another case where IA64 and
PA-RISC expand mappings: upward expansion.

This fixes that case too.

Signed-off-by: Hugh Dickins <hughd@google.com.>
Cc: stable@kernel.org
---
On April 12th you asked "Guys, can you think of any other thing
that might expand a mapping?": this is the only one I thought of.

 mm/mmap.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

--- 2.6.39-rc6/mm/mmap.c	2011-05-04 12:10:31.477543104 -0700
+++ linux/mm/mmap.c	2011-05-09 17:16:34.251725877 -0700
@@ -1767,10 +1767,13 @@ int expand_upwards(struct vm_area_struct
 		size = address - vma->vm_start;
 		grow = (address - vma->vm_end) >> PAGE_SHIFT;
 
-		error = acct_stack_growth(vma, size, grow);
-		if (!error) {
-			vma->vm_end = address;
-			perf_event_mmap(vma);
+		error = -ENOMEM;
+		if (vma->vm_pgoff + (size >> PAGE_SHIFT) >= vma->vm_pgoff) {
+			error = acct_stack_growth(vma, size, grow);
+			if (!error) {
+				vma->vm_end = address;
+				perf_event_mmap(vma);
+			}
 		}
 	}
 	vma_unlock_anon_vma(vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
