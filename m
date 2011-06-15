Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 24F886B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 01:25:53 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p5F5PmNV014882
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 22:25:49 -0700
Received: from qwi2 (qwi2.prod.google.com [10.241.195.2])
	by kpbe14.cbf.corp.google.com with ESMTP id p5F5PWX1020455
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 22:25:47 -0700
Received: by qwi2 with SMTP id 2so48255qwi.22
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 22:25:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110614142347.8f9634a9.akpm@linux-foundation.org>
References: <1307079129-31328-1-git-send-email-yinghan@google.com>
	<20110614142347.8f9634a9.akpm@linux-foundation.org>
Date: Tue, 14 Jun 2011 22:25:39 -0700
Message-ID: <BANLkTi=c6YUHVJtdPZs3prXMqQtrsjsCvg@mail.gmail.com>
Subject: Re: [PATCH resend V2] Eliminate task stack trace duplication.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jun 14, 2011 at 2:23 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, =A02 Jun 2011 22:32:09 -0700 Ying Han <yinghan@google.com> wrote:
>
>> The problem with small dmesg ring buffer like 512k is that only limited =
number
>> of task traces will be logged. Sometimes we lose important information o=
nly
>> because of too many duplicated stack traces.

Thank you Andrew reviewing the patch !

> The description would be improved if it were to point out that this
> problem occurs when dumping lots of stacks in a single operation, such
> as sysrq-T.

I will add the description on the next post.

>
>> This patch tries to reduce the duplication of task stack trace in the du=
mp
>> message by hashing the task stack. The hashtable is a 32k pre-allocated =
buffer
>> during bootup. Then we hash the task stack with stack_depth 32 for each =
stack
>> entry. Each time if we find the identical task trace in the task stack, =
we dump
>> only the pid of the task which has the task trace dumped. So it is easy =
to back
>> track to the full stack with the pid.
>>
>> [ =A0 58.469730] kworker/0:0 =A0 =A0 S 0000000000000000 =A0 =A0 0 =A0 =
=A0 4 =A0 =A0 =A02 0x00000000
>> [ =A0 58.469735] =A0ffff88082fcfde80 0000000000000046 ffff88082e9d8000 f=
fff88082fcfc010
>> [ =A0 58.469739] =A0ffff88082fce9860 0000000000011440 ffff88082fcfdfd8 f=
fff88082fcfdfd8
>> [ =A0 58.469743] =A00000000000011440 0000000000000000 ffff88082fcee180 f=
fff88082fce9860
>> [ =A0 58.469747] Call Trace:
>> [ =A0 58.469751] =A0[<ffffffff8108525a>] worker_thread+0x24b/0x250
>> [ =A0 58.469754] =A0[<ffffffff8108500f>] ? manage_workers+0x192/0x192
>> [ =A0 58.469757] =A0[<ffffffff810885bd>] kthread+0x82/0x8a
>> [ =A0 58.469760] =A0[<ffffffff8141aed4>] kernel_thread_helper+0x4/0x10
>> [ =A0 58.469763] =A0[<ffffffff8108853b>] ? kthread_worker_fn+0x112/0x112
>> [ =A0 58.469765] =A0[<ffffffff8141aed0>] ? gs_change+0xb/0xb
>> [ =A0 58.469768] kworker/u:0 =A0 =A0 S 0000000000000004 =A0 =A0 0 =A0 =
=A0 5 =A0 =A0 =A02 0x00000000
>> [ =A0 58.469773] =A0ffff88082fcffe80 0000000000000046 ffff880800000000 f=
fff88082fcfe010
>> [ =A0 58.469777] =A0ffff88082fcea080 0000000000011440 ffff88082fcfffd8 f=
fff88082fcfffd8
>> [ =A0 58.469781] =A00000000000011440 0000000000000000 ffff88082fd4e9a0 f=
fff88082fcea080
>> [ =A0 58.469785] Call Trace:
>> [ =A0 58.469786] <Same stack as pid 4>
>> [ =A0 58.470235] kworker/0:1 =A0 =A0 S 0000000000000000 =A0 =A0 0 =A0 =
=A013 =A0 =A0 =A02 0x00000000
>> [ =A0 58.470255] =A0ffff88082fd3fe80 0000000000000046 ffff880800000000 f=
fff88082fd3e010
>> [ =A0 58.470279] =A0ffff88082fcee180 0000000000011440 ffff88082fd3ffd8 f=
fff88082fd3ffd8
>> [ =A0 58.470301] =A00000000000011440 0000000000000000 ffffffff8180b020 f=
fff88082fcee180
>> [ =A0 58.470325] Call Trace:
>> [ =A0 58.470332] <Same stack as pid 4>
>
> That looks good to me. =A0Not only does it save space, it also makes the
> human processing of these traces more efficient.
>
> Are these pids unique? =A0What happens if I have a pid 4 in two pid
> namespaces?

