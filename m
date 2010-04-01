Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D4AE76B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 01:46:51 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o315klkB024459
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 1 Apr 2010 14:46:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ADB2B45DE60
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 14:46:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 88F4445DE4D
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 14:46:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BE9FE18001
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 14:46:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 22148E18002
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 14:46:47 +0900 (JST)
Date: Thu, 1 Apr 2010 14:42:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of
 PageSwapCache  pages
Message-Id: <20100401144234.e3848876.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <n2k28c262361003312144k3a1a725aj1eb22efe6d360118@mail.gmail.com>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
	<1269940489-5776-15-git-send-email-mel@csn.ul.ie>
	<20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com>
	<j2s28c262361003311943ke6d39007of3861743cef3733a@mail.gmail.com>
	<20100401120123.f9f9e872.kamezawa.hiroyu@jp.fujitsu.com>
	<n2k28c262361003312144k3a1a725aj1eb22efe6d360118@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010 13:44:29 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Thu, Apr 1, 2010 at 12:01 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 1 Apr 2010 11:43:18 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> On Wed, Mar 31, 2010 at 2:26 PM, KAMEZAWA Hiroyuki A  A  A  /*
> >> >> diff --git a/mm/rmap.c b/mm/rmap.c
> >> >> index af35b75..d5ea1f2 100644
> >> >> --- a/mm/rmap.c
> >> >> +++ b/mm/rmap.c
> >> >> @@ -1394,9 +1394,11 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
> >> >>
> >> >> A  A  A  if (unlikely(PageKsm(page)))
> >> >> A  A  A  A  A  A  A  return rmap_walk_ksm(page, rmap_one, arg);
> >> >> - A  A  else if (PageAnon(page))
> >> >> + A  A  else if (PageAnon(page)) {
> >> >> + A  A  A  A  A  A  if (PageSwapCache(page))
> >> >> + A  A  A  A  A  A  A  A  A  A  return SWAP_AGAIN;
> >> >> A  A  A  A  A  A  A  return rmap_walk_anon(page, rmap_one, arg);
> >> >
> >> > SwapCache has a condition as (PageSwapCache(page) && page_mapped(page) == true.
> >> >
> >>
> >> In case of tmpfs, page has swapcache but not mapped.
> >>
> >> > Please see do_swap_page(), PageSwapCache bit is cleared only when
> >> >
> >> > do_swap_page()...
> >> > A  A  A  swap_free(entry);
> >> > A  A  A  A if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
> >> > A  A  A  A  A  A  A  A try_to_free_swap(page);
> >> >
> >> > Then, PageSwapCache is cleared only when swap is freeable even if mapped.
> >> >
> >> > rmap_walk_anon() should be called and the check is not necessary.
> >>
> >> Frankly speaking, I don't understand what is Mel's problem, why he added
> >> Swapcache check in rmap_walk, and why do you said we don't need it.
> >>
> >> Could you explain more detail if you don't mind?
> >>
> > I may miss something.
> >
> > unmap_and_move()
> > A 1. try_to_unmap(TTU_MIGRATION)
> > A 2. move_to_newpage
> > A 3. remove_migration_ptes
> > A  A  A  A -> rmap_walk()
> >
> > Then, to map a page back we unmapped we call rmap_walk().
> >
> > Assume a SwapCache which is mapped, then, PageAnon(page) == true.
> >
> > A At 1. try_to_unmap() will rewrite pte with swp_entry of SwapCache.
> > A  A  A  mapcount goes to 0.
> > A At 2. SwapCache is copied to a new page.
> > A At 3. The new page is mapped back to the place. Now, newpage's mapcount is 0.
> > A  A  A  Before patch, the new page is mapped back to all ptes.
> > A  A  A  After patch, the new page is not mapped back because its mapcount is 0.
> >
> > I don't think shared SwapCache of anon is not an usual behavior, so, the logic
> > before patch is more attractive.
> >
> > If SwapCache is not mapped before "1", we skip "1" and rmap_walk will do nothing
> > because page->mapping is NULL.
> >
> 
> Thanks. I agree. We don't need the check.
> Then, my question is why Mel added the check in rmap_walk.
> He mentioned some BUG trigger and fixed things after this patch.
> What's it?
> Is it really related to this logic?
> I don't think so or we are missing something.
> 
Hmm. Consiering again.

Now.
	if (PageAnon(page)) {
		rcu_locked = 1;
		rcu_read_lock();
		if (!page_mapped(page)) {
			if (!PageSwapCache(page))
				goto rcu_unlock;
		} else {
			anon_vma = page_anon_vma(page);
			atomic_inc(&anon_vma->external_refcount);
		}


Maybe this is a fix.

==
	skip_remap = 0;
	if (PageAnon(page)) {
		rcu_read_lock();
		if (!page_mapped(page)) {
			if (!PageSwapCache(page))
				goto rcu_unlock;
			/*
			 * We can't convice this anon_vma is valid or not because
			 * !page_mapped(page). Then, we do migration(radix-tree replacement)
			 * but don't remap it which touches anon_vma in page->mapping.
			 */
			skip_remap = 1;
			goto skip_unmap;
		} else {
			anon_vma = page_anon_vma(page);
			atomic_inc(&anon_vma->external_refcount);
		}
	}	
	.....copy page, radix-tree replacement,....

	if (!rc && !skip_remap)
		 remove_migration_ptes(page, page);
==

Thanks,
-Kame











--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
