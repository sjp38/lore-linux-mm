Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id mB96f6Ur010932
	for <linux-mm@kvack.org>; Mon, 8 Dec 2008 22:41:06 -0800
Received: from rv-out-0506.google.com (rvbf6.prod.google.com [10.140.82.6])
	by wpaz13.hot.corp.google.com with ESMTP id mB96f4YP013876
	for <linux-mm@kvack.org>; Mon, 8 Dec 2008 22:41:05 -0800
Received: by rv-out-0506.google.com with SMTP id f6so1654806rvb.53
        for <linux-mm@kvack.org>; Mon, 08 Dec 2008 22:41:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081208110511.ad735d14.nishimura@mxp.nes.nec.co.jp>
References: <20081208105824.f8f5d67b.nishimura@mxp.nes.nec.co.jp>
	 <20081208110511.ad735d14.nishimura@mxp.nes.nec.co.jp>
Date: Mon, 8 Dec 2008 22:41:04 -0800
Message-ID: <6599ad830812082241v1790eb7dq65caf512451c3af@mail.gmail.com>
Subject: Re: [PATCH -mmotm 3/4] memcg: avoid dead lock caused by race between
	oom and cpuset_attach
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, Dec 7, 2008 at 6:05 PM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> mpol_rebind_mm(), which can be called from cpuset_attach(), does down_write(mm->mmap_sem).
> This means down_write(mm->mmap_sem) can be called under cgroup_mutex.
>
> OTOH, page fault path does down_read(mm->mmap_sem) and calls mem_cgroup_try_charge_xxx(),
> which may eventually calls mem_cgroup_out_of_memory(). And mem_cgroup_out_of_memory()
> calls cgroup_lock().
> This means cgroup_lock() can be called under down_read(mm->mmap_sem).

We should probably try to get cgroup_lock() out of the cpuset code
that calls mpol_rebind_mm() as well.

Paul

>
> If those two paths race, dead lock can happen.
>
> This patch avoid this dead lock by:
>  - remove cgroup_lock() from mem_cgroup_out_of_memory().
>  - define new mutex (memcg_tasklist) and serialize mem_cgroup_move_task()
>    (->attach handler of memory cgroup) and mem_cgroup_out_of_memory.
>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu,com>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
>  mm/memcontrol.c |    5 +++++
>  mm/oom_kill.c   |    2 --
>  2 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9877b03..fec4fc3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -51,6 +51,7 @@ static int really_do_swap_account __initdata = 1; /* for remember boot option*/
>  #define do_swap_account                (0)
>  #endif
>
> +static DEFINE_MUTEX(memcg_tasklist);   /* can be hold under cgroup_mutex */
>
>  /*
>  * Statistics for memory cgroup.
> @@ -797,7 +798,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>
>                if (!nr_retries--) {
>                        if (oom) {
> +                               mutex_lock(&memcg_tasklist);
>                                mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
> +                               mutex_unlock(&memcg_tasklist);
>                                mem_over_limit->last_oom_jiffies = jiffies;
>                        }
>                        goto nomem;
> @@ -2173,10 +2176,12 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
>                                struct cgroup *old_cont,
>                                struct task_struct *p)
>  {
> +       mutex_lock(&memcg_tasklist);
>        /*
>         * FIXME: It's better to move charges of this process from old
>         * memcg to new memcg. But it's just on TODO-List now.
>         */
> +       mutex_unlock(&memcg_tasklist);
>  }
>
>  struct cgroup_subsys mem_cgroup_subsys = {
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index fd150e3..40ba050 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -429,7 +429,6 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>        unsigned long points = 0;
>        struct task_struct *p;
>
> -       cgroup_lock();
>        read_lock(&tasklist_lock);
>  retry:
>        p = select_bad_process(&points, mem);
> @@ -444,7 +443,6 @@ retry:
>                goto retry;
>  out:
>        read_unlock(&tasklist_lock);
> -       cgroup_unlock();
>  }
>  #endif
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
