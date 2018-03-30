Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 246446B0028
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 11:43:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c5so7739543pfn.17
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 08:43:48 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id bh1-v6si8278025plb.246.2018.03.30.08.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 08:43:46 -0700 (PDT)
Date: Fri, 30 Mar 2018 23:43:03 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm,oom: Do not unfreeze OOM victim thread.
Message-ID: <201803302314.3pX8ZwUa%fengguang.wu@intel.com>
References: <1522334218-4268-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522334218-4268-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kbuild-all@01.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

Hi Tetsuo,

I love your patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.16-rc7 next-20180329]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Tetsuo-Handa/mm-oom-Do-not-unfreeze-OOM-victim-thread/20180330-215548
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> kernel/power/process.c:154:42: sparse: too many arguments for function oom_killer_disable
   kernel/power/process.c: In function 'freeze_processes':
   kernel/power/process.c:154:17: error: too many arguments to function 'oom_killer_disable'
     if (!error && !oom_killer_disable(msecs_to_jiffies(freeze_timeout_msecs)))
                    ^~~~~~~~~~~~~~~~~~
   In file included from kernel/power/process.c:13:0:
   include/linux/oom.h:109:13: note: declared here
    extern bool oom_killer_disable(void);
                ^~~~~~~~~~~~~~~~~~

vim +154 kernel/power/process.c

6161b2ce8 Pavel Machek      2005-09-03  115  
11b2ce2ba Rafael J. Wysocki 2006-12-06  116  /**
2aede851d Rafael J. Wysocki 2011-09-26  117   * freeze_processes - Signal user space processes to enter the refrigerator.
2b44c4db2 Colin Cross       2013-07-24  118   * The current thread will not be frozen.  The same process that calls
2b44c4db2 Colin Cross       2013-07-24  119   * freeze_processes must later call thaw_processes.
03afed8bc Tejun Heo         2011-11-21  120   *
03afed8bc Tejun Heo         2011-11-21  121   * On success, returns 0.  On failure, -errno and system is fully thawed.
11b2ce2ba Rafael J. Wysocki 2006-12-06  122   */
11b2ce2ba Rafael J. Wysocki 2006-12-06  123  int freeze_processes(void)
11b2ce2ba Rafael J. Wysocki 2006-12-06  124  {
e7cd8a722 Rafael J. Wysocki 2007-07-19  125  	int error;
11b2ce2ba Rafael J. Wysocki 2006-12-06  126  
247bc0374 Rafael J. Wysocki 2012-03-28  127  	error = __usermodehelper_disable(UMH_FREEZING);
1e73203cd Rafael J. Wysocki 2012-03-28  128  	if (error)
1e73203cd Rafael J. Wysocki 2012-03-28  129  		return error;
1e73203cd Rafael J. Wysocki 2012-03-28  130  
2b44c4db2 Colin Cross       2013-07-24  131  	/* Make sure this task doesn't get frozen */
2b44c4db2 Colin Cross       2013-07-24  132  	current->flags |= PF_SUSPEND_TASK;
2b44c4db2 Colin Cross       2013-07-24  133  
a3201227f Tejun Heo         2011-11-21  134  	if (!pm_freezing)
a3201227f Tejun Heo         2011-11-21  135  		atomic_inc(&system_freezing_cnt);
a3201227f Tejun Heo         2011-11-21  136  
33e4f80ee Rafael J. Wysocki 2017-06-12  137  	pm_wakeup_clear(true);
35536ae17 Michal Hocko      2015-02-11  138  	pr_info("Freezing user space processes ... ");
a3201227f Tejun Heo         2011-11-21  139  	pm_freezing = true;
ebb12db51 Rafael J. Wysocki 2008-06-11  140  	error = try_to_freeze_tasks(true);
2aede851d Rafael J. Wysocki 2011-09-26  141  	if (!error) {
247bc0374 Rafael J. Wysocki 2012-03-28  142  		__usermodehelper_set_disable_depth(UMH_DISABLED);
35536ae17 Michal Hocko      2015-02-11  143  		pr_cont("done.");
2aede851d Rafael J. Wysocki 2011-09-26  144  	}
35536ae17 Michal Hocko      2015-02-11  145  	pr_cont("\n");
2aede851d Rafael J. Wysocki 2011-09-26  146  	BUG_ON(in_atomic());
2aede851d Rafael J. Wysocki 2011-09-26  147  
c32b3cbe0 Michal Hocko      2015-02-11  148  	/*
c32b3cbe0 Michal Hocko      2015-02-11  149  	 * Now that the whole userspace is frozen we need to disbale
c32b3cbe0 Michal Hocko      2015-02-11  150  	 * the OOM killer to disallow any further interference with
7d2e7a22c Michal Hocko      2016-10-07  151  	 * killable tasks. There is no guarantee oom victims will
7d2e7a22c Michal Hocko      2016-10-07  152  	 * ever reach a point they go away we have to wait with a timeout.
c32b3cbe0 Michal Hocko      2015-02-11  153  	 */
7d2e7a22c Michal Hocko      2016-10-07 @154  	if (!error && !oom_killer_disable(msecs_to_jiffies(freeze_timeout_msecs)))
c32b3cbe0 Michal Hocko      2015-02-11  155  		error = -EBUSY;
c32b3cbe0 Michal Hocko      2015-02-11  156  
03afed8bc Tejun Heo         2011-11-21  157  	if (error)
03afed8bc Tejun Heo         2011-11-21  158  		thaw_processes();
2aede851d Rafael J. Wysocki 2011-09-26  159  	return error;
2aede851d Rafael J. Wysocki 2011-09-26  160  }
2aede851d Rafael J. Wysocki 2011-09-26  161  

:::::: The code at line 154 was first introduced by commit
:::::: 7d2e7a22cf27e7569e6816ccc05dd74248048b30 oom, suspend: fix oom_killer_disable vs. pm suspend properly

:::::: TO: Michal Hocko <mhocko@suse.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
