Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 797A06B0038
	for <linux-mm@kvack.org>; Sat, 27 Dec 2014 02:03:22 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so14155563pad.24
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 23:03:22 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id kn8si16401860pbc.244.2014.12.26.23.03.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Dec 2014 23:03:21 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id z10so14116327pdj.0
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 23:03:20 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Date: Sat, 27 Dec 2014 16:04:04 +0900 (KST)
Subject: Re: [PATCH 1/3] stacktrace: add seq_print_stack_trace()
In-Reply-To: <00bfb81bf8749f3be738d20dd263b81490693309.1419602920.git.s.strogin@partner.samsung.com>
Message-ID: <alpine.DEB.2.10.1412271602580.1819@hxeon>
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <00bfb81bf8749f3be738d20dd263b81490693309.1419602920.git.s.strogin@partner.samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Stefan I. Strogin" <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>



On Fri, 26 Dec 2014, Stefan I. Strogin wrote:

> Add a function seq_print_stack_trace() which prints stacktraces to seq_files.
>
> Signed-off-by: Stefan I. Strogin <s.strogin@partner.samsung.com>

Reviewed-by: SeongJae Park <sj38.park@gmail.com>

> ---
> include/linux/stacktrace.h |  4 ++++
> kernel/stacktrace.c        | 17 +++++++++++++++++
> 2 files changed, 21 insertions(+)
>
> diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
> index 669045a..6d62484 100644
> --- a/include/linux/stacktrace.h
> +++ b/include/linux/stacktrace.h
> @@ -2,6 +2,7 @@
> #define __LINUX_STACKTRACE_H
>
> #include <linux/types.h>
> +#include <linux/seq_file.h>
>
> struct task_struct;
> struct pt_regs;
> @@ -24,6 +25,8 @@ extern void save_stack_trace_tsk(struct task_struct *tsk,
> extern void print_stack_trace(struct stack_trace *trace, int spaces);
> extern int snprint_stack_trace(char *buf, size_t size,
> 			struct stack_trace *trace, int spaces);
> +extern void seq_print_stack_trace(struct seq_file *m,
> +			struct stack_trace *trace, int spaces);
>
> #ifdef CONFIG_USER_STACKTRACE_SUPPORT
> extern void save_stack_trace_user(struct stack_trace *trace);
> @@ -37,6 +40,7 @@ extern void save_stack_trace_user(struct stack_trace *trace);
> # define save_stack_trace_user(trace)			do { } while (0)
> # define print_stack_trace(trace, spaces)		do { } while (0)
> # define snprint_stack_trace(buf, size, trace, spaces)	do { } while (0)
> +# define seq_print_stack_trace(m, trace, spaces)	do { } while (0)
> #endif
>
> #endif
> diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
> index b6e4c16..66ef6f4 100644
> --- a/kernel/stacktrace.c
> +++ b/kernel/stacktrace.c
> @@ -57,6 +57,23 @@ int snprint_stack_trace(char *buf, size_t size,
> }
> EXPORT_SYMBOL_GPL(snprint_stack_trace);
>
> +void seq_print_stack_trace(struct seq_file *m, struct stack_trace *trace,
> +			int spaces)
> +{
> +	int i;
> +
> +	if (WARN_ON(!trace->entries))
> +		return;
> +
> +	for (i = 0; i < trace->nr_entries; i++) {
> +		unsigned long ip = trace->entries[i];
> +
> +		seq_printf(m, "%*c[<%p>] %pS\n", 1 + spaces, ' ',
> +				(void *) ip, (void *) ip);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(seq_print_stack_trace);
> +
> /*
>  * Architectures that do not implement save_stack_trace_tsk or
>  * save_stack_trace_regs get this weak alias and a once-per-bootup warning
> -- 
> 2.1.0
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
