Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 526FC6B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 08:23:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k46so6155183wre.9
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 05:23:43 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id z74si1142948wmz.204.2017.08.18.05.23.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Aug 2017 05:23:41 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id CF2471DC0C6
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 12:23:40 +0000 (UTC)
Date: Fri, 18 Aug 2017 13:23:39 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Message-ID: <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Aug 17, 2017 at 01:44:40PM -0700, Linus Torvalds wrote:
> On Thu, Aug 17, 2017 at 1:18 PM, Liang, Kan <kan.liang@intel.com> wrote:
> >
> > Here is the call stack of wait_on_page_bit_common
> > when the queue is long (entries >1000).
> >
> > # Overhead  Trace output
> > # ........  ..................
> > #
> >    100.00%  (ffffffff931aefca)
> >             |
> >             ---wait_on_page_bit
> >                __migration_entry_wait
> >                migration_entry_wait
> >                do_swap_page
> >                __handle_mm_fault
> >                handle_mm_fault
> >                __do_page_fault
> >                do_page_fault
> >                page_fault
> 
> Hmm. Ok, so it does seem to very much be related to migration. Your
> wake_up_page_bit() profile made me suspect that, but this one seems to
> pretty much confirm it.
> 
> So it looks like that wait_on_page_locked() thing in
> __migration_entry_wait(), and what probably happens is that your load
> ends up triggering a lot of migration (or just migration of a very hot
> page), and then *every* thread ends up waiting for whatever page that
> ended up getting migrated.
> 

Agreed.

> And so the wait queue for that page grows hugely long.
> 

It's basically only bounded by the maximum number of threads that can exist.

> Looking at the other profile, the thing that is locking the page (that
> everybody then ends up waiting on) would seem to be
> migrate_misplaced_transhuge_page(), so this is _presumably_ due to
> NUMA balancing.
> 

Yes, migrate_misplaced_transhuge_page requires NUMA balancing to be part
of the picture.

> Does the problem go away if you disable the NUMA balancing code?
> 
> Adding Mel and Kirill to the participants, just to make them aware of
> the issue, and just because their names show up when I look at blame.
> 

I'm not imagining a way of dealing with this that would reliably detect
when there are a large number of waiters without adding a mess. We could
adjust the scanning rate to reduce the problem but it would be difficult
to target properly and wouldn't prevent the problem occurring with the
added hassle that it would now be intermittent.

Assuming the problem goes away by disabling NUMA then it would be nice if it
could be determined that the page lock holder is trying to allocate a page
when the queue is huge. That is part of the operation that potentially
takes a long time and may be why so many callers are stacking up. If
so, I would suggest clearing __GFP_DIRECT_RECLAIM from the GFP flags in
migrate_misplaced_transhuge_page and assume that a remote hit is always
going to be cheaper than compacting memory to successfully allocate a
THP. That may be worth doing unconditionally because we'd have to save a
*lot* of remote misses to offset compaction cost.

Nothing fancy other than needing a comment if it works.

diff --git a/mm/migrate.c b/mm/migrate.c
index 627671551873..87b0275ddcdb 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1926,7 +1926,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		goto out_dropref;
 
 	new_page = alloc_pages_node(node,
-		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
+		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE) & ~__GFP_DIRECT_RECLAIM,
 		HPAGE_PMD_ORDER);
 	if (!new_page)
 		goto out_fail;

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
