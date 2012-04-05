Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7A0356B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 12:55:51 -0400 (EDT)
Subject: Re: [PATCH 2/3] tracing: Extract out common code for
 kprobes/uprobes traceevents
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20120403010452.17852.14232.sendpatchset@srdronam.in.ibm.com>
References: <20120403010442.17852.9888.sendpatchset@srdronam.in.ibm.com>
	 <20120403010452.17852.14232.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 05 Apr 2012 12:55:41 -0400
Message-ID: <1333644941.3764.32.camel@pippen.local.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Tue, 2012-04-03 at 06:34 +0530, Srikar Dronamraju wrote:


> -/*
> - * Fetch a null-terminated string. Caller MUST set *(u32 *)dest with max
> - * length and relative data location.
> - */
> -static __kprobes void FETCH_FUNC_NAME(memory, string)(struct pt_regs *regs,
> -                                                     void *addr, void *dest)
> -{
> -       long ret;
> -       int maxlen = get_rloc_len(*(u32 *)dest);
> -       u8 *dst = get_rloc_data(dest);
> -       u8 *src = addr;
> -       mm_segment_t old_fs = get_fs();
> -       if (!maxlen)
> -               return;

> diff --git a/kernel/trace/trace_probe.c b/kernel/trace/trace_probe.c
> new file mode 100644
> index 0000000..deb375a
> --- /dev/null
> +++ b/kernel/trace/trace_probe.c

> +DEFINE_BASIC_FETCH_FUNCS(memory)
> +/*
> + * Fetch a null-terminated string. Caller MUST set *(u32 *)dest with max
> + * length and relative data location.
> + */
> +static __kprobes void FETCH_FUNC_NAME(memory, string)(struct pt_regs *regs,
> +						      void *addr, void *dest)
> +{
> +	int maxlen;
> +	long ret;
> +
> +	maxlen = get_rloc_len(*(u32 *)dest);
> +	u8 *dst = get_rloc_data(dest);
> +	u8 *src = addr;


Please do not mix declarations and actual code. The above declares
maxlen and ret, then assigns maxlen (actual code) and then you declare
dst and src (as well as assign it).

The original version (shown at the top) is fine. Why did you change it?
Although the original should have a space:

static __kprobes void FETCH_FUNC_NAME(memory, string)(struct pt_regs *regs,
                                                     void *addr, void *dest)
{
       long ret;
       int maxlen = get_rloc_len(*(u32 *)dest);
       u8 *dst = get_rloc_data(dest);
       u8 *src = addr;
       mm_segment_t old_fs = get_fs();
					<--- new line needed (from original)
       if (!maxlen)
               return;

> +	mm_segment_t old_fs = get_fs();
> +
> +	if (!maxlen)
> +		return;
> +
> +	/*
> +	 * Try to get string again, since the string can be changed while
> +	 * probing.
> +	 */
> +	set_fs(KERNEL_DS);
> +	pagefault_disable();
> +
> +	do
> +		ret = __copy_from_user_inatomic(dst++, src++, 1);
> +	while (dst[-1] && ret == 0 && src - (u8 *)addr < maxlen);
> +
> +	dst[-1] = '\0';
> +	pagefault_enable();
> +	set_fs(old_fs);
> +
> +	if (ret < 0) {	/* Failed to fetch string */
> +		((u8 *)get_rloc_data(dest))[0] = '\0';
> +		*(u32 *)dest = make_data_rloc(0, get_rloc_offs(*(u32 *)dest));
> +	} else {
> +		*(u32 *)dest = make_data_rloc(src - (u8 *)addr,
> +					      get_rloc_offs(*(u32 *)dest));
> +	}
> +}


> +
> +#define WRITE_BUFSIZE 128

The original code had WRITE_BUFSIZE as 4096 this has it with 128. That's
a big difference. Even if you have a reason for changing this, don't do
it in this patch. That should be a separate patch with an explanation of
why this was changed.

The rest of the patch looks fine.

-- Steve

> +
> +ssize_t traceprobe_probes_write(struct file *file, const char __user *buffer,
> +				size_t count, loff_t *ppos,
> +				int (*createfn)(int, char **))
> +{
> +	char *kbuf, *tmp;
> +	int ret = 0;
> +	size_t done = 0;
> +	size_t size;
> +
> +
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
