Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id F0C906B0031
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 11:41:21 -0400 (EDT)
Date: Mon, 15 Jul 2013 17:41:19 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2] memcg: do not trap chargers with full callstack
 on OOM
Message-ID: <20130715154119.GA32435@dhcp22.suse.cz>
References: <20130705210246.11D2135A@pobox.sk>
 <20130705191854.GR17812@cmpxchg.org>
 <20130708014224.50F06960@pobox.sk>
 <20130709131029.GH20281@dhcp22.suse.cz>
 <20130709151921.5160C199@pobox.sk>
 <20130709135450.GI20281@dhcp22.suse.cz>
 <20130710182506.F25DF461@pobox.sk>
 <20130711072507.GA21667@dhcp22.suse.cz>
 <20130714012641.C2DA4E05@pobox.sk>
 <20130714015112.FFCB7AF7@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130714015112.FFCB7AF7@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com

On Sun 14-07-13 01:51:12, azurIt wrote:
> > CC: "Johannes Weiner" <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "cgroups mailinglist" <cgroups@vger.kernel.org>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com
> >> CC: "Johannes Weiner" <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "cgroups mailinglist" <cgroups@vger.kernel.org>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com
> >>On Wed 10-07-13 18:25:06, azurIt wrote:
> >>> >> Now i realized that i forgot to remove UID from that cgroup before
> >>> >> trying to remove it, so cgroup cannot be removed anyway (we are using
> >>> >> third party cgroup called cgroup-uid from Andrea Righi, which is able
> >>> >> to associate all user's processes with target cgroup). Look here for
> >>> >> cgroup-uid patch:
> >>> >> https://www.develer.com/~arighi/linux/patches/cgroup-uid/cgroup-uid-v8.patch
> >>> >> 
> >>> >> ANYWAY, i'm 101% sure that 'tasks' file was empty and 'under_oom' was
> >>> >> permanently '1'.
> >>> >
> >>> >This is really strange. Could you post the whole diff against stable
> >>> >tree you are using (except for grsecurity stuff and the above cgroup-uid
> >>> >patch)?
> >>> 
> >>> 
> >>> Here are all patches which i applied to kernel 3.2.48 in my last test:
> >>> http://watchdog.sk/lkml/patches3/
> >>
> >>The two patches from Johannes seem correct.
> >>
> >>From a quick look even grsecurity patchset shouldn't interfere as it
> >>doesn't seem to put any code between handle_mm_fault and mm_fault_error
> >>and there also doesn't seem to be any new handle_mm_fault call sites.
> >>
> >>But I cannot tell there aren't other code paths which would lead to a
> >>memcg charge, thus oom, without proper FAULT_FLAG_KERNEL handling.
> >
> >
> >Michal,
> >
> >now i can definitely confirm that problem with unremovable cgroups
> >persists. What info do you need from me? I applied also your little
> >'WARN_ON' patch.
> 
> Ok, i think you want this:
> http://watchdog.sk/lkml/kern4.log

Jul 14 01:11:39 server01 kernel: [  593.589087] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
Jul 14 01:11:39 server01 kernel: [  593.589451] [12021]  1333 12021   172027    64723   4       0             0 apache2
Jul 14 01:11:39 server01 kernel: [  593.589647] [12030]  1333 12030   172030    64748   2       0             0 apache2
Jul 14 01:11:39 server01 kernel: [  593.589836] [12031]  1333 12031   172030    64749   3       0             0 apache2
Jul 14 01:11:39 server01 kernel: [  593.590025] [12032]  1333 12032   170619    63428   3       0             0 apache2
Jul 14 01:11:39 server01 kernel: [  593.590213] [12033]  1333 12033   167934    60524   2       0             0 apache2
Jul 14 01:11:39 server01 kernel: [  593.590401] [12034]  1333 12034   170747    63496   4       0             0 apache2
Jul 14 01:11:39 server01 kernel: [  593.590588] [12035]  1333 12035   169659    62451   1       0             0 apache2
Jul 14 01:11:39 server01 kernel: [  593.590776] [12036]  1333 12036   167614    60384   3       0             0 apache2
Jul 14 01:11:39 server01 kernel: [  593.590984] [12037]  1333 12037   166342    58964   3       0             0 apache2
Jul 14 01:11:39 server01 kernel: [  593.591178] Memory cgroup out of memory: Kill process 12021 (apache2) score 847 or sacrifice child
Jul 14 01:11:39 server01 kernel: [  593.591370] Killed process 12021 (apache2) total-vm:688108kB, anon-rss:255472kB, file-rss:3420kB
Jul 14 01:11:41 server01 kernel: [  595.392920] ------------[ cut here ]------------
Jul 14 01:11:41 server01 kernel: [  595.393096] WARNING: at kernel/exit.c:888 do_exit+0x7d0/0x870()
Jul 14 01:11:41 server01 kernel: [  595.393256] Hardware name: S5000VSA
Jul 14 01:11:41 server01 kernel: [  595.393415] Pid: 12037, comm: apache2 Not tainted 3.2.48-grsec #1
Jul 14 01:11:41 server01 kernel: [  595.393577] Call Trace:
Jul 14 01:11:41 server01 kernel: [  595.393737]  [<ffffffff8105520a>] warn_slowpath_common+0x7a/0xb0
Jul 14 01:11:41 server01 kernel: [  595.393903]  [<ffffffff8105525a>] warn_slowpath_null+0x1a/0x20
Jul 14 01:11:41 server01 kernel: [  595.394068]  [<ffffffff81059c50>] do_exit+0x7d0/0x870
Jul 14 01:11:41 server01 kernel: [  595.394231]  [<ffffffff81050254>] ? thread_group_times+0x44/0xb0
Jul 14 01:11:41 server01 kernel: [  595.394392]  [<ffffffff81059d41>] do_group_exit+0x51/0xc0
Jul 14 01:11:41 server01 kernel: [  595.394551]  [<ffffffff81059dc7>] sys_exit_group+0x17/0x20
Jul 14 01:11:41 server01 kernel: [  595.394714]  [<ffffffff815caea6>] system_call_fastpath+0x18/0x1d
Jul 14 01:11:41 server01 kernel: [  595.394921] ---[ end trace 738570e688acf099 ]---

OK, so you had an OOM which has been handled by in-kernel oom handler
(it killed 12021) and 12037 was in the same group. The warning tells us
that it went through mem_cgroup_oom as well (otherwise it wouldn't have
memcg_oom.wait_on_memcg set and the warning wouldn't trigger) and then
it exited on the userspace request (by exit syscall).

I do not see any way how, this could happen though. If mem_cgroup_oom
is called then we always return CHARGE_NOMEM which turns into ENOMEM
returned by __mem_cgroup_try_charge (invoke_oom must have been set to
true).  So if nobody screwed the return value on the way up to page
fault handler then there is no way to escape.

I will check the code.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
