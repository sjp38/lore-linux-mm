Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 779596B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 20:46:40 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o690kasC017918
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Jul 2010 09:46:36 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 728F345DE4D
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 09:46:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5076245DE6E
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 09:46:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 30B991DB8040
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 09:46:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D5A641DB803E
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 09:46:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 2/2] vmscan: shrink_slab() require number of lru_pages, not page order
In-Reply-To: <alpine.DEB.2.00.1007081540400.15083@router.home>
References: <20100708133152.5e556508.akpm@linux-foundation.org> <alpine.DEB.2.00.1007081540400.15083@router.home>
Message-Id: <20100709092124.CD5A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  9 Jul 2010 09:46:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 8 Jul 2010, Andrew Morton wrote:
> 
> > > AFAICT this is not argument error but someone changed the naming of the
> > > parameter.
> >
> > It's been there since day zero:
> >
> > : commit 2a16e3f4b0c408b9e50297d2ec27e295d490267a
> > : Author:     Christoph Lameter <clameter@engr.sgi.com>
> > : AuthorDate: Wed Feb 1 03:05:35 2006 -0800
> > : Commit:     Linus Torvalds <torvalds@g5.osdl.org>
> > : CommitDate: Wed Feb 1 08:53:16 2006 -0800
> > :
> > :     [PATCH] Reclaim slab during zone reclaim
> 
> That only shows that the order parameter was passed to shrink_slab() which
> is what I remember being done intentionally.
> 
> Vaguely recall that this was necessary to avoid shrink_slab() throwing out
> too many pages for higher order allocs.

But It make opposite effect. number of scanning objects of shrink_slab() are

                          lru_scanned        max_pass
basic_scan_objects = 4 x -------------  x -----------------------------
                          lru_pages        shrinker->seeks (default:2)

scan_objects = min(basic_scan_objects, max_pass * 2)


That said, small lru_pages parameter makes too many slab dropping.
Practically, zone-reclaim always take max_pass*2. about inode, 
shrink_icache_memory() takes number of unused inode as max_pass.
It mean one shrink_slab() calling drop all icache. Is this optimal
behavior? why?

Am I missing something?

> Initially zone_reclaim was full of heuristics that later were replaced by
> counter as the new ZVCs became available and gradually better ways of
> accounting for pages became possible.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
