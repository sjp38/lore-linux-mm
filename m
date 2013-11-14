Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6946B0055
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 08:43:07 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lf10so2093456pab.36
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 05:43:07 -0800 (PST)
Received: from psmtp.com ([74.125.245.117])
        by mx.google.com with SMTP id tu7si28033605pab.191.2013.11.14.05.43.05
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 05:43:06 -0800 (PST)
Received: by mail-vc0-f170.google.com with SMTP id hv10so697473vcb.29
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 05:43:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1384363093-8025-1-git-send-email-snanda@chromium.org>
References: <CANMivWaXE=bn4fhvGdz3cPwN+CZpWwrWqmU1BKX8o+vE2JawOw@mail.gmail.com>
	<1384363093-8025-1-git-send-email-snanda@chromium.org>
Date: Thu, 14 Nov 2013 17:43:03 +0400
Message-ID: <CAMw+i9hi9pBPkfWHo3mh0=PATQFzbNOCSPaLkw+zqUvwK2wbxA@mail.gmail.com>
Subject: Re: [PATCH v6] mm, oom: Fix race when selecting process to kill
From: dserrg <dserrg@gmail.com>
Content-Type: multipart/alternative; boundary=089e0160caaec96d5a04eb234227
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sameer Nanda <snanda@chromium.org>
Cc: rusty@rustcorp.com.au, hannes@cmpxchg.org, msb@chromium.org, oleg@redhat.com, =?KOI8-R?B?7dXS2snOIPfMwcTJzcnS?= <murzin.v@gmail.com>, linux-mm@kvack.org, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, semenzato@google.com, linux-kernel@vger.kernel.org

--089e0160caaec96d5a04eb234227
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: quoted-printable

(sorry for html)

Why do we even bother with locking?
Why not just merge my original patch? (The link is in Vladimir's message)
It provides much more elegant (and working!) solution for this problem.
David, how did you miss it in the first place?

Oh.. and by the way. I was hitting the same bug in other
while_each_thread loops in oom_kill.c. Anyway, goodluck ;)
14 =CE=CF=D1=C2. 2013 =C7. 2:18 =D0=CF=CC=D8=DA=CF=D7=C1=D4=C5=CC=D8 "Samee=
r Nanda" <snanda@chromium.org>
=CE=C1=D0=C9=D3=C1=CC:

