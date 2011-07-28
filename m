Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EC0256B016B
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 17:15:00 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p6SLEuvN013217
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 14:14:56 -0700
Received: from yxl31 (yxl31.prod.google.com [10.190.3.223])
	by kpbe16.cbf.corp.google.com with ESMTP id p6SLEpbw004743
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 14:14:55 -0700
Received: by yxl31 with SMTP id 31so2430155yxl.41
        for <linux-mm@kvack.org>; Thu, 28 Jul 2011 14:14:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110727161936.e6ab9299.akpm@linux-foundation.org>
References: <1311103882-13544-1-git-send-email-abrestic@google.com>
	<20110727161936.e6ab9299.akpm@linux-foundation.org>
Date: Thu, 28 Jul 2011 14:14:54 -0700
Message-ID: <CAL1qeaH7Uo+xpzy46eXq8Lt=4OUU9Epr7_XJjtomTk1njtnqNQ@mail.gmail.com>
Subject: Re: [PATCH V4] Eliminate task stack trace duplication.
From: Andrew Bresticker <abrestic@google.com>
Content-Type: multipart/alternative; boundary=001636c9267008bbcb04a927a892
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org, Ying Han <yinghan@google.com>

--001636c9267008bbcb04a927a892
Content-Type: text/plain; charset=ISO-8859-1

Hi Andrew,

Thanks for reviewing the patch!

On Wed, Jul 27, 2011 at 4:19 PM, Andrew Morton <akpm@linux-foundation.org>wrote:

> On Tue, 19 Jul 2011 12:31:22 -0700
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
> That looks nice.
>
> > ...
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > Signed-off-by: Andrew Bresticker <abrestic@google.com>
> > ---
> >  arch/x86/Kconfig                  |    3 +
> >  arch/x86/include/asm/stacktrace.h |    6 ++-
> >  arch/x86/kernel/dumpstack.c       |   24 ++++++--
> >  arch/x86/kernel/dumpstack_32.c    |    7 ++-
> >  arch/x86/kernel/dumpstack_64.c    |   11 +++-
> >  arch/x86/kernel/stacktrace.c      |  106
> +++++++++++++++++++++++++++++++++++++
> >  drivers/tty/sysrq.c               |    2 +-
> >  include/linux/sched.h             |    3 +-
> >  include/linux/stacktrace.h        |    2 +
> >  kernel/debug/kdb/kdb_bt.c         |    8 ++--
> >  kernel/rtmutex-debug.c            |    2 +-
> >  kernel/sched.c                    |   20 ++++++-
> >  kernel/stacktrace.c               |   10 ++++
> >  13 files changed, 180 insertions(+), 24 deletions(-)
>
> This is all pretty x86-centric.  I wonder if the code could/should be
> implemented in a fashion whcih would permit other architectures to use
> it?
>

With this interface we would need to modify show_stack() on each
architecture since we added the dup_stack_pid argument.  I'll look into
changing the interface so that we don't have to do this.  Do you have any
suggestions?


> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -103,6 +103,9 @@ config LOCKDEP_SUPPORT
> >  config STACKTRACE_SUPPORT
> >       def_bool y
> >
> > +config STACKTRACE
> > +     def_bool y
> > +
>
> What's this change for?
>

We don't need this any more.  I'll get rid of it.


