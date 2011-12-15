Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 6140F6B0075
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 09:55:02 -0500 (EST)
Date: Thu, 15 Dec 2011 15:54:52 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH 4/5] memcg: remove PCG_CACHE bit
Message-ID: <20111215145452.GJ3047@cmpxchg.org>
References: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
 <20111215150822.7b609f89.kamezawa.hiroyu@jp.fujitsu.com>
 <20111215102442.GI3047@cmpxchg.org>
 <20111215193631.782a3e8b.kamezawa.hiroyu@jp.fujitsu.com>
 <20111215210406.093c9a4e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111215210406.093c9a4e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, Dec 15, 2011 at 09:04:06PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Dec 2011 19:36:31 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 15 Dec 2011 11:24:42 +0100
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > > What I think is required is to break up the charging and committing
> > > like we do for swap cache already:
> > > 
> > > 	if (!mem_cgroup_try_charge())
> > > 		goto error;
> > > 	page_add_new_anon_rmap()
> > > 	mem_cgroup_commit()
> > > 
> > > This will also allow us to even get rid of passing around the charge
> > > type everywhere...
> > > 
> > 
> > Thank you. I'll look into.
> > 
> > To be honest, I want to remove 'rss' and 'cache' counter ;(
> > This doesn't have much meanings after lru was splitted.
> > 
> 
> I'll use this version for test. This patch is under far deep stacks of
> unmerged patches, anyway.

Ok, makes sense.  I can do the PCG_CACHE removal, btw, I have half the
patches sitting around anyway, just need to fix up huge_memory.c.

> @@ -2938,9 +2948,13 @@ void mem_cgroup_uncharge_page(struct page *page)
>  
>  void mem_cgroup_uncharge_cache_page(struct page *page)
>  {
> +	int ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
>  	VM_BUG_ON(page_mapped(page));
>  	VM_BUG_ON(page->mapping);
> -	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> +
> +	if (page_is_file_cache(page))
> +		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> +	__mem_cgroup_uncharge_common(page, ctype);

I think this is missing a negation, but it doesn't matter because the
SHMEM and CACHE charge types are treated exactly the same way.  I'll
send a patch series that removes it soon, there is more shmem related
things...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
