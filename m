Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id CA5526B13F5
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 19:12:18 -0500 (EST)
Received: by qadz32 with SMTP id z32so3544502qad.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 16:12:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328655520-10580-1-git-send-email-yinghan@google.com>
References: <1328655520-10580-1-git-send-email-yinghan@google.com>
Date: Tue, 7 Feb 2012 16:12:17 -0800
Message-ID: <CALWz4iwdFEatcoZ80yVt9r9Uf6LdcbHatTQdM8fcM0yWqcH2cQ@mail.gmail.com>
Subject: Re: [PATCH V7] Eliminate task stack trace duplication
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, x86@kernel.org

On Tue, Feb 7, 2012 at 2:58 PM, Ying Han <yinghan@google.com> wrote:
> The problem with small dmesg ring buffer like 512k is that only limited n=
umber
> of task traces will be logged. Sometimes we lose important information on=
ly
> because of too many duplicated stack traces. This problem occurs when dum=
ping
> lots of stacks in a single operation, such as sysrq-T.
>
> This patch tries to reduce the duplication of task stack trace in the dum=
p
> message by hashing the task stack. The hashtable is a 32k pre-allocated b=
uffer
> during bootup. Each time if we find the identical task trace in the task =
stack,
> we dump only the pid of the task which has the task trace dumped. So it i=
s easy
> to back track to the full stack with the pid.
>
> When we do the hashing, we eliminate garbage entries from stack traces. T=
hose
> entries are still being printed in the dump to provide more debugging
> informations.
>
> [ =A0 58.469730] kworker/0:0 =A0 =A0 S 0000000000000000 =A0 =A0 0 =A0 =A0=
 4 =A0 =A0 =A02 0x00000000
> [ =A0 58.469735] =A0ffff88082fcfde80 0000000000000046 ffff88082e9d8000 ff=
ff88082fcfc010
> [ =A0 58.469739] =A0ffff88082fce9860 0000000000011440 ffff88082fcfdfd8 ff=
ff88082fcfdfd8
> [ =A0 58.469743] =A00000000000011440 0000000000000000 ffff88082fcee180 ff=
ff88082fce9860
> [ =A0 58.469747] Call Trace:
> [ =A0 58.469751] =A0[<ffffffff8108525a>] worker_thread+0x24b/0x250
> [ =A0 58.469754] =A0[<ffffffff8108500f>] ? manage_workers+0x192/0x192
> [ =A0 58.469757] =A0[<ffffffff810885bd>] kthread+0x82/0x8a
> [ =A0 58.469760] =A0[<ffffffff8141aed4>] kernel_thread_helper+0x4/0x10
> [ =A0 58.469763] =A0[<ffffffff8108853b>] ? kthread_worker_fn+0x112/0x112
> [ =A0 58.469765] =A0[<ffffffff8141aed0>] ? gs_change+0xb/0xb
> [ =A0 58.469768] kworker/u:0 =A0 =A0 S 0000000000000004 =A0 =A0 0 =A0 =A0=
 5 =A0 =A0 =A02 0x00000000
