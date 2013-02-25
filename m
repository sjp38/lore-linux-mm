Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D875B6B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 18:23:30 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id wz12so1957580pbc.31
        for <linux-mm@kvack.org>; Mon, 25 Feb 2013 15:23:30 -0800 (PST)
Date: Mon, 25 Feb 2013 18:23:26 -0500
From: Andrew Shewmaker <agshew@gmail.com>
Subject: [RFC PATCH v1 1/1] mm: tuning hardcoded reserved memory
Message-ID: <20130225232326.GB1704@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

__vm_enough_memory reserves a hardcoded 3% of free memory for other processes
when overcommit is disabled. However, 3% is becoming excessive as memory sizes 
increase and memory cgroups provide a more flexible way to manage the issue anyway.
This patch against 3.8 removes the "other" reserve.

I've found that reducing this reserve is beneficial in the case where a system 
with overcommit disabled has one primary user that wants to allocate as much 
memory as possible with a just few processes.

An additional hardcoded 3% is reserved for root, both when overcommit is enabled 
and when it is disabled. I've made it tunable in private patches, and I plan on 
submitting some version of them, but I can't decide whether a ratio or a byte 
count would be more acceptable. What would people prefer see?

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>

diff --git a/mm/mmap.c b/mm/mmap.c
index 09da0b2..eef9505 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -183,11 +183,6 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		allowed -= allowed / 32;
 	allowed += total_swap_pages;
 
-	/* Don't let a single process grow too big:
-	   leave 3% of the size of this process for other processes */
-	if (mm)
-		allowed -= mm->total_vm / 32;
-
 	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
 		return 0;
 error:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
