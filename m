Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1B0666B00AD
	for <linux-mm@kvack.org>; Sat,  9 May 2009 05:13:53 -0400 (EDT)
Date: Sat, 9 May 2009 17:13:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch] tracing/mm: add page frame snapshot trace
Message-ID: <20090509091325.GA7994@localhost>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508124433.GB15949@localhost> <20090509062758.GB21354@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090509062758.GB21354@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: =?utf-8?B?RnLDqWTDqXJpYw==?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Ingo,

On Sat, May 09, 2009 at 02:27:58PM +0800, Ingo Molnar wrote:
> 
> * Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > > So this should be done in cooperation with instrumentation 
> > > folks, while improving _all_ of Linux instrumentation in 
> > > general. Or, if you dont have the time/interest to work with us 
> > > on that, it should not be done at all. Not having the 
> > > resources/interest to do something properly is not a license to 
> > > introduce further instrumentation crap into Linux.
> > 
> > I'd be glad to work with you on the 'object collections' ftrace 
> > interfaces.  Maybe next month. For now my time have been allocated 
> > for the hwpoison work, sorry!
> 
> No problem - our offer still stands: we are glad to help out with 
> the instrumentation side bits. We'll even write all the patches for 
> you, just please help us out with making it maximally useful to 
> _you_ :-)

Thank you very much!

The good fact is, 2/3 of the code and experiences can be reused.

> Find below a first prototype patch written by Steve yesterday and 
> tidied up a bit by me today. It can also be tried on latest -tip:
> 
>   http://people.redhat.com/mingo/tip.git/README
> 
> This patch adds the first version of the 'object collections' 
> instrumentation facility under /debug/tracing/objects/mm/. It has a 
> single control so far, a 'number of pages to dump' trigger file:
> 
> To dump 1000 pages to the trace buffers, do:
> 
>   echo 1000 > /debug/tracing/objects/mm/pages/trigger
> 
> To dump all pages to the trace buffers, do:
> 
>   echo -1 > /debug/tracing/objects/mm/pages/trigger

That is not too intuitive, I'm afraid.

> Preliminary timings on an older, 1GB RAM 2 GHz Athlon64 box show 
> that it's plenty fast:
> 
>  # time echo -1 > /debug/tracing/objects/mm/pages/trigger
> 
>   real	0m0.127s
>   user	0m0.000s
>   sys	0m0.126s
> 
>  # time cat /debug/tracing/per_cpu/*/trace_pipe_raw > /tmp/page-trace.bin
> 
>   real	0m0.065s
>   user	0m0.001s
>   sys	0m0.064s
> 
>   # ls -l /tmp/1
>   -rw-r--r-- 1 root root 13774848 2009-05-09 11:46 /tmp/page-dump.bin
> 
> 127 millisecs to collect, 65 milliseconds to dump. (And that's not 
> using splice() to dump the trace data.)

That's pretty fast and on par with kpageflags!

> The current (very preliminary) record format is:
> 
>   # cat /debug/tracing/events/mm/dump_pages/format 
>   name: dump_pages
>   ID: 40
>   format:
> 	field:unsigned short common_type;	offset:0;	size:2;
> 	field:unsigned char common_flags;	offset:2;	size:1;
> 	field:unsigned char common_preempt_count;	offset:3;	size:1;
> 	field:int common_pid;	offset:4;	size:4;
> 	field:int common_tgid;	offset:8;	size:4;
> 
> 	field:unsigned long pfn;	offset:16;	size:8;
> 	field:unsigned long flags;	offset:24;	size:8;
> 	field:unsigned long index;	offset:32;	size:8;
> 	field:unsigned int count;	offset:40;	size:4;
> 	field:unsigned int mapcount;	offset:44;	size:4;
> 
>   print fmt: "pfn=%lu flags=%lx count=%u mapcount=%u index=%lu", 
>   REC->pfn, REC->flags, REC->count, REC->mapcount, REC->index
> 
> Note: the page->flags value should probably be converted into more 
> independent values i suspect, like get_uflags() is - the raw 
> page->flags is too compressed and inter-dependent on other 
> properties of struct page to be directly usable.

Agreed.

> Also, buffer size has to be large enough to hold the dump. To hold 
> one million entries (4GB of RAM), this should be enough:
> 
>   echo 60000 > /debug/tracing/buffer_size_kb
> 
> Once we add synchronization between producer and consumer, pretty 
> much any buffer size will suffice.

That would be good.

> The trace records are unique so user-space can filter out the dump 
> and only the dump - even if there are other trace events in the 
> buffer.

OK.

> TODO:
> 
>  - add smarter flags output - a'la your get_uflags().

That's 100% code reuse :-)

>  - add synchronization between trace producer and trace consumer
> 
>  - port user-space bits to this facility: Documentation/vm/page-types.c

