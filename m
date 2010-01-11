Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1643E6B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 22:43:20 -0500 (EST)
Received: by ywh5 with SMTP id 5so44733597ywh.11
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 19:43:19 -0800 (PST)
Date: Mon, 11 Jan 2010 12:40:49 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 -mmotm-2010-01-06-14-34] Fix fault count of task in GUP
Message-Id: <20100111124049.dc651e69.minchan.kim@barrios-desktop>
In-Reply-To: <20100111114224.bbf0fc62.minchan.kim@barrios-desktop>
References: <20100111114224.bbf0fc62.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


 * V2
  * Don't count in case of kernel thread

== CUT HERE ==

get_user_pagse calls handle_mm_fault to get the arguemented
task's page. handle_mm_fault cause major or minor fault and
get_user_pages counts it into task which is passed by argument.

But the fault happens in current task's context.
So we have to count it not argumented task's context but current
task's one.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
CC: Nick Piggin <npiggin@suse.de>
CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
 mm/memory.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 521abf6..0eb9536 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1485,11 +1485,11 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 						return i ? i : -EFAULT;
 					BUG();
 				}
-				if (ret & VM_FAULT_MAJOR)
-					tsk->maj_flt++;
-				else
-					tsk->min_flt++;
-
+				if (!(current->flags & PF_KTHREAD))
+					if (ret & VM_FAULT_MAJOR)
+						current->maj_flt++;
+					else
+						current->min_flt++;
 				/*
 				 * The VM_FAULT_WRITE bit tells us that
 				 * do_wp_page has broken COW when necessary,
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
