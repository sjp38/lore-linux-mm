Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 03DA96B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 05:45:35 -0400 (EDT)
Date: Mon, 17 Jun 2013 11:45:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: Revert pinned_vm braindamage
Message-ID: <20130617094530.GO3204@twins.programming.kicks-ass.net>
References: <20130606124351.GZ27176@twins.programming.kicks-ass.net>
 <20130613140632.15982af2ebc443b24bfff86a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130613140632.15982af2ebc443b24bfff86a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: torvalds@linux-foundation.org, roland@kernel.org, mingo@kernel.org, tglx@linutronix.de, kosaki.motohiro@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org, Mike Marciniszyn <infinipath@intel.com>

On Thu, Jun 13, 2013 at 02:06:32PM -0700, Andrew Morton wrote:
> Let's try to get this wrapped up?
> 
> On Thu, 6 Jun 2013 14:43:51 +0200 Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > 
> > Patch bc3e53f682 ("mm: distinguish between mlocked and pinned pages")
> > broke RLIMIT_MEMLOCK.
> 
> I rather like what bc3e53f682 did, actually.  RLIMIT_MEMLOCK limits the
> amount of memory you can mlock().  Nice and simple.
> 
> This pinning thing which infiniband/perf are doing is conceptually
> different and if we care at all, perhaps we should be looking at adding
> RLIMIT_PINNED.

We could do that; but I really don't like doing it for the reasons I
outlined previously. It gives the user another knob to twiddle which is
pretty much the same as one he already has just slightly different.

Like said, I see RLIMIT_MEMLOCK to mean the amount of pages the user can
exempt from paging; since that is what the VM cares about most.

> > Before that patch: mm_struct::locked_vm < RLIMIT_MEMLOCK; after that
> > patch we have: mm_struct::locked_vm < RLIMIT_MEMLOCK &&
> > mm_struct::pinned_vm < RLIMIT_MEMLOCK.
> 
> But this is a policy decision which was implemented in perf_mmap() and
> perf can alter that decision.  How bad would it be if perf just ignored
> RLIMIT_MEMLOCK?

Then it could pin all memory -- seems like something bad.

> drivers/infiniband/hw/qib/qib_user_pages.c has issues, btw.  It
> compares the amount-to-be-pinned with rlimit(RLIMIT_MEMLOCK), but
> forgets to also look at current->mm->pinned_vm.  Duh.
> 
> It also does the pinned accounting in __qib_get_user_pages() but in
> __qib_release_user_pages(), the caller is supposed to do it, which is
> rather awkward.
> 
> 
> Longer-term I don't think that inifinband or perf should be dinking
> around with rlimit(RLIMIT_MEMLOCK) or ->pinned_vm.  Those policy
> decisions should be hoisted into a core mm helper where we can do it
> uniformly (and more correctly than infiniband's attempt!).

Agreed, hence my VM_PINNED proposal that would lift most of that to the
core VM.

I just got really lost in the IB code :/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
