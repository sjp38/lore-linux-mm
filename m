Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 061A06B00B9
	for <linux-mm@kvack.org>; Sat,  9 May 2009 06:36:35 -0400 (EDT)
Date: Sat, 9 May 2009 12:36:46 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] tracing/mm: add page frame snapshot trace
Message-ID: <20090509103646.GA16138@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508124433.GB15949@localhost> <20090509062758.GB21354@elte.hu> <20090509091325.GA7994@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090509091325.GA7994@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> > Preliminary timings on an older, 1GB RAM 2 GHz Athlon64 box show 
> > that it's plenty fast:
> > 
> >  # time echo -1 > /debug/tracing/objects/mm/pages/trigger
> > 
> >   real	0m0.127s
> >   user	0m0.000s
> >   sys	0m0.126s
> > 
> >  # time cat /debug/tracing/per_cpu/*/trace_pipe_raw > /tmp/page-trace.bin
> > 
> >   real	0m0.065s
> >   user	0m0.001s
> >   sys	0m0.064s
> > 
> >   # ls -l /tmp/1
> >   -rw-r--r-- 1 root root 13774848 2009-05-09 11:46 /tmp/page-dump.bin
> > 
> > 127 millisecs to collect, 65 milliseconds to dump. (And that's not 
> > using splice() to dump the trace data.)
> 
> That's pretty fast and on par with kpageflags!

It's already faster here than kpageflags, on a 32 GB box i just 
tried, and the sum of timings (dumping + reading of 4 million page 
frame records, into/from a sufficiently large trace buffer) is 2.8 
seconds.

current upstream kpageflags is 3.3 seconds:

 phoenix:/home/mingo> time cat /proc/kpageflags  > /tmp/1

 real	0m3.338s
 user	0m0.004s
 sys	0m0.608s

(although it varies around a bit, sometimes back to 3.0 secs, 
sometimes more)

That's about 10% faster. Note that output performance could be 
improved more by using splice().

Also, it's apples to oranges, in an unfavorable-to-ftrace way: the 
pages object collection outputs all of these fields:

	field:unsigned short common_type;	offset:0;	size:2;
	field:unsigned char common_flags;	offset:2;	size:1;
	field:unsigned char common_preempt_count;	offset:3;	size:1;
	field:int common_pid;	offset:4;	size:4;
	field:int common_tgid;	offset:8;	size:4;

	field:unsigned long pfn;	offset:16;	size:8;
	field:unsigned long flags;	offset:24;	size:8;
	field:unsigned long index;	offset:32;	size:8;
	field:unsigned int count;	offset:40;	size:4;
	field:unsigned int mapcount;	offset:44;	size:4;

plus it generates and outputs the timestamp as well - while 
kpageflags is just page flags. (and kpagecount is only page counts)

Spreading the dumping+output out to the 16 CPUs of this box would 
shorten the run time at least 10-fold, to about 0.3-0.5 seconds 
IMHO. (but that has to be tried and measured first)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