>
> >  config HAVE_LATENCYTOP_SUPPORT
> >       def_bool y
> >
> >
> > ...
> >
> > +static unsigned int stack_trace_lookup(int len)
> > +{
> > +     int j;
> > +     int index = 0;
> > +     unsigned int ret = 0;
> > +     struct task_stack *stack;
> > +
> > +     index = task_stack_hash(cur_stack, len) % DEDUP_STACK_LAST_ENTRY;
> > +
> > +     for (j = 0; j < DEDUP_HASH_MAX_ITERATIONS; j++) {
> > +             stack = stack_hash_table + (index + (1 << j)) %
> > +                                             DEDUP_STACK_LAST_ENTRY;
> > +             if (stack->entries[0] == 0x0) {
> > +                     memcpy(stack, cur_stack, sizeof(*cur_stack));
> > +                     ret = 0;
> > +                     break;
> > +             } else {
> > +                     if (memcmp(stack->entries, cur_stack->entries,
> > +                                             sizeof(stack->entries)) ==
> 0) {
> > +                             ret = stack->pid;
> > +                             break;
> > +                     }
> > +             }
> > +     }
> > +     memset(cur_stack, 0, sizeof(struct task_stack));
> > +
> > +     return ret;
> > +}
>
> I can kinda see what this function is doing - maintaining an LRU ring
> of task stacks.  Or something.  I didn't look very hard because I
> shouldn't have to ;) Please comment this function: tell us what it's
> doing and why it's doing it?
>
> What surprises me about this patch is that it appears to be maintaining
> an array of entire stack traces.  Why not just generate a good hash of
> the stack contents and assume that if one task's hash is equal to
> another tasks's hash, then the two tasks have the same stack trace?
>
> That way,
>
> struct task_stack {
>        pid_t pid;
>        unsigned long entries[DEDUP_MAX_STACK_DEPTH];
> };
>
> becomes
>
> struct task_stack {
>        pid_t pid;
>         unsigned long stack_hash;
> };
>

I'll clean this up for the next version.


>
> >
> > ...
> >
>

Thanks,
Andrew

--001636c9267008bbcb04a927a892
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Andrew,<div><br></div><div>Thanks for reviewing the patch!<br><br><div c=
lass=3D"gmail_quote">On Wed, Jul 27, 2011 at 4:19 PM, Andrew Morton <span d=
ir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org">akpm@linux-foun=
dation.org</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div><div></div><div class=3D"h5">On Tue, 1=
9 Jul 2011 12:31:22 -0700<br>
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
</div></div>That looks nice.<br>
<br>
&gt; ...<br>
<div class=3D"im">&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; Signed-off-by: Andrew Bresticker &lt;<a href=3D"mailto:abrestic@google=
.com">abrestic@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0arch/x86/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +<br=
>
&gt; =A0arch/x86/include/asm/stacktrace.h | =A0 =A06 ++-<br>
&gt; =A0arch/x86/kernel/dumpstack.c =A0 =A0 =A0 | =A0 24 ++++++--<br>
&gt; =A0arch/x86/kernel/dumpstack_32.c =A0 =A0| =A0 =A07 ++-<br>
&gt; =A0arch/x86/kernel/dumpstack_64.c =A0 =A0| =A0 11 +++-<br>
&gt; =A0arch/x86/kernel/stacktrace.c =A0 =A0 =A0| =A0106 ++++++++++++++++++=
+++++++++++++++++++<br>
&gt; =A0drivers/tty/sysrq.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-<br>
&gt; =A0include/linux/sched.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-<br>
&gt; =A0include/linux/stacktrace.h =A0 =A0 =A0 =A0| =A0 =A02 +<br>
&gt; =A0kernel/debug/kdb/kdb_bt.c =A0 =A0 =A0 =A0 | =A0 =A08 ++--<br>
&gt; =A0kernel/rtmutex-debug.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-<br>
&gt; =A0kernel/sched.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 20 ++++=
++-<br>
&gt; =A0kernel/stacktrace.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 10 ++++<br>
&gt; =A013 files changed, 180 insertions(+), 24 deletions(-)<br>
<br>
</div>This is all pretty x86-centric. =A0I wonder if the code could/should =
be<br>
implemented in a fashion whcih would permit other architectures to use<br>
it?<br></blockquote><div><br></div><div>With this interface we would need t=
o modify show_stack() on each architecture since we added the dup_stack_pid=
 argument. =A0I&#39;ll look into changing the interface so that we don&#39;=
