Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DB5AE6B00A3
	for <linux-mm@kvack.org>; Sat,  9 May 2009 02:27:56 -0400 (EDT)
Date: Sat, 9 May 2009 08:27:58 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] tracing/mm: add page frame snapshot trace
Message-ID: <20090509062758.GB21354@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508124433.GB15949@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090508124433.GB15949@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> > So this should be done in cooperation with instrumentation 
> > folks, while improving _all_ of Linux instrumentation in 
> > general. Or, if you dont have the time/interest to work with us 
> > on that, it should not be done at all. Not having the 
> > resources/interest to do something properly is not a license to 
> > introduce further instrumentation crap into Linux.
> 
> I'd be glad to work with you on the 'object collections' ftrace 
> interfaces.  Maybe next month. For now my time have been allocated 
> for the hwpoison work, sorry!

No problem - our offer still stands: we are glad to help out with 
the instrumentation side bits. We'll even write all the patches for 
you, just please help us out with making it maximally useful to 
_you_ :-)

Find below a first prototype patch written by Steve yesterday and 
tidied up a bit by me today. It can also be tried on latest -tip:

  http://people.redhat.com/mingo/tip.git/README

This patch adds the first version of the 'object collections' 
instrumentation facility under /debug/tracing/objects/mm/. It has a 
single control so far, a 'number of pages to dump' trigger file:

To dump 1000 pages to the trace buffers, do:

  echo 1000 > /debug/tracing/objects/mm/pages/trigger

To dump all pages to the trace buffers, do:

  echo -1 > /debug/tracing/objects/mm/pages/trigger

Preliminary timings on an older, 1GB RAM 2 GHz Athlon64 box show 
that it's plenty fast:

 # time echo -1 > /debug/tracing/objects/mm/pages/trigger

  real	0m0.127s
  user	0m0.000s
  sys	0m0.126s

 # time cat /debug/tracing/per_cpu/*/trace_pipe_raw > /tmp/page-trace.bin

  real	0m0.065s
  user	0m0.001s
  sys	0m0.064s

  # ls -l /tmp/1
  -rw-r--r-- 1 root root 13774848 2009-05-09 11:46 /tmp/page-dump.bin

127 millisecs to collect, 65 milliseconds to dump. (And that's not 
using splice() to dump the trace data.)

The current (very preliminary) record format is:

  # cat /debug/tracing/events/mm/dump_pages/format 
  name: dump_pages
  ID: 40
  format:
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

  print fmt: "pfn=%lu flags=%lx count=%u mapcount=%u index=%lu", 
  REC->pfn, REC->flags, REC->count, REC->mapcount, REC->index

Note: the page->flags value should probably be converted into more 
independent values i suspect, like get_uflags() is - the raw 
page->flags is too compressed and inter-dependent on other 
properties of struct page to be directly usable.

Also, buffer size has to be large enough to hold the dump. To hold 
one million entries (4GB of RAM), this should be enough:

  echo 60000 > /debug/tracing/buffer_size_kb

Once we add synchronization between producer and consumer, pretty 
much any buffer size will suffice.

The trace records are unique so user-space can filter out the dump 
and only the dump - even if there are other trace events in the 
buffer.

TODO:

 - add smarter flags output - a'la your get_uflags().

 - add synchronization between trace producer and trace consumer

 - port user-space bits to this facility: Documentation/vm/page-types.c

What do you think about this patch? We could also further reduce the 
patch/plugin size by factoring out some of this code into generic 
tracing code. This will be best done when we add the 'tasks' object 
collection to dump a tasks snapshot to the trace buffer.

	Ingo

---------------------------->
