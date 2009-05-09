Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 590426B00C5
	for <linux-mm@kvack.org>; Sat,  9 May 2009 08:23:34 -0400 (EDT)
Date: Sat, 9 May 2009 20:23:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch] tracing/mm: add page frame snapshot trace
Message-ID: <20090509122309.GC8940@localhost>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508124433.GB15949@localhost> <20090509062758.GB21354@elte.hu> <20090509091325.GA7994@localhost> <20090509100137.GC20941@elte.hu> <20090509105742.GA8398@localhost> <20090509110513.GD16138@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090509110513.GD16138@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: =?utf-8?B?RnLDqWTDqXJpYw==?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, May 09, 2009 at 07:05:13PM +0800, Ingo Molnar wrote:
> 
> * Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Sat, May 09, 2009 at 06:01:37PM +0800, Ingo Molnar wrote:
> > > 
> > > * Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > 
> > > > 2) support concurrent object iterations
> > > >    For example, a huge 1TB memory space can be split up into 10
> > > >    segments which can be queried concurrently (with different options).
> > > 
> > > this should already be possible. If you lseek the trigger file, that 
> > > will be understood as an 'offset' by the patch, and then write a 
> > > (decimal) value into the file, that will be the count.
> > > 
> > > So it should already be possible to fork off nr_cpus helper threads, 
> > > one bound to each CPU, each triggering trace output of a separate 
> > > segment of the memory map - and each reading that CPU's 
> > > trace_pipe_raw file to recover the data - all in parallel.
> > 
> 
> > How will this work out in general? More examples, when walking 
> > pages by file/process, is it possible to divide the 
> > files/processes into N sets, and dump their pages concurrently? 
> > When walking the (huge) inode lists of different superblocks, is 
> > it possible to fork one thread for each superblock?
> > 
> > In the above situations, they would demand concurrent instances 
> > with different filename/pid/superblock options.
> 
> the iterators are certainly more complex, and harder to parallelise, 
> in those cases, i submit.

OK. I'm pushing the parallelism idea because 4+ cores is going to be
commonplace in desktop(not to mention the servers). And I have a clear 
use case for the parallelism: user space directed memory shrinking
before hibernation. Where the user space tool scan all/most pages in
all/most files in all superblocks and then selectively fadvise(DONTNEED).

In that case we want to work as fast as possible in order not to slow
down the hibernation speed. Parallelism definitely helps.

> But i like the page map example because it is (by far!) the largest 
> collection of objects. Four million pages on a test-box i have.

Yes!

> So if the design is right and we do dumping on that extreme-end very 
> well, we might not even care that much about parallelising dumping 
> in other situations, even if there are thousands of tasks - it will 
> just be even faster. And then we can keep the iterators and the APIs 
> as simple as simple.

That offset trick won't work well for small files. When we have lots
of small files, the parallelism granularity shall be files instead of
page chunks inside them. Maybe I'm too stressing.

> ( End even for tasks, which are perhaps the hardest to iterate, we
>   can still do the /proc method of iterating up to the offset by 
>   counting. It wastes some time for each separate thread as it has 
>   to count up to its offset, but it still allows the dumping itself
>   to be parallelised. Or we could dump blocks of the PID hash array. 
>   That distributes tasks well, and can be iterated very easily with 
>   low/zero contention. The result will come out unordered in any 
>   case. )

For task/file based page walking, the best parallelism unit can be
the task/file, instead of page segments inside them.

And there is the sparse file problem. There will be large holes in
the address space of file and process(and even physical memory!).

It would be good to not output any lines for the holes. Even better,
in the case of file/process, lots of pages will share the same flags,
count and mapcount. If not printing their pfn, the output can be
stripped from per-page lines
        index flags count mapcount
to per-page-range summaries:
        index len flags count mapcount

For example, here is an output from my filecache tool. This trick
could reduce 10x output size!

        # idx   len     state   refcnt
        0       1       RAMU___ 2
        1       3       ___U___ 1
        4       1       RAMU___ 2
        5       57      R_MU___ 2
        62      2       ___U___ 1
        64      60      R_MU___ 2
        124     6       ___U___ 1
        130     1       R_MU___ 2
        131     1       ___U___ 1
        132     2       R_MU___ 2
        134     1       ___U___ 1
        135     2       R_MU___ 2
        137     1       ___U___ 1
        138     5       R_MU___ 2
        143     1       ___U___ 1
        144     2       R_MU___ 2
        146     2       ___U___ 1
        148     26      R_MU___ 2
        174     3       ___U___ 1
        177     54      R_MU___ 2
        231     1       ___U___ 1
        232     16      R_MU___ 2
        248     2       ___U___ 1

Another problem can be, the holes are often really huge. If user space
walk the pages by 

        while true
        do
                echo n n+10000 > range-to-dump
                cat trace >> log
        done

Then the holes will still consume a lot of unnecessary context switches.
It would better to work this way:
        while true
        do 
                echo 10000 > amount-to-dump
                cat trace >> log
        done

Is this possible?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
