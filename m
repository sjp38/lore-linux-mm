Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2FE6B0169
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 19:20:42 -0400 (EDT)
Date: Wed, 27 Jul 2011 16:19:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V4] Eliminate task stack trace duplication.
Message-Id: <20110727161936.e6ab9299.akpm@linux-foundation.org>
In-Reply-To: <1311103882-13544-1-git-send-email-abrestic@google.com>
References: <1311103882-13544-1-git-send-email-abrestic@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Bresticker <abrestic@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org, Ying Han <yinghan@google.com>

On Tue, 19 Jul 2011 12:31:22 -0700
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

That looks nice.

> ...
>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: Andrew Bresticker <abrestic@google.com>
> ---
>  arch/x86/Kconfig                  |    3 +
>  arch/x86/include/asm/stacktrace.h |    6 ++-
>  arch/x86/kernel/dumpstack.c       |   24 ++++++--
>  arch/x86/kernel/dumpstack_32.c    |    7 ++-
>  arch/x86/kernel/dumpstack_64.c    |   11 +++-
>  arch/x86/kernel/stacktrace.c      |  106 +++++++++++++++++++++++++++++++++++++
>  drivers/tty/sysrq.c               |    2 +-
>  include/linux/sched.h             |    3 +-
>  include/linux/stacktrace.h        |    2 +
>  kernel/debug/kdb/kdb_bt.c         |    8 ++--
>  kernel/rtmutex-debug.c            |    2 +-
>  kernel/sched.c                    |   20 ++++++-
>  kernel/stacktrace.c               |   10 ++++
>  13 files changed, 180 insertions(+), 24 deletions(-)

This is all pretty x86-centric.  I wonder if the code could/should be
implemented in a fashion whcih would permit other architectures to use
it?

> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -103,6 +103,9 @@ config LOCKDEP_SUPPORT
>  config STACKTRACE_SUPPORT
>  	def_bool y
>  
> +config STACKTRACE
> +	def_bool y
> +

What's this change for?

>  config HAVE_LATENCYTOP_SUPPORT
>  	def_bool y
>  
>
> ...
>
> +static unsigned int stack_trace_lookup(int len)
> +{
> +	int j;
> +	int index = 0;
> +	unsigned int ret = 0;
> +	struct task_stack *stack;
> +
> +	index = task_stack_hash(cur_stack, len) % DEDUP_STACK_LAST_ENTRY;
> +
> +	for (j = 0; j < DEDUP_HASH_MAX_ITERATIONS; j++) {
> +		stack = stack_hash_table + (index + (1 << j)) %
> +						DEDUP_STACK_LAST_ENTRY;
> +		if (stack->entries[0] == 0x0) {
> +			memcpy(stack, cur_stack, sizeof(*cur_stack));
> +			ret = 0;
> +			break;
> +		} else {
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

I can kinda see what this function is doing - maintaining an LRU ring
of task stacks.  Or something.  I didn't look very hard because I
shouldn't have to ;) Please comment this function: tell us what it's
doing and why it's doing it?

What surprises me about this patch is that it appears to be maintaining
an array of entire stack traces.  Why not just generate a good hash of
the stack contents and assume that if one task's hash is equal to
another tasks's hash, then the two tasks have the same stack trace?

That way,

struct task_stack {
	pid_t pid;
	unsigned long entries[DEDUP_MAX_STACK_DEPTH];
};

becomes

struct task_stack {
	pid_t pid;
	unsigned long stack_hash;
};

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
