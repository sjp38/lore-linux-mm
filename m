Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 2D4B56B0044
	for <linux-mm@kvack.org>; Tue,  8 May 2012 16:47:04 -0400 (EDT)
Received: by qabg27 with SMTP id g27so1146163qab.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 13:47:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1336448238-3728-1-git-send-email-glommer@parallels.com>
References: <1336448238-3728-1-git-send-email-glommer@parallels.com>
Date: Tue, 8 May 2012 13:47:02 -0700
Message-ID: <CABCjUKAo=guO5GBEiLSyOKbp3tRTpmwWWF0H+FoVqWF=S-JyZQ@mail.gmail.com>
Subject: Re: [RFC] alternative mechanism to skip memcg kmem allocations
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, May 7, 2012 at 8:37 PM, Glauber Costa <glommer@parallels.com> wrote=
:
> Since Kame expressed the wish to see a context-based method to skip
> accounting for caches, I came up with the following proposal for
> your appreciation.
>
> It basically works in the same way as preempt_disable()/preempt_enable():
> By marking a region under which all allocations will be accounted
> to the root memcg.
>
> I basically see two main advantages of it:
>
> =A0* No need to clutter the code with *_noaccount functions; they could
> =A0 become specially widespread if we needed to skip accounting for
> =A0 kmalloc variants like track, zalloc, etc.
> =A0* Works with other caches, not only kmalloc; specially interesting
> =A0 since during cache creation we touch things like cache_cache,
> =A0 that could very well we wrapped inside a noaccount region.
>
> However:
>
> =A0* It touches task_struct
> =A0* It is harder to keep drivers away from using it. With
> =A0 kmalloc_no_account we could simply not export it. Here, one can
> =A0 always set this in the task_struct...
>
> Let me know what you think of it.

I like this idea a lot.

>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Suleiman Souhlal <suleiman@google.com>
> ---
> =A0include/linux/sched.h | =A0 =A01 +
> =A0mm/memcontrol.c =A0 =A0 =A0 | =A0 34 +++++++++++++++++++++++++++++++++=
+
> =A02 files changed, 35 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 81a173c..516a9fe 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1613,6 +1613,7 @@ struct task_struct {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_pages; /* uncharged usage=
 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long memsw_nr_pages; /* uncharged=
 mem+swap usage */
> =A0 =A0 =A0 =A0} memcg_batch;
> + =A0 =A0 =A0 int memcg_kmem_skip_account;
> =A0#endif
> =A0#ifdef CONFIG_HAVE_HW_BREAKPOINT
> =A0 =A0 =A0 =A0atomic_t ptrace_bp_refcnt;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8c7c404..833f4cd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -479,6 +479,33 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup =
*memcg)
> =A0EXPORT_SYMBOL(tcp_proto_cgroup);
> =A0#endif /* CONFIG_INET */
>
> +static void memcg_stop_kmem_account(void)
> +{
> + =A0 =A0 =A0 struct task_struct *p;
> +
> + =A0 =A0 =A0 if (!current->mm)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 p =3D rcu_dereference(current->mm->owner);
> + =A0 =A0 =A0 if (p) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_lock(p);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->memcg_kmem_skip_account =3D true;
> + =A0 =A0 =A0 }

This doesn't seem right. The flag has to be set on current, not on
another task, or weird things will happen (like the flag getting
lost).

Also, we might want to make it a count instead of a boolean, so that
it's possible to nest it.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
