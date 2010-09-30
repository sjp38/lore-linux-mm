Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 849F86B0047
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 02:01:02 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8U60xZb000606
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 30 Sep 2010 15:00:59 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E687145DE5B
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 15:00:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8250F45DE56
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 15:00:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BF7E11DB803F
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 15:00:57 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 77116E38006
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 15:00:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch]vmscan: protect exectuable page from inactive list scan
In-Reply-To: <1285825564.1773.45.camel@shli-laptop>
References: <20100930125537.2A9A.A69D9226@jp.fujitsu.com> <1285825564.1773.45.camel@shli-laptop>
Message-Id: <20100930145539.2AA6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 30 Sep 2010 15:00:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Wu, Fengguang" <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 2010-09-30 at 12:46 +0800, KOSAKI Motohiro wrote:
> > > On Thu, 2010-09-30 at 10:57 +0800, Wu, Fengguang wrote:
> > > > On Thu, Sep 30, 2010 at 10:27:04AM +0800, KOSAKI Motohiro wrote:
> > > > > > On Wed, 2010-09-29 at 18:17 +0800, Johannes Weiner wrote:
> > > > > > > On Wed, Sep 29, 2010 at 10:57:40AM +0800, Shaohua Li wrote:
> > > > > > > > With commit 645747462435, pte referenced file page isn't activated in inactive
> > > > > > > > list scan. For VM_EXEC page, if it can't get a chance to active list, the
> > > > > > > > executable page protect loses its effect. We protect such page in inactive scan
> > > > > > > > here, now such page will be guaranteed cached in a full scan of active and
> > > > > > > > inactive list, which restores previous behavior.
> > > > > > > 
> > > > > > > This change was in the back of my head since the used-once detection
> > > > > > > was merged but there were never any regressions reported that would
> > > > > > > indicate a requirement for it.
> > > > > > The executable page protect is to improve responsibility. I would expect
> > > > > > it's hard for user to report such regression. 
> > > > > 
> > > > > Seems strange. 8cab4754d24a0f was introduced for fixing real world problem.
> > > > > So, I wonder why current people can't feel the same lag if it is.
> > > > > 
> > > > > 
> > > > > > > Does this patch fix a problem you observed?
> > > > > > No, I haven't done test where Fengguang does in commit 8cab4754d24a0f.
> > > > > 
> > > > > But, I am usually not against a number. If you will finished to test them I'm happy :)
> > > > 
> > > > Yeah, it needs good numbers for adding such special case code.
> > > > I attached the scripts used for 8cab4754d24a0f, hope this helps.
> > > > 
> > > > Note that the test-mmap-exec-prot.sh used /proc/sys/fs/suid_dumpable
> > > > as an indicator whether the extra logic is enabled. This is a convenient
> > > > trick I sometimes play with new code:
> > > > 
> > > > +                       extern int suid_dumpable;
> > > > +                       if (suid_dumpable)
> > > >                         if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> > > >                                 list_add(&page->lru, &l_active);
> > > >                                 continue;
> > > ok, I'll test them, but might a little later, after a 7-day holiday.
> > > 
> > > > > > 
> > > > > > > > --- a/mm/vmscan.c
> > > > > > > > +++ b/mm/vmscan.c
> > > > > > > > @@ -608,8 +608,15 @@ static enum page_references page_check_references(struct page *page,
> > > > > > > >  		 * quickly recovered.
> > > > > > > >  		 */
> > > > > > > >  		SetPageReferenced(page);
> > > > > > > > -
> > > > > > > > -		if (referenced_page)
> > > > > > > > +		/*
> > > > > > > > +		 * Identify pte referenced and file-backed pages and give them
> > > > > > > > +		 * one trip around the active list. So that executable code get
> > > > > > > > +		 * better chances to stay in memory under moderate memory
> > > > > > > > +		 * pressure. JVM can create lots of anon VM_EXEC pages, so we
> > > > > > > > +		 * ignore them here.
> > > > > > > > +               if (referenced_page || ((vm_flags & VM_EXEC) &&
> > > > > > > > +                   page_is_file_cache(page)))
> > > > > > > >                         return PAGEREF_ACTIVATE;
> > > > 
> > > > > > > 
> > > > > > > PTE-referenced PageAnon() pages are activated unconditionally a few
> > > > > > > lines further up, so the page_is_file_cache() check filters only shmem
> > > > > > > pages.  I doubt this was your intention...?
> > > > > > This is intented. the executable page protect is just to protect
> > > > > > executable file pages. please see 8cab4754d24a0f.
> > > > > 
> > > > > 8cab4754d24a0f was using !PageAnon() but your one are using page_is_file_cache.
> > > > > 8cab4754d24a0f doesn't tell us the reason of the change, no?
> > > > 
> > > > What if the executable file happen to be on tmpfs?  The !PageAnon()
> > > > test also covers that case. The page_is_file_cache() test here seems
> > > > unnecessary. And it looks better to move the VM_EXEC test above the
> > > > SetPageReferenced() line to avoid possible side effects.
> > > oops, I should mention this commit 41e20983fe553 here. That commit
> > > changes it to page_is_file_cache()
> > 
> > Hmmm...
> > 
> > I think 41e20983fe553 is red herring fix. because 1) Even if all pages are
> > VM_EXEC, we don't have to make OOM anyway. tmpfs or not is not good
> > decision source. (note: On embedded, regular file-system can be smaller than tmpfs)
> > 2) We've already fixed tmpfs used once page issue. (e9d6c15738 and 
> > vmscantmpfs-treat-used-once-pages-on-tmpfs-as-used-once.patch in -mm)
> IIRC, e9d6c15738 solved the used once issue at the time when the page is
> added to lru list at the first time. while this issue is moving a page
> from inactive list to active list or give the page another around to
> active list. if we have no the filter, moving vast executable tmpfs
> pages to activate list can still increasing anon list rotate rate and
> cause more file pages scan and oom killer.

before invoking OOM, we scan pages about two times between priority-12
and priority-0. then, one time activation is harmless. but two times
activation and/or another rotate factor can be made trouble.

before vmscantmpfs-treat-used-once-pages-on-tmpfs-as-used-once.patch,
tmpfs pages are always rotated at least once. and VM_EXEC add +1 time.
Thus, two times rotate occur and bring to trouble. I think.

If this is not enough solution, of cource we need additional fix. but
tmpfs is not special. It's fs independent issue. 


However I agree page_is_file_cache() check is harmless because typical
guys don't put executable into tmpfs. So, If you can't agree me, I can
accept your one.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
