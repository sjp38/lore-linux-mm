Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id EA9B86B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 18:08:20 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130730192455.GA22259@gmail.com>
References: <20130628093809.GB29205@gmail.com>
	 <1372453461.22432.216.camel@schen9-DESK> <20130629071245.GA5084@gmail.com>
	 <1372710497.22432.224.camel@schen9-DESK> <20130702064538.GB3143@gmail.com>
	 <1373997195.22432.297.camel@schen9-DESK> <20130723094513.GA24522@gmail.com>
	 <20130723095124.GW27075@twins.programming.kicks-ass.net>
	 <20130723095306.GA26174@gmail.com> <1375143209.22432.419.camel@schen9-DESK>
	 <20130730192455.GA22259@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 05 Aug 2013 15:08:23 -0700
Message-ID: <1375740503.22432.429.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi,
 Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Tue, 2013-07-30 at 21:24 +0200, Ingo Molnar wrote:

> > 
> > Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> 
> > +config RWSEM_SPIN_ON_WRITE_OWNER
> > +	bool "Optimistic spin write acquisition for writer owned rw-sem"
> > +	default n
> > +	depends on SMP
> > +	help
> > +	  Allows a writer to perform optimistic spinning if another writer own
> > +	  the read write semaphore.  If the lock owner is running, it is likely
> > +	  to release the lock soon. Spinning gives a greater chance for writer to
> > +	  acquire a semaphore before putting it to sleep.
> 
> The way you've worded this new Kconfig option makes it 
> sound as if it's not just for testing, and I'm not a big 
> believer in extra Kconfig degrees of freedom for 
> scalability features of core locking primitives like 
> rwsems, in production kernels ...
> 
> So the bad news is that such scalability optimizations 
> really need to work for everyone.
> 
> The good news is that I don't think there's anything 
> particularly controversial about making the rwsem write 
> side perform just as well as mutexes - it would in fact be 
> a very nice quality of implementation feature: it gives 
> people freedom to switch between mutexes and rwsems without 
> having to worry about scalability differences too much.
> 

Sorry for replying to your email late as I was pulled to
some other tasks.

Ingo, any objection if I make the optimistic writer spin the
default for SMP without an extra config? This will make 
the rw_semaphore structure grow a bit to accommodate the
owner and spin_mlock field.

Thanks.

Tim
> Once readers are mixed into the workload can we keep the 
> XFS assumptions, if they are broken in any way?
> 
> We are spinning here so we have full awareness about the 
> state of the lock and we can react to a new reader in very 
> short order - so at a quick glance I don't see any 
> fundamental difficulty in being able to resolve it - beyond 
> the SMOP aspect that is ... :-)
> 
> Thanks,
> 
> 	Ingo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
