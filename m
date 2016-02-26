Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0EFE46B0005
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 12:45:35 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id y8so42803105igp.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:45:35 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0226.hostedemail.com. [216.40.44.226])
        by mx.google.com with ESMTPS id ii10si5784122igb.46.2016.02.26.09.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 09:45:34 -0800 (PST)
Date: Fri, 26 Feb 2016 12:45:31 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3 4/7] arch, ftrace: For KASAN put hard/soft IRQ
 entries into separate sections
Message-ID: <20160226124531.365bc27d@gandalf.local.home>
In-Reply-To: <c387c8362eb0eeb622fd7425904b9b429fc636f0.1456492360.git.glider@google.com>
References: <cover.1456492360.git.glider@google.com>
	<c387c8362eb0eeb622fd7425904b9b429fc636f0.1456492360.git.glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 26 Feb 2016 14:30:43 +0100
Alexander Potapenko <glider@google.com> wrote:

> diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
> index c2b340e..4da848d 100644
> --- a/include/linux/ftrace.h
> +++ b/include/linux/ftrace.h
> @@ -799,16 +799,6 @@ ftrace_push_return_trace(unsigned long ret, unsigned long func, int *depth,
>   */
>  #define __notrace_funcgraph		notrace
>  
> -/*
> - * We want to which function is an entrypoint of a hardirq.
> - * That will help us to put a signal on output.
> - */
> -#define __irq_entry		 __attribute__((__section__(".irqentry.text")))
> -
> -/* Limits of hardirq entrypoints */
> -extern char __irqentry_text_start[];
> -extern char __irqentry_text_end[];
> -
>  #define FTRACE_NOTRACE_DEPTH 65536
>  #define FTRACE_RETFUNC_DEPTH 50
>  #define FTRACE_RETSTACK_ALLOC_SIZE 32
> @@ -845,7 +835,6 @@ static inline void unpause_graph_tracing(void)
>  #else /* !CONFIG_FUNCTION_GRAPH_TRACER */
>  
>  #define __notrace_funcgraph
> -#define __irq_entry
>  #define INIT_FTRACE_GRAPH
>  
>  static inline void ftrace_graph_init_task(struct task_struct *t) { }
> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
> index 0e95fcc..1dcecaf 100644
> --- a/include/linux/interrupt.h
> +++ b/include/linux/interrupt.h
> @@ -673,4 +673,24 @@ extern int early_irq_init(void);
>  extern int arch_probe_nr_irqs(void);
>  extern int arch_early_irq_init(void);
>  
> +#if defined(CONFIG_FUNCTION_GRAPH_TRACER) || defined(CONFIG_KASAN)
> +/*
> + * We want to know which function is an entrypoint of a hardirq or a softirq.
> + */
> +#define __irq_entry		 __attribute__((__section__(".irqentry.text")))
> +#define __softirq_entry  \
> +	__attribute__((__section__(".softirqentry.text")))
> +
> +/* Limits of hardirq entrypoints */
> +extern char __irqentry_text_start[];
> +extern char __irqentry_text_end[];
> +/* Limits of softirq entrypoints */
> +extern char __softirqentry_text_start[];
> +extern char __softirqentry_text_end[];
> +
> +#else
> +#define __irq_entry
> +#define __softirq_entry
> +#endif
> +
>  #endif
> diff --git a/kernel/softirq.c b/kernel/softirq.c

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
