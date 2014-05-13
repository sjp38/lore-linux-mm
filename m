Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 71DC26B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 14:58:35 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so696709eek.7
        for <linux-mm@kvack.org>; Tue, 13 May 2014 11:58:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id o49si13827456eef.218.2014.05.13.11.58.33
        for <linux-mm@kvack.org>;
        Tue, 13 May 2014 11:58:34 -0700 (PDT)
Date: Tue, 13 May 2014 20:57:42 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
	waitqueue lookups in unlock_page fastpath
Message-ID: <20140513185742.GD12123@redhat.com>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de> <1399974350-11089-20-git-send-email-mgorman@suse.de> <20140513125313.GR23991@suse.de> <20140513141748.GD2485@laptop.programming.kicks-ass.net> <20140513152719.GF18164@linux.vnet.ibm.com> <20140513154435.GG2485@laptop.programming.kicks-ass.net> <20140513161418.GH18164@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140513161418.GH18164@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On 05/13, Paul E. McKenney wrote:
>
> On Tue, May 13, 2014 at 05:44:35PM +0200, Peter Zijlstra wrote:
> >
> > Ah, yes, so I'll defer to Oleg and Linus to explain that one. As per the
> > name: smp_mb__before_spinlock() should of course imply a full barrier.
>
> How about if I queue a name change to smp_wmb__before_spinlock()?

I agree, this is more accurate, simply because it describes what it
actually does.

But just in case, as for try_to_wake_up() it does not actually need
wmb() between "CONDITION = T" and "task->state = RUNNING". It would
be fine if these 2 STORE's are re-ordered, we can rely on rq->lock.

What it actually needs is a barrier between "CONDITION = T" and
"task->state & state" check. But since we do not have a store-load
barrier, wmb() was added to ensure that "CONDITION = T" can't leak
into the critical section.

But it seems that set_tlb_flush_pending() already assumes that it
acts as wmb(), so probably smp_wmb__before_spinlock() is fine.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
