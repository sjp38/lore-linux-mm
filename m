Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9119C6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 17:22:26 -0400 (EDT)
Date: Tue, 14 Jun 2011 14:23:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend V2] Eliminate task stack trace duplication.
Message-Id: <20110614142347.8f9634a9.akpm@linux-foundation.org>
In-Reply-To: <1307079129-31328-1-git-send-email-yinghan@google.com>
References: <1307079129-31328-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu,  2 Jun 2011 22:32:09 -0700 Ying Han <yinghan@google.com> wrote:

> The problem with small dmesg ring buffer like 512k is that only limited number
> of task traces will be logged. Sometimes we lose important information only
> because of too many duplicated stack traces.

The description would be improved if it were to point out that this
problem occurs when dumping lots of stacks in a single operation, such
as sysrq-T.

> This patch tries to reduce the duplication of task stack trace in the dump
> message by hashing the task stack. The hashtable is a 32k pre-allocated buffer
> during bootup. Then we hash the task stack with stack_depth 32 for each stack
> entry. Each time if we find the identical task trace in the task stack, we dump
> only the pid of the task which has the task trace dumped. So it is easy to back
> track to the full stack with the pid.
> 
> [   58.469730] kworker/0:0     S 0000000000000000     0     4      2 0x00000000
> [   58.469735]  ffff88082fcfde80 0000000000000046 ffff88082e9d8000 ffff88082fcfc010
> [   58.469739]  ffff88082fce9860 0000000000011440 ffff88082fcfdfd8 ffff88082fcfdfd8
> [   58.469743]  0000000000011440 0000000000000000 ffff88082fcee180 ffff88082fce9860
> [   58.469747] Call Trace:
> [   58.469751]  [<ffffffff8108525a>] worker_thread+0x24b/0x250
> [   58.469754]  [<ffffffff8108500f>] ? manage_workers+0x192/0x192
> [   58.469757]  [<ffffffff810885bd>] kthread+0x82/0x8a
> [   58.469760]  [<ffffffff8141aed4>] kernel_thread_helper+0x4/0x10
> [   58.469763]  [<ffffffff8108853b>] ? kthread_worker_fn+0x112/0x112
> [   58.469765]  [<ffffffff8141aed0>] ? gs_change+0xb/0xb
> [   58.469768] kworker/u:0     S 0000000000000004     0     5      2 0x00000000
> [   58.469773]  ffff88082fcffe80 0000000000000046 ffff880800000000 ffff88082fcfe010
> [   58.469777]  ffff88082fcea080 0000000000011440 ffff88082fcfffd8 ffff88082fcfffd8
> [   58.469781]  0000000000011440 0000000000000000 ffff88082fd4e9a0 ffff88082fcea080
> [   58.469785] Call Trace:
> [   58.469786] <Same stack as pid 4>
> [   58.470235] kworker/0:1     S 0000000000000000     0    13      2 0x00000000
> [   58.470255]  ffff88082fd3fe80 0000000000000046 ffff880800000000 ffff88082fd3e010
> [   58.470279]  ffff88082fcee180 0000000000011440 ffff88082fd3ffd8 ffff88082fd3ffd8
> [   58.470301]  0000000000011440 0000000000000000 ffffffff8180b020 ffff88082fcee180
> [   58.470325] Call Trace:
> [   58.470332] <Same stack as pid 4>

That looks good to me.  Not only does it save space, it also makes the
human processing of these traces more efficient.

Are these pids unique?  What happens if I have a pid 4 in two pid
namespaces?  If that's a problem then we could use the task_struct* as
a key or something.  Perhaps add a new "stack trace number" field to
each trace and increment/display that as the dump proceeds.

>
> ...
>
>  void
>  show_trace_log_lvl(struct task_struct *task, struct pt_regs *regs,
> -		unsigned long *stack, unsigned long bp, char *log_lvl)
> +		unsigned long *stack, unsigned long bp, char *log_lvl,
> +		int index)

