Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBABW4FY005308
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Dec 2008 20:32:04 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7835D45DD7E
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 20:32:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CD2245DD7B
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 20:32:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 26DA31DB803E
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 20:32:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D05211DB8038
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 20:32:03 +0900 (JST)
Message-ID: <31051.10.75.179.61.1228908723.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081210105000.GC25467@balbir.in.ibm.com>
References: <20081210051947.GH7593@balbir.in.ibm.com>
    <20081210174906.7c1a1a50.kamezawa.hiroyu@jp.fujitsu.com>
    <20081210105000.GC25467@balbir.in.ibm.com>
Date: Wed, 10 Dec 2008 20:32:03 +0900 (JST)
Subject: Re: [RFC][RFT] memcg fix cgroup_mutex deadlock when cpusetreclaims
     memory
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, menage@google.com, KAMEZAWA Hiroyuki <kamezawa.hiroyuki@jp.fujitsu.com>, Daisuke Miyakawa <dmiyakawa@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Balbir Singh said:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-10
> 17:49:06]:
>
>> On Wed, 10 Dec 2008 10:49:47 +0530
>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>> > Hi,
>> >
>> > Here is a proposed fix for the memory controller cgroup_mutex deadlock
>> > reported. It is lightly tested and reviewed. I need help with review
>> > and test. Is the reported deadlock reproducible after this patch? A
>> > careful review of the cpuset impact will also be highly appreciated.
>> >
>> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
>> >
>> > cpuset_migrate_mm() holds cgroup_mutex throughout the duration of
>> > do_migrate_pages(). The issue with that is that
>> >
>> > 1. It can lead to deadlock with memcg, as do_migrate_pages()
>> >    enters reclaim
>> > 2. It can lead to long latencies, preventing users from creating/
>> >    destroying other cgroups anywhere else
>> >
>> > The patch holds callback_mutex through the duration of
>> cpuset_migrate_mm() and
>> > gives up cgroup_mutex while doing so.
>> >
>> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> > ---
>> >
>> >  include/linux/cpuset.h |   13 ++++++++++++-
>> >  kernel/cpuset.c        |   23 ++++++++++++-----------
>> >  2 files changed, 24 insertions(+), 12 deletions(-)
>> >
>> > diff -puN kernel/cgroup.c~cpuset-remove-cgroup-mutex-from-update-path
>> kernel/cgroup.c
>> > diff -puN kernel/cpuset.c~cpuset-remove-cgroup-mutex-from-update-path
>> kernel/cpuset.c
>> > --- a/kernel/cpuset.c~cpuset-remove-cgroup-mutex-from-update-path
>> > +++ a/kernel/cpuset.c
>> > @@ -369,7 +369,7 @@ static void guarantee_online_mems(const
>> >   * task has been modifying its cpuset.
>> >   */
>> >
>> > -void cpuset_update_task_memory_state(void)
>> > +void __cpuset_update_task_memory_state(bool held)
>> >  {
>> >  	int my_cpusets_mem_gen;
>> >  	struct task_struct *tsk = current;
>> > @@ -380,7 +380,8 @@ void cpuset_update_task_memory_state(voi
>> >  	rcu_read_unlock();
>> >
>> >  	if (my_cpusets_mem_gen != tsk->cpuset_mems_generation) {
>> > -		mutex_lock(&callback_mutex);
>> > +		if (!held)
>> > +			mutex_lock(&callback_mutex);
>> >  		task_lock(tsk);
>> >  		cs = task_cs(tsk); /* Maybe changed when task not locked */
>> >  		guarantee_online_mems(cs, &tsk->mems_allowed);
>> > @@ -394,7 +395,8 @@ void cpuset_update_task_memory_state(voi
>> >  		else
>> >  			tsk->flags &= ~PF_SPREAD_SLAB;
>> >  		task_unlock(tsk);
>> > -		mutex_unlock(&callback_mutex);
>> > +		if (!held)
>> > +			mutex_unlock(&callback_mutex);
>> >  		mpol_rebind_task(tsk, &tsk->mems_allowed);
>> >  	}
>> >  }
>> > @@ -949,13 +951,15 @@ static int update_cpumask(struct cpuset
>> >   *    so that the migration code can allocate pages on these nodes.
>> >   *
>> >   *    Call holding cgroup_mutex, so current's cpuset won't change
>> > - *    during this call, as manage_mutex holds off any cpuset_attach()
>> > + *    during this call, as callback_mutex holds off any
>> cpuset_attach()
>> >   *    calls.  Therefore we don't need to take task_lock around the
>> >   *    call to guarantee_online_mems(), as we know no one is changing
>> >   *    our task's cpuset.
>> >   *
>> >   *    Hold callback_mutex around the two modifications of our tasks
>> > - *    mems_allowed to synchronize with cpuset_mems_allowed().
>> > + *    mems_allowed to synchronize with cpuset_mems_allowed(). Give
>> > + *    up cgroup_mutex to avoid deadlocking with other subsystems
>> > + *    as we enter reclaim from do_migrate_pages().
>> >   *
>> >   *    While the mm_struct we are migrating is typically from some
>> >   *    other task, the task_struct mems_allowed that we are hacking
>> > @@ -976,17 +980,14 @@ static void cpuset_migrate_mm(struct mm_
>> >  {
>> >  	struct task_struct *tsk = current;
>> >
>> > -	cpuset_update_task_memory_state();
>> > -
>> > +	cgroup_unlock();
>> >  	mutex_lock(&callback_mutex);
>> > +	cpuset_update_task_memory_state_locked();
>> >  	tsk->mems_allowed = *to;
>> > -	mutex_unlock(&callback_mutex);
>> > -
>> >  	do_migrate_pages(mm, from, to, MPOL_MF_MOVE_ALL);
>> > -
>> > -	mutex_lock(&callback_mutex);
>> >  	guarantee_online_mems(task_cs(tsk),&tsk->mems_allowed);
>> >  	mutex_unlock(&callback_mutex);
>> > +	cgroup_lock();
>> >  }
>> >
>>
>> Hmm...can't this happen ?
>>
>> Assume there is a task X and cgroup Z1 and Z2. Z1 and Z2 doesn't need to
>> be in
>> the same hierarchy.
>> ==
>> 	CPU A attach task X to cgroup Z1
>> 		cgroup_lock()
>> 			for_each_subsys_state()
>
> You mean for_each_subsys() right?
>
>> 				=> attach(X,Z)
>> 					=> migrate_mm()
>> 						=> cgroup_unlock()
>> 							migration
>>
>> 	CPU B attach task X to cgroup Z2 at the same time
>> 		cgroup_lock()
>> 			replace css_set.
>> ==
>>
>> Works on CPU B can't break for_each_subsys_state() in CPU A ?
>>
>
> for_each_subsys is hierarchy aware, so if we try to add the same task
> to different hierachies, it should not be a problem right?
>
Ah, maybe. But what happens when Z1 and Z2 is the same hierarchy ?
Are there some locks ?

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
