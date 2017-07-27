Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 681856B04D1
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 17:41:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u17so222648619pfa.6
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 14:41:55 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h10si12005256plk.237.2017.07.27.14.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 14:41:54 -0700 (PDT)
Date: Fri, 28 Jul 2017 05:41:07 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [v4 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <201707280527.uGsOPEe0%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="pWyiEgJYm5f9v55/"
Content-Disposition: inline
In-Reply-To: <20170726132718.14806-3-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org


--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Roman,

[auto build test ERROR on linus/master]
[also build test ERROR on v4.13-rc2 next-20170727]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Roman-Gushchin/cgroup-aware-OOM-killer/20170728-051627
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   mm/oom_kill.c: In function 'oom_kill_memcg_victim':
>> mm/oom_kill.c:1005:24: error: dereferencing pointer to incomplete type 'struct mem_cgroup'
       if (oc->chosen_memcg->oom_kill_all_tasks)
                           ^~

vim +1005 mm/oom_kill.c

   982	
   983	static bool oom_kill_memcg_victim(struct oom_control *oc)
   984	{
   985		if (oc->chosen) {
   986			if (oc->chosen != (void *)-1UL) {
   987				__oom_kill_process(oc->chosen);
   988				put_task_struct(oc->chosen);
   989				schedule_timeout_killable(1);
   990			}
   991			return true;
   992	
   993		} else if (oc->chosen_memcg) {
   994			if (oc->chosen_memcg == (void *)-1UL)
   995				return true;
   996	
   997			/* Always begin with the biggest task */
   998			oc->chosen_points = 0;
   999			oc->chosen = NULL;
  1000			mem_cgroup_scan_tasks(oc->chosen_memcg, oom_evaluate_task, oc);
  1001			if (oc->chosen && oc->chosen != (void *)-1UL) {
  1002				__oom_kill_process(oc->chosen);
  1003				put_task_struct(oc->chosen);
  1004	
> 1005				if (oc->chosen_memcg->oom_kill_all_tasks)
  1006					mem_cgroup_scan_tasks(oc->chosen_memcg,
  1007							      oom_kill_memcg_member,
  1008							      NULL);
  1009			}
  1010	
  1011			mem_cgroup_put(oc->chosen_memcg);
  1012			oc->chosen_memcg = NULL;
  1013			return true;
  1014	
  1015		} else {
  1016			oc->chosen_points = 0;
  1017			return false;
  1018		}
  1019	}
  1020	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--pWyiEgJYm5f9v55/
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
hDHuLzbXBvsQMusES8azamD8/A80IKL9dl8AAA==

--pWyiEgJYm5f9v55/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