The `index' arg is a bit mysterious, especially as it has such a bland name.

Please document it somewhere (perhaps here).  Include a description of
the magical value 0.

>  {
> -	printk("%sCall Trace:\n", log_lvl);
> -	dump_trace(task, regs, stack, bp, &print_trace_ops, log_lvl);
> +	if (index) {
> +		printk("%sCall Trace:\n", log_lvl);
> +		printk("<Same stack as pid %d>\n\n", index);

So it's a pid.  Perhaps it should have type pid_t and have "pid" in its
name.

> +	} else {
> +		printk("%sCall Trace:\n", log_lvl);
> +		dump_trace(task, regs, stack, bp, &print_trace_ops, log_lvl);
> +	}
>  }
>  
>
> ...
>
> @@ -94,6 +95,117 @@ void save_stack_trace_tsk(struct task_struct *tsk, struct stack_trace *trace)
>  }
>  EXPORT_SYMBOL_GPL(save_stack_trace_tsk);

Some nice comments describing what we're doing in this file would be good.

It's regrettable that this code is available only on x86.  Fixable?

> +#define DEDUP_MAX_STACK_DEPTH 32
> +#define DEDUP_STACK_HASH 32768
> +#define DEDUP_STACK_ENTRY (DEDUP_STACK_HASH/sizeof(struct task_stack) - 1)
> +
> +struct task_stack {
> +	pid_t pid;
> +	unsigned long entries[DEDUP_MAX_STACK_DEPTH];
> +};
> +
> +struct task_stack *stack_hash_table;
> +static struct task_stack *cur_stack;
> +__cacheline_aligned_in_smp DEFINE_SPINLOCK(stack_hash_lock);
> +
> +void __init stack_trace_hash_init(void)
> +{
> +	stack_hash_table = vmalloc(DEDUP_STACK_HASH);
> +	cur_stack = stack_hash_table + DEDUP_STACK_ENTRY;
> +}

Why vmalloc?

Why not allocate it at compile time?

> +void stack_trace_hash_clean(void)
> +{
> +	memset(stack_hash_table, 0, DEDUP_STACK_HASH);
> +}
> +
> +static inline u32 task_stack_hash(struct task_stack *stack, int len)
> +{
> +	u32 index = jhash(stack->entries, len * sizeof(unsigned long), 0);
> +
> +	return index;
> +}
> +
> +static unsigned int stack_trace_lookup(int len)
> +{
> +	int j;
> +	int index = 0;
> +	unsigned int ret = 0;
> +	struct task_stack *stack;
> +
> +	index = task_stack_hash(cur_stack, len) % DEDUP_STACK_ENTRY;
> +
> +	for (j = 0; j < 10; j++) {
> +		stack = stack_hash_table + (index + (1 << j)) %
> +						DEDUP_STACK_ENTRY;
> +		if (stack->entries[0] == 0x0) {

Good place for a comment describing why we got here.

> +			memcpy(stack, cur_stack, sizeof(*cur_stack));
> +			ret = 0;
> +			break;
> +		} else {

Ditto.

> +			if (memcmp(stack->entries, cur_stack->entries,
> +						sizeof(stack->entries)) == 0) {
> +				ret = stack->pid;
> +				break;
> +			}
> +		}
> +	}
> +	memset(cur_stack, 0, sizeof(struct task_stack));
> +
> +	return ret;
> +}

Using memcmp() is pretty weak - the elimination of duplicates would
work better if this code was integrated with the stack unwinding
machinery, so we're not comparing random garbage non-return-address
stack slots.

>
> ...
>
> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -5727,10 +5727,11 @@ out_unlock:
>  
>  static const char stat_nam[] = TASK_STATE_TO_CHAR_STR;
>  
> -void sched_show_task(struct task_struct *p)
> +void _sched_show_task(struct task_struct *p, int dedup)
>  {
>  	unsigned long free = 0;
>  	unsigned state;
> +	int index = 0;
>  
>  	state = p->state ? __ffs(p->state) + 1 : 0;
>  	printk(KERN_INFO "%-15.15s %c", p->comm,
> @@ -5753,7 +5754,19 @@ void sched_show_task(struct task_struct *p)
>  		task_pid_nr(p), task_pid_nr(p->real_parent),
>  		(unsigned long)task_thread_info(p)->flags);
>  
> -	show_stack(p, NULL);
> +	if (dedup && stack_hash_table)
> +		index = save_dup_stack_trace(p);
> +	show_stack(p, NULL, index);
> +}
> +
> +void sched_show_task(struct task_struct *p)
> +{
> +	_sched_show_task(p, 0);
> +}
> +
> +void sched_show_task_dedup(struct task_struct *p)
> +{
> +	_sched_show_task(p, 1);
>  }

stack_hash_table only exists on x86.  Did everything else just get broken?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
