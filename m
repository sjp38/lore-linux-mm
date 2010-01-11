Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BF55F6B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 21:48:27 -0500 (EST)
Received: by gxk24 with SMTP id 24so21081154gxk.6
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 18:48:26 -0800 (PST)
Date: Mon, 11 Jan 2010 11:46:07 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH -mmotm-2010-01-06-14-34] Count minor fault in break_ksm
Message-Id: <20100111114607.1d8cd1e0.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Izik Eidus <ieidus@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

We have counted task's maj/min fault after handle_mm_fault.
break_ksm misses that.

I wanted to check by VM_FAULT_ERROR. 
But now break_ksm doesn't handle HWPOISON error. 

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
CC: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 56a0da1..3a1fda4 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -367,9 +367,13 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 		page = follow_page(vma, addr, FOLL_GET);
 		if (!page)
 			break;
-		if (PageKsm(page))
+		if (PageKsm(page)) {
 			ret = handle_mm_fault(vma->vm_mm, vma, addr,
 							FAULT_FLAG_WRITE);
+			if (!(ret & (VM_FAULT_SIGBUS | VM_FAULT_OOM)
+					|| current->flags & PF_KTHREAD))
+				current->min_flt++;
+		}
 		else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
-- 
1.5.6.3



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
