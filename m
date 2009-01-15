Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 993066B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 08:43:10 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0FDh6EB012665
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Jan 2009 22:43:08 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E091145DD81
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:43:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B235E45DD7D
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:43:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 929D7E08009
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:43:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E6F2E08006
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:43:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mark_page_accessed() in do_swap_page() move latter than memcg charge
In-Reply-To: <20090115212030.EBE9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <Pine.LNX.4.64.0901151145470.11108@blonde.anvils> <20090115212030.EBE9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20090115224112.EBEC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Jan 2009 22:43:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, menage@google.com, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> (CC to Rik and Nick)
> 
> Hi
> 
> Thank you reviewing.
> 
> > > mark_page_accessed() update reclaim_stat statics.
> > > but currently, memcg charge is called after mark_page_accessed().
> > > 
> > > then, mark_page_accessed() don't update memcg statics correctly.
> > 
> > Statics?  "Stats" is a good abbreviation for statistics,
> > but statics are something else.
> 
> Doh! your are definitly right. thanks.
> 
> > > ---
> > >  mm/memory.c |    4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > 
> > > Index: b/mm/memory.c
> > > ===================================================================
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -2426,8 +2426,6 @@ static int do_swap_page(struct mm_struct
> > >  		count_vm_event(PGMAJFAULT);
> > >  	}
> > >  
> > > -	mark_page_accessed(page);
> > > -
> > >  	lock_page(page);
> > >  	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> > >  
> > > @@ -2480,6 +2478,8 @@ static int do_swap_page(struct mm_struct
> > >  		try_to_free_swap(page);
> > >  	unlock_page(page);
> > >  
> > > +	mark_page_accessed(page);
> > > +
> > >  	if (write_access) {
> > >  		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
> > >  		if (ret & VM_FAULT_ERROR)
> > 
> > This catches my eye, because I'd discussed with Nick and was going to
> > send in a patch which entirely _removes_ this mark_page_accessed call
> > from do_swap_page (and replaces follow_page's mark_page_accessed call
> > by a pte_mkyoung): they seem inconsistent to me, in the light of
> > bf3f3bc5e734706730c12a323f9b2068052aa1f0 mm: don't mark_page_accessed
> > in fault path.
> 
> Actually, bf3f3bc5e734706730c12a323f9b2068052aa1f0 only remove 
> the mark_page_accessed() in filemap_fault().
> current mmotm's do_swap_page() still have mark_page_accessed().
> 
> but your suggestion is very worth.
> ok, I'm thinking and sorting out again.
> 
> Rik's commit 9ff473b9a72942c5ac0ad35607cae28d8d59ed7a vmscan: evict streaming IO first
> does "reclaim stastics don't only update at reclaim, but also at fault and read/write.
> it makes proper anon/file reclaim balancing stastics value before starting actual reclaim".
> and it depend on fault path calling mark_page_accessed(). 
> 
> Then, we need following change. I think.
> 
>   - Remove calling mark_page_accessed() in do_swap_page().
>     it makes consistency against filemap_fault().
>   - Add calling update_page_reclaim_stat() into do_swap_page() and 
>     filemap_fault().
> 
> Am I overlooking something?

Doh! please ignore last mail's patch. I forgot grab zone->lru_lock.
it's perfectly buggy.

I'll make it again tommorow.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
