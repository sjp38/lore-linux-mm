Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id ED0666B0038
	for <linux-mm@kvack.org>; Tue, 13 May 2014 10:17:53 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id e16so478698qcx.27
        for <linux-mm@kvack.org>; Tue, 13 May 2014 07:17:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id e7si7787590qai.272.2014.05.13.07.17.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 07:17:53 -0700 (PDT)
Date: Tue, 13 May 2014 16:17:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140513141748.GD2485@laptop.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140513125313.GR23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Tue, May 13, 2014 at 01:53:13PM +0100, Mel Gorman wrote:
> On Tue, May 13, 2014 at 10:45:50AM +0100, Mel Gorman wrote:
> >  void unlock_page(struct page *page)
> >  {
> > +	wait_queue_head_t *wqh = clear_page_waiters(page);
> > +
> >  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> > +
> > +	/*
> > +	 * No additional barrier needed due to clear_bit_unlock barriering all updates
> > +	 * before waking waiters
> > +	 */
> >  	clear_bit_unlock(PG_locked, &page->flags);
> > -	smp_mb__after_clear_bit();
> > -	wake_up_page(page, PG_locked);
> 
> This is wrong. The smp_mb__after_clear_bit() is still required to ensure
> that the cleared bit is visible before the wakeup on all architectures.

wakeup implies a mb, and I just noticed that our Documentation is
'obsolete' and only mentions it implies a wmb.

Also, if you're going to use smp_mb__after_atomic() you can use
clear_bit() and not use clear_bit_unlock().



---
Subject: doc: Update wakeup barrier documentation

As per commit e0acd0a68ec7 ("sched: fix the theoretical signal_wake_up()
vs schedule() race") both wakeup and schedule now imply a full barrier.

Furthermore, the barrier is unconditional when calling try_to_wake_up()
and has been for a fair while.

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 Documentation/memory-barriers.txt | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
index 46412bded104..dae5158c2382 100644
--- a/Documentation/memory-barriers.txt
+++ b/Documentation/memory-barriers.txt
@@ -1881,9 +1881,9 @@ The whole sequence above is available in various canned forms, all of which
 	event_indicated = 1;
 	wake_up_process(event_daemon);
 
-A write memory barrier is implied by wake_up() and co. if and only if they wake
-something up.  The barrier occurs before the task state is cleared, and so sits
-between the STORE to indicate the event and the STORE to set TASK_RUNNING:
+A full memory barrier is implied by wake_up() and co. The barrier occurs
+before the task state is cleared, and so sits between the STORE to indicate
+the event and the STORE to set TASK_RUNNING:
 
 	CPU 1				CPU 2
 	===============================	===============================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
