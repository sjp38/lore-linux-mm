Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id BE1936B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:38:53 -0400 (EDT)
Date: Fri, 20 Jul 2012 16:38:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Cgroup: Fix memory accounting scalability in
 shrink_page_list
Message-ID: <20120720143848.GF12434@tiehlicka.suse.cz>
References: <1342740866.13492.50.camel@schen9-DESK>
 <20120720135329.GA12440@tiehlicka.suse.cz>
 <20120720141625.GA1426@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120720141625.GA1426@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "andi.kleen" <andi.kleen@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri 20-07-12 16:16:25, Johannes Weiner wrote:
> On Fri, Jul 20, 2012 at 03:53:29PM +0200, Michal Hocko wrote:
> > On Thu 19-07-12 16:34:26, Tim Chen wrote:
> > [...]
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 33dc256..aac5672 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -779,6 +779,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  
> > >  	cond_resched();
> > >  
> > > +	mem_cgroup_uncharge_start();
> > >  	while (!list_empty(page_list)) {
> > >  		enum page_references references;
> > >  		struct address_space *mapping;
> > 
> > Is this safe? We have a scheduling point few lines below. What prevents
> > from task move while we are in the middle of the batch?
> 
> The batch is accounted in task_struct, so moving a batching task to
> another CPU shouldn't be a problem.

But it could also move to a different group, right?

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
