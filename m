Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6188D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 04:48:56 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 38CF43EE0C0
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:48:52 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 14F8645DE5A
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:48:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E579545DE56
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:48:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D42B0E38003
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:48:51 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DD46E38001
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:48:51 +0900 (JST)
Date: Mon, 28 Feb 2011 18:42:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are disabled
 while isolating pages for migration
Message-Id: <20110228184230.7c2eefb7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110228092814.GC9548@csn.ul.ie>
References: <1298664299-10270-1-git-send-email-mel@csn.ul.ie>
	<1298664299-10270-3-git-send-email-mel@csn.ul.ie>
	<20110228111746.34f3f3e0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110228054818.GF22700@random.random>
	<20110228145402.65e6f200.kamezawa.hiroyu@jp.fujitsu.com>
	<20110228092814.GC9548@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 28 Feb 2011 09:28:14 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> On Mon, Feb 28, 2011 at 02:54:02PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon, 28 Feb 2011 06:48:18 +0100
> > Andrea Arcangeli <aarcange@redhat.com> wrote:
> > 
> > > On Mon, Feb 28, 2011 at 11:17:46AM +0900, KAMEZAWA Hiroyuki wrote:
> > > > BTW, I forget why we always take zone->lru_lock with IRQ disabled....
> > > 
> > > To decrease lock contention in SMP to deliver overall better
> > > performance (not sure how much it helps though). It was supposed to be
> > > hold for a very short time (PAGEVEC_SIZE) to avoid giving irq latency
> > > problems.
> > > 
> > 
> > memory hotplug uses MIGRATE_ISOLATED migrate types for scanning pfn range
> > without lru_lock. I wonder whether we can make use of it (the function
> > which memory hotplug may need rework for the compaction but  migrate_type can
> > be used, I think).
> > 
> 
> I don't see how migrate_type would be of any benefit here particularly
> as compaction does not directly affect the migratetype of a pageblock. I
> have not checked closely which part of hotplug you are on about but if
> you're talking about when pages actually get offlined, the zone lock is
> not necessary there because the pages are not on the LRU. In compactions
> case, they are. Did I misunderstand?
> 

memory offline code doesn't take big lru_lock (and call isolate_lru_page())
at picking up migration target pages from LRU. While this, allocation from
the zone is allowed. memory offline is done by mem_section unit.

memory offline does.

   1. making a whole section as MIGRATETYPE_ISOLATED.
   2. scan pfn within section.
   3. find a page on LRU
   4. isolate_lru_page() -> take/release lru_lock. ----(*)
   5. migrate it.
   6. making all pages in the range as RESERVED.

During this, by marking the pageblock as MIGRATETYPE_ISOLATED,

  - new allocation will never picks up a page in the range.
  - newly freed pages in the range will never be allocated and never in pcp.
  - page type of the range will never change.

then, memory offline success.

If (*) seems too heavy anyway and will be no help even if with some batching
as isolate_lru_page_pagevec() or some, okay please forget offlining.


BTW, can't we drop disable_irq() from all lru_lock related codes ?

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
