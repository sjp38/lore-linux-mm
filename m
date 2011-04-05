Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7AAE38D003B
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 21:27:12 -0400 (EDT)
Message-ID: <4D9A6FE8.2010301@hitachi.com>
Date: Tue, 05 Apr 2011 10:27:04 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2.6.39-rc1-tip 26/26] 26: uprobes: filter chain
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6> <20110401143737.15455.30181.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143737.15455.30181.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>

(2011/04/01 23:37), Srikar Dronamraju wrote:
> Loops through the filters callbacks of currently registered
> consumers to see if any consumer is interested in tracing this task.
> 
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> ---
>  kernel/uprobes.c |   17 +++++++++++++++++
>  1 files changed, 17 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/uprobes.c b/kernel/uprobes.c
> index c950f13..62ccb56 100644
> --- a/kernel/uprobes.c
> +++ b/kernel/uprobes.c
> @@ -450,6 +450,23 @@ static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
>  	up_read(&uprobe->consumer_rwsem);
>  }
>  
> +static bool filter_chain(struct uprobe *uprobe, struct task_struct *t)
> +{
> +	struct uprobe_consumer *consumer;
> +	bool ret = false;
> +
> +	down_read(&uprobe->consumer_rwsem);
> +	for (consumer = uprobe->consumers; consumer;
> +					consumer = consumer->next) {
> +		if (!consumer->filter || consumer->filter(consumer, t)) {
> +			ret = true;
> +			break;
> +		}
> +	}
> +	up_read(&uprobe->consumer_rwsem);
> +	return ret;
> +}
> +

Where this function is called from ? This patch seems the last one of this series...

Thank you,

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
