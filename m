Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id A96836B0033
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 05:53:34 -0400 (EDT)
Date: Thu, 5 Sep 2013 11:53:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130905095331.GA9702@dhcp22.suse.cz>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
 <20130803170831.GB23319@cmpxchg.org>
 <20130830215852.3E5D3D66@pobox.sk>
 <20130902123802.5B8E8CB1@pobox.sk>
 <20130903204850.GA1412@cmpxchg.org>
 <20130904114523.A9F0173C@pobox.sk>
 <20130904115741.GA28285@dhcp22.suse.cz>
 <20130904141000.0F910EFA@pobox.sk>
 <20130904122632.GB28285@dhcp22.suse.cz>
 <20130905111430.CB1392B4@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130905111430.CB1392B4@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-09-13 11:14:30, azurIt wrote:
[...]
> My script detected another freezed cgroup today, sending stacks. Is
> there anything interesting?

3 tasks are sleeping and waiting for somebody to take an action to
resolve memcg OOM. The memcg oom killer is enabled for that group?  If
yes, which task has been selected to be killed? You can find that in oom
report in dmesg.

I can see a way how this might happen. If the killed task happened to
allocate a memory while it is exiting then it would get to the oom
condition again without freeing any memory so nobody waiting on the
memcg_oom_waitq gets woken. We have a report like that: 
https://lkml.org/lkml/2013/7/31/94

The issue got silent in the meantime so it is time to wake it up.
It would be definitely good to see what happened in your case though.
If any of the bellow tasks was the oom victim then it is very probable
this is the same issue.

> pid: 1031
[...]
> stack:
> [<ffffffff8110f255>] mem_cgroup_oom_synchronize+0x165/0x190
> [<ffffffff810d269e>] pagefault_out_of_memory+0xe/0x120
> [<ffffffff81026f5e>] mm_fault_error+0x9e/0x150
> [<ffffffff81027414>] do_page_fault+0x404/0x490
> [<ffffffff815cb7bf>] page_fault+0x1f/0x30
> [<ffffffffffffffff>] 0xffffffffffffffff
[...]
> pid: 1036
> stack:
> [<ffffffff8110f255>] mem_cgroup_oom_synchronize+0x165/0x190
> [<ffffffff810d269e>] pagefault_out_of_memory+0xe/0x120
> [<ffffffff81026f5e>] mm_fault_error+0x9e/0x150
> [<ffffffff81027414>] do_page_fault+0x404/0x490
> [<ffffffff815cb7bf>] page_fault+0x1f/0x30
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> pid: 1038
> stack:
> [<ffffffff8110f255>] mem_cgroup_oom_synchronize+0x165/0x190
> [<ffffffff810d269e>] pagefault_out_of_memory+0xe/0x120
> [<ffffffff81026f5e>] mm_fault_error+0x9e/0x150
> [<ffffffff81027414>] do_page_fault+0x404/0x490
> [<ffffffff815cb7bf>] page_fault+0x1f/0x30
> [<ffffffffffffffff>] 0xffffffffffffffff

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
