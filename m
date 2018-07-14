Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 987B66B0005
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 22:24:51 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id m2-v6so20796202plt.14
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:24:51 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id v32-v6si25483527plb.273.2018.07.13.19.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 19:24:50 -0700 (PDT)
Date: Sat, 14 Jul 2018 10:24:02 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [mmotm:master 170/329] kernel/sched/psi.c:153:18: sparse: incorrect
 type in initializer (different address spaces)
Message-ID: <201807141000.0Sx0DCur%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   fa5441daae8ad99af4e198bcd4d57cffdd582961
commit: 60ad478b408f38c98f4df24d1cd87f5b3f130831 [170/329] psi: pressure stall information for CPU, memory, and IO
reproduce:
        # apt-get install sparse
        git checkout 60ad478b408f38c98f4df24d1cd87f5b3f130831
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> kernel/sched/psi.c:153:18: sparse: incorrect type in initializer (different address spaces) @@    expected struct psi_group_cpu *cpus @@    got struct psi_group_struct psi_group_cpu *cpus @@
   kernel/sched/psi.c:153:18:    expected struct psi_group_cpu *cpus
   kernel/sched/psi.c:153:18:    got struct psi_group_cpu [noderef] <asn:3>*<noident>
>> kernel/sched/psi.c:219:48: sparse: incorrect type in initializer (different address spaces) @@    expected void const [noderef] <asn:3>*__vpp_verify @@    got nst [noderef] <asn:3>*__vpp_verify @@
   kernel/sched/psi.c:219:48:    expected void const [noderef] <asn:3>*__vpp_verify
   kernel/sched/psi.c:219:48:    got struct psi_group_cpu *<noident>
>> kernel/sched/psi.c:255:17: sparse: expression using sizeof(void)
   kernel/sched/psi.c:256:17: sparse: expression using sizeof(void)
   kernel/sched/psi.c:338:18: sparse: incorrect type in initializer (different address spaces) @@    expected void const [noderef] <asn:3>*__vpp_verify @@    got nst [noderef] <asn:3>*__vpp_verify @@
   kernel/sched/psi.c:338:18:    expected void const [noderef] <asn:3>*__vpp_verify
   kernel/sched/psi.c:338:18:    got struct psi_group_cpu *<noident>

