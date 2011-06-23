Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8560A900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 04:15:37 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2AD363EE0C3
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 17:15:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 03CA045DE52
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 17:15:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DE99F45DE4D
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 17:15:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE20F1DB803F
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 17:15:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CA2D1DB802F
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 17:15:32 +0900 (JST)
Date: Thu, 23 Jun 2011 17:08:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: unlock page before charging it. (WasRe: [PATCH
 V2] mm: Do not keep page locked during page fault while charging it for
 memcg
Message-Id: <20110623170811.16f4435f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110623074133.GA31593@tiehlicka.suse.cz>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
	<20110622121516.GA28359@infradead.org>
	<20110622123204.GC14343@tiehlicka.suse.cz>
	<20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623074133.GA31593@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Lutz Vieweg <lvml@5t9.de>

On Thu, 23 Jun 2011 09:41:33 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 23-06-11 15:08:42, KAMEZAWA Hiroyuki wrote:
> > On Wed, 22 Jun 2011 14:32:04 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Wed 22-06-11 08:15:16, Christoph Hellwig wrote:
> > > > > +
> > > > > +			/* We have to drop the page lock here because memcg
> > > > > +			 * charging might block for unbound time if memcg oom
> > > > > +			 * killer is disabled.
> > > > > +			 */
> > > > > +			unlock_page(vmf.page);
> > > > > +			ret = mem_cgroup_newpage_charge(page, mm, GFP_KERNEL);
> > > > > +			lock_page(vmf.page);
> > > > 
> > > > This introduces a completely poinless unlock/lock cycle for non-memcg
> > > > pagefaults.  Please make sure it only happens when actually needed.
> > > 
> > > Fair point. Thanks!
> > > What about the following?
> > > I realize that pushing more memcg logic into mm/memory.c is not nice but
> > > I found it better than pushing the old page into mem_cgroup_newpage_charge.
> > > We could also check whether the old page is in the root cgroup because
> > > memcg oom killer is not active there but that would add more code into
> > > this hot path so I guess it is not worth it.
> > > 
> > > Changes since v1
> > > - do not unlock page when memory controller is disabled.
> > > 
> > 
> > Great work. Then I confirmed Lutz' problem is fixed.
> > 
> > But I like following style rather than additional lock/unlock.
> > How do you think ?
> 
> Yes, I like it much more than the hairy way I did it. See comments bellow.
> 
> > I tested this on the latest git tree and confirmed
> > the Lutz's livelock problem is fixed. And I think this should go stable tree.
> > 
> > 
> > ==
> > From 7e9250da9ff529958d4c1ff511458dbdac8e4b81 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 23 Jun 2011 15:05:57 +0900
> > Subject: [PATCH] memcg: unlock page before charging it.
> > 
> > Currently we are keeping faulted page locked throughout whole __do_fault
> > call (except for page_mkwrite code path). If we do early COW we allocate a
> > new page which has to be charged for a memcg (mem_cgroup_newpage_charge).
> > 
> > This function, however, might block for unbounded amount of time if memcg
> > oom killer is disabled or fork-bomb is running because the only way out of
> > the OOM situation is either an external event or OOM-situation fix.
> > 
> > processes from faulting it in which is not good at all because we are
> 
> Missing the beginning of the sentence?
> 

Ah, yes...

> > basically punishing potentially an unrelated process for OOM condition
> > in a different group (I have seen stuck system because of ld-2.11.1.so being
> > locked).
> > 
> > We can do test easily.
> >  % cgcreate -g memory:A
> >  % cgset -r memory.limit_in_bytes=64M A
> >  % cgset -r memory.memsw.limit_in_bytes=64M A
> >  % cd kernel_dir; cgexec -g memory:A make -j
> > 
> > Then, the whole system will live-locked until you kill 'make -j'
> > by hands (or push reboot...) This is because some important
> > page in a shared library are locked and never released bcause of fork-bomb.
> > 
> > This patch delays "charge" until unlock_page() called. There is
> > no problem as far as we keep reference on a page.
> > (memcg doesn't require page_lock()).
> > 
> > Then, above livelock disappears.
> > 
> > Reported-by: Lutz Vieweg <lvml@5t9.de>
> > Original-idea-by: Michal Hocko <mhocko@suse.cz>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memory.c |   28 +++++++++++++++++++---------
> >  1 files changed, 19 insertions(+), 9 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 87d9353..66442da 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3129,7 +3129,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	struct page *page;
> >  	pte_t entry;
> >  	int anon = 0;
> > -	int charged = 0;
> > +	struct page *need_charge = NULL;
> >  	struct page *dirty_page = NULL;
> >  	struct vm_fault vmf;
> >  	int ret;
> > @@ -3177,12 +3177,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  				ret = VM_FAULT_OOM;
> >  				goto out;
> >  			}
> > -			if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
> > -				ret = VM_FAULT_OOM;
> > -				page_cache_release(page);
> > -				goto out;
> > -			}
> > -			charged = 1;
> > +			need_charge = page;
> >  			copy_user_highpage(page, vmf.page, address, vma);
> >  			__SetPageUptodate(page);
> >  		} else {
> > @@ -3251,12 +3246,11 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		/* no need to invalidate: a not-present page won't be cached */
> >  		update_mmu_cache(vma, address, page_table);
> >  	} else {
> > -		if (charged)
> > -			mem_cgroup_uncharge_page(page);
> >  		if (anon)
> >  			page_cache_release(page);
> >  		else
> >  			anon = 1; /* no anon but release faulted_page */
> > +		need_charge = NULL;
> >  	}
> >  
> >  	pte_unmap_unlock(page_table, ptl);
> > @@ -3268,6 +3262,17 @@ out:
> >  		if (set_page_dirty(dirty_page))
> >  			page_mkwrite = 1;
> >  		unlock_page(dirty_page);
> > +		if (need_charge) {
> > +			/*
> > +			 * charge this page before we drop refcnt.
> > +			 * memory cgroup returns OOM condition when
> > +			 * this task is killed. So, it's not necesasry
> > +			 * to undo.
> > +			 */
> > +			if (mem_cgroup_newpage_charge(need_charge,
> > +					mm, GFP_KERNEL))
> > +				ret = VM_FAULT_OOM;
> > +		}
> 
> We do not need this hunk, don't we? dirty_page is set only if !anon so
> we never get to this path from COW.
> 
You're right. (And Nishimura pointed out this, too)

> Other than that:
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> 

I found the page is added to LRU before charging. (In this case,
memcg's LRU is ignored.) I'll post a new version with a fix.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