I know that we might have different process sharing the same PID
within different namespace. How that is handled on the original stack
trace w/o the dedup? Hmm, I need to look closely into the pid
namespace.

If that's a problem then we could use the task_struct* as
> a key or something. =A0Perhaps add a new "stack trace number" field to
> each trace and increment/display that as the dump proceeds.


>>
>> ...
>>
>> =A0void
>> =A0show_trace_log_lvl(struct task_struct *task, struct pt_regs *regs,
>> - =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *stack, unsigned long bp, char *=
log_lvl)
>> + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *stack, unsigned long bp, char *=
log_lvl,
>> + =A0 =A0 =A0 =A0 =A0 =A0 int index)
>
> The `index' arg is a bit mysterious, especially as it has such a bland na=
me.

>

 Please document it somewhere (perhaps here). =A0Include a description of
> the magical value 0.

ok, will make better documentation.

>
>> =A0{
>> - =A0 =A0 printk("%sCall Trace:\n", log_lvl);
>> - =A0 =A0 dump_trace(task, regs, stack, bp, &print_trace_ops, log_lvl);
>> + =A0 =A0 if (index) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 printk("%sCall Trace:\n", log_lvl);
>> + =A0 =A0 =A0 =A0 =A0 =A0 printk("<Same stack as pid %d>\n\n", index);
>
> So it's a pid. =A0Perhaps it should have type pid_t and have "pid" in its
> name.

will include the change.
>
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 printk("%sCall Trace:\n", log_lvl);
>> + =A0 =A0 =A0 =A0 =A0 =A0 dump_trace(task, regs, stack, bp, &print_trace=
_ops, log_lvl);
>> + =A0 =A0 }
>> =A0}
>>
>>
>> ...
>>
>> @@ -94,6 +95,117 @@ void save_stack_trace_tsk(struct task_struct *tsk, s=
truct stack_trace *trace)
>> =A0}
>> =A0EXPORT_SYMBOL_GPL(save_stack_trace_tsk);
>
> Some nice comments describing what we're doing in this file would be good=
.

ok, will add comments.

>
> It's regrettable that this code is available only on x86. =A0Fixable?

Hmm, i can take a look on other architectures. Not sure how much
changes are involved. I might go ahead send out the next patch w/ x86
only and other arch support comes with separate patch.

>
>> +#define DEDUP_MAX_STACK_DEPTH 32
>> +#define DEDUP_STACK_HASH 32768
>> +#define DEDUP_STACK_ENTRY (DEDUP_STACK_HASH/sizeof(struct task_stack) -=
 1)
>> +
>> +struct task_stack {
>> + =A0 =A0 pid_t pid;
>> + =A0 =A0 unsigned long entries[DEDUP_MAX_STACK_DEPTH];
>> +};
>> +
>> +struct task_stack *stack_hash_table;
>> +static struct task_stack *cur_stack;
>> +__cacheline_aligned_in_smp DEFINE_SPINLOCK(stack_hash_lock);
>> +
>> +void __init stack_trace_hash_init(void)
>> +{
>> + =A0 =A0 stack_hash_table =3D vmalloc(DEDUP_STACK_HASH);
>> + =A0 =A0 cur_stack =3D stack_hash_table + DEDUP_STACK_ENTRY;
>> +}
>
> Why vmalloc?
>
> Why not allocate it at compile time?

Hmm, sounds good to me. I will make the change.

>
>> +void stack_trace_hash_clean(void)
>> +{
>> + =A0 =A0 memset(stack_hash_table, 0, DEDUP_STACK_HASH);
>> +}
>> +
>> +static inline u32 task_stack_hash(struct task_stack *stack, int len)
>> +{
>> + =A0 =A0 u32 index =3D jhash(stack->entries, len * sizeof(unsigned long=
), 0);
>> +
>> + =A0 =A0 return index;
>> +}
>> +
>> +static unsigned int stack_trace_lookup(int len)
>> +{
>> + =A0 =A0 int j;
>> + =A0 =A0 int index =3D 0;
>> + =A0 =A0 unsigned int ret =3D 0;
>> + =A0 =A0 struct task_stack *stack;
>> +
>> + =A0 =A0 index =3D task_stack_hash(cur_stack, len) % DEDUP_STACK_ENTRY;
>> +
>> + =A0 =A0 for (j =3D 0; j < 10; j++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 stack =3D stack_hash_table + (index + (1 << j)=
) %
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 DEDUP_STACK_ENTRY;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (stack->entries[0] =3D=3D 0x0) {
>
> Good place for a comment describing why we got here.

Ok.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(stack, cur_stack, sizeo=
f(*cur_stack));
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else {
>
> Ditto.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memcmp(stack->entries, cur=
_stack->entries,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 sizeof(stack->entries)) =3D=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D stack-=
>pid;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> + =A0 =A0 memset(cur_stack, 0, sizeof(struct task_stack));
>> +
>> + =A0 =A0 return ret;
>> +}
>
> Using memcmp() is pretty weak - the elimination of duplicates would
> work better if this code was integrated with the stack unwinding
> machinery, so we're not comparing random garbage non-return-address
> stack slots.

I can look into that.

>
>>
>> ...
>>
>> --- a/kernel/sched.c
>> +++ b/kernel/sched.c
>> @@ -5727,10 +5727,11 @@ out_unlock:
>>
>> =A0static const char stat_nam[] =3D TASK_STATE_TO_CHAR_STR;
>>
>> -void sched_show_task(struct task_struct *p)
>> +void _sched_show_task(struct task_struct *p, int dedup)
>> =A0{
>> =A0 =A0 =A0 unsigned long free =3D 0;
>> =A0 =A0 =A0 unsigned state;
>> + =A0 =A0 int index =3D 0;
>>
>> =A0 =A0 =A0 state =3D p->state ? __ffs(p->state) + 1 : 0;
>> =A0 =A0 =A0 printk(KERN_INFO "%-15.15s %c", p->comm,
>> @@ -5753,7 +5754,19 @@ void sched_show_task(struct task_struct *p)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_pid_nr(p), task_pid_nr(p->real_parent),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned long)task_thread_info(p)->flags);
>>
>> - =A0 =A0 show_stack(p, NULL);
>> + =A0 =A0 if (dedup && stack_hash_table)
>> + =A0 =A0 =A0 =A0 =A0 =A0 index =3D save_dup_stack_trace(p);
>> + =A0 =A0 show_stack(p, NULL, index);
>> +}
>> +
>> +void sched_show_task(struct task_struct *p)
>> +{
>> + =A0 =A0 _sched_show_task(p, 0);
>> +}
>> +
>> +void sched_show_task_dedup(struct task_struct *p)
>> +{
>> + =A0 =A0 _sched_show_task(p, 1);
>> =A0}
>
> stack_hash_table only exists on x86. =A0Did everything else just get brok=
en?

I will look into that.
>
>

Thank you

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
