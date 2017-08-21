Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EAF5280422
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 14:32:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z96so22409195wrb.5
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 11:32:37 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id b2si11981363ede.103.2017.08.21.11.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 11:32:35 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 27C0B1C16CB
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 19:32:35 +0100 (IST)
Date: Mon, 21 Aug 2017 19:32:34 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Message-ID: <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Aug 18, 2017 at 12:14:12PM -0700, Linus Torvalds wrote:
> On Fri, Aug 18, 2017 at 11:54 AM, Mel Gorman
> <mgorman@techsingularity.net> wrote:
> >
> > One option to mitigate (but not eliminate) the problem is to record when
> > the page lock is contended and pass in TNF_PAGE_CONTENDED (new flag) to
> > task_numa_fault().
> 
> Well, finding it contended is fairly easy - just look at the page wait
> queue, and if it's not empty, assume it's due to contention.
> 

Yes.

> I also wonder if we could be even *more* hacky, and in the whole
> __migration_entry_wait() path, change the logic from:
> 
>  - wait on page lock before retrying the fault
> 
> to
> 
>  - yield()
> 
> which is hacky, but there's a rationale for it:
> 
>  (a) avoid the crazy long wait queues ;)
> 
>  (b) we know that migration is *supposed* to be CPU-bound (not IO
> bound), so yielding the CPU and retrying may just be the right thing
> to do.
> 

Potentially. I spent a few hours trying to construct a test case that
would migrate constantly that could be used as a basis for evaluating a
patch or alternative. Unfortunately it was not as easy as I thought and
I still have to construct a case that causes migration storms that would
result in multiple threads waiting on a single page.

> Because that code sequence doesn't actually depend on
> "wait_on_page_lock()" for _correctness_ anyway, afaik. Anybody who
> does "migration_entry_wait()" _has_ to retry anyway, since the page
> table contents may have changed by waiting.
> 
> So I'm not proud of the attached patch, and I don't think it's really
> acceptable as-is, but maybe it's worth testing? And maybe it's
> arguably no worse than what we have now?
> 
> Comments?
> 

The transhuge migration path for numa balancing doesn't go through the
migration_entry_wait patch despite similarly named functions that suggest
it does so this may only has the most effect when THP is disabled. It's
worth trying anyway.

Covering both paths would be something like the patch below which spins
until the page is unlocked or it should reschedule. It's not even boot
tested as I spent what time I had on the test case that I hoped would be
able to prove it really works.

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 79b36f57c3ba..31cda1288176 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -517,6 +517,13 @@ static inline void wait_on_page_locked(struct page *page)
 		wait_on_page_bit(compound_head(page), PG_locked);
 }
 
+void __spinwait_on_page_locked(struct page *page);
+static inline void spinwait_on_page_locked(struct page *page)
+{
+	if (PageLocked(page))
+		__spinwait_on_page_locked(page);
+}
+
 static inline int wait_on_page_locked_killable(struct page *page)
 {
 	if (!PageLocked(page))
diff --git a/mm/filemap.c b/mm/filemap.c
index a49702445ce0..c9d6f49614bc 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1210,6 +1210,15 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 	}
 }
 
+void __spinwait_on_page_locked(struct page *page)
+{
+	do {
+		cpu_relax();
+	} while (PageLocked(page) && !cond_resched());
+
+	wait_on_page_locked(page);
+}
+
 /**
  * page_cache_next_hole - find the next hole (not-present entry)
  * @mapping: mapping
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 90731e3b7e58..c7025c806420 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1443,7 +1443,7 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 		if (!get_page_unless_zero(page))
 			goto out_unlock;
 		spin_unlock(vmf->ptl);
-		wait_on_page_locked(page);
+		spinwait_on_page_locked(page);
 		put_page(page);
 		goto out;
 	}
@@ -1480,7 +1480,7 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 		if (!get_page_unless_zero(page))
 			goto out_unlock;
 		spin_unlock(vmf->ptl);
-		wait_on_page_locked(page);
+		spinwait_on_page_locked(page);
 		put_page(page);
 		goto out;
 	}
diff --git a/mm/migrate.c b/mm/migrate.c
index e84eeb4e4356..9b6c3fc5beac 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -308,7 +308,7 @@ void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
 	if (!get_page_unless_zero(page))
 		goto out;
 	pte_unmap_unlock(ptep, ptl);
-	wait_on_page_locked(page);
+	spinwait_on_page_locked(page);
 	put_page(page);
 	return;
 out:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
