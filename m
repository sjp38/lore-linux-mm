Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 29DE96B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:24:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L9P6Ge012071
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Apr 2009 18:25:06 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FEE145DE55
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:25:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E3B5445DE51
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:25:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CDE7F1DB8038
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:25:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A0031DB803C
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:25:02 +0900 (JST)
Date: Tue, 21 Apr 2009 18:23:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 3/3][rfc] vmscan: batched swap slot allocation
Message-Id: <20090421182331.5c96615e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090421085231.GB2527@cmpxchg.org>
References: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
	<1240259085-25872-3-git-send-email-hannes@cmpxchg.org>
	<20090421095857.b989ce44.kamezawa.hiroyu@jp.fujitsu.com>
	<20090421085231.GB2527@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009 10:52:31 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> > Keeping multiple pages locked while they stay on private list ? 
> 
> Yeah, it's a bit suboptimal but I don't see a way around it.
> 
Hmm, seems to increase stale swap cache dramatically under memcg ;)

> > BTW, isn't it better to add "allocate multiple swap space at once" function
> > like
> >  - void get_swap_pages(nr, swp_entry_array[])
> > ? "nr" will not be bigger than SWAP_CLUSTER_MAX.
> 
> It will sometimes be, see __zone_reclaim().
> 
Hm ? If I read the code correctly, __zone_reclaim() just call shrink_zone() and
"nr" to shrink_page_list() is SWAP_CLUSTER_MAX, at most.

> I had such a function once.  The interesting part is: how and when do
> you call it?  If you drop the page lock in between, you need to redo
> the checks for unevictability and whether the page has become mapped
> etc.
> 
> You also need to have the pages in swap cache as soon as possible or
> optimistic swap-in will 'steal' your swap slots.  See add_to_swap()
> when the cache radix tree says -EEXIST.
> 

If I was you, modify "offset" calculation of
  get_swap_pages()
     -> scan_swap_map()
to allow that a cpu  tends to find countinous swap page cluster.
Too difficult ?

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
