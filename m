Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BAE336B007E
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 19:44:19 -0400 (EDT)
Received: by iajr24 with SMTP id r24so309472iaj.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 16:44:19 -0700 (PDT)
Date: Thu, 26 Apr 2012 16:44:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: drop page_table_lock to uncharge memcg pages
In-Reply-To: <20120426163922.4879dcb1.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1204261642190.15785@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1204261556100.15785@chino.kir.corp.google.com> <20120426163922.4879dcb1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Thu, 26 Apr 2012, Andrew Morton wrote:

> > mm->page_table_lock is hotly contested for page fault tests and isn't
> > necessary to do mem_cgroup_uncharge_page() in do_huge_pmd_wp_page().
> > 
> > ...
> >
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -968,8 +968,10 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	spin_lock(&mm->page_table_lock);
> >  	put_page(page);
> >  	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
> > +		spin_unlock(&mm->page_table_lock);
> >  		mem_cgroup_uncharge_page(new_page);
> >  		put_page(new_page);
> > +		goto out;
> >  	} else {
> >  		pmd_t entry;
> >  		VM_BUG_ON(!PageHead(page));
> 
> But this is on the basically-never-happens race path and will surely have no
> measurable benefit?
> 

It happens more often than you may think on page fault tests; how 
representative pft has ever been of actual workloads, especially with thp 
where the benfits of allocating the hugepage usually result in better 
performance in the long-term even for a short-term performance loss, is 
debatable.  However, all other thp code has always dropped 
mm->page_table_lock before calling mem_cgroup_uncharge_page() and this one 
seems to have been missed.  Worth correcting, in my opinion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
