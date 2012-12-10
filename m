Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 01A496B0068
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 16:03:36 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1585174bkc.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 13:03:34 -0800 (PST)
Date: Mon, 10 Dec 2012 22:03:30 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [GIT TREE] Unified NUMA balancing tree, v3
Message-ID: <20121210210330.GA16207@gmail.com>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
 <alpine.LFD.2.02.1212101902050.4422@ionos>
 <50C62CE7.2000306@redhat.com>
 <20121210191545.GA14412@gmail.com>
 <20121210192828.GL1009@suse.de>
 <20121210200755.GA15097@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121210200755.GA15097@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Ingo Molnar <mingo@kernel.org> wrote:

> > If you had read that report, you would know that I didn't 
> > have results for specjbb with THP enabled due to the JVM 
> > crashing with null pointer exceptions.
> 
> Hm, it's the unified tree where most of the mm/ bits are the 
> AutoNUMA bits from your tree. (It does not match 100%, because 
> your tree has an ancient version of key memory usage 
> statistics that the scheduler needs for its convergence model. 
> I'll take a look at the differences.)

Beyond the difference in page frame statistics and the 
difference in the handling of "4K-EMU", the bits below are the 
difference I found (on the THP side) between numa/base-v3 and 
your -v10 tree - but I'm not sure it should have effect on your 
JVM segfault under THP ...

I tried with preemption on/off, debugging on/off, tried your 
.config - none triggers JVM segfaults with 4x JVM or 1x JVM 
SPECjbb tests.

Thanks,

	Ingo

------------------------->
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c25e37c..409b2f3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -711,8 +711,7 @@ out:
 	 * run pte_offset_map on the pmd, if an huge pmd could
 	 * materialize from under us from a different thread.
 	 */
-	if (unlikely(pmd_none(*pmd)) &&
-	    unlikely(__pte_alloc(mm, vma, pmd, address)))
+	if (unlikely(__pte_alloc(mm, vma, pmd, address)))
 		return VM_FAULT_OOM;
 	/* if an huge pmd materialized from under us just retry later */
 	if (unlikely(pmd_trans_huge(*pmd)))
diff --git a/mm/memory.c b/mm/memory.c
index 8022526..30e1335 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3845,8 +3750,7 @@ retry:
 	 * run pte_offset_map on the pmd, if an huge pmd could
 	 * materialize from under us from a different thread.
 	 */
-	if (unlikely(pmd_none(*pmd)) &&
-	    unlikely(__pte_alloc(mm, vma, pmd, address)))
+	if (unlikely(pmd_none(*pmd)) && __pte_alloc(mm, vma, pmd, address))
 		return VM_FAULT_OOM;
 	/* if an huge pmd materialized from under us just retry later */
 	if (unlikely(pmd_trans_huge(*pmd)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
