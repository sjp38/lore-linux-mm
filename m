Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id E83966B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:53:52 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id z14so14620022igp.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 06:53:52 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0159.hostedemail.com. [216.40.44.159])
        by mx.google.com with ESMTPS id c1si5101116igx.104.2016.01.28.06.53.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 06:53:52 -0800 (PST)
Date: Thu, 28 Jan 2016 09:53:49 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1 4/8] arch, ftrace: For KASAN put hard/soft IRQ
 entries into separate sections
Message-ID: <20160128095349.6f771f14@gandalf.local.home>
In-Reply-To: <99939a92dd93dc5856c4ec7bf32dbe0035cdc689.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
	<99939a92dd93dc5856c4ec7bf32dbe0035cdc689.1453918525.git.glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 27 Jan 2016 19:25:09 +0100
Alexander Potapenko <glider@google.com> wrote:

> --- a/include/linux/ftrace.h
> +++ b/include/linux/ftrace.h
> @@ -762,6 +762,26 @@ struct ftrace_graph_ret {
>  typedef void (*trace_func_graph_ret_t)(struct ftrace_graph_ret *); /* return */
>  typedef int (*trace_func_graph_ent_t)(struct ftrace_graph_ent *); /* entry */
>  
> +#if defined(CONFIG_FUNCTION_GRAPH_TRACER) || defined(CONFIG_KASAN)
> +/*
> + * We want to know which function is an entrypoint of a hardirq.
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
>  #ifdef CONFIG_FUNCTION_GRAPH_TRACER
>  
>  /* for init task */

Since this is no longer just used for function tracing, perhaps the
code should be moved to include/linux/irq.h or something.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
