Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id E15116B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 17:06:34 -0400 (EDT)
Date: Thu, 13 Jun 2013 14:06:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Revert pinned_vm braindamage
Message-Id: <20130613140632.15982af2ebc443b24bfff86a@linux-foundation.org>
In-Reply-To: <20130606124351.GZ27176@twins.programming.kicks-ass.net>
References: <20130606124351.GZ27176@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, roland@kernel.org, mingo@kernel.org, tglx@linutronix.de, kosaki.motohiro@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org, Mike Marciniszyn <infinipath@intel.com>

Let's try to get this wrapped up?

On Thu, 6 Jun 2013 14:43:51 +0200 Peter Zijlstra <peterz@infradead.org> wrote:

> 
> Patch bc3e53f682 ("mm: distinguish between mlocked and pinned pages")
> broke RLIMIT_MEMLOCK.

I rather like what bc3e53f682 did, actually.  RLIMIT_MEMLOCK limits the
amount of memory you can mlock().  Nice and simple.

This pinning thing which infiniband/perf are doing is conceptually
different and if we care at all, perhaps we should be looking at adding
RLIMIT_PINNED.

> Before that patch: mm_struct::locked_vm < RLIMIT_MEMLOCK; after that
> patch we have: mm_struct::locked_vm < RLIMIT_MEMLOCK &&
> mm_struct::pinned_vm < RLIMIT_MEMLOCK.

But this is a policy decision which was implemented in perf_mmap() and
perf can alter that decision.  How bad would it be if perf just ignored
RLIMIT_MEMLOCK?


drivers/infiniband/hw/qib/qib_user_pages.c has issues, btw.  It
compares the amount-to-be-pinned with rlimit(RLIMIT_MEMLOCK), but
forgets to also look at current->mm->pinned_vm.  Duh.

It also does the pinned accounting in __qib_get_user_pages() but in
__qib_release_user_pages(), the caller is supposed to do it, which is
rather awkward.


Longer-term I don't think that inifinband or perf should be dinking
around with rlimit(RLIMIT_MEMLOCK) or ->pinned_vm.  Those policy
decisions should be hoisted into a core mm helper where we can do it
uniformly (and more correctly than infiniband's attempt!).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
