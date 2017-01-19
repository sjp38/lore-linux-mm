Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 663EE6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 21:48:10 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so41054991pfy.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 18:48:10 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id j186si2050740pfb.193.2017.01.18.18.48.08
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 18:48:09 -0800 (PST)
Date: Thu, 19 Jan 2017 11:47:55 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 05/15] lockdep: Make check_prev_add can use a separate
 stack_trace
Message-ID: <20170119024755.GO3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-6-git-send-email-byungchul.park@lge.com>
 <20170112161643.GB3144@twins.programming.kicks-ass.net>
 <20170113101143.GE3326@X58A-UD3R>
 <20170117155431.GE5680@worktop>
 <20170118020432.GK3326@X58A-UD3R>
 <20170118151053.GF6500@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118151053.GF6500@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 04:10:53PM +0100, Peter Zijlstra wrote:
> On Wed, Jan 18, 2017 at 11:04:32AM +0900, Byungchul Park wrote:
> > On Tue, Jan 17, 2017 at 04:54:31PM +0100, Peter Zijlstra wrote:
> > > On Fri, Jan 13, 2017 at 07:11:43PM +0900, Byungchul Park wrote:
> > > > What do you think about the following patches doing it?
> > > 
> > > I was more thinking about something like so...
> > > 
> > > Also, I think I want to muck with struct stack_trace; the members:
> > > max_nr_entries and skip are input arguments to save_stack_trace() and
> > > bloat the structure for no reason.
> > 
> > With your approach, save_trace() must be called whenever check_prevs_add()
> > is called, which might be unnecessary.
> 
> True.. but since we hold the graph_lock this is a slow path anyway, so I
> didn't care much.

If we don't need to care it, the problem becomes easy to solve. But IMHO,
it'd be better to care it as original lockdep code did, because
save_trace() might have bigger overhead than we expect and
check_prevs_add() can be called frequently, so it'd be better to avoid it
when possible.

> Then again, I forgot to clean up in a bunch of paths.
> 
> > Frankly speaking, I think what I proposed resolved it neatly. Don't you
> > think so?
> 
> My initial reaction was to your patches being radically different to
> what I had proposed. But after fixing mine I don't particularly like
> either one of them.
> 
> Also, I think yours has a hole in, you check nr_stack_trace_entries
> against an older copy to check we did save_stack(), this is not accurate
> as check_prev_add() can drop graph_lock in the verbose case and then
> someone else could have done save_stack().

Right. My mistake..

Then.. The following patch on top of my patch 2/2 can solve it. Right?

---

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 49b9386..0f5bded 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1892,7 +1892,7 @@ static inline void inc_chains(void)
 		if (entry->class == hlock_class(next)) {
 			if (distance == 1)
 				entry->distance = 1;
-			return 2;
+			return 1;
 		}
 	}
 
@@ -1927,9 +1927,10 @@ static inline void inc_chains(void)
 		print_lock_name(hlock_class(next));
 		printk(KERN_CONT "\n");
 		dump_stack();
-		return graph_lock();
+		if (!graph_lock())
+			return 0;
 	}
-	return 1;
+	return 2;
 }
 
 /*
@@ -1975,15 +1976,16 @@ static inline void inc_chains(void)
 			 * added:
 			 */
 			if (hlock->read != 2 && hlock->check) {
-				if (!check_prev_add(curr, hlock, next,
-							distance, &trace, save))
+				int ret = check_prev_add(curr, hlock, next,
+							distance, &trace, save);
+				if (!ret)
 					return 0;
 
 				/*
 				 * Stop saving stack_trace if save_trace() was
 				 * called at least once:
 				 */
-				if (save && start_nr != nr_stack_trace_entries)
+				if (save && ret == 2)
 					save = NULL;
 
 				/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