t have to do this. =A0Do you have any suggestions?</div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; --- a/arch/x86/Kconfig<br>
&gt; +++ b/arch/x86/Kconfig<br>
&gt; @@ -103,6 +103,9 @@ config LOCKDEP_SUPPORT<br>
&gt; =A0config STACKTRACE_SUPPORT<br>
&gt; =A0 =A0 =A0 def_bool y<br>
&gt;<br>
&gt; +config STACKTRACE<br>
&gt; + =A0 =A0 def_bool y<br>
&gt; +<br>
<br>
</div>What&#39;s this change for?<br></blockquote><div><br></div><div>We do=
n&#39;t need this any more. =A0I&#39;ll get rid of it.</div><div>=A0</div><=
blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px=
 #ccc solid;padding-left:1ex;">

<div class=3D"im"><br>
&gt; =A0config HAVE_LATENCYTOP_SUPPORT<br>
&gt; =A0 =A0 =A0 def_bool y<br>
&gt;<br>
&gt;<br>
</div>&gt; ...<br>
<div class=3D"im">&gt;<br>
&gt; +static unsigned int stack_trace_lookup(int len)<br>
&gt; +{<br>
&gt; + =A0 =A0 int j;<br>
&gt; + =A0 =A0 int index =3D 0;<br>
&gt; + =A0 =A0 unsigned int ret =3D 0;<br>
&gt; + =A0 =A0 struct task_stack *stack;<br>
&gt; +<br>
&gt; + =A0 =A0 index =3D task_stack_hash(cur_stack, len) % DEDUP_STACK_LAST=
_ENTRY;<br>
&gt; +<br>
&gt; + =A0 =A0 for (j =3D 0; j &lt; DEDUP_HASH_MAX_ITERATIONS; j++) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 stack =3D stack_hash_table + (index + (1 &lt=
;&lt; j)) %<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 DEDUP_STACK_LAST_ENTRY;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (stack-&gt;entries[0] =3D=3D 0x0) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(stack, cur_stack, siz=
eof(*cur_stack));<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memcmp(stack-&gt;entries=
, cur_stack-&gt;entries,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 sizeof(stack-&gt;entries)) =3D=3D 0) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D stac=
k-&gt;pid;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 memset(cur_stack, 0, sizeof(struct task_stack));<br>
&gt; +<br>
&gt; + =A0 =A0 return ret;<br>
&gt; +}<br>
<br>
</div>I can kinda see what this function is doing - maintaining an LRU ring=
<br>
of task stacks. =A0Or something. =A0I didn&#39;t look very hard because I<b=
r>
shouldn&#39;t have to ;) Please comment this function: tell us what it&#39;=
s<br>
doing and why it&#39;s doing it?<br>
<br>
What surprises me about this patch is that it appears to be maintaining<br>
an array of entire stack traces. =A0Why not just generate a good hash of<br=
>
the stack contents and assume that if one task&#39;s hash is equal to<br>
another tasks&#39;s hash, then the two tasks have the same stack trace?<br>
<br>
That way,<br>
<div class=3D"im"><br>
struct task_stack {<br>
 =A0 =A0 =A0 =A0pid_t pid;<br>
 =A0 =A0 =A0 =A0unsigned long entries[DEDUP_MAX_STACK_DEPTH];<br>
</div>};<br>
<br>
becomes<br>
<div class=3D"im"><br>
struct task_stack {<br>
 =A0 =A0 =A0 =A0pid_t pid;<br>
</div> =A0 =A0 =A0 =A0unsigned long stack_hash;<br>
};<br></blockquote><div><br></div><div>I&#39;ll clean this up for the next =
version.</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"marg=
in:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
&gt;<br>
&gt; ...<br>
&gt;<br></blockquote><div><br></div><div>Thanks,</div><div>Andrew=A0</div><=
/div><br></div>

--001636c9267008bbcb04a927a892--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
