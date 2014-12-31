Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id EC22E6B0038
	for <linux-mm@kvack.org>; Wed, 31 Dec 2014 01:46:51 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so20499439pdj.27
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 22:46:51 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ct2si5776659pbb.21.2014.12.30.22.46.48
        for <linux-mm@kvack.org>;
        Tue, 30 Dec 2014 22:46:50 -0800 (PST)
Date: Wed, 31 Dec 2014 15:47:59 +0900
From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH 0/3] mm: cma: /proc/cmainfo
Message-ID: <20141231064759.GB1766@sejong>
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <20141229023639.GC27095@bbox>
 <54A1B11A.6020307@codeaurora.org>
 <20141230044726.GA22342@bbox>
 <54A34A1C.90603@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54A34A1C.90603@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>, Laura Abbott <lauraa@codeaurora.org>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, rostedt@goodmis.org

Hello,

On Wed, Dec 31, 2014 at 09:58:04AM +0900, Gioh Kim wrote:
> 2014-12-30 i??i?? 1:47i?? Minchan Kim i?'(e??) i?' e,?:
> >On Mon, Dec 29, 2014 at 11:52:58AM -0800, Laura Abbott wrote:
> >>I've been meaning to write something like this for a while so I'm
> >>happy to see an attempt made to fix this. I can't speak for the
> >>author's reasons for wanting this information but there are
> >>several reasons why I was thinking of something similar.
> >>
> >>The most common bug reports seen internally on CMA are 1) CMA is
> >>too slow and 2) CMA failed to allocate memory. For #1, not all
> >>allocations may be slow so it's useful to be able to keep track
> >>of which allocations are taking too long. For #2, migration
> >
> >Then, I don't think we could keep all of allocations. What we need
> >is only slow allocations. I hope we can do that with ftrace.
> >
> >ex)
> >
> ># cd /sys/kernel/debug/tracing
> ># echo 1 > options/stacktrace
> ># echo cam_alloc > set_ftrace_filter
> ># echo your_threshold > tracing_thresh
> >
> >I know it doesn't work now but I think it's more flexible
> >and general way to handle such issues(ie, latency of some functions).
> >So, I hope we could enhance ftrace rather than new wheel.
> >Ccing ftrace people.
> 
> For CMA performance test or code flow check, ftrace is better.
> 
> ex)
> echo cma_alloc > /sys/kernel/debug/tracing/set_graph_function
> echo function_graph > /sys/kernel/debug/tracing/current_tracer
> echo funcgraph-proc > /sys/kernel/debug/tracing/trace_options
> echo nosleep-time > /sys/kernel/debug/tracing/trace_options
> echo funcgraph-tail > /sys/kernel/debug/tracing/trace_options
> echo 1 > /sys/kernel/debug/tracing/tracing_on
> 
> This can trace every cam_alloc and allocation time.
> I think ftrace is better to debug latency.
> If a buffer had allocated and had peak latency and freed,
> we can check it.

It'd be great if we can reuse the max latency tracing feature for the
function graph tracer in order to track a latency problem of an
arbitrary function more easily.  I've written a PoC code that can be
used like below..

  # cd /sys/kernel/debug/tracing
  # echo 0 > tracing_on
  # echo function_graph > current_tracer
  # echo funcgraph-latency > trace_options
  # echo cma_alloc > graph_latency_func
  # echo 1 > tracing_on

Now the tracing_max_latency file has a max latency of the cma_alloc()
in usec and the snapshot file contains a snapshot of all the codepath
to the function at the time.

Would anybody like to play with it? :)

Thanks,
Namhyung


diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 0eddfeb05fee..4a3d5ed2802c 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -723,6 +723,7 @@ extern char trace_find_mark(unsigned long long duration);
 #define TRACE_GRAPH_PRINT_ABS_TIME      0x20
 #define TRACE_GRAPH_PRINT_IRQS          0x40
 #define TRACE_GRAPH_PRINT_TAIL          0x80
+#define TRACE_GRAPH_MAX_LATENCY         0x100
 #define TRACE_GRAPH_PRINT_FILL_SHIFT	28
 #define TRACE_GRAPH_PRINT_FILL_MASK	(0x3 << TRACE_GRAPH_PRINT_FILL_SHIFT)
 
diff --git a/kernel/trace/trace_functions_graph.c b/kernel/trace/trace_functions_graph.c
index ba476009e5de..7fc3e21d1354 100644
--- a/kernel/trace/trace_functions_graph.c
+++ b/kernel/trace/trace_functions_graph.c
@@ -8,6 +8,7 @@
  */
 #include <linux/debugfs.h>
 #include <linux/uaccess.h>
+#include <linux/module.h>
 #include <linux/ftrace.h>
 #include <linux/slab.h>
 #include <linux/fs.h>
@@ -44,6 +45,10 @@ void ftrace_graph_stop(void)
 
 /* When set, irq functions will be ignored */
 static int ftrace_graph_skip_irqs;
