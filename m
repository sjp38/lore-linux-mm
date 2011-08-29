Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 470E0900138
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 03:08:20 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p7T78HWN018514
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:08:17 -0700
Received: from qyk34 (qyk34.prod.google.com [10.241.83.162])
	by wpaz13.hot.corp.google.com with ESMTP id p7T77tHT007039
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:08:16 -0700
Received: by qyk34 with SMTP id 34so3928786qyk.5
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:08:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110826161936.52979754.akpm@linux-foundation.org>
References: <1311902759-14971-1-git-send-email-abrestic@google.com>
	<20110826161936.52979754.akpm@linux-foundation.org>
Date: Mon, 29 Aug 2011 00:08:13 -0700
Message-ID: <CALWz4izx_ErppadXUADRb9ooo+kXGr2uz=WBg-RKXSKcSsj3bg@mail.gmail.com>
Subject: Re: [PATCH V5] Eliminate task stack trace duplication.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00163628429ef3e86304ab9f8e36
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--00163628429ef3e86304ab9f8e36
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Aug 26, 2011 at 4:19 PM, Andrew Morton <akpm@linux-foundation.org>wrote:

> (I'm back!)
>

Thank you Andrew for the comments.

Hmm, Looks like we still need some changes for this patch to get it merged
into -mm and I might be able to jump into it sometime next week. :)

--Ying

