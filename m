Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 526DA6B0007
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 03:26:07 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 31-v6so14880095plf.19
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 00:26:07 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v18-v6si39065055plo.285.2018.06.01.00.26.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jun 2018 00:26:06 -0700 (PDT)
Date: Fri, 1 Jun 2018 15:26:04 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [LKP] [lkp-robot] [mm, memcontrol] 309fe96bfc:
 vm-scalability.throughput +23.0% improvement
Message-ID: <20180601072604.GB27302@intel.com>
References: <20180528114019.GF9904@yexl-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180528114019.GF9904@yexl-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <xiaolong.ye@intel.com>
Cc: Tejun Heo <tj@kernel.org>, lkp@01.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Mon, May 28, 2018 at 07:40:19PM +0800, kernel test robot wrote:
> 
> Greeting,
> 
> FYI, we noticed a +23.0% improvement of vm-scalability.throughput due to commit:
> 
> 
> commit: 309fe96bfc0ae387f53612927a8f0dc3eb056efd ("mm, memcontrol: implement memory.swap.events")
> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git master
> 
> in testcase: vm-scalability
> on test machine: 144 threads Intel(R) Xeon(R) CPU E7-8890 v3 @ 2.50GHz with 512G memory
> with following parameters:
> 
> 	runtime: 300s
> 	size: 1T
> 	test: lru-shm
> 	cpufreq_governor: performance
> 
> test-description: The motivation behind this suite is to exercise functions and regions of the mm/ of the Linux kernel which are of interest to us.
> test-url: https://git.kernel.org/cgit/linux/kernel/git/wfg/vm-scalability.git/
> 

With the patch I just sent out:
"mem_cgroup: make sure moving_account, move_lock_task and stat_cpu in the
same cacheline"

Applying this commit on top doesn't yield 23% improvement any more, but
a 6% performace drop...

I found the culprit being the following one line introduced in this commit:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d90b0201a8c4..07ab974c0a49 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6019,13 +6019,17 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
 	if (!memcg)
 		return 0;
 
-	if (!entry.val)
+	if (!entry.val) {
+		memcg_memory_event(memcg, MEMCG_SWAP_FAIL);
 		return 0;
+	}
 
 	memcg = mem_cgroup_id_get_online(memcg);
 
If I remove that memcg_memory_event() call, performance will restore.

It's beyond my understanding why this code path matters since there is
no swap device setup in the test machine so I don't see how possible
get_swap_page() could ever be called.

Still investigating...
