Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 8C5E16B0068
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 12:38:18 -0400 (EDT)
Subject: Re: [PATCH] Cgroup: Fix memory accounting scalability in
 shrink_page_list
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <5008CE38.2020300@jp.fujitsu.com>
References: <1342740866.13492.50.camel@schen9-DESK>
	 <5008CE38.2020300@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 20 Jul 2012 09:38:18 -0700
Message-ID: <1342802298.13492.59.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri, 2012-07-20 at 12:19 +0900, Kamezawa Hiroyuki wrote:

> 
> When I added batching, I didn't touch page-reclaim path because it delays
> res_counter_uncharge() and make more threads run into page reclaim.
> But, from above score, bactching seems required.
> 
> And because of current design of per-zone-per-memcg-LRU, batching
> works very very well....all lru pages shrink_page_list() scans are on
> the same memcg.
> 
> BTW, it's better to show 'how much improved' in patch description..

I didn't put the specific improvement in patch description as the
performance change is specific to my machine and benchmark and
improvement could be variable for others.  However, I did include the
specific number in the body of my message.  Hope that is enough.
 

> 
> 
> > ---
> > Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 33dc256..aac5672 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -779,6 +779,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >
> >   	cond_resched();
> >
> > +	mem_cgroup_uncharge_start();
> >   	while (!list_empty(page_list)) {
> >   		enum page_references references;
> >   		struct address_space *mapping;
> > @@ -1026,6 +1027,7 @@ keep_lumpy:
> >
> >   	list_splice(&ret_pages, page_list);
> >   	count_vm_events(PGACTIVATE, pgactivate);
> > +	mem_cgroup_uncharge_end();
> 
> I guess placing mem_cgroup_uncharge_end() just after the loop may be better looking.

I initially though of doing that.  I later pushed the statement down to
after list_splice(&ret_pages, page_list) as that's when the page reclaim
is actually completed.  It probably doesn't matter one way or the other.
I can move it to just after the loop if people think that's better.

Thanks for reviewing the change.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
