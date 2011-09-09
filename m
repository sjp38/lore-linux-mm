Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B73DA900138
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 02:49:18 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7CA633EE0B5
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 15:49:13 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E3ABC45DEBD
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 15:49:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C123545DEB4
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 15:49:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AC8571DB8038
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 15:49:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64CF01DB8041
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 15:49:12 +0900 (JST)
Date: Fri, 9 Sep 2011 15:48:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm: memcg: close race between charge and putback
Message-Id: <20110909154820.96b75cb3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110909062855.GA10972@redhat.com>
References: <1315467622-9520-1-git-send-email-jweiner@redhat.com>
	<20110908173042.4a6f8ac0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110908085404.GA1316@redhat.com>
	<20110908181901.1d488d73.kamezawa.hiroyu@jp.fujitsu.com>
	<20110908093316.GB1316@redhat.com>
	<20110908184221.feb2dab6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110908095349.GC1316@redhat.com>
	<20110909092853.7aac8544.kamezawa.hiroyu@jp.fujitsu.com>
	<20110909062855.GA10972@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 9 Sep 2011 08:28:55 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Fri, Sep 09, 2011 at 09:28:53AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 8 Sep 2011 11:53:49 +0200
> > Johannes Weiner <jweiner@redhat.com> wrote:
> > 
> > > On Thu, Sep 08, 2011 at 06:42:21PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Thu, 8 Sep 2011 11:33:16 +0200
> > > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > > 
> > > > > On Thu, Sep 08, 2011 at 06:19:01PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > > On Thu, 8 Sep 2011 10:54:04 +0200
> > > > > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > > > > 
> > > > > > > On Thu, Sep 08, 2011 at 05:30:42PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > > > > On Thu,  8 Sep 2011 09:40:22 +0200
> > > > > > > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > > > > > > 
> > > > > > > > > There is a potential race between a thread charging a page and another
> > > > > > > > > thread putting it back to the LRU list:
> > > > > > > > > 
> > > > > > > > > charge:                         putback:
> > > > > > > > > SetPageCgroupUsed               SetPageLRU
> > > > > > > > > PageLRU && add to memcg LRU     PageCgroupUsed && add to memcg LRU
> > > > > > > > > 
> > > > > > > > 
> > > > > > > > I assumed that all pages are charged before added to LRU.
> > > > > > > > (i.e. event happens in charge->lru_lock->putback order.)
> > > > > > > > 
> > > > > > > > But hmm, this assumption may be bad for maintainance.
> > > > > > > > Do you find a code which adds pages to LRU before charge ?
> > > > > > > > 
> > > > > > > > Hmm, if there are codes which recharge the page to other memcg,
> > > > > > > > it will cause bug and my assumption may be harmful.
> > > > > > > 
> > > > > > > Swap slots are read optimistically into swapcache and put to the LRU,
> > > > > > > then charged upon fault.  
> > > > > > 
> > > > > > Yes, then swap charge removes page from LRU before charge.
> > > > > > IIUC, it needed to do so because page->mem_cgroup may be replaced.
> > > > > 
> > > > > But only from the memcg LRU.  It's still on the global per-zone LRU,
> > > > > so reclaim could isolate/putback it during the charge.  And then
> > > > > 
> > > > > > > > > charge:                         putback:
> > > > > > > > > SetPageCgroupUsed               SetPageLRU
> > > > > > > > > PageLRU && add to memcg LRU     PageCgroupUsed && add to memcg LRU
> > > > > 
> > > > > applies.
> > > > 
> > > > Hmm, in this case, I thought memcg puts back the page to its LRU by itself
> > > > under lru_loc after charge and the race was hidden.
> > > 
> > > But it locklessly checks PageLRU and bails if it's cleared and that is
> > 
> > I think PageLRU check is done under zone->lru_lock.
> 
> Yes, but only if a preliminary, lockless check observed PageLRU being
> set:
> 
> static void mem_cgroup_lru_add_after_commit(struct page *page)
> {
>         unsigned long flags;
>         struct zone *zone = page_zone(page);
>         struct page_cgroup *pc = lookup_page_cgroup(page);
>         /*
>          * putback:                             charge:
>          * SetPageLRU                           SetPageCgroupUsed
>          * smp_mb                               smp_mb
>          * PageCgroupUsed && add to memcg LRU   PageLRU && add to memcg LRU
>          *
>          * Ensure that one of the two sides adds the page to the memcg
>          * LRU during a race.
>          */
>         smp_mb();
>         /* taking care of that the page is added to LRU while we commit it */
>         if (likely(!PageLRU(page)))
>                 return;
>         spin_lock_irqsave(&zone->lru_lock, flags);
>         /* link when the page is linked to LRU but page_cgroup isn't */
>         if (PageLRU(page) && !PageCgroupAcctLRU(pc))
>                 mem_cgroup_add_lru_list(page, page_lru(page));
>         spin_unlock_irqrestore(&zone->lru_lock, flags);
> }
> 
> Without the barriers, the preliminary check may see !PageLRU while a
> racing putback observed !PageCgroupUsed and nobody will add the page
> to the memcg-LRU.
> 

Ok, thank you for clarification. I understand the point.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
