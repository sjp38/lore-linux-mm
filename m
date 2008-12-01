Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB17eAcB020331
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Dec 2008 16:40:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B99B845DE52
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 16:40:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 97E2C45DD77
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 16:40:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 67C511DB803E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 16:40:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 05CA11DB8046
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 16:40:10 +0900 (JST)
Date: Mon, 1 Dec 2008 16:39:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 1/2] mm: pagecache allocation gfp fixes
Message-Id: <20081201163921.bd5d71aa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081201105038.cf128e4a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081127093401.GE28285@wotan.suse.de>
	<84144f020811270152i5d5c50a8i9dbd78aa4a7da646@mail.gmail.com>
	<20081127101837.GJ28285@wotan.suse.de>
	<Pine.LNX.4.64.0811271749100.17307@blonde.site>
	<20081128120440.GA13786@wotan.suse.de>
	<Pine.LNX.4.64.0812010053510.14288@blonde.site>
	<20081201105038.cf128e4a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008 10:50:38 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 1 Dec 2008 01:18:09 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
>
> It comes from the fact that memcg reclaims memory not because of memory shortage
> but of memory limit.
> "From which zone the memory should be reclaimed" is not problem. 
> I used GFP_HIGHUSER_MOVABLE to show "reclaim from anyware" in explicit way.
> too bad ?
> 
Maybe I got your point..

Hmm...but...

mmotm-Nov29's following gfp_mask is buggy (mis leading).
==
int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
                pgoff_t offset, gfp_t gfp_mask)
{
        int error;

        error = mem_cgroup_cache_charge(page, current->mm,
                                        gfp_mask & ~__GFP_HIGHMEM);
        if (error)
==

mem_cgroup_cache_charge() has to reclaim memory from HIGHMEM (if used.) 
to make room. (not to reclaim memory from some specified area.)

(Anyway) memcg's page reclaim code uses following
==
unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
                                                gfp_t gfp_mask,
                                           bool noswap)
{

        sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
                        (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
....
}
==

And we don't see bug..

I'll try mmotm-Nov30 and find some way to do better explanation.
This gfp semantics of memcg is a bit different from other gfp's.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
