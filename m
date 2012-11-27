Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 3173C6B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 15:54:40 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so5237955eaa.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 12:54:38 -0800 (PST)
Date: Tue, 27 Nov 2012 21:54:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2 -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121127205431.GA2433@dhcp22.suse.cz>
References: <20121123074023.GA24698@dhcp22.suse.cz>
 <20121123102137.10D6D653@pobox.sk>
 <20121123100438.GF24698@dhcp22.suse.cz>
 <20121125011047.7477BB5E@pobox.sk>
 <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <50B403CA.501@jp.fujitsu.com>
 <20121127194813.GP24381@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121127194813.GP24381@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Tue 27-11-12 14:48:13, Johannes Weiner wrote:
[...]
> > >diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > >index 10e667f..aac9b21 100644
> > >--- a/include/linux/gfp.h
> > >+++ b/include/linux/gfp.h
> > >@@ -152,6 +152,9 @@ struct vm_area_struct;
> > >  /* 4GB DMA on some platforms */
> > >  #define GFP_DMA32	__GFP_DMA32
> > >
> > >+/* memcg oom killer is not allowed */
> > >+#define GFP_MEMCG_NO_OOM	__GFP_NORETRY
> 
> Could we leave this within memcg, please?  An extra flag to
> mem_cgroup_cache_charge() or the like.  GFP flags are about
> controlling the page allocator, this seems abusive.  We have an oom
> flag down in try_charge, maybe just propagate this up the stack?

OK, what about the patch bellow?
I have dropped Kame's Acked-by because it has been reworked. The patch
is the same in principle.

> > >diff --git a/mm/filemap.c b/mm/filemap.c
> > >index 83efee7..ef14351 100644
> > >--- a/mm/filemap.c
> > >+++ b/mm/filemap.c
> > >@@ -447,7 +447,13 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
> > >  	VM_BUG_ON(!PageLocked(page));
> > >  	VM_BUG_ON(PageSwapBacked(page));
> > >
> > >-	error = mem_cgroup_cache_charge(page, current->mm,
> > >+	/*
> > >+	 * Cannot trigger OOM even if gfp_mask would allow that normally
> > >+	 * because we might be called from a locked context and that
> > >+	 * could lead to deadlocks if the killed process is waiting for
> > >+	 * the same lock.
> > >+	 */
> > >+	error = mem_cgroup_cache_charge_no_oom(page, current->mm,
> > >  					gfp_mask & GFP_RECLAIM_MASK);
> > >  	if (error)
> > >  		goto out;
> 
> Shmem does not use this function but also charges under the i_mutex in
> the write path and fallocate at least.

Right you are
---
