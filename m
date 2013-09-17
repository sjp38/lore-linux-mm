Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 25D8C6B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 07:15:38 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Tue, 17 Sep 2013 13:15:35 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130911200426.GO856@cmpxchg.org>, <20130914124831.4DD20346@pobox.sk>, <20130916134014.GA3674@dhcp22.suse.cz>, <20130916160119.2E76C2A1@pobox.sk>, <20130916140607.GC3674@dhcp22.suse.cz>, <20130916161316.5113F6E7@pobox.sk>, <20130916145744.GE3674@dhcp22.suse.cz>, <20130916170543.77F1ECB4@pobox.sk>, <20130916152548.GF3674@dhcp22.suse.cz>, <20130916225246.A633145B@pobox.sk> <20130917000244.GD3278@cmpxchg.org>
In-Reply-To: <20130917000244.GD3278@cmpxchg.org>
MIME-Version: 1.0
Message-Id: <20130917131535.94E0A843@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>
Cc: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>, =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

______________________________________________________________
> Od: Johannes Weiner <hannes@cmpxchg.org>
> Komu: azurIt <azurit@pobox.sk>
> DA!tum: 17.09.2013 02:02
> Predmet: Re: [patch 0/7] improve memcg oom killer robustness v2
>
> CC: "Michal Hocko" <mhocko@suse.cz>, "Andrew Morton" <akpm@linux-foundation.org>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>On Mon, Sep 16, 2013 at 10:52:46PM +0200, azurIt wrote:
>> > CC: "Johannes Weiner" <hannes@cmpxchg.org>, "Andrew Morton" <akpm@linux-foundation.org>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>> >On Mon 16-09-13 17:05:43, azurIt wrote:
>> >> > CC: "Johannes Weiner" <hannes@cmpxchg.org>, "Andrew Morton" <akpm@linux-foundation.org>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>> >> >On Mon 16-09-13 16:13:16, azurIt wrote:
>> >> >[...]
>> >> >> >You can use sysrq+l via serial console to see tasks hogging the CPU or
>> >> >> >sysrq+t to see all the existing tasks.
>> >> >> 
>> >> >> 
>> >> >> Doesn't work here, it just prints 'l' resp. 't'.
>> >> >
>> >> >I am using telnet for accessing my serial consoles exported by
>> >> >the multiplicator or KVM and it can send sysrq via ctrl+t (Send
>> >> >Break). Check your serial console setup.
>> >> 
>> >> 
>> >> 
>> >> I'm using Raritan KVM and i created keyboard macro 'sysrq + l' resp.
>> >> 'sysrq + t'. I'm also unable to use it on my local PC. Maybe it needs
>> >> to be enabled somehow?
>> >
>> >Probably yes. echo 1 > /proc/sys/kernel/sysrq should enable all sysrq
>> >commands. You can select also some of them (have a look at
>> >Documentation/sysrq.txt for more information)
>> 
>> 
>> Now it happens again and i was just looking on the server's
>> htop. I'm sure that this time it was only one process (apache)
>> running under user account (not root). It was taking about 100% CPU
>> (about 100% of one core). I was able to kill it by hand inside htop
>> but everything was very slow, server load was immediately on
>> 500. I'm sure it must be related to that Johannes kernel patches
>> because i'm also using i/o throttling in cgroups via Block IO
>> controller so users are unable to create such a huge I/O. I will try
>> to take stacks of processes but i'm not able to identify the
>> problematic process so i will have to take them from *all* apache
>> processes while killing them.
>
>It would be fantastic if you could capture those stacks.  sysrq+t
>captures ALL of them in one go and drops them into your syslog.
>
>/proc/<pid>/stack for individual tasks works too.


Is something unusual on this stack?


[<ffffffff810d1a5e>] dump_header+0x7e/0x1e0
[<ffffffff810d195f>] ? find_lock_task_mm+0x2f/0x70
[<ffffffff810d1f25>] oom_kill_process+0x85/0x2a0
[<ffffffff810d24a8>] mem_cgroup_out_of_memory+0xa8/0xf0
[<ffffffff8110fb76>] mem_cgroup_oom_synchronize+0x2e6/0x310
[<ffffffff8110efc0>] ? mem_cgroup_uncharge_page+0x40/0x40
[<ffffffff810d2703>] pagefault_out_of_memory+0x13/0x130
[<ffffffff81026f6e>] mm_fault_error+0x9e/0x150
[<ffffffff81027424>] do_page_fault+0x404/0x490
[<ffffffff810f952c>] ? do_mmap_pgoff+0x3dc/0x430
[<ffffffff815cb87f>] page_fault+0x1f/0x30


Problem happens again but my script was unable to get stacks. I was able to see processes which were doing problems (two this time) and i have their PIDs. The stack above is from different process but from the same cgroup (memcg OOM killed it and prints it's stack into syslog).

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
