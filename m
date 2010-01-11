Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A56DC6B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 21:44:43 -0500 (EST)
Received: by gxk24 with SMTP id 24so21079092gxk.6
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 18:44:42 -0800 (PST)
Date: Mon, 11 Jan 2010 11:42:24 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH -mmotm-2010-01-06-14-34] Fix fault count of task in GUP
Message-Id: <20100111114224.bbf0fc62.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


get_user_pages calls handle_mm_fault to pin the arguemented
task's page. handle_mm_fault cause major or minor fault and
get_user_pages counts it into task which is passed by argument.

But the fault happens in current task's context.
So we have to count it not argumented task's context but current
task's one.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
CC: Nick Piggin <npiggin@suse.de>
CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
 mm/memory.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 521abf6..2513581 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1486,9 +1486,9 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 					BUG();
 				}
 				if (ret & VM_FAULT_MAJOR)
-					tsk->maj_flt++;
+					current->maj_flt++;
 				else
-					tsk->min_flt++;
+					current->min_flt++;
 
 				/*
 				 * The VM_FAULT_WRITE bit tells us that
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
