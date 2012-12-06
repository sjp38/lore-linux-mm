Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 657B16B00B0
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 12:07:01 -0500 (EST)
Date: Thu, 6 Dec 2012 18:06:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121206170658.GD10931@dhcp22.suse.cz>
References: <20121130160811.6BB25BDD@pobox.sk>
 <20121130153942.GL29317@dhcp22.suse.cz>
 <20121130165937.F9564EBE@pobox.sk>
 <20121130161923.GN29317@dhcp22.suse.cz>
 <20121203151601.GA17093@dhcp22.suse.cz>
 <20121205023644.18C3006B@pobox.sk>
 <20121205141722.GA9714@dhcp22.suse.cz>
 <20121206012924.FE077FD7@pobox.sk>
 <20121206095423.GB10931@dhcp22.suse.cz>
 <20121206111249.58F013EA@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121206111249.58F013EA@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 06-12-12 11:12:49, azurIt wrote:
> >Dohh. The very same stack mem_cgroup_newpage_charge called from the page
> >fault. The heavy inlining is not particularly helping here... So there
> >must be some other THP charge leaking out.
> >[/me is diving into the code again]
> >
> >* do_huge_pmd_anonymous_page falls back to handle_pte_fault
> >* do_huge_pmd_wp_page_fallback falls back to simple pages so it doesn't
> >  charge the huge page
> >* do_huge_pmd_wp_page splits the huge page and retries with fallback to
> >  handle_pte_fault
> >* collapse_huge_page is not called in the page fault path
> >* do_wp_page, do_anonymous_page and __do_fault  operate on a single page
> >  so the memcg charging cannot return ENOMEM
> >
> >There are no other callers AFAICS so I am getting clueless. Maybe more
> >debugging will tell us something (the inlining has been reduced for thp
> >paths which can reduce performance in thp page fault heavy workloads but
> >this will give us better traces - I hope).
> 
> 
> Should i apply all patches togather? (fix for this bug, more log
> messages, backported fix from 3.5 and this new one)

Yes please
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