> [ =A0 58.469773] =A0ffff88082fcffe80 0000000000000046 ffff880800000000 ff=
ff88082fcfe010
> [ =A0 58.469777] =A0ffff88082fcea080 0000000000011440 ffff88082fcfffd8 ff=
ff88082fcfffd8
> [ =A0 58.469781] =A00000000000011440 0000000000000000 ffff88082fd4e9a0 ff=
ff88082fcea080
> [ =A0 58.469785] Call Trace:
> [ =A0 58.469786] <Same stack as pid 4>
> [ =A0 58.470235] kworker/0:1 =A0 =A0 S 0000000000000000 =A0 =A0 0 =A0 =A0=
13 =A0 =A0 =A02 0x00000000
> [ =A0 58.470255] =A0ffff88082fd3fe80 0000000000000046 ffff880800000000 ff=
ff88082fd3e010
> [ =A0 58.470279] =A0ffff88082fcee180 0000000000011440 ffff88082fd3ffd8 ff=
ff88082fd3ffd8
> [ =A0 58.470301] =A00000000000011440 0000000000000000 ffffffff8180b020 ff=
ff88082fcee180
> [ =A0 58.470325] Call Trace:
> [ =A0 58.470332] <Same stack as pid 4>
>
> changelog v7..v6:
> 1. rebase on v3.3_rc2, the only change is moving changes from kernel/sche=
d.c
> to kernel/sched/core.c
>
> changelog v6..v5:
> 1. clear saved stack trace before printing a set of stacks. this ensures =
the printed
> stack traces are not omitted messages.
> 2. add log level in printing duplicate stack.
> 3. remove the show_stack() API change, and non-x86 arch won't need furthe=
r change.
> 4. add more inline documentations.
>
> changelog v5..v4:
> 1. removed changes to Kconfig file
> 2. changed hashtable to keep only hash value and length of stack
> 3. simplified hashtable lookup
>
> changelog v4..v3:
> 1. improve de-duplication by eliminating garbage entries from stack trace=
s.
> with this change 793/825 stack traces were recognized as duplicates. in v=
3
> only 482/839 were duplicates.
>
> changelog v3..v2:
> 1. again better documentation on the patch description.
> 2. make the stack_hash_table to be allocated at compile time.
> 3. have better name of variable index
> 4. move save_dup_stack_trace() in kernel/stacktrace.c
>
> changelog v2..v1:
> 1. better documentation on the patch description
> 2. move the spinlock inside the hash lockup, so reducing the holding time=
.
>
> Note:
> 1. with pid namespace, we might have same pid number for different proces=
ses. i
> wonder how the stack trace (w/o dedup) handles the case, it uses tsk->pid=
 as well
> as far as I checked.
> 2. the core functionality is in x86-specific code, this could be moved ou=
t to
> support other architectures.
> 3. Andrew made the suggestion of doing appending to stack_hash_table[].
>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
> =A0arch/x86/include/asm/stacktrace.h | =A0 11 +++-
> =A0arch/x86/kernel/dumpstack.c =A0 =A0 =A0 | =A0 24 ++++++-
> =A0arch/x86/kernel/dumpstack_32.c =A0 =A0| =A0 =A07 +-
> =A0arch/x86/kernel/dumpstack_64.c =A0 =A0| =A0 =A07 +-
> =A0arch/x86/kernel/stacktrace.c =A0 =A0 =A0| =A0123 +++++++++++++++++++++=
++++++++++++++++
> =A0include/linux/sched.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +
> =A0include/linux/stacktrace.h =A0 =A0 =A0 =A0| =A0 =A04 +
> =A0kernel/sched/core.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 32 +++++++++-
> =A0kernel/stacktrace.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 15 +++++
> =A09 files changed, 211 insertions(+), 15 deletions(-)
>
> diff --git a/arch/x86/include/asm/stacktrace.h b/arch/x86/include/asm/sta=
cktrace.h
> index 70bbe39..32557fe 100644
> --- a/arch/x86/include/asm/stacktrace.h
> +++ b/arch/x86/include/asm/stacktrace.h
> @@ -81,13 +81,20 @@ stack_frame(struct task_struct *task, struct pt_regs =
*regs)
> =A0}
> =A0#endif
>
> +/*
> + * The parameter dup_stack_pid is used for task stack deduplication.
> + * The non-zero value of dup_stack_pid indicates the pid of the
> + * task with the same stack trace.
> + */
> =A0extern void
> =A0show_trace_log_lvl(struct task_struct *task, struct pt_regs *regs,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *stack, unsigned long =
bp, char *log_lvl);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *stack, unsigned long =
bp, char *log_lvl,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pid_t dup_stack_pid);
>
> =A0extern void
> =A0show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *sp, unsigned long bp,=
 char *log_lvl);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *sp, unsigned long bp,=
 char *log_lvl,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pid_t dup_stack_pid);
