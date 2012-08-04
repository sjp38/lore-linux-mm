Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 338D86B0068
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 19:02:49 -0400 (EDT)
Date: Sat, 4 Aug 2012 23:59:10 +0100
From: "Dr. David Alan Gilbert" <dave@treblig.org>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120804225910.GB1255@gallifrey>
References: <1343064870.26034.23.camel@twins>
 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
 <20120804143719.GB10459@redhat.com>
 <20120804220245.GB3307@linux.vnet.ibm.com>
 <20120804224705.GD10459@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120804224705.GD10459@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

* Andrea Arcangeli (aarcange@redhat.com) wrote:
> On Sat, Aug 04, 2012 at 03:02:45PM -0700, Paul E. McKenney wrote:
> > OK, I'll bite.  ;-)
> 
> :))
> 
> > The most sane way for this to happen is with feedback-driven techniques
> > involving profiling, similar to what is done for basic-block reordering
> > or branch prediction.  The idea is that you compile the kernel in an
> > as-yet (and thankfully) mythical pointer-profiling mode, which records
> > the values of pointer loads and also measures the pointer-load latency.
> > If a situation is found where a given pointer almost always has the
> > same value but has high load latency (for example, is almost always a
> > high-latency cache miss), this fact is recorded and fed back into a
> > subsequent kernel build.  This subsequent kernel build might choose to
> > speculate the value of the pointer concurrently with the pointer load.
> > 
> > And of course, when interpreting the phrase "most sane way" at the
> > beginning of the prior paragraph, it would probably be wise to keep
> > in mind who wrote it.  And that "most sane way" might have little or
> > no resemblance to anything that typical kernel hackers would consider
> > anywhere near sanity.  ;-)
> 
> I see. The above scenario is sure fair enough assumption. We're
> clearly stretching the constraints to see what is theoretically
> possible and this is a very clear explanation of how gcc could have an
> hardcoded "guessed" address in the .text.
> 
> Next step to clearify now, is how gcc can safely dereference such a
> "guessed" address without the kernel knowing about it.
> 
> If gcc would really dereference a guessed address coming from a
> profiling run without kernel being aware of it, it would eventually
> crash the kernel with an oops. gcc cannot know what another CPU will
> do with the kernel pagetables. It'd be perfectly legitimate to
> temporarily move the data at the "guessed address" to another page and
> to update the pointer through stop_cpu during some weird "cpu
> offlining scenario" or anything you can imagine. I mean gcc must
> behave in all cases so it's not allowed to deference the guessed
> address at any given time.

A compiler could decide to dereference it using a non-faulting load,
do the calculations or whatever on the returned value of the non-faulting
load, and then check whether the load actually faulted, and whether the
address matched the prediction before it did a store based on it's
guess.

Dave
-- 
 -----Open up your eyes, open up your mind, open up your code -------   
/ Dr. David Alan Gilbert    |       Running GNU/Linux       | Happy  \ 
\ gro.gilbert @ treblig.org |                               | In Hex /
 \ _________________________|_____ http://www.treblig.org   |_______/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
