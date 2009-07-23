Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2ECBB6B004D
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 22:08:46 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6N28imf007985
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Jul 2009 11:08:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DA5C2AEAA1
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 11:08:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4679B1EF084
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 11:08:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D77581DB8038
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 11:08:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8691F1DB8040
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 11:08:43 +0900 (JST)
Date: Thu, 23 Jul 2009 11:06:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 06/10] ksm: identify PageKsm pages
Message-Id: <20090723110655.f08cdcdc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0907221346040.529@sister.anvils>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
	<1247851850-4298-2-git-send-email-ieidus@redhat.com>
	<1247851850-4298-3-git-send-email-ieidus@redhat.com>
	<1247851850-4298-4-git-send-email-ieidus@redhat.com>
	<1247851850-4298-5-git-send-email-ieidus@redhat.com>
	<1247851850-4298-6-git-send-email-ieidus@redhat.com>
	<1247851850-4298-7-git-send-email-ieidus@redhat.com>
	<20090721175139.GE2239@random.random>
	<4A660101.3000307@redhat.com>
	<Pine.LNX.4.64.0907221346040.529@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Jul 2009 13:54:06 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Tue, 21 Jul 2009, Rik van Riel wrote:
> > Andrea Arcangeli wrote:
> > > > -	if (PageAnon(old_page)) {
> > > > +	if (PageAnon(old_page) && !PageKsm(old_page)) {
> > > >    if (!trylock_page(old_page)) {
> > > >     page_cache_get(old_page);
> > > >     pte_unmap_unlock(page_table, ptl);
> > > 
> > > What exactly does it buy to have PageAnon return 1 on ksm pages,
> > > besides requiring the above additional check (that if we stick to the
> > > above code, I would find safer to move inside reuse_swap_page).
> > 
> > I guess that if they are to remain unswappable, they
> > should go onto the unevictable list.
> 
> The KSM pages are not put on any LRU, so wouldn't be slowing vmscan
> down with futile scans: isn't the unevictable list for pages which
> belong to another LRU once they become evictable again?
> 
> (At this instant I've forgotten why there's an unevictable list at
> all - somewhere in vmscan.c which is accustomed to dealing with
> pages on lists, so easier to have them on a list than not?)
> 
I forget, too. But in short thinking, Unevictable pages should be
on LRU (marked as PG_lru) for isolating page (from LRU) called by
page migration etc.

isolate_lru_page()
	-> put page on private list
	-> do some work
	-> putback_lru_page()

sequence is useful at handling pages in a list.
Because mlock/munclock can be called arbitrarily, unevicatable lru
works enough good for making above kinds of code simpler.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
