Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 23C4E6B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 21:56:33 -0500 (EST)
Received: by pfdd184 with SMTP id d184so35037351pfd.3
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 18:56:32 -0800 (PST)
Received: from m50-138.163.com (m50-138.163.com. [123.125.50.138])
        by mx.google.com with ESMTP id 2si23436415pfh.103.2015.12.04.18.56.29
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 18:56:32 -0800 (PST)
Date: Sat, 5 Dec 2015 10:55:42 +0800
From: Geliang Tang <geliangtang@163.com>
Subject: Re: [PATCH] mm/memcontrol.c: use list_{first,next}_entry
Message-ID: <20151205025542.GB9812@bogon>
References: <9e62e3006561653fcbf0c49cf0b9c2b653a8ed0e.1449152124.git.geliangtang@163.com>
 <20151203162718.GK9264@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203162718.GK9264@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geliang Tang <geliangtang@163.com>

On Thu, Dec 03, 2015 at 05:27:18PM +0100, Michal Hocko wrote:
> On Thu 03-12-15 22:16:55, Geliang Tang wrote:
> > To make the intention clearer, use list_{first,next}_entry instead
> > of list_entry.
> 
> Does this really help readability? This function simply uncharges the
> given list of pages. Why cannot we simply use list_for_each_entry
> instead...

I have tested it, list_for_each_entry can't work. Dose it mean that my
patch is OK? Or please give me some other advices.

Thanks.

- Geliang

> > Signed-off-by: Geliang Tang <geliangtang@163.com>
> > ---
> >  mm/memcontrol.c | 9 +++------
> >  1 file changed, 3 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 79a29d5..a6301ea 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -5395,16 +5395,12 @@ static void uncharge_list(struct list_head *page_list)
> >  	unsigned long nr_file = 0;
> >  	unsigned long nr_huge = 0;
> >  	unsigned long pgpgout = 0;
> > -	struct list_head *next;
> >  	struct page *page;
> >  
> > -	next = page_list->next;
> > +	page = list_first_entry(page_list, struct page, lru);
> >  	do {
> >  		unsigned int nr_pages = 1;
> >  
> > -		page = list_entry(next, struct page, lru);
> > -		next = page->lru.next;
> > -
> >  		VM_BUG_ON_PAGE(PageLRU(page), page);
> >  		VM_BUG_ON_PAGE(page_count(page), page);
> >  
> > @@ -5440,7 +5436,8 @@ static void uncharge_list(struct list_head *page_list)
> >  		page->mem_cgroup = NULL;
> >  
> >  		pgpgout++;
> > -	} while (next != page_list);
> > +	} while (!list_is_last(&page->lru, page_list) &&
> > +		 (page = list_next_entry(page, lru)));
> >  
> >  	if (memcg)
> >  		uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
> > -- 
> > 2.5.0
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
