Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5C80C6B01AF
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 13:34:19 -0400 (EDT)
Date: Tue, 23 Mar 2010 18:34:09 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge
 regression in performance
Message-ID: <20100323173409.GA24845@elte.hu>
References: <bug-15618-10286@https.bugzilla.kernel.org/>
 <20100323102208.512c16cc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100323102208.512c16cc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, ant.starikov@gmail.com, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> lolz.  Catastrophic meltdown.  Thanks for doing all that work - at a guess 
> I'd say it's mmap_sem. [...]

Looks like we dont need to guess, just look at the call graph profile (a'ka 
the smoking gun):

> > I perf'ed on 2.6.32.9-70.fc12.x86_64 kernel
> >
> > [...]
> >
> > callgraph(top part only):
> > 
> > 53.09%      dve22lts-mc  [kernel]                                         [k]
> > _spin_lock_irqsave
> >                |          
> >                |--49.90%-- __down_read_trylock
> >                |          down_read_trylock
> >                |          do_page_fault
> >                |          page_fault
> >                |          |          
> >                |          |--99.99%-- __GI_memcpy
> >                |          |          |          
> >                |          |          |--84.28%-- (nil)
> >                |          |          |          
> >                |          |          |--9.78%-- 0x100000000
> >                |          |          |          
> >                |          |           --5.94%-- 0x1
> >                |           --0.01%-- 
> > [...]
> > 
> >                |          
> >                |--49.39%-- __up_read
> >                |          up_read
> >                |          |          
> >                |          |--100.00%-- do_page_fault
> >                |          |          page_fault
> >                |          |          |          
> >                |          |          |--99.99%-- __GI_memcpy
> >                |          |          |          |          
> >                |          |          |          |--84.18%-- (nil)
> >                |          |          |          |          
> >                |          |          |          |--10.13%-- 0x100000000
> >                |          |          |          |          
> >                |          |          |           --5.69%-- 0x1
> >                |          |           --0.01%-- 
> > [...]

It shows a very brutal amount of page fault invoked mmap_sem spinning 
overhead.

> Perhaps with some assist from the CPU scheduler.

Doesnt look like it, the perf stat numbers show that the scheduler is only 
very lightly involved:

  > > 129875.554435 task-clock-msecs # 10.210 CPUs 
  > >          1883 context-switches # 0.000 M/sec 
 
a context switch only every ~68 milliseconds.

	Ingo
	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
