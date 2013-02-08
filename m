Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 8EDB16B0008
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 04:44:24 -0500 (EST)
Date: Fri, 8 Feb 2013 10:44:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM if PF_NO_MEMCG_OOM
 is set
Message-ID: <20130208094420.GA7557@dhcp22.suse.cz>
References: <20130125160723.FAE73567@pobox.sk>
 <20130125163130.GF4721@dhcp22.suse.cz>
 <20130205134937.GA22804@dhcp22.suse.cz>
 <20130205154947.CD6411E2@pobox.sk>
 <20130205160934.GB22804@dhcp22.suse.cz>
 <20130206021721.1AE9E3C7@pobox.sk>
 <20130206140119.GD10254@dhcp22.suse.cz>
 <20130206142219.GF10254@dhcp22.suse.cz>
 <20130206160051.GG10254@dhcp22.suse.cz>
 <20130208060304.799F362F@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130208060304.799F362F@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 08-02-13 06:03:04, azurIt wrote:
> Michal, thank you very much but it just didn't work and broke
> everything :(

I am sorry to hear that. The patch should help to solve the deadlock you
have seen earlier. It in no way can solve side effects of failing writes
and it also cannot help much if the oom is permanent.

> This happened:
> Problem started to occur really often immediately after booting the
> new kernel, every few minutes for one of my users. But everything
> other seems to work fine so i gave it a try for a day (which was a
> mistake). I grabbed some data for you and go to sleep:
> http://watchdog.sk/lkml/memcg-bug-4.tar.gz

Do you have logs from that time period?

I have only glanced through the stacks and most of the threads are
waiting in the mem_cgroup_handle_oom (mostly from the page fault path
where we do not have other options than waiting) which suggests that
your memory limit is seriously underestimated. If you look at the number
of charging failures (memory.failcnt per-group file) then you will get
9332083 failures in _average_ per group. This is a lot!
Not all those failures end with OOM, of course. But it clearly signals
that the workload need much more memory than the limit allows.

> Few hours later i was woke up from my sweet sweet dreams by alerts
> smses - Apache wasn't working and our system failed to restart
> it. When i observed the situation, two apache processes (of that user
> as above) were still running and it wasn't possible to kill them by
> any way. I grabbed some data for you:
> http://watchdog.sk/lkml/memcg-bug-5.tar.gz

There are only 5 groups in this one and all of them have no memory
charged (so no OOM going on). All tasks are somewhere in the ptrace
code.

grep cache -r .
./1360297489/memory.stat:cache 0
./1360297489/memory.stat:total_cache 65642496
./1360297491/memory.stat:cache 0
./1360297491/memory.stat:total_cache 65642496
./1360297492/memory.stat:cache 0
./1360297492/memory.stat:total_cache 65642496
./1360297490/memory.stat:cache 0
./1360297490/memory.stat:total_cache 65642496
./1360297488/memory.stat:cache 0
./1360297488/memory.stat:total_cache 65642496

which suggests that this is a parent group and the memory is charged in
a child group. I guess that all those are under OOM as the number seems
like they have limit at 62M.

> Then I logged to the console and this was waiting for me:
> http://watchdog.sk/lkml/error.jpg

This is just a warning and it should be harmless. There is just one WARN
in ptrace_check_attach:
	WARN_ON_ONCE(task_is_stopped(child))

This has been introduced by
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=321fb561
and the commit description claim this shouldn't happen. I am not
familiar with this code but it sounds like a bug in the tracing code
which is not related to the discussed issue.

> Finally i rebooted into different kernel, wrote this e-mail and go to
> my lovely bed ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