>
> On Thu, 28 Jul 2011 18:25:59 -0700
> Andrew Bresticker <abrestic@google.com> wrote:
>
> > The problem with small dmesg ring buffer like 512k is that only limited
> number
> > of task traces will be logged. Sometimes we lose important information
> only
> > because of too many duplicated stack traces. This problem occurs when
> dumping
> > lots of stacks in a single operation, such as sysrq-T.
> >
> > This patch tries to reduce the duplication of task stack trace in the
> dump
> > message by hashing the task stack. The hashtable is a 32k pre-allocated
> buffer
> > during bootup. Then we hash the task stack with stack_depth 32 for each
> stack
> > entry. Each time if we find the identical task trace in the task stack,
> we dump
> > only the pid of the task which has the task trace dumped. So it is easy
> to back
> > track to the full stack with the pid.
> >
> > [   58.469730] kworker/0:0     S 0000000000000000     0     4      2
> 0x00000000
> > [   58.469735]  ffff88082fcfde80 0000000000000046 ffff88082e9d8000
> ffff88082fcfc010
> > [   58.469739]  ffff88082fce9860 0000000000011440 ffff88082fcfdfd8
> ffff88082fcfdfd8
> > [   58.469743]  0000000000011440 0000000000000000 ffff88082fcee180
> ffff88082fce9860
> > [   58.469747] Call Trace:
> > [   58.469751]  [<ffffffff8108525a>] worker_thread+0x24b/0x250
> > [   58.469754]  [<ffffffff8108500f>] ? manage_workers+0x192/0x192
> > [   58.469757]  [<ffffffff810885bd>] kthread+0x82/0x8a
> > [   58.469760]  [<ffffffff8141aed4>] kernel_thread_helper+0x4/0x10
> > [   58.469763]  [<ffffffff8108853b>] ? kthread_worker_fn+0x112/0x112
> > [   58.469765]  [<ffffffff8141aed0>] ? gs_change+0xb/0xb
> > [   58.469768] kworker/u:0     S 0000000000000004     0     5      2
> 0x00000000
> > [   58.469773]  ffff88082fcffe80 0000000000000046 ffff880800000000
> ffff88082fcfe010
> > [   58.469777]  ffff88082fcea080 0000000000011440 ffff88082fcfffd8
> ffff88082fcfffd8
> > [   58.469781]  0000000000011440 0000000000000000 ffff88082fd4e9a0
> ffff88082fcea080
> > [   58.469785] Call Trace:
> > [   58.469786] <Same stack as pid 4>
> > [   58.470235] kworker/0:1     S 0000000000000000     0    13      2
> 0x00000000
> > [   58.470255]  ffff88082fd3fe80 0000000000000046 ffff880800000000
> ffff88082fd3e010
> > [   58.470279]  ffff88082fcee180 0000000000011440 ffff88082fd3ffd8
> ffff88082fd3ffd8
> > [   58.470301]  0000000000011440 0000000000000000 ffffffff8180b020
> ffff88082fcee180
> > [   58.470325] Call Trace:
> > [   58.470332] <Same stack as pid 4>
>
> The code looks OK(ish) to me.  I'm still concerned that the implementation
> will miss lots of de-duplications because it is hashing random crud in
> the stack frame.
>
> > Note: Non-x86 architectures will need to be updated since show_stack()
> > now takes an additional argument.
>
> Well, we can't break all architectures.
>
> I can't think of a way to make the preprocessor convert show_stack(a,
> b) into show_stack(a, b, N) (this can be done in the other direction).
> So all I can think of is to rename x86 show_stack() to something else and
> do
>
> #define show_stack_something_else(a, b, c) show_stack(a, b)
>
> for other architectures.
>
> But on the other hand, why did the show_stack() interface get changed?
> show_stack() dumps a single tasks's stack, so top-level callers have no
> earthly reason to be passing the dup_stack_pid into show_stack().
> dup_stack_pid is purely for many-task stackdumps.
>
> Also, the code as-is is pretty much useless for other architectures.
> The core changes in arch/x86/kernel/stacktrace.c look pretty generic -
> can we design and place this code so that all architectures can use it?
>
>
> > The problem with small dmesg ring buffer like 512k is that only limited
> number
> > of task traces will be logged. Sometimes we lose important information
> only
> > because of too many duplicated stack traces. This problem occurs when
> dumping
> > lots of stacks in a single operation, such as sysrq-T.
> >
> > This patch tries to reduce the duplication of task stack trace in the
> dump
> > message by hashing the task stack. The hashtable is a 32k pre-allocated
> buffer
> > during bootup. Then we hash the task stack with stack_depth 32 for each
> stack
> > entry. Each time if we find the identical task trace in the task stack,
> we dump
> > only the pid of the task which has the task trace dumped. So it is easy
> to back
> > track to the full stack with the pid.
> >
> >
> > ...
> >
> > +/*
> > + * The implementation of stack trace dedup. It tries to reduce the
> duplication
> > + * of task stack trace in the dump by hashing the stack trace. The
> hashtable is
> > + * 32k pre-allocated buffer. Then we hash the task stack with
> stack_depth
> > + * DEDUP_MAX_STACK_DEPTH for each stack entry. Each time if an identical
> trace
> > + * is found in the stack, we dump only the pid of previous task. So it
> is easy
> > + * to back track to the full stack with the pid.
> > + */
> > +#define DEDUP_MAX_STACK_DEPTH 32
> > +#define DEDUP_STACK_HASH 32768
> > +#define DEDUP_STACK_ENTRIES (DEDUP_STACK_HASH/sizeof(struct task_stack))
> > +#define DEDUP_HASH_MAX_ITERATIONS 10
>
> It wouldn't hurt to document DEDUP_HASH_MAX_ITERATIONS (at least).
>
> But then, why does DEDUP_HASH_MAX_ITERATIONS exist? (below)
>
> > +struct task_stack {
> > +     pid_t pid;
> > +     int len;
> > +     unsigned long hash;
> > +};
> > +
> > +static struct task_stack stack_hash_table[DEDUP_STACK_ENTRIES];
> > +static struct task_stack cur_stack;
> > +static __cacheline_aligned_in_smp DEFINE_SPINLOCK(stack_hash_lock);
> > +
> > +/*
> > + * The stack hashtable uses linear probing to resolve collisions.
> > + * We consider two stacks to be the same if their hash values and
> lengths
> > + * are equal.
> > + */
> > +static unsigned int stack_trace_lookup(void)
> > +{
> > +     int j;
> > +     int index;
> > +     unsigned int ret = 0;
> > +     struct task_stack *stack;
> > +
> > +     index = cur_stack.hash % DEDUP_STACK_ENTRIES;
> > +
> > +     for (j = 0; j < DEDUP_HASH_MAX_ITERATIONS; j++) {
> > +             stack = stack_hash_table + (index + j) %
> DEDUP_STACK_ENTRIES;
>
> (this would be more efficient if DEDUP_STACK_ENTRIES was a power of 2)
>
> > +             if (stack->hash == 0) {
> > +                     *stack = cur_stack;
> > +                     ret = 0;
> > +                     break;
> > +             } else {
> > +                     if (stack->hash == cur_stack.hash &&
> > +                         stack->len == cur_stack.len) {
> > +                             ret = stack->pid;
> > +                             break;
> > +                     }
> > +             }
> > +     }
> > +     if (j == DEDUP_HASH_MAX_ITERATIONS)
> > +             stack_hash_table[index] = cur_stack;
>
> Why stop there?  Why not just append to stack_hash_table[]?  When we
> first decide to do a multi-task stackdump, zero the index into the
> array.  Each time a task is processed, look to see if it is unique and
> if so, add its task_stack to the end of the array.
>
> This may require adding a stacktrace_ops.start().  This could be done
> while moving stacktrace_ops (which advertises itself as a "Generic
> stack tracer"!) out of x86-specific code.
>
> > +     memset(&cur_stack, 0, sizeof(cur_stack));
>
> Sane, but I'm not sure it's necessary.
>
> > +     return ret;
> > +}
> > +
> >
> > ...
> >
>
> Making this all arch-neutral is quite a bit of work, which you may not
> feel like undertaking, ho hum.  Also, the lack of any documentation in
> that x86 code makes it unready for prime time.
>

--00163628429ef3e86304ab9f8e36
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Aug 26, 2011 at 4:19 PM, Andrew =
Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org">a=
kpm@linux-foundation.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex;">
(I&#39;m back!)<br></blockquote><div><br></div><div>Thank you Andrew for th=
e comments.=A0</div><div><br></div><div>Hmm, Looks like we still need some =
changes for this patch to get it merged into -mm and I might be able to jum=
p into it sometime next week. :)</div>
<div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
On Thu, 28 Jul 2011 18:25:59 -0700<br>
Andrew Bresticker &lt;<a href=3D"mailto:abrestic@google.com">abrestic@googl=
e.com</a>&gt; wrote:<br>
<br>
&gt; The problem with small dmesg ring buffer like 512k is that only limite=
d number<br>
&gt; of task traces will be logged. Sometimes we lose important information=
 only<br>
&gt; because of too many duplicated stack traces. This problem occurs when =
dumping<br>
&gt; lots of stacks in a single operation, such as sysrq-T.<br>
&gt;<br>
&gt; This patch tries to reduce the duplication of task stack trace in the =
dump<br>
&gt; message by hashing the task stack. The hashtable is a 32k pre-allocate=
d buffer<br>
&gt; during bootup. Then we hash the task stack with stack_depth 32 for eac=
h stack<br>
&gt; entry. Each time if we find the identical task trace in the task stack=
, we dump<br>
&gt; only the pid of the task which has the task trace dumped. So it is eas=
y to back<br>
&gt; track to the full stack with the pid.<br>
&gt;<br>
&gt; [ =A0 58.469730] kworker/0:0 =A0 =A0 S 0000000000000000 =A0 =A0 0 =A0 =
=A0 4 =A0 =A0 =A02 0x00000000<br>
&gt; [ =A0 58.469735] =A0ffff88082fcfde80 0000000000000046 ffff88082e9d8000=
 ffff88082fcfc010<br>
&gt; [ =A0 58.469739] =A0ffff88082fce9860 0000000000011440 ffff88082fcfdfd8=
 ffff88082fcfdfd8<br>
&gt; [ =A0 58.469743] =A00000000000011440 0000000000000000 ffff88082fcee180=
 ffff88082fce9860<br>
&gt; [ =A0 58.469747] Call Trace:<br>
&gt; [ =A0 58.469751] =A0[&lt;ffffffff8108525a&gt;] worker_thread+0x24b/0x2=
50<br>
&gt; [ =A0 58.469754] =A0[&lt;ffffffff8108500f&gt;] ? manage_workers+0x192/=
0x192<br>
&gt; [ =A0 58.469757] =A0[&lt;ffffffff810885bd&gt;] kthread+0x82/0x8a<br>
&gt; [ =A0 58.469760] =A0[&lt;ffffffff8141aed4&gt;] kernel_thread_helper+0x=
4/0x10<br>
&gt; [ =A0 58.469763] =A0[&lt;ffffffff8108853b&gt;] ? kthread_worker_fn+0x1=
12/0x112<br>
&gt; [ =A0 58.469765] =A0[&lt;ffffffff8141aed0&gt;] ? gs_change+0xb/0xb<br>
&gt; [ =A0 58.469768] kworker/u:0 =A0 =A0 S 0000000000000004 =A0 =A0 0 =A0 =
=A0 5 =A0 =A0 =A02 0x00000000<br>
&gt; [ =A0 58.469773] =A0ffff88082fcffe80 0000000000000046 ffff880800000000=
 ffff88082fcfe010<br>
&gt; [ =A0 58.469777] =A0ffff88082fcea080 0000000000011440 ffff88082fcfffd8=
 ffff88082fcfffd8<br>
&gt; [ =A0 58.469781] =A00000000000011440 0000000000000000 ffff88082fd4e9a0=
 ffff88082fcea080<br>
&gt; [ =A0 58.469785] Call Trace:<br>
&gt; [ =A0 58.469786] &lt;Same stack as pid 4&gt;<br>
&gt; [ =A0 58.470235] kworker/0:1 =A0 =A0 S 0000000000000000 =A0 =A0 0 =A0 =
=A013 =A0 =A0 =A02 0x00000000<br>
&gt; [ =A0 58.470255] =A0ffff88082fd3fe80 0000000000000046 ffff880800000000=
 ffff88082fd3e010<br>
&gt; [ =A0 58.470279] =A0ffff88082fcee180 0000000000011440 ffff88082fd3ffd8=
 ffff88082fd3ffd8<br>
&gt; [ =A0 58.470301] =A00000000000011440 0000000000000000 ffffffff8180b020=
 ffff88082fcee180<br>
&gt; [ =A0 58.470325] Call Trace:<br>
&gt; [ =A0 58.470332] &lt;Same stack as pid 4&gt;<br>
<br>
</div></div>The code looks OK(ish) to me. =A0I&#39;m still concerned that t=
he implementation<br>
will miss lots of de-duplications because it is hashing random crud in<br>
the stack frame.<br>
<div class=3D"im"><br>
&gt; Note: Non-x86 architectures will need to be updated since show_stack()=
<br>
&gt; now takes an additional argument.<br>
<br>
</div>Well, we can&#39;t break all architectures.<br>
<br>
I can&#39;t think of a way to make the preprocessor convert show_stack(a,<b=
r>
b) into show_stack(a, b, N) (this can be done in the other direction).<br>
So all I can think of is to rename x86 show_stack() to something else and d=
o<br>
<br>
#define show_stack_something_else(a, b, c) show_stack(a, b)<br>
<br>
for other architectures.<br>
<br>
But on the other hand, why did the show_stack() interface get changed?<br>
show_stack() dumps a single tasks&#39;s stack, so top-level callers have no=
<br>
earthly reason to be passing the dup_stack_pid into show_stack().<br>
dup_stack_pid is purely for many-task stackdumps.<br>
<br>
Also, the code as-is is pretty much useless for other architectures.<br>
The core changes in arch/x86/kernel/stacktrace.c look pretty generic -<br>
can we design and place this code so that all architectures can use it?<br>
<div class=3D"im"><br>
<br>
&gt; The problem with small dmesg ring buffer like 512k is that only limite=
d number<br>
&gt; of task traces will be logged. Sometimes we lose important information=
 only<br>
