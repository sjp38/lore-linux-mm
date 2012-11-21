Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 36ABA6B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 17:46:59 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so5356727eek.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:46:57 -0800 (PST)
Date: Wed, 21 Nov 2012 23:46:53 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121121224653.GA4164@gmail.com>
References: <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com>
 <20121120060014.GA14065@gmail.com>
 <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com>
 <20121120074445.GA14539@gmail.com>
 <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com>
 <20121120090637.GA14873@gmail.com>
 <CA+55aFyR9FsGYWSKkgsnZB7JhheDMjEQgbzb0gsqawSTpetPvA@mail.gmail.com>
 <20121121171047.GA28875@gmail.com>
 <CA+55aFwCiA=4+piuvf6uTT6dqeJm_Nmib_zZ=4Xj0_JmN1GrnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwCiA=4+piuvf6uTT6dqeJm_Nmib_zZ=4Xj0_JmN1GrnA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Nov 21, 2012 at 7:10 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > Because scalability slowdowns are often non-linear.
> 
> Only if you hold locks or have other non-cpu-private activity.
> 
> Which the vsyscall code really shouldn't have.

Yeah, the faults accessing any sort of thread shared cache line 
was my main thinking - the vsyscall faults are so hidden, and 
David's transaction score was so low that I could not exclude 
some extremely high page fault rate (which would not get 
reported by anything other than a strange blip on the profile). 
I was thinking of a hundred thousand vsyscall page faults per 
second as a possibility - SPECjbb measures time for every 
transaction.

So this was just a "maybe-that-has-an-effect" blind theory of 
mine - and David's testing did not confirm it so we know it was 
a bad idea.

I basically wanted to see a profile from David that looked as 
flat as mine - that would have excluded a handful of unknown 
unknowns.

> That said, it might be worth removing the 
> "prefetchw(&mm->mmap_sem)" from the VM fault path. Partly 
> because software prefetches have never ever worked on any 
> reasonable hardware, and partly because it could seriously 
> screw up things like the vsyscall stuff.

Yeah, I was wondering about that one too ...

> I think we only turn prefetchw into an actual prefetch 
> instruction on 3DNOW hardware. Which is the *old* AMD chips. I 
> don't think even the Athlon does that.
> 
> Anyway, it might be interesting to see a instruction-level 
> annotated profile of do_page_fault() or whatever

Yes.

> > So with CONFIG_NUMA_BALANCING=y we are taking a higher page 
> > fault rate, in exchange for a speedup.
> 
> The thing is, so is autonuma.
> 
> And autonuma doesn't show any of these problems. [...]

AutoNUMA regresses on this workload, at least on my box:

                         v3.7  AutoNUMA   |  numa/core-v16    [ vs. v3.7]
                        -----  --------   |  -------------    -----------
                                          |
  [ SPECjbb transactions/sec ]            |
  [ higher is better         ]            |
                                          |
  SPECjbb single-1x32    524k     507k    |       638k           +21.7%

It regresses by 3.3% over mainline. [I have not measured a 
THP-disabled number for AutoNUMA.]

Maybe it does not regress on David's box - I have just 
re-checked all of David's mails and AFAICS he has not reported 
AutoNUMA SPECjbb performance.

> Why are you ignoring that fact?

I'm not :-(

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
