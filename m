Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A79458D003B
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 21:27:00 -0400 (EDT)
Message-ID: <4D9A6FDA.9030304@hitachi.com>
Date: Tue, 05 Apr 2011 10:26:50 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2.6.39-rc1-tip 18/26] 18: uprobes: commonly used filters.
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6> <20110401143602.15455.82211.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143602.15455.82211.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

(2011/04/01 23:36), Srikar Dronamraju wrote:
> Provides most commonly used filters that most users of uprobes can
> reuse.  However this would be useful once we can dynamically associate a
> filter with a uprobe-event tracer.

Hmm, would you mean that these filters are currently not used?
If so, it would be better to remove this from the series, and
send again with an actual user code.

Thank you,

> 
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> ---
>  include/linux/uprobes.h |    5 +++++
>  kernel/uprobes.c        |   50 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 55 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
> index 26c4d78..34b989f 100644
> --- a/include/linux/uprobes.h
> +++ b/include/linux/uprobes.h
> @@ -65,6 +65,11 @@ struct uprobe_consumer {
>  	struct uprobe_consumer *next;
>  };
>  
> +struct uprobe_simple_consumer {
> +	struct uprobe_consumer consumer;
> +	pid_t fvalue;
> +};
> +
>  struct uprobe {
>  	struct rb_node		rb_node;	/* node in the rb tree */
>  	atomic_t		ref;
> diff --git a/kernel/uprobes.c b/kernel/uprobes.c
> index cdd52d0..c950f13 100644
> --- a/kernel/uprobes.c
> +++ b/kernel/uprobes.c
> @@ -1389,6 +1389,56 @@ int uprobe_post_notifier(struct pt_regs *regs)
>  	return 0;
>  }
>  
> +bool uprobes_pid_filter(struct uprobe_consumer *self, struct task_struct *t)
> +{
> +	struct uprobe_simple_consumer *usc;
> +
> +	usc = container_of(self, struct uprobe_simple_consumer, consumer);
> +	if (t->tgid == usc->fvalue)
> +		return true;
> +	return false;
> +}
> +
> +bool uprobes_tid_filter(struct uprobe_consumer *self, struct task_struct *t)
> +{
> +	struct uprobe_simple_consumer *usc;
> +
> +	usc = container_of(self, struct uprobe_simple_consumer, consumer);
> +	if (t->pid == usc->fvalue)
> +		return true;
> +	return false;
> +}
> +
> +bool uprobes_ppid_filter(struct uprobe_consumer *self, struct task_struct *t)
> +{
> +	pid_t pid;
> +	struct uprobe_simple_consumer *usc;
> +
> +	usc = container_of(self, struct uprobe_simple_consumer, consumer);
> +	rcu_read_lock();
> +	pid = task_tgid_vnr(t->real_parent);
> +	rcu_read_unlock();
> +
> +	if (pid == usc->fvalue)
> +		return true;
> +	return false;
> +}
> +
> +bool uprobes_sid_filter(struct uprobe_consumer *self, struct task_struct *t)
> +{
> +	pid_t pid;
> +	struct uprobe_simple_consumer *usc;
> +
> +	usc = container_of(self, struct uprobe_simple_consumer, consumer);
> +	rcu_read_lock();
> +	pid = pid_vnr(task_session(t));
> +	rcu_read_unlock();
> +
> +	if (pid == usc->fvalue)
> +		return true;
> +	return false;
> +}
> +
>  struct notifier_block uprobes_exception_nb = {
>  	.notifier_call = uprobes_exception_notify,
>  	.priority = 0x7ffffff0,

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
