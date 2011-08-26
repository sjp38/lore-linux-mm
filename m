Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDA16B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 19:20:23 -0400 (EDT)
Date: Fri, 26 Aug 2011 16:19:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V5] Eliminate task stack trace duplication.
Message-Id: <20110826161936.52979754.akpm@linux-foundation.org>
In-Reply-To: <1311902759-14971-1-git-send-email-abrestic@google.com>
References: <1311902759-14971-1-git-send-email-abrestic@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Bresticker <abrestic@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org, Ying Han <yinghan@google.com>

(I'm back!)

On Thu, 28 Jul 2011 18:25:59 -0700
Andrew Bresticker <abrestic@google.com> wrote:

> The problem with small dmesg ring buffer like 512k is that only limited number
> of task traces will be logged. Sometimes we lose important information only
> because of too many duplicated stack traces. This problem occurs when dumping
> lots of stacks in a single operation, such as sysrq-T.
> 
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

The code looks OK(ish) to me.  I'm still concerned that the implementation
will miss lots of de-duplications because it is hashing random crud in
the stack frame.

> Note: Non-x86 architectures will need to be updated since show_stack()
> now takes an additional argument.

Well, we can't break all architectures.

I can't think of a way to make the preprocessor convert show_stack(a,
b) into show_stack(a, b, N) (this can be done in the other direction). 
So all I can think of is to rename x86 show_stack() to something else and do

#define show_stack_something_else(a, b, c) show_stack(a, b)

for other architectures.

But on the other hand, why did the show_stack() interface get changed? 
show_stack() dumps a single tasks's stack, so top-level callers have no
earthly reason to be passing the dup_stack_pid into show_stack(). 
dup_stack_pid is purely for many-task stackdumps.

Also, the code as-is is pretty much useless for other architectures. 
The core changes in arch/x86/kernel/stacktrace.c look pretty generic -
can we design and place this code so that all architectures can use it?


> The problem with small dmesg ring buffer like 512k is that only limited number
> of task traces will be logged. Sometimes we lose important information only
> because of too many duplicated stack traces. This problem occurs when dumping
> lots of stacks in a single operation, such as sysrq-T.
> 
> This patch tries to reduce the duplication of task stack trace in the dump
> message by hashing the task stack. The hashtable is a 32k pre-allocated buffer
> during bootup. Then we hash the task stack with stack_depth 32 for each stack
> entry. Each time if we find the identical task trace in the task stack, we dump
> only the pid of the task which has the task trace dumped. So it is easy to back
> track to the full stack with the pid.
> 
>
> ...
>
> +/*
> + * The implementation of stack trace dedup. It tries to reduce the duplication
> + * of task stack trace in the dump by hashing the stack trace. The hashtable is
> + * 32k pre-allocated buffer. Then we hash the task stack with stack_depth
> + * DEDUP_MAX_STACK_DEPTH for each stack entry. Each time if an identical trace
> + * is found in the stack, we dump only the pid of previous task. So it is easy
> + * to back track to the full stack with the pid.
> + */
> +#define DEDUP_MAX_STACK_DEPTH 32
> +#define DEDUP_STACK_HASH 32768
> +#define DEDUP_STACK_ENTRIES (DEDUP_STACK_HASH/sizeof(struct task_stack))
> +#define DEDUP_HASH_MAX_ITERATIONS 10

It wouldn't hurt to document DEDUP_HASH_MAX_ITERATIONS (at least).

But then, why does DEDUP_HASH_MAX_ITERATIONS exist? (below)

> +struct task_stack {
> +	pid_t pid;
> +	int len;
> +	unsigned long hash;
> +};
> +
> +static struct task_stack stack_hash_table[DEDUP_STACK_ENTRIES];
> +static struct task_stack cur_stack;
> +static __cacheline_aligned_in_smp DEFINE_SPINLOCK(stack_hash_lock);
> +
> +/*
> + * The stack hashtable uses linear probing to resolve collisions.
> + * We consider two stacks to be the same if their hash values and lengths
> + * are equal.
> + */
> +static unsigned int stack_trace_lookup(void)
> +{
> +	int j;
> +	int index;
> +	unsigned int ret = 0;
> +	struct task_stack *stack;
> +
> +	index = cur_stack.hash % DEDUP_STACK_ENTRIES;
> +
> +	for (j = 0; j < DEDUP_HASH_MAX_ITERATIONS; j++) {
> +		stack = stack_hash_table + (index + j) % DEDUP_STACK_ENTRIES;

(this would be more efficient if DEDUP_STACK_ENTRIES was a power of 2)

> +		if (stack->hash == 0) {
> +			*stack = cur_stack;
> +			ret = 0;
> +			break;
> +		} else {
> +			if (stack->hash == cur_stack.hash &&
> +			    stack->len == cur_stack.len) {
> +				ret = stack->pid;
> +				break;
> +			}
> +		}
> +	}
> +	if (j == DEDUP_HASH_MAX_ITERATIONS)
> +		stack_hash_table[index] = cur_stack;

Why stop there?  Why not just append to stack_hash_table[]?  When we
first decide to do a multi-task stackdump, zero the index into the
array.  Each time a task is processed, look to see if it is unique and
if so, add its task_stack to the end of the array.

This may require adding a stacktrace_ops.start().  This could be done
while moving stacktrace_ops (which advertises itself as a "Generic
stack tracer"!) out of x86-specific code.

> +	memset(&cur_stack, 0, sizeof(cur_stack));

Sane, but I'm not sure it's necessary.

> +	return ret;
> +}
> +
>
> ...
>

Making this all arch-neutral is quite a bit of work, which you may not
feel like undertaking, ho hum.  Also, the lack of any documentation in
that x86 code makes it unready for prime time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
