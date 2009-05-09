Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 97ACD6B003D
	for <linux-mm@kvack.org>; Sat,  9 May 2009 07:05:29 -0400 (EDT)
Date: Sat, 9 May 2009 13:05:13 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] tracing/mm: add page frame snapshot trace
Message-ID: <20090509110513.GD16138@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508124433.GB15949@localhost> <20090509062758.GB21354@elte.hu> <20090509091325.GA7994@localhost> <20090509100137.GC20941@elte.hu> <20090509105742.GA8398@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090509105742.GA8398@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Sat, May 09, 2009 at 06:01:37PM +0800, Ingo Molnar wrote:
> > 
> > * Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > 2) support concurrent object iterations
> > >    For example, a huge 1TB memory space can be split up into 10
> > >    segments which can be queried concurrently (with different options).
> > 
> > this should already be possible. If you lseek the trigger file, that 
> > will be understood as an 'offset' by the patch, and then write a 
> > (decimal) value into the file, that will be the count.
> > 
> > So it should already be possible to fork off nr_cpus helper threads, 
> > one bound to each CPU, each triggering trace output of a separate 
> > segment of the memory map - and each reading that CPU's 
> > trace_pipe_raw file to recover the data - all in parallel.
> 

> How will this work out in general? More examples, when walking 
> pages by file/process, is it possible to divide the 
> files/processes into N sets, and dump their pages concurrently? 
> When walking the (huge) inode lists of different superblocks, is 
> it possible to fork one thread for each superblock?
> 
> In the above situations, they would demand concurrent instances 
> with different filename/pid/superblock options.

the iterators are certainly more complex, and harder to parallelise, 
in those cases, i submit.

But i like the page map example because it is (by far!) the largest 
collection of objects. Four million pages on a test-box i have.

So if the design is right and we do dumping on that extreme-end very 
well, we might not even care that much about parallelising dumping 
in other situations, even if there are thousands of tasks - it will 
just be even faster. And then we can keep the iterators and the APIs 
as simple as simple.

( End even for tasks, which are perhaps the hardest to iterate, we
  can still do the /proc method of iterating up to the offset by 
  counting. It wastes some time for each separate thread as it has 
  to count up to its offset, but it still allows the dumping itself
  to be parallelised. Or we could dump blocks of the PID hash array. 
  That distributes tasks well, and can be iterated very easily with 
  low/zero contention. The result will come out unordered in any 
  case. )

What do you think?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
