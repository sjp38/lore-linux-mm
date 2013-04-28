Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 060D86B0034
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 17:40:40 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id mc17so1499093pbc.39
        for <linux-mm@kvack.org>; Sun, 28 Apr 2013 14:40:40 -0700 (PDT)
Date: Sun, 28 Apr 2013 14:40:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add anon_hugepage stat
In-Reply-To: <20130426111739.GF31157@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1304281432160.5570@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com> <20130426111739.GF31157@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Fri, 26 Apr 2013, Michal Hocko wrote:

> Yes, useful and I had it on my todo list for quite some time. Never got
> to it though. Thanks!
> 

I think I'll add an anon_pages counter as well for non-thp for comparison, 
and probably do it in the same patch.

The problem is that we don't always have the memcg context for the page 
when calling page_add_anon_rmap() or page_remove_rmap().

 [ An example in this patch is in page_remove_rmap() where I was calling 
   mem_cgroup_update_page_stat() after mem_cgroup_uncharge_page(). ]

For example, in unuse_pte():

	if (page == swapcache)
		page_add_anon_rmap(page, vma, addr);
	else /* ksm created a completely new copy */
		page_add_new_anon_rmap(page, vma, addr);
	mem_cgroup_commit_charge_swapin(page, memcg);

There are a couple of options to fix this and I really don't have a strong 
preference for which one we go with:

 - pass struct mem_cgroup * to page_add_anon_rmap() and 
   page_remove_rmap(), such as "memcg" in the above example), or

 - separate out the anon page/hugepage ZVC accounting entirely from these 
   two functions and add a followup call to a new function dedicated for 
   this purpose once the memcg commit has been done.

I'm leaning toward doing the latter just because it's cleaner, but it 
means page_remove_rmap() picks up a return value (anon or not?) and 
page_add_anon_rmap() picks up a return value (_mapcount == 0?).

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
