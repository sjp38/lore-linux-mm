Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 75EEF6B00A9
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 03:55:26 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id h18so233269igc.1
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 00:55:26 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id n10si31894154igi.6.2014.02.26.00.55.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 00:55:24 -0800 (PST)
Date: Wed, 26 Feb 2014 09:55:18 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2] mm: per-thread vma caching
Message-ID: <20140226085518.GI3104@twins.programming.kicks-ass.net>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
 <20140226085048.GE18404@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140226085048.GE18404@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 26, 2014 at 09:50:48AM +0100, Peter Zijlstra wrote:
> On Tue, Feb 25, 2014 at 10:16:46AM -0800, Davidlohr Bueso wrote:
> > +void vmacache_invalidate_all(void)
> > +{
> > +	struct task_struct *g, *p;
> > +
> > +	rcu_read_lock();
> > +	for_each_process_thread(g, p) {
> > +		/*
> > +		 * Only flush the vmacache pointers as the
> > +		 * mm seqnum is already set and curr's will
> > +		 * be set upon invalidation when the next
> > +		 * lookup is done.
> > +		 */
> > +		memset(p->vmacache, 0, sizeof(p->vmacache));
> > +	}
> > +	rcu_read_unlock();
> > +}
> 
> With all the things being said on this particular piece already; I
> wanted to add that the iteration there is incomplete; we can clone()
> using CLONE_VM without using CLONE_THREAD.
> 
> Its not common, but it can be done. In that case the above iteration
> will miss a task that shares the same mm.

Bugger; n/m that. I just spotted that it's yet another way to iterate
all tasks in the system.

Of course we need multiple macros to do this :/

Pretty horrifically expensive though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
