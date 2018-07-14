Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECE5F6B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 22:39:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a23-v6so10141928pfo.23
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:39:50 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q74-v6si25774752pfa.272.2018.07.13.19.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 19:39:49 -0700 (PDT)
Date: Sat, 14 Jul 2018 10:38:59 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [mmotm:master 173/329] kernel/sched/psi.c:504:26: sparse: incorrect
 type in assignment (different address spaces)
Message-ID: <201807141056.PLxOnvl7%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   fa5441daae8ad99af4e198bcd4d57cffdd582961
commit: 05447370dd1cb96635f9502de590442a34903ff1 [173/329] psi: cgroup support
reproduce:
        # apt-get install sparse
        git checkout 05447370dd1cb96635f9502de590442a34903ff1
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   kernel/sched/psi.c:153:18: sparse: incorrect type in initializer (different address spaces) @@    expected struct psi_group_cpu *cpus @@    got struct psi_group_struct psi_group_cpu *cpus @@
   kernel/sched/psi.c:153:18:    expected struct psi_group_cpu *cpus
   kernel/sched/psi.c:153:18:    got struct psi_group_cpu [noderef] <asn:3>*<noident>
   kernel/sched/psi.c:220:48: sparse: incorrect type in initializer (different address spaces) @@    expected void const [noderef] <asn:3>*__vpp_verify @@    got nst [noderef] <asn:3>*__vpp_verify @@
   kernel/sched/psi.c:220:48:    expected void const [noderef] <asn:3>*__vpp_verify
   kernel/sched/psi.c:220:48:    got struct psi_group_cpu *<noident>
   kernel/sched/psi.c:256:17: sparse: expression using sizeof(void)
   kernel/sched/psi.c:257:17: sparse: expression using sizeof(void)
   kernel/sched/psi.c:339:18: sparse: incorrect type in initializer (different address spaces) @@    expected void const [noderef] <asn:3>*__vpp_verify @@    got nst [noderef] <asn:3>*__vpp_verify @@
   kernel/sched/psi.c:339:18:    expected void const [noderef] <asn:3>*__vpp_verify
   kernel/sched/psi.c:339:18:    got struct psi_group_cpu *<noident>
>> kernel/sched/psi.c:504:26: sparse: incorrect type in assignment (different address spaces) @@    expected struct psi_group_cpu *cpus @@    got struct psi_group_struct psi_group_cpu *cpus @@
   kernel/sched/psi.c:504:26:    expected struct psi_group_cpu *cpus
   kernel/sched/psi.c:504:26:    got struct psi_group_cpu [noderef] <asn:3>*<noident>
>> kernel/sched/psi.c:514:32: sparse: incorrect type in argument 1 (different address spaces) @@    expected void [noderef] <asn:3>*__pdata @@    got oid [noderef] <asn:3>*__pdata @@
   kernel/sched/psi.c:514:32:    expected void [noderef] <asn:3>*__pdata
   kernel/sched/psi.c:514:32:    got struct psi_group_cpu *cpus
>> kernel/sched/psi.c:425:21: sparse: dereference of noderef expression

