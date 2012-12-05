Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 528EC6B0044
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 09:17:25 -0500 (EST)
Date: Wed, 5 Dec 2012 15:17:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121205141722.GA9714@dhcp22.suse.cz>
References: <20121130032918.59B3F780@pobox.sk>
 <20121130124506.GH29317@dhcp22.suse.cz>
 <20121130144427.51A09169@pobox.sk>
 <20121130144431.GI29317@dhcp22.suse.cz>
 <20121130160811.6BB25BDD@pobox.sk>
 <20121130153942.GL29317@dhcp22.suse.cz>
 <20121130165937.F9564EBE@pobox.sk>
 <20121130161923.GN29317@dhcp22.suse.cz>
 <20121203151601.GA17093@dhcp22.suse.cz>
 <20121205023644.18C3006B@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121205023644.18C3006B@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed 05-12-12 02:36:44, azurIt wrote:
> >The following should print the traces when we hand over ENOMEM to the
> >caller. It should catch all charge paths (migration is not covered but
> >that one is not important here). If we don't see any traces from here
> >and there is still global OOM striking then there must be something else
> >to trigger this.
> >Could you test this with the patch which aims at fixing your deadlock,
> >please? I realise that this is a production environment but I do not see
> >anything relevant in the code.
> 
> 
> Michal,
> 
> i think/hope this is what you wanted:
> http://www.watchdog.sk/lkml/oom_mysqld2

Dec  5 02:20:48 server01 kernel: [  380.995947] WARNING: at mm/memcontrol.c:2400 T.1146+0x2c1/0x5d0()
Dec  5 02:20:48 server01 kernel: [  380.995950] Hardware name: S5000VSA
Dec  5 02:20:48 server01 kernel: [  380.995952] Pid: 5351, comm: apache2 Not tainted 3.2.34-grsec #1
Dec  5 02:20:48 server01 kernel: [  380.995954] Call Trace:
Dec  5 02:20:48 server01 kernel: [  380.995960]  [<ffffffff81054eaa>] warn_slowpath_common+0x7a/0xb0
Dec  5 02:20:48 server01 kernel: [  380.995963]  [<ffffffff81054efa>] warn_slowpath_null+0x1a/0x20
Dec  5 02:20:48 server01 kernel: [  380.995965]  [<ffffffff8110b2e1>] T.1146+0x2c1/0x5d0
Dec  5 02:20:48 server01 kernel: [  380.995967]  [<ffffffff8110ba83>] mem_cgroup_charge_common+0x53/0x90
Dec  5 02:20:48 server01 kernel: [  380.995970]  [<ffffffff8110bb05>] mem_cgroup_newpage_charge+0x45/0x50
Dec  5 02:20:48 server01 kernel: [  380.995974]  [<ffffffff810eddf9>] handle_pte_fault+0x609/0x940
Dec  5 02:20:48 server01 kernel: [  380.995978]  [<ffffffff8102aa8f>] ? pte_alloc_one+0x3f/0x50
Dec  5 02:20:48 server01 kernel: [  380.995981]  [<ffffffff810ee268>] handle_mm_fault+0x138/0x260
Dec  5 02:20:48 server01 kernel: [  380.995983]  [<ffffffff810270ed>] do_page_fault+0x13d/0x460
Dec  5 02:20:48 server01 kernel: [  380.995986]  [<ffffffff810f429c>] ? do_mmap_pgoff+0x3dc/0x430
Dec  5 02:20:48 server01 kernel: [  380.995988]  [<ffffffff810f197d>] ? remove_vma+0x5d/0x80
Dec  5 02:20:48 server01 kernel: [  380.995992]  [<ffffffff815b54ff>] page_fault+0x1f/0x30
Dec  5 02:20:48 server01 kernel: [  380.995994] ---[ end trace 25bbb3e634c25b7f ]---
Dec  5 02:20:48 server01 kernel: [  380.996373] apache2 invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0, oom_score_adj=0
Dec  5 02:20:48 server01 kernel: [  380.996377] apache2 cpuset=uid mems_allowed=0
Dec  5 02:20:48 server01 kernel: [  380.996379] Pid: 5351, comm: apache2 Tainted: G        W    3.2.34-grsec #1
Dec  5 02:20:48 server01 kernel: [  380.996380] Call Trace:
Dec  5 02:20:48 server01 kernel: [  380.996384]  [<ffffffff810cc91e>] dump_header+0x7e/0x1e0
Dec  5 02:20:48 server01 kernel: [  380.996387]  [<ffffffff810cc81f>] ? find_lock_task_mm+0x2f/0x70
Dec  5 02:20:48 server01 kernel: [  380.996389]  [<ffffffff810ccde5>] oom_kill_process+0x85/0x2a0
Dec  5 02:20:48 server01 kernel: [  380.996392]  [<ffffffff810cd495>] out_of_memory+0xe5/0x200
Dec  5 02:20:48 server01 kernel: [  380.996394]  [<ffffffff8102aa8f>] ? pte_alloc_one+0x3f/0x50
Dec  5 02:20:48 server01 kernel: [  380.996397]  [<ffffffff810cd66d>] pagefault_out_of_memory+0xbd/0x110
Dec  5 02:20:48 server01 kernel: [  380.996399]  [<ffffffff81026ec6>] mm_fault_error+0xb6/0x1a0
Dec  5 02:20:48 server01 kernel: [  380.996401]  [<ffffffff8102739e>] do_page_fault+0x3ee/0x460
Dec  5 02:20:48 server01 kernel: [  380.996403]  [<ffffffff810f429c>] ? do_mmap_pgoff+0x3dc/0x430
Dec  5 02:20:48 server01 kernel: [  380.996405]  [<ffffffff810f197d>] ? remove_vma+0x5d/0x80
Dec  5 02:20:48 server01 kernel: [  380.996408]  [<ffffffff815b54ff>] page_fault+0x1f/0x30

OK, so the ENOMEM seems to be leaking from mem_cgroup_newpage_charge.
This can only happen if this was an atomic allocation request
(!__GFP_WAIT) or if oom is not allowed which is the case only for
transparent huge page allocation.
The first case can be excluded (in the clean 3.2 stable kernel) because
all callers of mem_cgroup_newpage_charge use GFP_KERNEL. The later one
should be OK because the page fault should fallback to a regular page if
THP allocation/charge fails.
[/me goes to double check]
Hmm do_huge_pmd_wp_page seems to charge a huge page and fails with
VM_FAULT_OOM without any fallback. We should do_huge_pmd_wp_page_fallback
instead. This has been fixed in 3.5-rc1 by 1f1d06c3 (thp, memcg: split
hugepage for memcg oom on cow) but it hasn't been backported to 3.2. The
patch applies to 3.2 without any further modifications. I didn't have
time to test it but if it helps you we should push this to the stable
tree.
---
