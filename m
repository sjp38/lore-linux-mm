Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id AFDED6B0033
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 12:41:18 -0400 (EDT)
Date: Wed, 28 Aug 2013 18:41:00 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH -v3] sched, numa: Use {cpu, pid} to create task groups
 for shared faults
Message-ID: <20130828164100.GS10002@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130730113857.GR3008@twins.programming.kicks-ass.net>
 <20130731150751.GA15144@twins.programming.kicks-ass.net>
 <51F93105.8020503@hp.com>
 <20130802164715.GP27162@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130802164715.GP27162@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Don Morris <don.morris@hp.com>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, riel@redhat.com

On Fri, Aug 02, 2013 at 06:47:15PM +0200, Peter Zijlstra wrote:
> Subject: sched, numa: Use {cpu, pid} to create task groups for shared faults
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Tue Jul 30 10:40:20 CEST 2013
> 
> A very simple/straight forward shared fault task grouping
> implementation.
> 
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>

So Rik and me found a possible issue with this -- although in the end it
turned out to be a userspace 'feature' instead.

It might be possible for a COW page to be 'shared' and thus get a
last_cpupid set from another process. When we break cow and reuse the
now private and writable page might still have this last_cpupid and thus
cause a shared fault and form grouping.

Something like the below resets the last_cpupid field on reuse much like
fresh COW copies will have.

There might be something that avoids the above scenario but I'm too
tired to come up with anything.

---

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2730,6 +2730,9 @@ static int do_wp_page(struct mm_struct *
 		get_page(dirty_page);
 
 reuse:
+		if (old_page)
+			page_cpupid_xchg_last(old_page, (1 << LAST_CPUPID_SHIFT) - 1);
+
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = pte_mkyoung(orig_pte);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