vim +504 kernel/sched/psi.c

   330	
   331	static void psi_group_change(struct psi_group *group, int cpu, u64 now,
   332				     unsigned int clear, unsigned int set)
   333	{
   334		enum psi_state state = PSI_NONE;
   335		struct psi_group_cpu *groupc;
   336		unsigned int *tasks;
   337		unsigned int to, bo;
   338	
 > 339		groupc = per_cpu_ptr(group->cpus, cpu);
   340		tasks = groupc->tasks;
   341	
   342		/* Update task counts according to the set/clear bitmasks */
   343		for (to = 0; (bo = ffs(clear)); to += bo, clear >>= bo) {
   344			int idx = to + (bo - 1);
   345	
   346			if (tasks[idx] == 0 && !psi_bug) {
   347				printk_deferred(KERN_ERR "psi: task underflow! cpu=%d idx=%d tasks=[%u %u %u] clear=%x set=%x\n",
   348						cpu, idx, tasks[0], tasks[1], tasks[2],
   349						clear, set);
   350				psi_bug = 1;
   351			}
   352			tasks[idx]--;
   353		}
   354		for (to = 0; (bo = ffs(set)); to += bo, set >>= bo)
   355			tasks[to + (bo - 1)]++;
   356	
   357		/* Time in which tasks wait for the CPU */
   358		state = PSI_NONE;
   359		if (tasks[NR_RUNNING] > 1)
   360			state = PSI_SOME;
   361		time_state(&groupc->res[PSI_CPU], state, now);
   362	
   363		/* Time in which tasks wait for memory */
   364		state = PSI_NONE;
   365		if (tasks[NR_MEMSTALL]) {
   366			if (!tasks[NR_RUNNING] ||
   367			    (cpu_curr(cpu)->flags & PF_MEMSTALL))
   368				state = PSI_FULL;
   369			else
   370				state = PSI_SOME;
   371		}
   372		time_state(&groupc->res[PSI_MEM], state, now);
   373	
   374		/* Time in which tasks wait for IO */
   375		state = PSI_NONE;
   376		if (tasks[NR_IOWAIT]) {
   377			if (!tasks[NR_RUNNING])
   378				state = PSI_FULL;
   379			else
   380				state = PSI_SOME;
   381		}
   382		time_state(&groupc->res[PSI_IO], state, now);
   383	
   384		/* Time in which tasks are non-idle, to weigh the CPU in summaries */
   385		if (groupc->nonidle)
   386			groupc->nonidle_time += now - groupc->nonidle_start;
   387		groupc->nonidle = tasks[NR_RUNNING] ||
   388			tasks[NR_IOWAIT] || tasks[NR_MEMSTALL];
   389		if (groupc->nonidle)
   390			groupc->nonidle_start = now;
   391	
   392		/* Kick the stats aggregation worker if it's gone to sleep */
   393		if (!delayed_work_pending(&group->clock_work))
   394			schedule_delayed_work(&group->clock_work, PSI_FREQ);
   395	}
   396	
   397	void psi_task_change(struct task_struct *task, u64 now, int clear, int set)
   398	{
   399	#ifdef CONFIG_CGROUPS
   400		struct cgroup *cgroup, *parent;
   401	#endif
   402		int cpu = task_cpu(task);
   403	
   404		if (psi_disabled)
   405			return;
   406	
   407		if (!task->pid)
   408			return;
   409	
   410		if (((task->psi_flags & set) ||
   411		     (task->psi_flags & clear) != clear) &&
   412		    !psi_bug) {
   413			printk_deferred(KERN_ERR "psi: inconsistent task state! task=%d:%s cpu=%d psi_flags=%x clear=%x set=%x\n",
   414					task->pid, task->comm, cpu,
   415					task->psi_flags, clear, set);
   416			psi_bug = 1;
   417		}
   418	
   419		task->psi_flags &= ~clear;
   420		task->psi_flags |= set;
   421	
   422		psi_group_change(&psi_system, cpu, now, clear, set);
   423	
   424	#ifdef CONFIG_CGROUPS
 > 425	       cgroup = task->cgroups->dfl_cgrp;
   426	       while (cgroup && (parent = cgroup_parent(cgroup))) {
   427	               struct psi_group *group;
   428	
   429	               group = cgroup_psi(cgroup);
   430	               psi_group_change(group, cpu, now, clear, set);
   431	
   432	               cgroup = parent;
   433	       }
   434	#endif
   435	}
   436	
   437	/**
   438	 * psi_memstall_enter - mark the beginning of a memory stall section
   439	 * @flags: flags to handle nested sections
   440	 *
   441	 * Marks the calling task as being stalled due to a lack of memory,
   442	 * such as waiting for a refault or performing reclaim.
   443	 */
   444	void psi_memstall_enter(unsigned long *flags)
   445	{
   446		struct rq_flags rf;
   447		struct rq *rq;
   448	
   449		if (psi_disabled)
   450			return;
   451	
   452		*flags = current->flags & PF_MEMSTALL;
   453		if (*flags)
   454			return;
   455		/*
   456		 * PF_MEMSTALL setting & accounting needs to be atomic wrt
   457		 * changes to the task's scheduling state, otherwise we can
   458		 * race with CPU migration.
   459		 */
   460		rq = this_rq_lock_irq(&rf);
   461	
   462		update_rq_clock(rq);
   463	
   464		current->flags |= PF_MEMSTALL;
   465		psi_task_change(current, rq_clock(rq), 0, TSK_MEMSTALL);
   466	
   467		rq_unlock_irq(rq, &rf);
   468	}
   469	
   470	/**
   471	 * psi_memstall_leave - mark the end of an memory stall section
   472	 * @flags: flags to handle nested memdelay sections
   473	 *
   474	 * Marks the calling task as no longer stalled due to lack of memory.
   475	 */
   476	void psi_memstall_leave(unsigned long *flags)
   477	{
   478		struct rq_flags rf;
   479		struct rq *rq;
   480	
   481		if (psi_disabled)
   482			return;
   483	
   484		if (*flags)
   485			return;
   486		/*
   487		 * PF_MEMSTALL clearing & accounting needs to be atomic wrt
   488		 * changes to the task's scheduling state, otherwise we could
   489		 * race with CPU migration.
   490		 */
   491		rq = this_rq_lock_irq(&rf);
   492	
   493		update_rq_clock(rq);
   494	
   495		current->flags &= ~PF_MEMSTALL;
   496		psi_task_change(current, rq_clock(rq), TSK_MEMSTALL, 0);
   497	
   498		rq_unlock_irq(rq, &rf);
   499	}
   500	
   501	#ifdef CONFIG_CGROUPS
   502	int psi_cgroup_alloc(struct cgroup *cgroup)
   503	{
 > 504		cgroup->psi.cpus = alloc_percpu(struct psi_group_cpu);
   505		if (!cgroup->psi.cpus)
   506			return -ENOMEM;
   507		psi_group_init(&cgroup->psi);
   508		return 0;
   509	}
   510	
   511	void psi_cgroup_free(struct cgroup *cgroup)
   512	{
   513		cancel_delayed_work_sync(&cgroup->psi.clock_work);
 > 514		free_percpu(cgroup->psi.cpus);
   515	}
   516	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
