Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 491936B0005
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 10:24:05 -0500 (EST)
Date: Fri, 8 Feb 2013 16:24:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM if PF_NO_MEMCG_OOM
 is set
Message-ID: <20130208152402.GD7557@dhcp22.suse.cz>
References: <20130205160934.GB22804@dhcp22.suse.cz>
 <20130206021721.1AE9E3C7@pobox.sk>
 <20130206140119.GD10254@dhcp22.suse.cz>
 <20130206142219.GF10254@dhcp22.suse.cz>
 <20130206160051.GG10254@dhcp22.suse.cz>
 <20130208060304.799F362F@pobox.sk>
 <20130208094420.GA7557@dhcp22.suse.cz>
 <20130208120249.FD733220@pobox.sk>
 <20130208123854.GB7557@dhcp22.suse.cz>
 <20130208145616.FB78CE24@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130208145616.FB78CE24@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 08-02-13 14:56:16, azurIt wrote:
> >kernel log would be sufficient.
> 
> 
> Full kernel log from kernel with you newest patch:
> http://watchdog.sk/lkml/kern2.log

OK, so the log says that there is a little slaughter on your yard:
$ grep "Memory cgroup out of memory:" kern2.log | wc -l
220

$ grep "Memory cgroup out of memory:" kern2.log | sed 's@.*Kill process \([0-9]*\) .*@\1@' | sort -u | wc -l
220

Which means that the oom killer didn't try to kill any task more than
once which is good because it tells us that the killed task manages to
die before we trigger oom again. So this is definitely not a deadlock.
You are just hitting OOM very often.
$ grep "killed as a result of limit" kern2.log | sed 's@.*\] @@' | sort | uniq -c | sort -k1 -n
      1 Task in /1091/uid killed as a result of limit of /1091
      1 Task in /1223/uid killed as a result of limit of /1223
      1 Task in /1229/uid killed as a result of limit of /1229
      1 Task in /1255/uid killed as a result of limit of /1255
      1 Task in /1424/uid killed as a result of limit of /1424
      1 Task in /1470/uid killed as a result of limit of /1470
      1 Task in /1567/uid killed as a result of limit of /1567
      2 Task in /1080/uid killed as a result of limit of /1080
      3 Task in /1381/uid killed as a result of limit of /1381
      4 Task in /1185/uid killed as a result of limit of /1185
      4 Task in /1289/uid killed as a result of limit of /1289
      4 Task in /1709/uid killed as a result of limit of /1709
      5 Task in /1279/uid killed as a result of limit of /1279
      6 Task in /1020/uid killed as a result of limit of /1020
      6 Task in /1527/uid killed as a result of limit of /1527
      9 Task in /1388/uid killed as a result of limit of /1388
     17 Task in /1281/uid killed as a result of limit of /1281
     22 Task in /1599/uid killed as a result of limit of /1599
     30 Task in /1155/uid killed as a result of limit of /1155
     31 Task in /1258/uid killed as a result of limit of /1258
     71 Task in /1293/uid killed as a result of limit of /1293

So the group 1293 suffers the most. I would check how much memory the
worklod in the group really needs because this level of OOM cannot
possible be healthy.

The log also says that the deadlock prevention implemented by the patch
triggered and some writes really failed due to potential OOM:
$ grep "If this message shows up" kern2.log 
Feb  8 01:17:10 server01 kernel: [  431.033593] __mem_cgroup_try_charge: task:apache2 pid:6733 got ENOMEM without OOM for memcg:ffff8803807d5600. If this message shows up very often for the same task then there is a risk that the process is not able to make any progress because of the current limit. Try to enlarge the hard limit.
Feb  8 01:22:52 server01 kernel: [  773.556782] __mem_cgroup_try_charge: task:apache2 pid:12092 got ENOMEM without OOM for memcg:ffff8803807d5600. If this message shows up very often for the same task then there is a risk that the process is not able to make any progress because of the current limit. Try to enlarge the hard limit.
Feb  8 01:22:52 server01 kernel: [  773.567916] __mem_cgroup_try_charge: task:apache2 pid:12093 got ENOMEM without OOM for memcg:ffff8803807d5600. If this message shows up very often for the same task then there is a risk that the process is not able to make any progress because of the current limit. Try to enlarge the hard limit.
Feb  8 01:29:00 server01 kernel: [ 1141.355693] __mem_cgroup_try_charge: task:apache2 pid:17734 got ENOMEM without OOM for memcg:ffff88036e956e00. If this message shows up very often for the same task then there is a risk that the process is not able to make any progress because of the current limit. Try to enlarge the hard limit.
Feb  8 03:30:39 server01 kernel: [ 8440.346811] __mem_cgroup_try_charge: task:apache2 pid:8687 got ENOMEM without OOM for memcg:ffff8803654d6e00. If this message shows up very often for the same task then there is a risk that the process is not able to make any progress because of the current limit. Try to enlarge the hard limit.

This doesn't look very unhealthy. I have expected that write would fail
more often but it seems that the biggest memory pressure comes from
mmaps and page faults which have no way other than OOM.

So my suggestion would be to reconsider limits for groups to provide
more realistical environment.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
