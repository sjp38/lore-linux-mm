Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B038E6B0047
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 01:46:08 -0400 (EDT)
Subject: Re: [patch]vmscan: protect exectuable page from inactive list scan
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20100930125537.2A9A.A69D9226@jp.fujitsu.com>
References: <20100930025750.GA10456@localhost>
	 <1285816845.1773.28.camel@shli-laptop>
	 <20100930125537.2A9A.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 30 Sep 2010 13:46:04 +0800
Message-ID: <1285825564.1773.45.camel@shli-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-09-30 at 12:46 +0800, KOSAKI Motohiro wrote:
> > On Thu, 2010-09-30 at 10:57 +0800, Wu, Fengguang wrote:
> > > On Thu, Sep 30, 2010 at 10:27:04AM +0800, KOSAKI Motohiro wrote:
> > > > > On Wed, 2010-09-29 at 18:17 +0800, Johannes Weiner wrote:
> > > > > > On Wed, Sep 29, 2010 at 10:57:40AM +0800, Shaohua Li wrote:
> > > > > > > With commit 645747462435, pte referenced file page isn't activated in inactive
> > > > > > > list scan. For VM_EXEC page, if it can't get a chance to active list, the
> > > > > > > executable page protect loses its effect. We protect such page in inactive scan
> > > > > > > here, now such page will be guaranteed cached in a full scan of active and
> > > > > > > inactive list, which restores previous behavior.
> > > > > > 
> > > > > > This change was in the back of my head since the used-once detection
> > > > > > was merged but there were never any regressions reported that would
> > > > > > indicate a requirement for it.
> > > > > The executable page protect is to improve responsibility. I would expect
> > > > > it's hard for user to report such regression. 
> > > > 
> > > > Seems strange. 8cab4754d24a0f was introduced for fixing real world problem.
> > > > So, I wonder why current people can't feel the same lag if it is.
> > > > 
> > > > 
> > > > > > Does this patch fix a problem you observed?
> > > > > No, I haven't done test where Fengguang does in commit 8cab4754d24a0f.
> > > > 
> > > > But, I am usually not against a number. If you will finished to test them I'm happy :)
> > > 
> > > Yeah, it needs good numbers for adding such special case code.
> > > I attached the scripts used for 8cab4754d24a0f, hope this helps.
> > > 
> > > Note that the test-mmap-exec-prot.sh used /proc/sys/fs/suid_dumpable
> > > as an indicator whether the extra logic is enabled. This is a convenient
> > > trick I sometimes play with new code:
> > > 
> > > +                       extern int suid_dumpable;
> > > +                       if (suid_dumpable)
> > >                         if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> > >                                 list_add(&page->lru, &l_active);
> > >                                 continue;
> > ok, I'll test them, but might a little later, after a 7-day holiday.
> > 
> > > > > 
> > > > > > > --- a/mm/vmscan.c
> > > > > > > +++ b/mm/vmscan.c
> > > > > > > @@ -608,8 +608,15 @@ static enum page_references page_check_references(struct page *page,
> > > > > > >  		 * quickly recovered.
> > > > > > >  		 */
> > > > > > >  		SetPageReferenced(page);
> > > > > > > -
> > > > > > > -		if (referenced_page)
> > > > > > > +		/*
> > > > > > > +		 * Identify pte referenced and file-backed pages and give them
> > > > > > > +		 * one trip around the active list. So that executable code get
> > > > > > > +		 * better chances to stay in memory under moderate memory
> > > > > > > +		 * pressure. JVM can create lots of anon VM_EXEC pages, so we
> > > > > > > +		 * ignore them here.
> > > > > > > +               if (referenced_page || ((vm_flags & VM_EXEC) &&
> > > > > > > +                   page_is_file_cache(page)))
> > > > > > >                         return PAGEREF_ACTIVATE;
> > > 
> > > > > > 
> > > > > > PTE-referenced PageAnon() pages are activated unconditionally a few
> > > > > > lines further up, so the page_is_file_cache() check filters only shmem
> > > > > > pages.  I doubt this was your intention...?
> > > > > This is intented. the executable page protect is just to protect
> > > > > executable file pages. please see 8cab4754d24a0f.
> > > > 
> > > > 8cab4754d24a0f was using !PageAnon() but your one are using page_is_file_cache.
> > > > 8cab4754d24a0f doesn't tell us the reason of the change, no?
> > > 
> > > What if the executable file happen to be on tmpfs?  The !PageAnon()
> > > test also covers that case. The page_is_file_cache() test here seems
> > > unnecessary. And it looks better to move the VM_EXEC test above the
> > > SetPageReferenced() line to avoid possible side effects.
> > oops, I should mention this commit 41e20983fe553 here. That commit
> > changes it to page_is_file_cache()
> 
> Hmmm...
> 
> I think 41e20983fe553 is red herring fix. because 1) Even if all pages are
> VM_EXEC, we don't have to make OOM anyway. tmpfs or not is not good
> decision source. (note: On embedded, regular file-system can be smaller than tmpfs)
> 2) We've already fixed tmpfs used once page issue. (e9d6c15738 and 
> vmscantmpfs-treat-used-once-pages-on-tmpfs-as-used-once.patch in -mm)
IIRC, e9d6c15738 solved the used once issue at the time when the page is
added to lru list at the first time. while this issue is moving a page
from inactive list to active list or give the page another around to
active list. if we have no the filter, moving vast executable tmpfs
pages to activate list can still increasing anon list rotate rate and
cause more file pages scan and oom killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
