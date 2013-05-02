Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 871B16B0260
	for <linux-mm@kvack.org>; Thu,  2 May 2013 10:17:12 -0400 (EDT)
Date: Thu, 2 May 2013 16:17:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add anon_hugepage stat
Message-ID: <20130502141709.GM1950@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com>
 <20130426111739.GF31157@dhcp22.suse.cz>
 <alpine.DEB.2.02.1304281432160.5570@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304281432160.5570@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Sun 28-04-13 14:40:37, David Rientjes wrote:
> On Fri, 26 Apr 2013, Michal Hocko wrote:
> 
> > Yes, useful and I had it on my todo list for quite some time. Never got
> > to it though. Thanks!
> > 
> 
> I think I'll add an anon_pages counter as well for non-thp for comparison, 

I am not sure I understand. I assume you want to export the anon counter
as well, right? Wouldn't that be too confusing? Yes, rss is a terrible
name and mixing it with swapcache is arguably a good idea but are there
any cases where you want anon - swapcache?

> and probably do it in the same patch.
> 
> The problem is that we don't always have the memcg context for the page 
> when calling page_add_anon_rmap() or page_remove_rmap().
> 
>  [ An example in this patch is in page_remove_rmap() where I was calling 
>    mem_cgroup_update_page_stat() after mem_cgroup_uncharge_page(). ]
> 
> For example, in unuse_pte():
> 
> 	if (page == swapcache)
> 		page_add_anon_rmap(page, vma, addr);
> 	else /* ksm created a completely new copy */
> 		page_add_new_anon_rmap(page, vma, addr);
> 	mem_cgroup_commit_charge_swapin(page, memcg);
> 
> There are a couple of options to fix this and I really don't have a strong 
> preference for which one we go with:
> 
>  - pass struct mem_cgroup * to page_add_anon_rmap() and 
>    page_remove_rmap(), such as "memcg" in the above example), or
> 
>  - separate out the anon page/hugepage ZVC accounting entirely from these 
>    two functions and add a followup call to a new function dedicated for 
>    this purpose once the memcg commit has been done.
> 
> I'm leaning toward doing the latter just because it's cleaner, but it 
> means page_remove_rmap() picks up a return value (anon or not?) and 
> page_add_anon_rmap() picks up a return value (_mapcount == 0?).
> 
> Comments?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
