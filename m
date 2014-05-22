Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id E4B4B6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 13:47:25 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so2850713pbc.1
        for <linux-mm@kvack.org>; Thu, 22 May 2014 10:47:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id aq3si583362pbc.124.2014.05.22.10.47.24
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 10:47:25 -0700 (PDT)
Date: Thu, 22 May 2014 10:47:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-Id: <20140522104722.f76b5b8dc0ec28510687be2e@linux-foundation.org>
In-Reply-To: <20140522084643.GD23991@suse.de>
References: <20140513141748.GD2485@laptop.programming.kicks-ass.net>
	<20140514161152.GA2615@redhat.com>
	<20140514192945.GA10830@redhat.com>
	<20140515104808.GF23991@suse.de>
	<20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
	<20140521121501.GT23991@suse.de>
	<20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
	<20140521213354.GL2485@laptop.programming.kicks-ass.net>
	<20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
	<20140522064529.GI30445@twins.programming.kicks-ass.net>
	<20140522084643.GD23991@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Thu, 22 May 2014 09:46:43 +0100 Mel Gorman <mgorman@suse.de> wrote:

> > > If I'm still on track here, what happens if we switch to wake-all so we
> > > can avoid the dangling flag?  I doubt if there are many collisions on
> > > that hash table?
> > 
> > Wake-all will be ugly and loose a herd of waiters, all racing to
> > acquire, all but one of whoem will loose the race. It also looses the
> > fairness, its currently a FIFO queue. Wake-all will allow starvation.
> > 
> 
> And the cost of the thundering herd of waiters may offset any benefit of
> reducing the number of calls to page_waitqueue and waker functions.

Well, none of this has been demonstrated.

As I speculated earlier, hash chain collisions will probably be rare,
except for the case where a bunch of processes are waiting on the same
page.  And in this case, perhaps wake-all is the desired behavior.

Take a look at do_read_cache_page().  It does lock_page(), but it
doesn't actually *need* to.  It checks ->mapping and PG_uptodate and
then...  unlocks the page!  We could have used wait_on_page_locked()
there and permitted concurrent threads to run concurrently.

btw, I'm struggling a bit to understand why we bother checking
->mapping there as we're about to unlock the page anyway...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