page-types' kernel ABI code is smallish. So would be trivial to port.

> What do you think about this patch? We could also further reduce the 
> patch/plugin size by factoring out some of this code into generic 
> tracing code. This will be best done when we add the 'tasks' object 
> collection to dump a tasks snapshot to the trace buffer.

To be frank, the code size is a bit larger than kpageflags, and
(as a newbie) the ftrace interface is not as straightforward as the
traditional read().

But that's acceptable, as long as it will allow more powerful object
dumping. I'll attempt to list two fundamental requirements:

1) support multiple object iteration paths
   For example, the pages can be iterated by
   - pfn
   - process virtual address
   - inode address space
   - swap space?

2) support concurrent object iterations
   For example, a huge 1TB memory space can be split up into 10
   segments which can be queried concurrently (with different options).

(1) provides great flexibility and advantage to the existing interface,
(2) provides equal performance to the existing interface.

Are they at least possible?

Thanks,
Fengguang

> 	Ingo
> 
> ---------------------------->
> >From dcac8cdac1d41af0336d8ed17c2cb898ba8a791f Mon Sep 17 00:00:00 2001
> From: Steven Rostedt <srostedt@redhat.com>
> Date: Fri, 8 May 2009 16:44:15 -0400
> Subject: [PATCH] tracing/mm: add page frame snapshot trace
> 
> This is a prototype to dump out a snapshot of the page tables to the
> tracing buffer. Currently it is very primitive, and just writes out
> the events. There is no synchronization to not loose the events,
> so /debug/tracing/buffer_size_kb has to be large enough for all
> events to fit.
> 
> We will do something about synchronization later. That is, have a way
> to read the buffer through the tracing/object/mm/page/X file and have
> the two in sync.
> 
> But this is just a prototype to get the ball rolling.
> 
> Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
>  include/trace/events/mm.h |   48 +++++++++++++
>  kernel/trace/Makefile     |    1 +
>  kernel/trace/trace_mm.c   |  172 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 221 insertions(+), 0 deletions(-)
> 
> diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
> new file mode 100644
> index 0000000..f5a1668
> --- /dev/null
> +++ b/include/trace/events/mm.h
> @@ -0,0 +1,48 @@
> +#if !defined(_TRACE_MM_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_MM_H
> +
> +#include <linux/tracepoint.h>
> +#include <linux/mm.h>
> +
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM mm
> +
> +/**
> + * dump_pages - called by the trace page dump trigger
> + * @pfn: page frame number
> + * @page: pointer to the page frame
> + *
> + * This is a helper trace point into the dumping of the page frames.
> + * It will record various infromation about a page frame.
> + */
> +TRACE_EVENT(dump_pages,
> +
> +	TP_PROTO(unsigned long pfn, struct page *page),
> +
> +	TP_ARGS(pfn, page),
> +
> +	TP_STRUCT__entry(
> +		__field(	unsigned long,	pfn		)
> +		__field(	unsigned long,	flags		)
> +		__field(	unsigned long,	index		)
> +		__field(	unsigned int,	count		)
> +		__field(	unsigned int,	mapcount	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pfn		= pfn;
> +		__entry->flags		= page->flags;
> +		__entry->count		= atomic_read(&page->_count);
> +		__entry->mapcount	= atomic_read(&page->_mapcount);
> +		__entry->index		= page->index;
> +	),
> +
> +	TP_printk("pfn=%lu flags=%lx count=%u mapcount=%u index=%lu",
> +		  __entry->pfn, __entry->flags, __entry->count,
> +		  __entry->mapcount, __entry->index)
> +);
> +
> +#endif /*  _TRACE_MM_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
> index 06b8585..848e5ce 100644
> --- a/kernel/trace/Makefile
> +++ b/kernel/trace/Makefile
> @@ -51,5 +51,6 @@ obj-$(CONFIG_EVENT_TRACING) += trace_export.o
>  obj-$(CONFIG_FTRACE_SYSCALLS) += trace_syscalls.o
>  obj-$(CONFIG_EVENT_PROFILE) += trace_event_profile.o
>  obj-$(CONFIG_EVENT_TRACING) += trace_events_filter.o
> +obj-$(CONFIG_EVENT_TRACING) += trace_mm.o
>  
>  libftrace-y := ftrace.o
> diff --git a/kernel/trace/trace_mm.c b/kernel/trace/trace_mm.c
> new file mode 100644
> index 0000000..87123ed
> --- /dev/null
> +++ b/kernel/trace/trace_mm.c
> @@ -0,0 +1,172 @@
> +/*
> + * Trace mm pages
> + *
> + * Copyright (C) 2009 Red Hat Inc, Steven Rostedt <srostedt@redhat.com>
> + *
> + * Code based on Matt Mackall's /proc/[kpagecount|kpageflags] code.
> + */
> +#include <linux/module.h>
> +#include <linux/bootmem.h>
> +#include <linux/debugfs.h>
> +#include <linux/uaccess.h>
> +
> +#include "trace_output.h"
> +
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/mm.h>
> +
> +void trace_read_page_frames(unsigned long start, unsigned long end,
> +			    void (*trace)(unsigned long pfn, struct page *page))
> +{
> +	unsigned long pfn = start;
> +	struct page *page;
> +
> +	if (start > max_pfn - 1)
> +		return;
> +
> +	if (end > max_pfn - 1)
> +		end = max_pfn - 1;
> +
> +	while (pfn < end) {
> +		page = NULL;
> +		if (pfn_valid(pfn))
> +			page = pfn_to_page(pfn);
> +		pfn++;
> +		if (page)
> +			trace(pfn, page);
> +	}
> +}
> +
> +static void trace_do_dump_pages(unsigned long pfn, struct page *page)
> +{
> +	trace_dump_pages(pfn, page);
> +}
> +
> +static ssize_t
> +trace_mm_trigger_read(struct file *filp, char __user *ubuf, size_t cnt,
> +		 loff_t *ppos)
> +{
> +	return simple_read_from_buffer(ubuf, cnt, ppos, "0\n", 2);
> +}
> +
> +
> +static ssize_t
> +trace_mm_trigger_write(struct file *filp, const char __user *ubuf, size_t cnt,
> +		       loff_t *ppos)
> +{
> +	unsigned long val, start, end;
> +	char buf[64];
> +	int ret;
> +
> +	if (cnt >= sizeof(buf))
> +		return -EINVAL;
> +
> +	if (copy_from_user(&buf, ubuf, cnt))
> +		return -EFAULT;
> +
> +	if (tracing_update_buffers() < 0)
> +		return -ENOMEM;
> +
> +	if (trace_set_clr_event("mm", "dump_pages", 1))
> +		return -EINVAL;
> +
> +	buf[cnt] = 0;
> +
> +	ret = strict_strtol(buf, 10, &val);
> +	if (ret < 0)
> +		return ret;
> +
> +	start = *ppos;
> +	if (val < 0)
> +		end = max_pfn - 1;
> +	else
> +		end = start + val;
> +
> +	trace_read_page_frames(start, end, trace_do_dump_pages);
> +
> +	*ppos += cnt;
> +
> +	return cnt;
> +}
> +
> +static const struct file_operations trace_mm_fops = {
> +	.open		= tracing_open_generic,
> +	.read		= trace_mm_trigger_read,
> +	.write		= trace_mm_trigger_write,
> +};
> +
> +/* move this into trace_objects.c when that file is created */
> +static struct dentry *trace_objects_dir(void)
> +{
> +	static struct dentry *d_objects;
> +	struct dentry *d_tracer;
> +
> +	if (d_objects)
> +		return d_objects;
> +
> +	d_tracer = tracing_init_dentry();
> +	if (!d_tracer)
> +		return NULL;
> +
> +	d_objects = debugfs_create_dir("objects", d_tracer);
> +	if (!d_objects)
> +		pr_warning("Could not create debugfs "
> +			   "'objects' directory\n");
> +
> +	return d_objects;
> +}
> +
> +
> +static struct dentry *trace_objects_mm_dir(void)
> +{
> +	static struct dentry *d_mm;
> +	struct dentry *d_objects;
> +
> +	if (d_mm)
> +		return d_mm;
> +
> +	d_objects = trace_objects_dir();
> +	if (!d_objects)
> +		return NULL;
> +
> +	d_mm = debugfs_create_dir("mm", d_objects);
> +	if (!d_mm)
> +		pr_warning("Could not create 'objects/mm' directory\n");
> +
> +	return d_mm;
> +}
> +
> +static struct dentry *trace_objects_mm_pages_dir(void)
> +{
> +	static struct dentry *d_pages;
> +	struct dentry *d_mm;
> +
> +	if (d_pages)
> +		return d_pages;
> +
> +	d_mm = trace_objects_mm_dir();
> +	if (!d_mm)
> +		return NULL;
> +
> +	d_pages = debugfs_create_dir("pages", d_mm);
> +	if (!d_pages)
> +		pr_warning("Could not create debugfs "
> +			   "'objects/mm/pages' directory\n");
> +
> +	return d_pages;
> +}
> +
> +static __init int trace_objects_mm_init(void)
> +{
> +	struct dentry *d_pages;
> +
> +	d_pages = trace_objects_mm_pages_dir();
> +	if (!d_pages)
> +		return 0;
> +
> +	trace_create_file("trigger", 0600, d_pages, NULL,
> +			  &trace_mm_fops);
> +
> +	return 0;
> +}
> +fs_initcall(trace_objects_mm_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
