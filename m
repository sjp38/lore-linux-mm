Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B1B316B01F6
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 20:43:53 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S0hqb8000710
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 09:43:52 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 72E4145DE52
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:43:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 535DA45DE51
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:43:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CF9FDE08002
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:57:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CF9FD1DB8040
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:57:31 +0900 (JST)
Date: Wed, 28 Apr 2010 09:39:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs when
 page tables are being moved after the VMA has already moved
Message-Id: <20100428093948.c4e6faa1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100427225852.GH8860@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-4-git-send-email-mel@csn.ul.ie>
	<20100427223004.GF8860@random.random>
	<20100427225852.GH8860@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 2010 00:58:52 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, Apr 28, 2010 at 12:30:04AM +0200, Andrea Arcangeli wrote:
> > I'll now evaluate the fix and see if I can find any other
> > way to handle this.
> 
> 
> I think a better fix for bug mentioned in patch 3, is like below. This
> seems to work fine on aa.git with the old (stable) 2.6.33 anon-vma
> code. Not sure if this also works with the new anon-vma code in
> mainline but at first glance I think it should. At that point we
> should be single threaded so it shouldn't matter if anon_vma is
> temporary null.
> 
> Then you've to re-evaluate the vma_adjust fixes for mainline-only in
> patch 2 at the light of the below (I didn't check patch 2 in detail).
> 
> Please try to reproduce with the below applied.
> 
> ----
> Subject: fix race between shift_arg_pages and rmap_walk
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> migrate.c requires rmap to be able to find all ptes mapping a page at
> all times, otherwise the migration entry can be instantiated, but it
> can't be removed if the second rmap_walk fails to find the page.
> 
> So shift_arg_pages must run atomically with respect of rmap_walk, and
> it's enough to run it under the anon_vma lock to make it atomic.
> 
> And split_huge_page() will have the same requirements as migrate.c
> already has.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Seems nice.

I'll test this but I think we need to take care of do_mremap(), too.
And it's more complicated....

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
