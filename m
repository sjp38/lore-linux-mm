Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9F8fxbE004674
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 15 Oct 2008 17:41:59 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 737D853C160
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 17:41:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BB82240049
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 17:41:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 322DA1DB8041
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 17:41:59 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4A251DB803C
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 17:41:58 +0900 (JST)
Date: Wed, 15 Oct 2008 17:41:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] memcg: migration account fix
Message-Id: <20081015174138.e8b92d48.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081015171655.1e19ebeb.nishimura@mxp.nes.nec.co.jp>
References: <20081010175936.f3b1f4e0.kamezawa.hiroyu@jp.fujitsu.com>
	<20081010180335.c9cf53c4.kamezawa.hiroyu@jp.fujitsu.com>
	<20081015171655.1e19ebeb.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Oct 2008 17:16:55 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > @@ -795,43 +767,67 @@ int mem_cgroup_prepare_migration(struct 
> >  	if (PageCgroupUsed(pc)) {
> >  		mem = pc->mem_cgroup;
> >  		css_get(&mem->css);
> > -		if (PageCgroupCache(pc)) {
> > -			if (page_is_file_cache(page))
> > -				ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> > -			else
> > -				ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> > -		}
> >  	}
> >  	unlock_page_cgroup(pc);
> > +
> >  	if (mem) {
> > -		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
> > -			ctype, mem);
> > +		ret = mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem);
> >  		css_put(&mem->css);
> > +		*ptr = mem;
> >  	}
> >  	return ret;
> >  }
> >  
> "*ptr = mem" should be outside of if(mem).
> Otherwise, ptr would be kept unset when !PageCgroupUsed.
> (unmap_and_move, caller of prepare_migration, doesn't initilize it.)
> 
Hmm, I see.

> And,
> 
> >  /* remove redundant charge if migration failed*/
> > -void mem_cgroup_end_migration(struct page *newpage)
> > +void mem_cgroup_end_migration(struct mem_cgroup *mem,
> > +		struct page *oldpage, struct page *newpage)
> >  {
> > +	struct page *target, *unused;
> > +	struct page_cgroup *pc;
> > +	enum charge_type ctype;
> > +
> mem_cgroup_end_migration should handle "mem == NULL" case
> (just return would be enough).
> 
ya, you're right.

> > +	/* at migration success, oldpage->mapping is NULL. */
> > +	if (oldpage->mapping) {
> > +		target = oldpage;
> > +		unused = NULL;
> > +	} else {
> > +		target = newpage;
> > +		unused = oldpage;
> > +	}
> > +
> > +	if (PageAnon(target))
> > +		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> > +	else if (page_is_file_cache(target))
> > +		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> > +	else
> > +		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> > +
> > +	/* unused page is not on radix-tree now. */
> > +	if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)
> > +		__mem_cgroup_uncharge_common(unused, ctype);
> > +
> > +	pc = lookup_page_cgroup(target);
> >  	/*
> > -	 * At success, page->mapping is not NULL.
> > -	 * special rollback care is necessary when
> > -	 * 1. at migration failure. (newpage->mapping is cleared in this case)
> > -	 * 2. the newpage was moved but not remapped again because the task
> > -	 *    exits and the newpage is obsolete. In this case, the new page
> > -	 *    may be a swapcache. So, we just call mem_cgroup_uncharge_page()
> > -	 *    always for avoiding mess. The  page_cgroup will be removed if
> > -	 *    unnecessary. File cache pages is still on radix-tree. Don't
> > -	 *    care it.
> > +	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
> > +	 * So, double-counting is effectively avoided.
> >  	 */
> > -	if (!newpage->mapping)
> > -		__mem_cgroup_uncharge_common(newpage,
> > -				MEM_CGROUP_CHARGE_TYPE_FORCE);
> > -	else if (PageAnon(newpage))
> > -		mem_cgroup_uncharge_page(newpage);
> > +	__mem_cgroup_commit_charge(mem, pc, ctype);
> > +
> > +	/*
> > +	 * Both of oldpage and newpage are still under lock_page().
> > +	 * Then, we don't have to care about race in radix-tree.
> > +	 * But we have to be careful that this page is unmapped or not.
> > +	 *
> > +	 * There is a case for !page_mapped(). At the start of
> > +	 * migration, oldpage was mapped. But now, it's zapped.
> > +	 * But we know *target* page is not freed/reused under us.
> > +	 * mem_cgroup_uncharge_page() does all necessary checks.
> > +	 */
> > +	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> > +		mem_cgroup_uncharge_page(target);
> >  }
> >  
> > +
> >  /*
> >   * A call to try to shrink memory usage under specified resource controller.
> >   * This is typically used for page reclaiming for shmem for reducing side
> > 
> 
> BTW, I'm now testing v7 patches with some fixes I've reported,
> and it has worked well so far(for several hours) in my test.
> (testing page migration and rmdir(force_empty) under swap in/out activity)
> 
Good to hear that :)

Thank you for all your help, patient review and tests !

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
