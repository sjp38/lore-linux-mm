Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 0B40C6B0033
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 18:25:51 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/6] arch: mm: remove obsolete init OOM protection
Date: Thu, 25 Jul 2013 18:25:33 -0400
Message-Id: <1374791138-15665-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Back before smart OOM killing, when faulting tasks where killed
directly on allocation failures, the arch-specific fault handlers
needed special protection for the init process.

Now that all fault handlers call into the generic OOM killer (609838c
"mm: invoke oom-killer from remaining unconverted page fault
handlers"), which already provides init protection, the arch-specific
leftovers can be removed.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/arc/mm/fault.c   | 5 -----
 arch/score/mm/fault.c | 6 ------
 arch/tile/mm/fault.c  | 6 ------
 3 files changed, 17 deletions(-)

diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 0fd1f0d..6b0bb41 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -122,7 +122,6 @@ good_area:
 			goto bad_area;
 	}
 
-survive:
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
@@ -201,10 +200,6 @@ no_context:
 	die("Oops", regs, address);
 
 out_of_memory:
-	if (is_global_init(tsk)) {
-		yield();
-		goto survive;
-	}
 	up_read(&mm->mmap_sem);
 
 	if (user_mode(regs)) {
diff --git a/arch/score/mm/fault.c b/arch/score/mm/fault.c
index 6b18fb0..4b71a62 100644
--- a/arch/score/mm/fault.c
+++ b/arch/score/mm/fault.c
@@ -100,7 +100,6 @@ good_area:
 			goto bad_area;
 	}
 
-survive:
 	/*
 	* If for any reason at all we couldn't handle the fault,
 	* make sure we exit gracefully rather than endlessly redo
@@ -167,11 +166,6 @@ no_context:
 	*/
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (is_global_init(tsk)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
 	if (!user_mode(regs))
 		goto no_context;
 	pagefault_out_of_memory();
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index f7f99f9..ac553ee 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -430,7 +430,6 @@ good_area:
 			goto bad_area;
 	}
 
- survive:
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
@@ -568,11 +567,6 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (is_global_init(tsk)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
 	if (is_kernel_mode)
 		goto no_context;
 	pagefault_out_of_memory();
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
