Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5C06C6B0037
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 04:32:20 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so901945pab.34
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 01:32:20 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id qv10si3135907pbb.232.2014.01.15.01.32.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 01:32:19 -0800 (PST)
Message-ID: <52D65568.6080106@huawei.com>
Date: Wed, 15 Jan 2014 17:31:20 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/fs: don't keep pages when receiving a pending SIGKILL
 in __get_user_pages()
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>, robin.yb@huawei.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, riel@redhat.com
Cc: Xishi Qiu <qiuxishi@huawei.com>, linux-fsdevel@vger.kernel.org, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

In the process IO direction, dio_refill_pages will call get_user_pages_fast 
to map the page from user space. If ret is less than 0 and IO is write, the 
function will create a zero page to fill data. This may work for some file 
system, but in some device operate we prefer whole write or fail, not half 
data half zero, e.g. fs metadata, like inode, identy.
This happens often when kill a process which is doing direct IO. Consider 
the following cases, the process A is doing IO process, may enter __get_user_pages 
function, if other processes send process A SIG_KILL, A will enter the 
following branches 
		/*
		 * If we have a pending SIGKILL, don't keep faulting
		 * pages and potentially allocating memory.
		 */
		if (unlikely(fatal_signal_pending(current)))
			return i ? i : -ERESTARTSYS;
Return current pages. direct IO will write the pages, the subsequent pages 
which can?t get will use zero page instead. 
This patch will modify this judgment, if receive SIG_KILL, release pages and 
return an error. Direct IO will find no blocks_available and return error 
direct, rather than half IO data and half zero page.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Signed-off-by: Bin Yang <robin.yb@huawei.com>
---
 mm/memory.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 6768ce9..0568faa 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1799,8 +1799,14 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			 * If we have a pending SIGKILL, don't keep faulting
 			 * pages and potentially allocating memory.
 			 */
-			if (unlikely(fatal_signal_pending(current)))
-				return i ? i : -ERESTARTSYS;
+			if (unlikely(fatal_signal_pending(current))) {
+				int j;
+				for (j = 0; j < i; j++) {
+					put_page(pages[j]);
+					pages[j] = NULL;
+				}
+				return  -ERESTARTSYS;
+			}
 
 			cond_resched();
 			while (!(page = follow_page_mask(vma, start,
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
