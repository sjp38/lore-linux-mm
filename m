Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 213FB6B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 02:57:09 -0500 (EST)
Date: Fri, 6 Nov 2009 16:49:34 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 2/8] memcg: move memcg_tasklist mutex
Message-Id: <20091106164934.b34d342f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091106145459.351b407f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091106141149.9c7e94d5.nishimura@mxp.nes.nec.co.jp>
	<20091106145459.351b407f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009 14:54:59 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 6 Nov 2009 14:11:49 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > memcg_tasklist was introduced to serialize mem_cgroup_out_of_memory() and
> > mem_cgroup_move_task() to ensure tasks cannot be moved to another cgroup
> > during select_bad_process().
> > 
> > task_in_mem_cgroup(), which can be called by select_bad_process(), will check
> > whether a task is in the mem_cgroup or not by dereferencing task->cgroups
> > ->subsys[]. So, it would be desirable to change task->cgroups
> > (rcu_assign_pointer() in cgroup_attach_task() does it) with memcg_tasklist held.
> > 
> > Now that we can define cancel_attach(), we can safely release memcg_tasklist
> > on fail path even if we hold memcg_tasklist in can_attach(). So let's move
> > mutex_lock/unlock() of memcg_tasklist.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |   22 ++++++++++++++++++++--
> >  1 files changed, 20 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 4bd3451..d3b2ac0 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3395,18 +3395,34 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
> >  	return ret;
> >  }
> >  
> > +static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> > +				struct cgroup *cgroup,
> > +				struct task_struct *p,
> > +				bool threadgroup)
> > +{
> > +	mutex_lock(&memcg_tasklist);
> > +	return 0;
> > +}
> 
> Hmm...Is this lock really necessary ?
> IOW, can't we just remove memcg_tasklist mutex ?
> What kind of bad race happens when we remove this ?
> 
It was introduced at commit 7f4d454d, in which I introduced the mutex instead of
using cgroup_mutex to fix a deadlock problem.

commit 7f4d454dee2e0bdd21bafd413d1c53e443a26540
Author: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Date:   Wed Jan 7 18:08:29 2009 -0800

    memcg: avoid deadlock caused by race between oom and cpuset_attach

    mpol_rebind_mm(), which can be called from cpuset_attach(), does
    down_write(mm->mmap_sem).  This means down_write(mm->mmap_sem) can be
    called under cgroup_mutex.

    OTOH, page fault path does down_read(mm->mmap_sem) and calls
    mem_cgroup_try_charge_xxx(), which may eventually calls
    mem_cgroup_out_of_memory().  And mem_cgroup_out_of_memory() calls
    cgroup_lock().  This means cgroup_lock() can be called under
    down_read(mm->mmap_sem).

    If those two paths race, deadlock can happen.

    This patch avoid this deadlock by:
      - remove cgroup_lock() from mem_cgroup_out_of_memory().
      - define new mutex (memcg_tasklist) and serialize mem_cgroup_move_task()
        (->attach handler of memory cgroup) and mem_cgroup_out_of_memory.

    Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
    Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
    Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

Before the commit, mem_cgroup_out_of_memory() holded(and released afterward) cgroup_mutex.
Those codes was introduced at commit c7ba5c9e.

commit c7ba5c9e8176704bfac0729875fa62798037584d
Author: Pavel Emelianov <xemul@openvz.org>
Date:   Thu Feb 7 00:13:58 2008 -0800

    Memory controller: OOM handling

    Out of memory handling for cgroups over their limit. A task from the
    cgroup over limit is chosen using the existing OOM logic and killed.

    TODO:
    1. As discussed in the OLS BOF session, consider implementing a user
    space policy for OOM handling.

    [akpm@linux-foundation.org: fix build due to oom-killer changes]
    Signed-off-by: Pavel Emelianov <xemul@openvz.org>
    Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
    Cc: Paul Menage <menage@google.com>
    Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
    Cc: "Eric W. Biederman" <ebiederm@xmission.com>
    Cc: Nick Piggin <nickpiggin@yahoo.com.au>
    Cc: Kirill Korotaev <dev@sw.ru>
    Cc: Herbert Poetzl <herbert@13thfloor.at>
    Cc: David Rientjes <rientjes@google.com>
    Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

I'm not sure about the intention of the original cgroup_lock() here, but I imagine that
it was for preventing task move during select_bad_process().

If there is no such a lock:

  Assume cgroup foo has exceeded its limit and is about to triggering oom.
  1. Process A, which has been in cgroup baa and uses large memory,
     is just moved to cgroup foo. Process A can be the candidates for being killed.
  2. Process B, which has been in cgroup foo and uses large memory,
     is just moved from cgroup foo. Process B can be excluded from the candidates for
     being killed. 

Hmm, but considering more, those race window exist anyway even if we holds a lock,
because try_charge decides wether it should trigger oom or not outside of the lock.

If this recharge feature is enabled, I think those problems might be avoided by doing like:

__mem_cgroup_try_charge()
{
	...
	if (oom) {
		mutex_lock(&memcg_tasklist);
		if (unlikely(mem_cgroup_check_under_limit)) {
			mutex_unlock(&memcg_tasklist);
			continue
		}
		mem_cgroup_out_of_memory();
		mutex_unlock(&memcg_tasklist);
		record_last_oom();
	}
	...
}

but it makes codes more complex and the recharge feature isn't necessarily enabled.

Well, I personally think we can remove these locks completely and make codes simpler.
What do you think ?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
