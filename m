Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAO6GSNt022618
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 24 Nov 2008 15:16:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DCAC45DE51
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 15:16:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 00CCB45DE4E
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 15:16:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DE2E41DB803E
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 15:16:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 97DEB1DB803A
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 15:16:27 +0900 (JST)
Date: Mon, 24 Nov 2008 15:15:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: memswap controller core swapcache fixes
Message-Id: <20081124151542.3c1a4c88.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081124144344.d2703a60.kamezawa.hiroyu@jp.fujitsu.com>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
	<Pine.LNX.4.64.0811232156120.4142@blonde.site>
	<Pine.LNX.4.64.0811232208380.6437@blonde.site>
	<20081124144344.d2703a60.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Nov 2008 14:43:44 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Sun, 23 Nov 2008 22:11:07 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > Two SwapCache bug fixes to mmotm's memcg-memswap-controller-core.patch:
> > 
> > One bug is independent of my current changes: there is no guarantee that
> > the page passed to mem_cgroup_try_charge_swapin() is still in SwapCache.
> > 
> 
> Ah, yes. I'm wrong that the page may not be SwapCache when lock_page() is
> called...

Ah...sorry again,

> > +	/*
> > +	 * A racing thread's fault, or swapoff, may have already updated
> > +	 * the pte, and even removed page from swap cache: return success
> > +	 * to go on to do_swap_page()'s pte_same() test, which should fail.
> > +	 */
> > +	if (!PageSwapCache(page))
> > +		return 0;
> > +
> >  	ent.val = page_private(page);

I think 
==
	if (!PageSwapCache(page))
		goto charge_cur_mm;
==
is better.

In following case,
==
	CPUA				CPUB
				    remove_from_swapcache
	lock_page()                 <==========================(*)
	try_charge_swapin()          
	....
	commit_charge()
==
At (*), the page may be fully unmapped and not charged
(and PCG_USED bit is cleared.)
If so, returing without any charge here means leak of charge.

Even if *charged* here,
  - mem_cgroup_cancel_charge_swapin (handles !pte_same() case.)
  - mem_cgroup_commit_charge_swapin (handles page is doubly charged case.)

try-commit-cancel is introduced to handle this kind of case and bug in my code
is accessing page->private without checking PageSwapCache().

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