+/* When set, record max latency of a given function */
+static int ftrace_graph_max_latency;
+
+static unsigned long ftrace_graph_latency_func;
 
 struct fgraph_cpu_data {
 	pid_t		last_pid;
@@ -84,6 +89,8 @@ static struct tracer_opt trace_opts[] = {
 	{ TRACER_OPT(funcgraph-irqs, TRACE_GRAPH_PRINT_IRQS) },
 	/* Display function name after trailing } */
 	{ TRACER_OPT(funcgraph-tail, TRACE_GRAPH_PRINT_TAIL) },
+	/* Record max latency of a given function } */
+	{ TRACER_OPT(funcgraph-latency, TRACE_GRAPH_MAX_LATENCY) },
 	{ } /* Empty entry */
 };
 
@@ -389,6 +396,22 @@ trace_graph_function(struct trace_array *tr,
 	__trace_graph_function(tr, ip, flags, pc);
 }
 
+#ifdef CONFIG_TRACER_MAX_TRACE
+static bool report_latency(struct trace_array *tr,
+			   struct ftrace_graph_ret *trace)
+{
+	unsigned long long delta = trace->rettime - trace->calltime;
+
+	if (!ftrace_graph_max_latency)
+		return false;
+
+	if (ftrace_graph_latency_func != trace->func)
+		return false;
+
+	return tr->max_latency < delta;
+}
+#endif
+
 void __trace_graph_return(struct trace_array *tr,
 				struct ftrace_graph_ret *trace,
 				unsigned long flags,
@@ -428,6 +451,22 @@ void trace_graph_return(struct ftrace_graph_ret *trace)
 	if (likely(disabled == 1)) {
 		pc = preempt_count();
 		__trace_graph_return(tr, trace, flags, pc);
+
+#ifdef CONFIG_TRACER_MAX_TRACE
+		if (report_latency(tr, trace)) {
+			static DEFINE_RAW_SPINLOCK(max_trace_lock);
+			unsigned long long delta;
+
+			delta = trace->rettime - trace->calltime;
+
+			raw_spin_lock(&max_trace_lock);
+			if (delta > tr->max_latency) {
+				tr->max_latency = delta;
+				update_max_tr(tr, current, cpu);
+			}
+			raw_spin_unlock(&max_trace_lock);
+		}
+#endif
 	}
 	atomic_dec(&data->disabled);
 	local_irq_restore(flags);
@@ -456,6 +495,11 @@ static int graph_trace_init(struct trace_array *tr)
 	int ret;
 
 	set_graph_array(tr);
+
+#ifdef CONFIG_TRACE_MAX_LATENCY
+	graph_array->max_latency = 0;
+#endif
+
 	if (tracing_thresh)
 		ret = register_ftrace_graph(&trace_graph_thresh_return,
 					    &trace_graph_thresh_entry);
@@ -1358,7 +1402,15 @@ func_graph_set_flag(struct trace_array *tr, u32 old_flags, u32 bit, int set)
 {
 	if (bit == TRACE_GRAPH_PRINT_IRQS)
 		ftrace_graph_skip_irqs = !set;
+	else if (bit == TRACE_GRAPH_MAX_LATENCY) {
+		ftrace_graph_max_latency = set;
 
+		if (set && !tr->allocated_snapshot) {
+			int ret = tracing_alloc_snapshot();
+			if (ret < 0)
+				return ret;
+		}
+	}
 	return 0;
 }
 
@@ -1425,6 +1477,43 @@ graph_depth_read(struct file *filp, char __user *ubuf, size_t cnt,
 	return simple_read_from_buffer(ubuf, cnt, ppos, buf, n);
 }
 
+static ssize_t
+graph_latency_write(struct file *filp, const char __user *ubuf, size_t cnt,
+		    loff_t *ppos)
+{
+	char buf[KSYM_SYMBOL_LEN];
+	long ret;
+
+	ret = strncpy_from_user(buf, ubuf, cnt);
+	if (ret <= 0)
+		return ret;
+
+	if (buf[ret - 1] == '\n')
+		buf[ret - 1] = '\0';
+
+	ftrace_graph_latency_func = kallsyms_lookup_name(buf);
+	if (!ftrace_graph_latency_func)
+		return -EINVAL;
+
+	*ppos += cnt;
+
+	return cnt;
+}
+
+static ssize_t
+graph_latency_read(struct file *filp, char __user *ubuf, size_t cnt,
+		   loff_t *ppos)
+{
+	char buf[KSYM_SYMBOL_LEN];
+
+	if (!ftrace_graph_latency_func)
+		return 0;
+
+	kallsyms_lookup(ftrace_graph_latency_func, NULL, NULL, NULL, buf);
+
+	return simple_read_from_buffer(ubuf, cnt, ppos, buf, strlen(buf));
+}
+
 static const struct file_operations graph_depth_fops = {
 	.open		= tracing_open_generic,
 	.write		= graph_depth_write,
@@ -1432,6 +1521,13 @@ static const struct file_operations graph_depth_fops = {
 	.llseek		= generic_file_llseek,
 };
 
+static const struct file_operations graph_latency_fops = {
+	.open		= tracing_open_generic,
+	.write		= graph_latency_write,
+	.read		= graph_latency_read,
+	.llseek		= generic_file_llseek,
+};
+
 static __init int init_graph_debugfs(void)
 {
 	struct dentry *d_tracer;
@@ -1442,6 +1538,10 @@ static __init int init_graph_debugfs(void)
 
 	trace_create_file("max_graph_depth", 0644, d_tracer,
 			  NULL, &graph_depth_fops);
+#ifdef CONFIG_TRACER_MAX_TRACE
+	trace_create_file("graph_latency_func", 0644, d_tracer,
+			  NULL, &graph_latency_fops);
+#endif
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
