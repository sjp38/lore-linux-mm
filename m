Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id BE13B6B0002
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 16:41:11 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id un1so621502pbc.40
        for <linux-mm@kvack.org>; Wed, 27 Feb 2013 13:41:11 -0800 (PST)
Date: Wed, 27 Feb 2013 15:56:30 -0500
From: Andrew Shewmaker <agshew@gmail.com>
Subject: [RFC PATCH v2 1/2] mm: tuning hardcoded reserved memory
Message-ID: <20130227205629.GA8429@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The following patches are against the mmtom git tree as of February 27th.

The first patch only affects OVERCOMMIT_NEVER mode, entirely removing 
the 3% reserve for other user processes.

The second patch affects both OVERCOMMIT_GUESS and OVERCOMMIT_NEVER 
modes, replacing the hardcoded 3% reserve for the root user with a 
tunable knob.

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>

---

__vm_enough_memory reserves 3% of free pages with the default 
overcommit mode and 6% when overcommit is disabled. These hardcoded 
values have become less reasonable as memory sizes have grown.

On scientific clusters, systems are generally dedicated to one user. 
Also, overcommit is sometimes disabled in order to prevent a long 
running job from suddenly failing days or weeks into a calculation.
In this case, a user wishing to allocate as much memory as possible 
to one process may be prevented from using, for example, around 7GB 
out of 128GB.

The effect is less, but still significant when a user starts a job 
with one process per core. I have repeatedly seen a set of processes 
requesting the same amount of memory fail because one of them could  
not allocate the amount of memory a user would expect to be able to 
allocate.

diff --git a/mm/mmap.c b/mm/mmap.c
index d1e4124..5993f33 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -182,11 +182,6 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
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