> The selection of the process to be killed happens in two spots:
> first in select_bad_process and then a further refinement by
> looking for child processes in oom_kill_process. Since this is
> a two step process, it is possible that the process selected by
> select_bad_process may get a SIGKILL just before oom_kill_process
> executes. If this were to happen, __unhash_process deletes this
> process from the thread_group list. This results in oom_kill_process
> getting stuck in an infinite loop when traversing the thread_group
> list of the selected process.
>
> Fix this race by adding a pid_alive check for the selected process
> with tasklist_lock held in oom_kill_process.
>
> Signed-off-by: Sameer Nanda <snanda@chromium.org>
> ---
>  include/linux/sched.h |  5 +++++
>  mm/oom_kill.c         | 34 +++++++++++++++++++++-------------
>  2 files changed, 26 insertions(+), 13 deletions(-)
>
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index e27baee..8975dbb 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2156,6 +2156,11 @@ extern bool current_is_single_threaded(void);
>  #define do_each_thread(g, t) \
>         for (g =3D t =3D &init_task ; (g =3D t =3D next_task(g)) !=3D &in=
it_task ; )
> do
>
> +/*
> + * Careful: while_each_thread is not RCU safe. Callers should hold
> + * read_lock(tasklist_lock) across while_each_thread loops.
> + */
> +
>  #define while_each_thread(g, t) \
>         while ((t =3D next_thread(t)) !=3D g)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 6738c47..0d1f804 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -412,31 +412,33 @@ void oom_kill_process(struct task_struct *p, gfp_t
> gfp_mask, int order,
>         static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>                                               DEFAULT_RATELIMIT_BURST);
>
> +       if (__ratelimit(&oom_rs))
> +               dump_header(p, gfp_mask, order, memcg, nodemask);
> +
> +       task_lock(p);
> +       pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
> +               message, task_pid_nr(p), p->comm, points);
> +       task_unlock(p);
> +
> +       read_lock(&tasklist_lock);
> +
>         /*
>          * If the task is already exiting, don't alarm the sysadmin or ki=
ll
>          * its children or threads, just set TIF_MEMDIE so it can die
> quickly
>          */
> -       if (p->flags & PF_EXITING) {
> +       if (p->flags & PF_EXITING || !pid_alive(p)) {
>                 set_tsk_thread_flag(p, TIF_MEMDIE);
>                 put_task_struct(p);
> +               read_unlock(&tasklist_lock);
>                 return;
>         }
>
> -       if (__ratelimit(&oom_rs))
> -               dump_header(p, gfp_mask, order, memcg, nodemask);
> -
> -       task_lock(p);
> -       pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
> -               message, task_pid_nr(p), p->comm, points);
> -       task_unlock(p);
> -
>         /*
>          * If any of p's children has a different mm and is eligible for
> kill,
>          * the one with the highest oom_badness() score is sacrificed for
> its
>          * parent.  This attempts to lose the minimal amount of work done
> while
>          * still freeing memory.
>          */
> -       read_lock(&tasklist_lock);
>         do {
>                 list_for_each_entry(child, &t->children, sibling) {
>                         unsigned int child_points;
> @@ -456,12 +458,17 @@ void oom_kill_process(struct task_struct *p, gfp_t
> gfp_mask, int order,
>                         }
>                 }
>         } while_each_thread(p, t);
> -       read_unlock(&tasklist_lock);
>
> -       rcu_read_lock();
>         p =3D find_lock_task_mm(victim);
> +
> +       /*
> +        * Since while_each_thread is currently not RCU safe, this unlock
> of
> +        * tasklist_lock may need to be moved further down if any
> additional
> +        * while_each_thread loops get added to this function.
> +        */
> +       read_unlock(&tasklist_lock);
> +
>         if (!p) {
> -               rcu_read_unlock();
>                 put_task_struct(victim);
>                 return;
>         } else if (victim !=3D p) {
> @@ -487,6 +494,7 @@ void oom_kill_process(struct task_struct *p, gfp_t
> gfp_mask, int order,
>          * That thread will now get access to memory reserves since it ha=
s
> a
>          * pending fatal signal.
>          */
> +       rcu_read_lock();
>         for_each_process(p)
>                 if (p->mm =3D=3D mm && !same_thread_group(p, victim) &&
>                     !(p->flags & PF_KTHREAD)) {
> --
> 1.8.4.1
>
>

--089e0160caaec96d5a04eb234227
Content-Type: text/html; charset=KOI8-R
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">(sorry for html)</p>
<p dir=3D"ltr">Why do we even bother with locking?<br>
Why not just merge my original patch? (The link is in Vladimir&#39;s messag=
e)<br>
It provides much more elegant (and working!) solution for this problem.<br>
David, how did you miss it in the first place?</p>
<p dir=3D"ltr">Oh.. and by the way. I was hitting the same bug in other<br>
while_each_thread loops in oom_kill.c. Anyway, goodluck ;)</p>
<div class=3D"gmail_quote">14 =CE=CF=D1=C2. 2013 =C7. 2:18 =D0=CF=CC=D8=DA=
=CF=D7=C1=D4=C5=CC=D8 &quot;Sameer Nanda&quot; &lt;<a href=3D"mailto:snanda=
@chromium.org">snanda@chromium.org</a>&gt; =CE=C1=D0=C9=D3=C1=CC:<br type=
=3D"attribution"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex">
The selection of the process to be killed happens in two spots:<br>
first in select_bad_process and then a further refinement by<br>
looking for child processes in oom_kill_process. Since this is<br>
a two step process, it is possible that the process selected by<br>
select_bad_process may get a SIGKILL just before oom_kill_process<br>
executes. If this were to happen, __unhash_process deletes this<br>
process from the thread_group list. This results in oom_kill_process<br>
getting stuck in an infinite loop when traversing the thread_group<br>
list of the selected process.<br>
<br>
Fix this race by adding a pid_alive check for the selected process<br>
with tasklist_lock held in oom_kill_process.<br>
<br>
Signed-off-by: Sameer Nanda &lt;<a href=3D"mailto:snanda@chromium.org">snan=
da@chromium.org</a>&gt;<br>
---<br>
=9Ainclude/linux/sched.h | =9A5 +++++<br>
=9Amm/oom_kill.c =9A =9A =9A =9A | 34 +++++++++++++++++++++-------------<br=
>
=9A2 files changed, 26 insertions(+), 13 deletions(-)<br>
<br>
diff --git a/include/linux/sched.h b/include/linux/sched.h<br>
index e27baee..8975dbb 100644<br>
--- a/include/linux/sched.h<br>
+++ b/include/linux/sched.h<br>
@@ -2156,6 +2156,11 @@ extern bool current_is_single_threaded(void);<br>
=9A#define do_each_thread(g, t) \<br>
=9A =9A =9A =9A for (g =3D t =3D &amp;init_task ; (g =3D t =3D next_task(g)=
) !=3D &amp;init_task ; ) do<br>
<br>
+/*<br>
+ * Careful: while_each_thread is not RCU safe. Callers should hold<br>
+ * read_lock(tasklist_lock) across while_each_thread loops.<br>
+ */<br>
+<br>
=9A#define while_each_thread(g, t) \<br>
=9A =9A =9A =9A while ((t =3D next_thread(t)) !=3D g)<br>
<br>
diff --git a/mm/oom_kill.c b/mm/oom_kill.c<br>
index 6738c47..0d1f804 100644<br>
--- a/mm/oom_kill.c<br>
+++ b/mm/oom_kill.c<br>
@@ -412,31 +412,33 @@ void oom_kill_process(struct task_struct *p, gfp_t gf=
p_mask, int order,<br>
=9A =9A =9A =9A static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INT=
ERVAL,<br>
=9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A=
 =9A =9A =9A =9A DEFAULT_RATELIMIT_BURST);<br>
<br>
+ =9A =9A =9A if (__ratelimit(&amp;oom_rs))<br>
+ =9A =9A =9A =9A =9A =9A =9A dump_header(p, gfp_mask, order, memcg, nodema=
sk);<br>
+<br>
+ =9A =9A =9A task_lock(p);<br>
+ =9A =9A =9A pr_err(&quot;%s: Kill process %d (%s) score %d or sacrifice c=
hild\n&quot;,<br>
+ =9A =9A =9A =9A =9A =9A =9A message, task_pid_nr(p), p-&gt;comm, points);=
<br>
+ =9A =9A =9A task_unlock(p);<br>
+<br>
+ =9A =9A =9A read_lock(&amp;tasklist_lock);<br>
+<br>
=9A =9A =9A =9A /*<br>
=9A =9A =9A =9A =9A* If the task is already exiting, don&#39;t alarm the sy=
sadmin or kill<br>
=9A =9A =9A =9A =9A* its children or threads, just set TIF_MEMDIE so it can=
 die quickly<br>
=9A =9A =9A =9A =9A*/<br>
- =9A =9A =9A if (p-&gt;flags &amp; PF_EXITING) {<br>
+ =9A =9A =9A if (p-&gt;flags &amp; PF_EXITING || !pid_alive(p)) {<br>
=9A =9A =9A =9A =9A =9A =9A =9A set_tsk_thread_flag(p, TIF_MEMDIE);<br>
=9A =9A =9A =9A =9A =9A =9A =9A put_task_struct(p);<br>
+ =9A =9A =9A =9A =9A =9A =9A read_unlock(&amp;tasklist_lock);<br>
=9A =9A =9A =9A =9A =9A =9A =9A return;<br>
=9A =9A =9A =9A }<br>
<br>
- =9A =9A =9A if (__ratelimit(&amp;oom_rs))<br>
- =9A =9A =9A =9A =9A =9A =9A dump_header(p, gfp_mask, order, memcg, nodema=
sk);<br>
-<br>
- =9A =9A =9A task_lock(p);<br>
- =9A =9A =9A pr_err(&quot;%s: Kill process %d (%s) score %d or sacrifice c=
hild\n&quot;,<br>
- =9A =9A =9A =9A =9A =9A =9A message, task_pid_nr(p), p-&gt;comm, points);=
<br>
- =9A =9A =9A task_unlock(p);<br>
-<br>
=9A =9A =9A =9A /*<br>
=9A =9A =9A =9A =9A* If any of p&#39;s children has a different mm and is e=
ligible for kill,<br>
=9A =9A =9A =9A =9A* the one with the highest oom_badness() score is sacrif=
iced for its<br>
=9A =9A =9A =9A =9A* parent. =9AThis attempts to lose the minimal amount of=
 work done while<br>
=9A =9A =9A =9A =9A* still freeing memory.<br>
=9A =9A =9A =9A =9A*/<br>
- =9A =9A =9A read_lock(&amp;tasklist_lock);<br>
=9A =9A =9A =9A do {<br>
=9A =9A =9A =9A =9A =9A =9A =9A list_for_each_entry(child, &amp;t-&gt;child=
ren, sibling) {<br>
=9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A unsigned int child_points;<=
br>
@@ -456,12 +458,17 @@ void oom_kill_process(struct task_struct *p, gfp_t gf=
p_mask, int order,<br>
=9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A =9A }<br>
=9A =9A =9A =9A =9A =9A =9A =9A }<br>
=9A =9A =9A =9A } while_each_thread(p, t);<br>
- =9A =9A =9A read_unlock(&amp;tasklist_lock);<br>
<br>
- =9A =9A =9A rcu_read_lock();<br>
=9A =9A =9A =9A p =3D find_lock_task_mm(victim);<br>
+<br>
+ =9A =9A =9A /*<br>
+ =9A =9A =9A =9A* Since while_each_thread is currently not RCU safe, this =
unlock of<br>
+ =9A =9A =9A =9A* tasklist_lock may need to be moved further down if any a=
dditional<br>
+ =9A =9A =9A =9A* while_each_thread loops get added to this function.<br>
+ =9A =9A =9A =9A*/<br>
+ =9A =9A =9A read_unlock(&amp;tasklist_lock);<br>
+<br>
=9A =9A =9A =9A if (!p) {<br>
- =9A =9A =9A =9A =9A =9A =9A rcu_read_unlock();<br>
=9A =9A =9A =9A =9A =9A =9A =9A put_task_struct(victim);<br>
=9A =9A =9A =9A =9A =9A =9A =9A return;<br>
=9A =9A =9A =9A } else if (victim !=3D p) {<br>
@@ -487,6 +494,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_=
mask, int order,<br>
=9A =9A =9A =9A =9A* That thread will now get access to memory reserves sin=
ce it has a<br>
=9A =9A =9A =9A =9A* pending fatal signal.<br>
=9A =9A =9A =9A =9A*/<br>
+ =9A =9A =9A rcu_read_lock();<br>
=9A =9A =9A =9A for_each_process(p)<br>
=9A =9A =9A =9A =9A =9A =9A =9A if (p-&gt;mm =3D=3D mm &amp;&amp; !same_thr=
ead_group(p, victim) &amp;&amp;<br>
=9A =9A =9A =9A =9A =9A =9A =9A =9A =9A !(p-&gt;flags &amp; PF_KTHREAD)) {<=
br>
--<br>
1.8.4.1<br>
<br>
</blockquote></div>

--089e0160caaec96d5a04eb234227--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
