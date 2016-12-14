Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id F0D4F6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:06:13 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id 186so30325524yby.5
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 03:06:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x14si15800311ywg.381.2016.12.14.03.06.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 03:06:13 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBEB3sLY106244
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:06:13 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 27ayxs0n8n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:06:12 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 14 Dec 2016 04:06:11 -0700
Date: Wed, 14 Dec 2016 03:06:09 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Fw: [lkp-developer] [sched,rcu]  cf7a2dca60: [No primary change]
 +186% will-it-scale.time.involuntary_context_switches
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161213151408.GC3924@linux.vnet.ibm.com>
 <20161214095425.GE25573@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161214095425.GE25573@dhcp22.suse.cz>
Message-Id: <20161214110609.GK3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org

On Wed, Dec 14, 2016 at 10:54:25AM +0100, Michal Hocko wrote:
> On Tue 13-12-16 07:14:08, Paul E. McKenney wrote:
> > Just FYI for the moment...
> > 
> > So even with the slowed-down checking, making cond_resched() do what
> > cond_resched_rcu_qs() does results in a smallish but quite measurable
> > degradation according to 0day.
> 
> So if I understand those results properly, the reason seems to be the
> increased involuntary context switches, right? Or am I misreading the
> data?
> I am looking at your "sched,rcu: Make cond_resched() provide RCU
> quiescent state" in linux-next and I am wondering whether rcu_all_qs has
> to be called unconditionally and not only when should_resched failed few
> times? I guess you have discussed that with Peter already but do not
> remember the outcome.

My first thought is to wait for the grace period to age further before
checking, the idea being to avoid increasing cond_resched() overhead
any further.  But if that doesn't work, then yes, I may have to look at
adding more checks to cond_resched().

> Thanks for letting my know! 
> 
> > I will try some things to reduce the
> > impact, but it is quite possible that we will need to live with both
> > interfaces.
> 
> Thanks a lot for your time!

Here is hoping for an eventual solution.  ;-)

							Thanx, Paul

> > ----- Forwarded message from kernel test robot <ying.huang@linux.intel.com> -----
> > 
> > Date: Mon, 12 Dec 2016 13:52:28 +0800
> > From: kernel test robot <ying.huang@linux.intel.com>
> > TO: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> > Cc: lkp@01.org
> > Subject: [lkp-developer] [sched,rcu]  cf7a2dca60: [No primary change] +186%
> > 	will-it-scale.time.involuntary_context_switches
> > 
> > Greeting,
> > 
> > There is no primary kpi change in this test, below is the data collected through multiple monitors running background just for your information.
> > 
> > 
> > commit: cf7a2dca6056544bb04a8f819fbbdb415bdb2933 ("sched,rcu: Make cond_resched() provide RCU quiescent state")
> > https://git.kernel.org/pub/scm/linux/kernel/git/paulmck/linux-rcu.git dev.2016.12.05c
> > 
> > in testcase: will-it-scale
> > on test machine: 32 threads Intel(R) Xeon(R) CPU E5-2680 0 @ 2.70GHz with 64G memory
> > with following parameters:
> > 
> > 	test: unlink2
> > 	cpufreq_governor: performance
> > 
> > test-description: Will It Scale takes a testcase and runs it from 1 through to n parallel copies to see if the testcase will scale. It builds both a process and threads based test in order to see any differences between the two.
> > test-url: https://github.com/antonblanchard/will-it-scale
> > 
> > 
> > 
> > Details are as below:
> > -------------------------------------------------------------------------------------------------->
> > 
> > 
> > To reproduce:
> > 
> >         git clone git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-tests.git
> >         cd lkp-tests
> >         bin/lkp install job.yaml  # job file is attached in this email
> >         bin/lkp run     job.yaml
> > 
> > testcase/path_params/tbox_group/run: will-it-scale/unlink2-performance/lkp-sb03
> > 
> > 15705d6709cb6ba6  cf7a2dca6056544bb04a8f819f  
> > ----------------  --------------------------  
> >          %stddev      change         %stddev
> >              \          |                \  
> >     116286                      114432        will-it-scale.per_process_ops
> >      20902 +-  5%       186%      59731 +-  5%  will-it-scale.time.involuntary_context_switches
> >       2694 +-  8%        61%       4344        vmstat.system.cs
> >      10903 +- 99%     -1e+04        148 +-  5%  latency_stats.max.wait_on_page_bit.__migration_entry_wait.migration_entry_wait.do_swap_page.handle_mm_fault.__do_page_fault.do_page_fault.page_fault
> >       3583 +- 38%      1e+04      14010 +- 51%  latency_stats.sum.ep_poll.SyS_epoll_wait.entry_SYSCALL_64_fastpath
> >       4143 +- 24%      1e+04      14549 +- 51%  latency_stats.sum.ep_poll.SyS_epoll_wait.do_syscall_64.return_from_SYSCALL_64
> >     271108 +- 71%     -2e+05      66364 +- 32%  latency_stats.sum.wait_on_page_bit.__migration_entry_wait.migration_entry_wait.do_swap_page.handle_mm_fault.__do_page_fault.do_page_fault.page_fault
> >     834637 +-  8%        62%    1351381        perf-stat.context-switches
> >      16449 +-  3%        54%      25349 +-  3%  perf-stat.cpu-migrations
> >      25.94              35%      35.02        perf-stat.node-store-miss-rate%
> >  2.534e+09              32%  3.335e+09        perf-stat.node-store-misses
> >  1.002e+12               4%  1.043e+12        perf-stat.dTLB-stores
> >   50923913               3%   52692115        perf-stat.iTLB-loads
> >  1.696e+12                   1.745e+12        perf-stat.dTLB-loads
> >  1.258e+12                   1.291e+12        perf-stat.branch-instructions
> >  6.132e+12                   6.274e+12        perf-stat.instructions
> >       0.37                        0.38        perf-stat.ipc
> >       0.37              -3%       0.35        perf-stat.branch-miss-rate%
> >      29.83              -4%      28.66        perf-stat.cache-miss-rate%
> >  1.117e+10              -4%  1.071e+10        perf-stat.cache-misses
> >  7.232e+09             -14%  6.187e+09        perf-stat.node-stores
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
