Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 849CB6B01A8
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 02:30:46 -0400 (EDT)
Date: Fri, 9 Sep 2011 08:28:55 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] mm: memcg: close race between charge and putback
Message-ID: <20110909062855.GA10972@redhat.com>
References: <1315467622-9520-1-git-send-email-jweiner@redhat.com>
 <20110908173042.4a6f8ac0.kamezawa.hiroyu@jp.fujitsu.com>
 <20110908085404.GA1316@redhat.com>
 <20110908181901.1d488d73.kamezawa.hiroyu@jp.fujitsu.com>
 <20110908093316.GB1316@redhat.com>
 <20110908184221.feb2dab6.kamezawa.hiroyu@jp.fujitsu.com>
 <20110908095349.GC1316@redhat.com>
 <20110909092853.7aac8544.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110909092853.7aac8544.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 09, 2011 at 09:28:53AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 8 Sep 2011 11:53:49 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > On Thu, Sep 08, 2011 at 06:42:21PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 8 Sep 2011 11:33:16 +0200
> > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > 
> > > > On Thu, Sep 08, 2011 at 06:19:01PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > On Thu, 8 Sep 2011 10:54:04 +0200
> > > > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > > > 
> > > > > > On Thu, Sep 08, 2011 at 05:30:42PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > > > On Thu,  8 Sep 2011 09:40:22 +0200
> > > > > > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > > > > > 
> > > > > > > > There is a potential race between a thread charging a page and another
> > > > > > > > thread putting it back to the LRU list:
> > > > > > > > 
> > > > > > > > charge:                         putback:
> > > > > > > > SetPageCgroupUsed               SetPageLRU
> > > > > > > > PageLRU && add to memcg LRU     PageCgroupUsed && add to memcg LRU
> > > > > > > > 
> > > > > > > 
> > > > > > > I assumed that all pages are charged before added to LRU.
> > > > > > > (i.e. event happens in charge->lru_lock->putback order.)
> > > > > > > 
> > > > > > > But hmm, this assumption may be bad for maintainance.
> > > > > > > Do you find a code which adds pages to LRU before charge ?
> > > > > > > 
> > > > > > > Hmm, if there are codes which recharge the page to other memcg,
> > > > > > > it will cause bug and my assumption may be harmful.
> > > > > > 
> > > > > > Swap slots are read optimistically into swapcache and put to the LRU,
> > > > > > then charged upon fault.  
> > > > > 
> > > > > Yes, then swap charge removes page from LRU before charge.
> > > > > IIUC, it needed to do so because page->mem_cgroup may be replaced.
> > > > 
> > > > But only from the memcg LRU.  It's still on the global per-zone LRU,
> > > > so reclaim could isolate/putback it during the charge.  And then
> > > > 
> > > > > > > > charge:                         putback:
> > > > > > > > SetPageCgroupUsed               SetPageLRU
> > > > > > > > PageLRU && add to memcg LRU     PageCgroupUsed && add to memcg LRU
> > > > 
> > > > applies.
> > > 
> > > Hmm, in this case, I thought memcg puts back the page to its LRU by itself
> > > under lru_loc after charge and the race was hidden.
> > 
> > But it locklessly checks PageLRU and bails if it's cleared and that is
> 
> I think PageLRU check is done under zone->lru_lock.

Yes, but only if a preliminary, lockless check observed PageLRU being
set:

static void mem_cgroup_lru_add_after_commit(struct page *page)
{
        unsigned long flags;
        struct zone *zone = page_zone(page);
        struct page_cgroup *pc = lookup_page_cgroup(page);
        /*
         * putback:                             charge:
         * SetPageLRU                           SetPageCgroupUsed
         * smp_mb                               smp_mb
         * PageCgroupUsed && add to memcg LRU   PageLRU && add to memcg LRU
         *
         * Ensure that one of the two sides adds the page to the memcg
         * LRU during a race.
         */
        smp_mb();
        /* taking care of that the page is added to LRU while we commit it */
        if (likely(!PageLRU(page)))
                return;
        spin_lock_irqsave(&zone->lru_lock, flags);
        /* link when the page is linked to LRU but page_cgroup isn't */
        if (PageLRU(page) && !PageCgroupAcctLRU(pc))
                mem_cgroup_add_lru_list(page, page_lru(page));
        spin_unlock_irqrestore(&zone->lru_lock, flags);
}

Without the barriers, the preliminary check may see !PageLRU while a
racing putback observed !PageCgroupUsed and nobody will add the page
to the memcg-LRU.

> > the problem: it's not guaranteed that PageLRU is observed on the
> > charging CPU when the putback side bailed because of PageCgroupUsed.
> > 
> zone->lru_lock is no help ?

Removing the preliminary check is not an option.  This is the path for
regular file cache and the common case is !PageLRU.  We do not want to
acquire the lock in estimated 99.999% of the cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