vim +153 kernel/sched/psi.c

   149	
   150	/* System-level pressure and stall tracking */
   151	static DEFINE_PER_CPU(struct psi_group_cpu, system_group_cpus);
   152	static struct psi_group psi_system = {
 > 153		.cpus = &system_group_cpus,
   154	};
   155	
   156	static void psi_clock(struct work_struct *work);
   157	
   158	static void psi_group_init(struct psi_group *group)
   159	{
   160		group->period_expires = jiffies + PSI_FREQ;
   161		INIT_DELAYED_WORK(&group->clock_work, psi_clock);
   162		mutex_init(&group->stat_lock);
   163	}
   164	
   165	void __init psi_init(void)
   166	{
   167		if (psi_disabled)
   168			return;
   169	
   170		psi_period = jiffies_to_nsecs(PSI_FREQ);
   171		psi_group_init(&psi_system);
   172	}
   173	
   174	static void calc_avgs(unsigned long avg[3], u64 time, int missed_periods)
   175	{
   176		unsigned long pct;
   177	
   178		/* Sample the most recent active period */
   179		pct = time * 100 / psi_period;
   180		pct *= FIXED_1;
   181		avg[0] = calc_load(avg[0], EXP_10s, pct);
   182		avg[1] = calc_load(avg[1], EXP_60s, pct);
   183		avg[2] = calc_load(avg[2], EXP_300s, pct);
   184	
   185		/* Fill in zeroes for periods of no activity */
   186		if (missed_periods) {
   187			avg[0] = calc_load_n(avg[0], EXP_10s, 0, missed_periods);
   188			avg[1] = calc_load_n(avg[1], EXP_60s, 0, missed_periods);
   189			avg[2] = calc_load_n(avg[2], EXP_300s, 0, missed_periods);
   190		}
   191	}
   192	
   193	static bool psi_update_stats(struct psi_group *group)
   194	{
   195		u64 some[NR_PSI_RESOURCES] = { 0, };
   196		u64 full[NR_PSI_RESOURCES] = { 0, };
   197		unsigned long nonidle_total = 0;
   198		unsigned long missed_periods;
   199		unsigned long expires;
   200		int cpu;
   201		int r;
   202	
   203		mutex_lock(&group->stat_lock);
   204	
   205		/*
   206		 * Collect the per-cpu time buckets and average them into a
   207		 * single time sample that is normalized to wallclock time.
   208		 *
   209		 * For averaging, each CPU is weighted by its non-idle time in
   210		 * the sampling period. This eliminates artifacts from uneven
   211		 * loading, or even entirely idle CPUs.
   212		 *
   213		 * We could pin the online CPUs here, but the noise introduced
   214		 * by missing up to one sample period from CPUs that are going
   215		 * away shouldn't matter in practice - just like the noise of
   216		 * previously offlined CPUs returning with a non-zero sample.
   217		 */
   218		for_each_online_cpu(cpu) {
 > 219			struct psi_group_cpu *groupc = per_cpu_ptr(group->cpus, cpu);
   220			unsigned long nonidle;
   221	
   222			if (!groupc->nonidle_time)
   223				continue;
   224	
   225			nonidle = nsecs_to_jiffies(groupc->nonidle_time);
   226			groupc->nonidle_time = 0;
   227			nonidle_total += nonidle;
   228	
   229			for (r = 0; r < NR_PSI_RESOURCES; r++) {
   230				struct psi_resource *res = &groupc->res[r];
   231	
   232				some[r] += (res->times[0] + res->times[1]) * nonidle;
   233				full[r] += res->times[1] * nonidle;
   234	
   235				/* It's racy, but we can tolerate some error */
   236				res->times[0] = 0;
   237				res->times[1] = 0;
   238			}
   239		}
   240	
   241		/*
   242		 * Integrate the sample into the running statistics that are
   243		 * reported to userspace: the cumulative stall times and the
   244		 * decaying averages.
   245		 *
   246		 * Pressure percentages are sampled at PSI_FREQ. We might be
   247		 * called more often when the user polls more frequently than
   248		 * that; we might be called less often when there is no task
   249		 * activity, thus no data, and clock ticks are sporadic. The
   250		 * below handles both.
   251		 */
   252	
   253		/* total= */
   254		for (r = 0; r < NR_PSI_RESOURCES; r++) {
 > 255			do_div(some[r], max(nonidle_total, 1UL));
   256			do_div(full[r], max(nonidle_total, 1UL));
   257	
   258			group->some[r] += some[r];
   259			group->full[r] += full[r];
   260		}
   261	
   262		/* avgX= */
   263		expires = group->period_expires;
   264		if (time_before(jiffies, expires))
   265			goto out;
   266	
   267		missed_periods = (jiffies - expires) / PSI_FREQ;
   268		group->period_expires = expires + ((1 + missed_periods) * PSI_FREQ);
   269	
   270		for (r = 0; r < NR_PSI_RESOURCES; r++) {
   271			u64 some, full;
   272	
   273			some = group->some[r] - group->last_some[r];
   274			full = group->full[r] - group->last_full[r];
   275	
   276			calc_avgs(group->avg_some[r], some, missed_periods);
   277			calc_avgs(group->avg_full[r], full, missed_periods);
   278	
   279			group->last_some[r] = group->some[r];
   280			group->last_full[r] = group->full[r];
   281		}
   282	out:
   283		mutex_unlock(&group->stat_lock);
   284		return nonidle_total;
   285	}
   286	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
