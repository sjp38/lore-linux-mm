Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 608FF6B0068
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 04:54:26 -0500 (EST)
Date: Thu, 6 Dec 2012 10:54:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121206095423.GB10931@dhcp22.suse.cz>
References: <20121130144427.51A09169@pobox.sk>
 <20121130144431.GI29317@dhcp22.suse.cz>
 <20121130160811.6BB25BDD@pobox.sk>
 <20121130153942.GL29317@dhcp22.suse.cz>
 <20121130165937.F9564EBE@pobox.sk>
 <20121130161923.GN29317@dhcp22.suse.cz>
 <20121203151601.GA17093@dhcp22.suse.cz>
 <20121205023644.18C3006B@pobox.sk>
 <20121205141722.GA9714@dhcp22.suse.cz>
 <20121206012924.FE077FD7@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121206012924.FE077FD7@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 06-12-12 01:29:24, azurIt wrote:
> >OK, so the ENOMEM seems to be leaking from mem_cgroup_newpage_charge.
> >This can only happen if this was an atomic allocation request
> >(!__GFP_WAIT) or if oom is not allowed which is the case only for
> >transparent huge page allocation.
> >The first case can be excluded (in the clean 3.2 stable kernel) because
> >all callers of mem_cgroup_newpage_charge use GFP_KERNEL. The later one
> >should be OK because the page fault should fallback to a regular page if
> >THP allocation/charge fails.
> >[/me goes to double check]
> >Hmm do_huge_pmd_wp_page seems to charge a huge page and fails with
> >VM_FAULT_OOM without any fallback. We should do_huge_pmd_wp_page_fallback
> >instead. This has been fixed in 3.5-rc1 by 1f1d06c3 (thp, memcg: split
> >hugepage for memcg oom on cow) but it hasn't been backported to 3.2. The
> >patch applies to 3.2 without any further modifications. I didn't have
> >time to test it but if it helps you we should push this to the stable
> >tree.
> 
> 
> This, unfortunately, didn't fix the problem :(
> http://www.watchdog.sk/lkml/oom_mysqld3

Dohh. The very same stack mem_cgroup_newpage_charge called from the page
fault. The heavy inlining is not particularly helping here... So there
must be some other THP charge leaking out.
[/me is diving into the code again]

* do_huge_pmd_anonymous_page falls back to handle_pte_fault
* do_huge_pmd_wp_page_fallback falls back to simple pages so it doesn't
  charge the huge page
* do_huge_pmd_wp_page splits the huge page and retries with fallback to
  handle_pte_fault
* collapse_huge_page is not called in the page fault path
* do_wp_page, do_anonymous_page and __do_fault  operate on a single page
  so the memcg charging cannot return ENOMEM

There are no other callers AFAICS so I am getting clueless. Maybe more
debugging will tell us something (the inlining has been reduced for thp
paths which can reduce performance in thp page fault heavy workloads but
this will give us better traces - I hope).

Anyway do you see the same problem if transparent huge pages are
disabled?
echo never > /sys/kernel/mm/transparent_hugepage/enabled)
---
