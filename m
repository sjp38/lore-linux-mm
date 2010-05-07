Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9A6DF6B029E
	for <linux-mm@kvack.org>; Thu,  6 May 2010 22:02:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4721Ji1030106
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 May 2010 11:01:19 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 164453266C4
	for <linux-mm@kvack.org>; Fri,  7 May 2010 11:01:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EB7421EF089
	for <linux-mm@kvack.org>; Fri,  7 May 2010 11:01:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D62F81DB803B
	for <linux-mm@kvack.org>; Fri,  7 May 2010 11:01:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BC1B1DB803A
	for <linux-mm@kvack.org>; Fri,  7 May 2010 11:01:18 +0900 (JST)
Date: Fri, 7 May 2010 10:57:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm,migration: Fix race between shift_arg_pages and
 rmap_walk by guaranteeing rmap_walk finds PTEs created within the temporary
 stack
Message-Id: <20100507105712.18fc90c4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie>
	<1273188053-26029-3-git-send-email-mel@csn.ul.ie>
	<alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 6 May 2010 18:40:39 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Fri, 7 May 2010, Mel Gorman wrote:
> > 
> > Page migration requires rmap to be able to find all migration ptes
> > created by migration. If the second rmap_walk clearing migration PTEs
> > misses an entry, it is left dangling causing a BUG_ON to trigger during
> > fault. For example;
> 
> So I still absolutely detest this patch.
> 
> Why didn't the other - much simpler - patch work? The one Rik pointed to:
> 
> 	http://lkml.org/lkml/2010/4/30/198
> 
> and didn't do that _disgusting_ temporary anon_vma?
> 
I vote for simple one rather than temporal anon_vma. IIUC, this patch is selected
for not to leak exec's problem out to mm/ by magical check.


> Alternatively, why don't we just take the anon_vma lock over this region, 
> so that rmap can't _walk_ the damn thing?
> 

IIUC, move_page_tables() may call "page table allocation" and it cannot be
done under spinlock.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
