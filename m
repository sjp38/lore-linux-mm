Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 720D36B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 18:38:16 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id k13so8432106iea.7
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 15:38:15 -0800 (PST)
Date: Tue, 5 Mar 2013 18:38:12 -0500
From: Andrew Shewmaker <agshew@gmail.com>
Subject: [PATCH v4 001/002] mm: limit growth of 3% hardcoded other user
 reserve
Message-ID: <20130305233811.GA1948@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

Limit the growth of the memory reserved for other processes
to the smaller of 3% or 8MB.

This affects only OVERCOMMIT_NEVER.

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>

---

Rebased onto v3.8-mmotm-2013-03-01-15-50

No longer assumes 4kb pages.
Code duplicated for nommu.

diff --git a/mm/mmap.c b/mm/mmap.c
index 49dc7d5..4eb2b1a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -184,9 +184,11 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	allowed += total_swap_pages;
 
 	/* Don't let a single process grow too big:
-	   leave 3% of the size of this process for other processes */
+	 * leave the smaller of 3% of the size of this process 
+         * or 8MB for other processes
+         */
 	if (mm)
-		allowed -= mm->total_vm / 32;
+		allowed -= min(mm->total_vm / 32, 1 << (23 - PAGE_SHIFT));
 
 	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
 		return 0;
diff --git a/mm/nommu.c b/mm/nommu.c
index f5d57a3..a93d214 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1945,9 +1945,11 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	allowed += total_swap_pages;
 
 	/* Don't let a single process grow too big:
-	   leave 3% of the size of this process for other processes */
+	 * leave the smaller of 3% of the size of this process 
+         * or 8MB for other processes
+         */
 	if (mm)
-		allowed -= mm->total_vm / 32;
+		allowed -= min(mm->total_vm / 32, 1 << (23 - PAGE_SHIFT));
 
 	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
 		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
