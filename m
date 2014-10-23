Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE156B0075
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:57:34 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id b6so886772lbj.17
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 06:57:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o7si2762791lbp.45.2014.10.23.06.57.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 06:57:32 -0700 (PDT)
Date: Thu, 23 Oct 2014 09:57:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcontrol: fix missed end-writeback page
 accounting
Message-ID: <20141023135729.GB24269@phnom.home.cmpxchg.org>
References: <1414002568-21042-1-git-send-email-hannes@cmpxchg.org>
 <1414002568-21042-3-git-send-email-hannes@cmpxchg.org>
 <20141022133936.44f2d2931948ce13477b5e64@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141022133936.44f2d2931948ce13477b5e64@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 22, 2014 at 01:39:36PM -0700, Andrew Morton wrote:
> On Wed, 22 Oct 2014 14:29:28 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > @@ -1061,9 +1062,10 @@ void page_add_file_rmap(struct page *page)
> >   */
> >  void page_remove_rmap(struct page *page)
> >  {
> > +	struct mem_cgroup *uninitialized_var(memcg);
> >  	bool anon = PageAnon(page);
> > -	bool locked;
> >  	unsigned long flags;
> > +	bool locked;
> >  
> >  	/*
> >  	 * The anon case has no mem_cgroup page_stat to update; but may
> > @@ -1071,7 +1073,7 @@ void page_remove_rmap(struct page *page)
> >  	 * we hold the lock against page_stat move: so avoid it on anon.
> >  	 */
> >  	if (!anon)
> > -		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> > +		memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
> >  
> >  	/* page still mapped by someone else? */
> >  	if (!atomic_add_negative(-1, &page->_mapcount))
> > @@ -1096,8 +1098,7 @@ void page_remove_rmap(struct page *page)
> >  				-hpage_nr_pages(page));
> >  	} else {
> >  		__dec_zone_page_state(page, NR_FILE_MAPPED);
> > -		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
> > -		mem_cgroup_end_update_page_stat(page, &locked, &flags);
> > +		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
> >  	}
> >  	if (unlikely(PageMlocked(page)))
> >  		clear_page_mlock(page);
> > @@ -1110,10 +1111,9 @@ void page_remove_rmap(struct page *page)
> >  	 * Leaving it set also helps swapoff to reinstate ptes
> >  	 * faster for those pages still in swapcache.
> >  	 */
> > -	return;
> >  out:
> >  	if (!anon)
> > -		mem_cgroup_end_update_page_stat(page, &locked, &flags);
> > +		mem_cgroup_end_page_stat(memcg, locked, flags);
> >  }
> 
> The anon and file paths have as much unique code as they do common
> code.  I wonder if page_remove_rmap() would come out better if split
> into two functions?  I gave that a quick try and it came out OK-looking.

I agree, that looks better.  How about this?

---
