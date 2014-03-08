Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 171326B0031
	for <linux-mm@kvack.org>; Sat,  8 Mar 2014 16:48:22 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id r10so5495584pdi.2
        for <linux-mm@kvack.org>; Sat, 08 Mar 2014 13:48:21 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qe9si12286155pbb.282.2014.03.08.13.48.20
        for <linux-mm@kvack.org>;
        Sat, 08 Mar 2014 13:48:21 -0800 (PST)
Date: Sun, 09 Mar 2014 05:48:17 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 432/471] kernel/sched/rt.c:1451:39: sparse:
 incorrect type in initializer (different address spaces)
Message-ID: <531b9021.6iBITNWPrSqc6ad1%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   f6bf2766c2091cbf8ffcc2c5009875dbdb678282
commit: 4a46dca81e38ce94eb5c2ba6f35d6e4bf4c86664 [432/471] scheduler: replace __get_cpu_var with this_cpu_ptr
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> kernel/sched/rt.c:1451:39: sparse: incorrect type in initializer (different address spaces)
   kernel/sched/rt.c:1451:39:    expected void const [noderef] <asn:3>*__vpp_verify
   kernel/sched/rt.c:1451:39:    got struct cpumask *<noident>
   kernel/sched/rt.c:1484:9: sparse: incompatible types in comparison expression (different address spaces)

vim +1451 kernel/sched/rt.c

  1435		if (!has_pushable_tasks(rq))
  1436			return NULL;
  1437	
  1438		plist_for_each_entry(p, head, pushable_tasks) {
  1439			if (pick_rt_task(rq, p, cpu))
  1440				return p;
  1441		}
  1442	
  1443		return NULL;
  1444	}
  1445	
  1446	static DEFINE_PER_CPU(cpumask_var_t, local_cpu_mask);
  1447	
  1448	static int find_lowest_rq(struct task_struct *task)
  1449	{
  1450		struct sched_domain *sd;
> 1451		struct cpumask *lowest_mask = this_cpu_ptr(local_cpu_mask);
  1452		int this_cpu = smp_processor_id();
  1453		int cpu      = task_cpu(task);
  1454	
  1455		/* Make sure the mask is initialized first */
  1456		if (unlikely(!lowest_mask))
  1457			return -1;
  1458	
  1459		if (task->nr_cpus_allowed == 1)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
