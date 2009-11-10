Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C32326B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:06:51 -0500 (EST)
Date: Tue, 10 Nov 2009 22:06:49 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 6/6] mm: sigbus instead of abusing oom
In-Reply-To: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911102202500.2816@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When do_nonlinear_fault() realizes that the page table must have been
corrupted for it to have been called, it does print_bad_pte() and
returns ... VM_FAULT_OOM, which is hard to understand.

It made some sense when I did it for 2.6.15, when do_page_fault()
just killed the current process; but nowadays it lets the OOM killer
decide who to kill - so page table corruption in one process would
be liable to kill another.

Change it to return VM_FAULT_SIGBUS instead: that doesn't guarantee
that the process will be killed, but is good enough for such a rare
abnormality, accompanied as it is by the "BUG: Bad page map" message.

And recent HWPOISON work has copied that code into do_swap_page(),
when it finds an impossible swap entry: fix that to VM_FAULT_SIGBUS too.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
This one has nothing whatever to do with KSM swapping,
just something that KAMEZAWA-san and Minchan noticed recently.

 mm/memory.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- mm5/mm/memory.c	2009-11-02 12:32:34.000000000 +0000
+++ mm6/mm/memory.c	2009-11-07 14:44:58.000000000 +0000
@@ -2529,7 +2529,7 @@ static int do_swap_page(struct mm_struct
 			ret = VM_FAULT_HWPOISON;
 		} else {
 			print_bad_pte(vma, address, orig_pte, NULL);
-			ret = VM_FAULT_OOM;
+			ret = VM_FAULT_SIGBUS;
 		}
 		goto out;
 	}
@@ -2925,7 +2925,7 @@ static int do_nonlinear_fault(struct mm_
 		 * Page table corrupted: show pte and kill process.
 		 */
 		print_bad_pte(vma, address, orig_pte, NULL);
-		return VM_FAULT_OOM;
+		return VM_FAULT_SIGBUS;
 	}
 
 	pgoff = pte_to_pgoff(orig_pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