&gt; because of too many duplicated stack traces. This problem occurs when =
dumping<br>
&gt; lots of stacks in a single operation, such as sysrq-T.<br>
&gt;<br>
&gt; This patch tries to reduce the duplication of task stack trace in the =
dump<br>
&gt; message by hashing the task stack. The hashtable is a 32k pre-allocate=
d buffer<br>
&gt; during bootup. Then we hash the task stack with stack_depth 32 for eac=
h stack<br>
&gt; entry. Each time if we find the identical task trace in the task stack=
, we dump<br>
&gt; only the pid of the task which has the task trace dumped. So it is eas=
y to back<br>
&gt; track to the full stack with the pid.<br>
&gt;<br>
&gt;<br>
</div>&gt; ...<br>
<div class=3D"im">&gt;<br>
&gt; +/*<br>
&gt; + * The implementation of stack trace dedup. It tries to reduce the du=
plication<br>
&gt; + * of task stack trace in the dump by hashing the stack trace. The ha=
shtable is<br>
&gt; + * 32k pre-allocated buffer. Then we hash the task stack with stack_d=
epth<br>
&gt; + * DEDUP_MAX_STACK_DEPTH for each stack entry. Each time if an identi=
cal trace<br>
&gt; + * is found in the stack, we dump only the pid of previous task. So i=
t is easy<br>
&gt; + * to back track to the full stack with the pid.<br>
&gt; + */<br>
&gt; +#define DEDUP_MAX_STACK_DEPTH 32<br>
&gt; +#define DEDUP_STACK_HASH 32768<br>
&gt; +#define DEDUP_STACK_ENTRIES (DEDUP_STACK_HASH/sizeof(struct task_stac=
k))<br>
&gt; +#define DEDUP_HASH_MAX_ITERATIONS 10<br>
<br>
</div>It wouldn&#39;t hurt to document DEDUP_HASH_MAX_ITERATIONS (at least)=
.<br>
<br>
But then, why does DEDUP_HASH_MAX_ITERATIONS exist? (below)<br>
<div class=3D"im"><br>
&gt; +struct task_stack {<br>
&gt; + =A0 =A0 pid_t pid;<br>
&gt; + =A0 =A0 int len;<br>
&gt; + =A0 =A0 unsigned long hash;<br>
&gt; +};<br>
&gt; +<br>
&gt; +static struct task_stack stack_hash_table[DEDUP_STACK_ENTRIES];<br>
&gt; +static struct task_stack cur_stack;<br>
&gt; +static __cacheline_aligned_in_smp DEFINE_SPINLOCK(stack_hash_lock);<b=
r>
&gt; +<br>
&gt; +/*<br>
&gt; + * The stack hashtable uses linear probing to resolve collisions.<br>
&gt; + * We consider two stacks to be the same if their hash values and len=
gths<br>
&gt; + * are equal.<br>
&gt; + */<br>
&gt; +static unsigned int stack_trace_lookup(void)<br>
&gt; +{<br>
&gt; + =A0 =A0 int j;<br>
&gt; + =A0 =A0 int index;<br>
&gt; + =A0 =A0 unsigned int ret =3D 0;<br>
&gt; + =A0 =A0 struct task_stack *stack;<br>
&gt; +<br>
&gt; + =A0 =A0 index =3D cur_stack.hash % DEDUP_STACK_ENTRIES;<br>
&gt; +<br>
&gt; + =A0 =A0 for (j =3D 0; j &lt; DEDUP_HASH_MAX_ITERATIONS; j++) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 stack =3D stack_hash_table + (index + j) % D=
EDUP_STACK_ENTRIES;<br>
<br>
</div>(this would be more efficient if DEDUP_STACK_ENTRIES was a power of 2=
)<br>
<div class=3D"im"><br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (stack-&gt;hash =3D=3D 0) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *stack =3D cur_stack;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (stack-&gt;hash =3D=3D cu=
r_stack.hash &amp;&amp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stack-&gt;len =3D=3D=
 cur_stack.len) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D stac=
k-&gt;pid;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 if (j =3D=3D DEDUP_HASH_MAX_ITERATIONS)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 stack_hash_table[index] =3D cur_stack;<br>
<br>
</div>Why stop there? =A0Why not just append to stack_hash_table[]? =A0When=
 we<br>
first decide to do a multi-task stackdump, zero the index into the<br>
array. =A0Each time a task is processed, look to see if it is unique and<br=
>
if so, add its task_stack to the end of the array.<br>
<br>
This may require adding a stacktrace_ops.start(). =A0This could be done<br>
while moving stacktrace_ops (which advertises itself as a &quot;Generic<br>
stack tracer&quot;!) out of x86-specific code.<br>
<div class=3D"im"><br>
&gt; + =A0 =A0 memset(&amp;cur_stack, 0, sizeof(cur_stack));<br>
<br>
</div>Sane, but I&#39;m not sure it&#39;s necessary.<br>
<br>
&gt; + =A0 =A0 return ret;<br>
&gt; +}<br>
&gt; +<br>
&gt;<br>
&gt; ...<br>
&gt;<br>
<br>
Making this all arch-neutral is quite a bit of work, which you may not<br>
feel like undertaking, ho hum. =A0Also, the lack of any documentation in<br=
>
that x86 code makes it unready for prime time.<br>
</blockquote></div><br>

--00163628429ef3e86304ab9f8e36--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