>
> =A0extern unsigned int code_bytes;
>
> diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
> index 1aae78f..ade9fda 100644
> --- a/arch/x86/kernel/dumpstack.c
> +++ b/arch/x86/kernel/dumpstack.c
> @@ -159,21 +159,37 @@ static const struct stacktrace_ops print_trace_ops =
=3D {
>
> =A0void
> =A0show_trace_log_lvl(struct task_struct *task, struct pt_regs *regs,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *stack, unsigned long bp, cha=
r *log_lvl)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *stack, unsigned long bp, cha=
r *log_lvl,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pid_t dup_stack_pid)
> =A0{
> =A0 =A0 =A0 =A0printk("%sCall Trace:\n", log_lvl);
> - =A0 =A0 =A0 dump_trace(task, regs, stack, bp, &print_trace_ops, log_lvl=
);
> + =A0 =A0 =A0 if (dup_stack_pid)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("%s<Same stack as pid %d>", log_lvl,=
 dup_stack_pid);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dump_trace(task, regs, stack, bp, &print_tr=
ace_ops, log_lvl);
> =A0}
>
> =A0void show_trace(struct task_struct *task, struct pt_regs *regs,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *stack, unsigned long bp)
> =A0{
> - =A0 =A0 =A0 show_trace_log_lvl(task, regs, stack, bp, "");
> + =A0 =A0 =A0 show_trace_log_lvl(task, regs, stack, bp, "", 0);
> =A0}
>
> =A0void show_stack(struct task_struct *task, unsigned long *sp)
> =A0{
> - =A0 =A0 =A0 show_stack_log_lvl(task, NULL, sp, 0, "");
> + =A0 =A0 =A0 show_stack_log_lvl(task, NULL, sp, 0, "", 0);
> +}
> +
> +/*
> + * Similar to show_stack except accepting the dup_stack_pid parameter.
> + * The parameter indicates whether or not the caller side tries to do
> + * a stack dedup, and the non-zero value indicates the pid of the
> + * task with the same stack trace.
> + */
> +void show_stack_dedup(struct task_struct *task, unsigned long *sp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pid_t dup_stack_pid)
> +{
> + =A0 =A0 =A0 show_stack_log_lvl(task, NULL, sp, 0, "", dup_stack_pid);
> =A0}
>
> =A0/*
> diff --git a/arch/x86/kernel/dumpstack_32.c b/arch/x86/kernel/dumpstack_3=
2.c
> index c99f9ed..b929c8d 100644
> --- a/arch/x86/kernel/dumpstack_32.c
> +++ b/arch/x86/kernel/dumpstack_32.c
> @@ -56,7 +56,8 @@ EXPORT_SYMBOL(dump_trace);
>
> =A0void
> =A0show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *sp, unsigned long bp,=
 char *log_lvl)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *sp, unsigned long bp,=
 char *log_lvl,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pid_t dup_stack_pid)
> =A0{
> =A0 =A0 =A0 =A0unsigned long *stack;
> =A0 =A0 =A0 =A0int i;
> @@ -78,7 +79,7 @@ show_stack_log_lvl(struct task_struct *task, struct pt_=
regs *regs,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0touch_nmi_watchdog();
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0printk(KERN_CONT "\n");
> - =A0 =A0 =A0 show_trace_log_lvl(task, regs, sp, bp, log_lvl);
> + =A0 =A0 =A0 show_trace_log_lvl(task, regs, sp, bp, log_lvl, dup_stack_p=
id);
> =A0}
>
>
> @@ -103,7 +104,7 @@ void show_registers(struct pt_regs *regs)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u8 *ip;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_EMERG "Stack:\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 show_stack_log_lvl(NULL, regs, &regs->sp, 0=
, KERN_EMERG);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 show_stack_log_lvl(NULL, regs, &regs->sp, 0=
, KERN_EMERG, 0);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_EMERG "Code: ");
>
> diff --git a/arch/x86/kernel/dumpstack_64.c b/arch/x86/kernel/dumpstack_6=
4.c
> index 6d728d9..cd56590 100644
> --- a/arch/x86/kernel/dumpstack_64.c
> +++ b/arch/x86/kernel/dumpstack_64.c
> @@ -198,7 +198,8 @@ EXPORT_SYMBOL(dump_trace);
>
> =A0void
> =A0show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *sp, unsigned long bp,=
 char *log_lvl)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *sp, unsigned long bp,=
 char *log_lvl,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pid_t dup_stack_pid)
> =A0{
> =A0 =A0 =A0 =A0unsigned long *irq_stack_end;
> =A0 =A0 =A0 =A0unsigned long *irq_stack;
> @@ -242,7 +243,7 @@ show_stack_log_lvl(struct task_struct *task, struct p=
t_regs *regs,
> =A0 =A0 =A0 =A0preempt_enable();
>
> =A0 =A0 =A0 =A0printk(KERN_CONT "\n");
> - =A0 =A0 =A0 show_trace_log_lvl(task, regs, sp, bp, log_lvl);
> + =A0 =A0 =A0 show_trace_log_lvl(task, regs, sp, bp, log_lvl, dup_stack_p=
id);
> =A0}
>
> =A0void show_registers(struct pt_regs *regs)
> @@ -271,7 +272,7 @@ void show_registers(struct pt_regs *regs)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_EMERG "Stack:\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0show_stack_log_lvl(NULL, regs, (unsigned l=
ong *)sp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00, K=
ERN_EMERG);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00, K=
ERN_EMERG, 0);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_EMERG "Code: ");
>
> diff --git a/arch/x86/kernel/stacktrace.c b/arch/x86/kernel/stacktrace.c
> index fdd0c64..6bee992 100644
> --- a/arch/x86/kernel/stacktrace.c
> +++ b/arch/x86/kernel/stacktrace.c
> @@ -7,6 +7,7 @@
> =A0#include <linux/stacktrace.h>
> =A0#include <linux/module.h>
> =A0#include <linux/uaccess.h>
> +#include <linux/jhash.h>
> =A0#include <asm/stacktrace.h>
>
> =A0static int save_stack_stack(void *data, char *name)
> @@ -81,6 +82,128 @@ void save_stack_trace_tsk(struct task_struct *tsk, st=
ruct stack_trace *trace)
> =A0}
> =A0EXPORT_SYMBOL_GPL(save_stack_trace_tsk);
>
> +/*
> + * The implementation of stack trace dedup.
> + *
> + * It tries to reduce the duplication of task stack trace in the dump by=
 hashing
> + * the stack trace. Each time if an identical trace is found in the stac=
k, we
> + * dump only the pid of previous task. So it is easy to back track to th=
e full
> + * stack with the pid.
> + *
> + * Note this chould be moved out of x86-specific code for all architectu=
res
> + * use.
> + */
> +
> +/*
> + * DEDUP_STACK_HASH: pre-allocated buffer size of the hashtable.
> + * DEDUP_STACK_ENTRIES: number of task stack entries in hashtable.
> + * DEDUP_HASH_MAX_ITERATIONS: in hashtable lookup, retry serveral entrie=
s if
> + * there is a collision.
> + */
> +#define DEDUP_STACK_HASH 32768
> +#define DEDUP_STACK_ENTRIES (DEDUP_STACK_HASH/sizeof(struct task_stack))
> +#define DEDUP_HASH_MAX_ITERATIONS 10
> +
> +/*
> + * The data structure of each hashtable entry
> + */
> +struct task_stack {
> + =A0 =A0 =A0 /* the pid of the task of the stack trace */
> + =A0 =A0 =A0 pid_t pid;
> +
> + =A0 =A0 =A0 /* the length of the stack entries */
> + =A0 =A0 =A0 int len;
> +
> + =A0 =A0 =A0 /* the hash value of the stack trace*/
> + =A0 =A0 =A0 unsigned long hash;
> +};
> +
> +static struct task_stack stack_hash_table[DEDUP_STACK_ENTRIES];
> +static struct task_stack cur_stack;
> +static __cacheline_aligned_in_smp DEFINE_SPINLOCK(stack_hash_lock);
> +
> +/*
> + * The stack hashtable uses linear probing to resolve collisions.
> + * We consider two stacks to be the same if their hash values and length=
s
> + * are equal.
> + */
> +static unsigned int stack_trace_lookup(void)
> +{
> + =A0 =A0 =A0 int j;
> + =A0 =A0 =A0 int index;
> + =A0 =A0 =A0 unsigned int ret =3D 0;
> + =A0 =A0 =A0 struct task_stack *stack;
> +
> + =A0 =A0 =A0 index =3D cur_stack.hash % DEDUP_STACK_ENTRIES;
> +
> + =A0 =A0 =A0 for (j =3D 0; j < DEDUP_HASH_MAX_ITERATIONS; j++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stack =3D stack_hash_table + (index + j) % =
DEDUP_STACK_ENTRIES;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (stack->hash =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *stack =3D cur_stack;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (stack->hash =3D=3D cur_=
stack.hash &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stack->len =3D=3D c=
ur_stack.len) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D sta=
ck->pid;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (j =3D=3D DEDUP_HASH_MAX_ITERATIONS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stack_hash_table[index] =3D cur_stack;
> +
> + =A0 =A0 =A0 memset(&cur_stack, 0, sizeof(cur_stack));
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static int save_dup_stack_stack(void *data, char *name)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void save_dup_stack_address(void *data, unsigned long addr, int r=
eliable)
> +{
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* To improve de-duplication, we'll only record reliable =
entries
> + =A0 =A0 =A0 =A0* in the stack trace.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!reliable)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 cur_stack.hash =3D jhash(&addr, sizeof(addr), cur_stack.has=
h);
> + =A0 =A0 =A0 cur_stack.len++;
> +}
> +
> +static const struct stacktrace_ops save_dup_stack_ops =3D {
> + =A0 =A0 =A0 .stack =3D save_dup_stack_stack,
> + =A0 =A0 =A0 .address =3D save_dup_stack_address,
> + =A0 =A0 =A0 .walk_stack =3D print_context_stack,
> +};
> +
> +/*
> + * Clear previously saved stack traces to ensure that later printed stac=
ks do
> + * not reference previously printed stacks.
> + */
> +void clear_dup_stack_traces(void)
> +{
> + =A0 =A0 =A0 memset(stack_hash_table, 0, sizeof(stack_hash_table));
> +}
> +
> +unsigned int save_dup_stack_trace(struct task_struct *tsk)
> +{
> + =A0 =A0 =A0 unsigned int ret =3D 0;
> + =A0 =A0 =A0 unsigned int dummy =3D 0;
> +
> + =A0 =A0 =A0 spin_lock(&stack_hash_lock);
> + =A0 =A0 =A0 dump_trace(tsk, NULL, NULL, 0, &save_dup_stack_ops, &dummy)=
;
> + =A0 =A0 =A0 cur_stack.pid =3D tsk->pid;
> + =A0 =A0 =A0 ret =3D stack_trace_lookup();
> + =A0 =A0 =A0 spin_unlock(&stack_hash_lock);
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> =A0/* Userspace stacktrace - based on kernel/trace/trace_sysprof.c */
>
> =A0struct stack_frame_user {
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 2234985..0f8af97 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -299,6 +299,9 @@ extern void show_regs(struct pt_regs *);
> =A0*/
> =A0extern void show_stack(struct task_struct *task, unsigned long *sp);
>
> +extern void show_stack_dedup(struct task_struct *task, unsigned long *sp=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pid_t dup_s=
tack_pid);
> +
> =A0void io_schedule(void);
> =A0long io_schedule_timeout(long timeout);
>
> diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
> index 115b570..c137416 100644
> --- a/include/linux/stacktrace.h
> +++ b/include/linux/stacktrace.h
> @@ -21,6 +21,8 @@ extern void save_stack_trace_tsk(struct task_struct *ts=
k,
>
> =A0extern void print_stack_trace(struct stack_trace *trace, int spaces);
>
> +extern void clear_dup_stack_traces(void);
> +extern unsigned int save_dup_stack_trace(struct task_struct *tsk);
> =A0#ifdef CONFIG_USER_STACKTRACE_SUPPORT
> =A0extern void save_stack_trace_user(struct stack_trace *trace);
> =A0#else
> @@ -32,6 +34,8 @@ extern void save_stack_trace_user(struct stack_trace *t=
race);
> =A0# define save_stack_trace_tsk(tsk, trace) =A0 =A0 =A0 =A0 =A0 =A0 =A0d=
o { } while (0)
> =A0# define save_stack_trace_user(trace) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0do { } while (0)
> =A0# define print_stack_trace(trace, spaces) =A0 =A0 =A0 =A0 =A0 =A0 =A0d=
o { } while (0)
> +# define clear_dup_stack_traces() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0do { } while (0)
> +# define save_dup_stack_trace(tsk) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 do { } while (0)
> =A0#endif
>
> =A0#endif
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index df00cb0..b2b9f7d 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -71,6 +71,7 @@
> =A0#include <linux/ftrace.h>
> =A0#include <linux/slab.h>
> =A0#include <linux/init_task.h>
> +#include <linux/stacktrace.h>
>
> =A0#include <asm/tlb.h>
> =A0#include <asm/irq_regs.h>
> @@ -4763,10 +4764,11 @@ out_unlock:
>
> =A0static const char stat_nam[] =3D TASK_STATE_TO_CHAR_STR;
>
> -void sched_show_task(struct task_struct *p)
> +void _sched_show_task(struct task_struct *p, int dedup)
> =A0{
> =A0 =A0 =A0 =A0unsigned long free =3D 0;
> =A0 =A0 =A0 =A0unsigned state;
> + =A0 =A0 =A0 pid_t dup_stack_pid =3D 0;
>
> =A0 =A0 =A0 =A0state =3D p->state ? __ffs(p->state) + 1 : 0;
> =A0 =A0 =A0 =A0printk(KERN_INFO "%-15.15s %c", p->comm,
> @@ -4789,13 +4791,37 @@ void sched_show_task(struct task_struct *p)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task_pid_nr(p), task_pid_nr(rcu_dereferenc=
e(p->real_parent)),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long)task_thread_info(p)->flags)=
;
>
> - =A0 =A0 =A0 show_stack(p, NULL);
> + =A0 =A0 =A0 if (dedup) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dup_stack_pid =3D save_dup_stack_trace(p);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 show_stack_dedup(p, NULL, dup_stack_pid);
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 show_stack(p, NULL);
> +}
> +
> +void sched_show_task(struct task_struct *p)
> +{
> + =A0 =A0 =A0 _sched_show_task(p, 0);
> +}
> +
> +/*
> + * Eliminate task stack trace duplication in multi-task stackdump.
> + * Note only x86-specific code now implements the feature.
> + */
> +void sched_show_task_dedup(struct task_struct *p)
> +{
> + =A0 =A0 =A0 _sched_show_task(p, 1);
> =A0}
>
> =A0void show_state_filter(unsigned long state_filter)
> =A0{
> =A0 =A0 =A0 =A0struct task_struct *g, *p;
>
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Prevent below printed stack traces from referring to p=
reviously
> + =A0 =A0 =A0 =A0* printed ones.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 clear_dup_stack_traces();
> +
> =A0#if BITS_PER_LONG =3D=3D 32
> =A0 =A0 =A0 =A0printk(KERN_INFO
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0task =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0P=
C stack =A0 pid father\n");
> @@ -4811,7 +4837,7 @@ void show_state_filter(unsigned long state_filter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0touch_nmi_watchdog();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!state_filter || (p->state & state_fil=
ter))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sched_show_task(p);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sched_show_task_dedup(p);
> =A0 =A0 =A0 =A0} while_each_thread(g, p);
>
> =A0 =A0 =A0 =A0touch_all_softlockup_watchdogs();
> diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
> index 00fe55c..85afece 100644
> --- a/kernel/stacktrace.c
> +++ b/kernel/stacktrace.c
> @@ -41,3 +41,18 @@ save_stack_trace_regs(struct pt_regs *regs, struct sta=
ck_trace *trace)
> =A0{
> =A0 =A0 =A0 =A0WARN_ONCE(1, KERN_INFO "save_stack_trace_regs() not implem=
ented yet.\n");
> =A0}
> +
> +/*
> + * Architectures that do not implement the task stack dedup will fallbac=
k to
> + * the default functionality.
> + */
> +__weak void
> +clear_dup_stack_traces(void)
> +{
> +}
> +
> +__weak unsigned int
> +save_dup_stack_trace(struct task_struct *tsk)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> --
> 1.7.7.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
