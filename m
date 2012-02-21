Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id CD1746B004A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 14:37:34 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so9486699pbc.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 11:37:34 -0800 (PST)
Date: Tue, 21 Feb 2012 11:37:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/10] mm/memcg: take care over pc->mem_cgroup
In-Reply-To: <4F4331BC.70205@openvz.org>
Message-ID: <alpine.LSU.2.00.1202211117340.1858@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils> <alpine.LSU.2.00.1202201533260.23274@eggly.anvils> <4F4331BC.70205@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 21 Feb 2012, Konstantin Khlebnikov wrote:
> 
> But just one question: how appears uncharged pages in mem-cg lru lists?

One way is swapin readahead pages, which cannot be charged to a memcg
until they're "claimed"; but we do need them visible on lru, otherwise
memory pressure couldn't reclaim them when necessary.

Another way is simply that uncharging has not historically removed the
page from lru list if it's on.  I usually assume that's an optimization:
why bother to get lru locks and take it off (and put it on the root lru?
if we don't, we're assuming it's will be freed very shortly - I'm not
sure that's always a good assumption), if freeing the page will usually
do that for us (without having to change lrus).

If I thought for longer, I might come up with other scenarios.

> Maybe we can forbid this case and uncharge these pages right in
> __page_cache_release() and release_pages() at final removing from LRU.
> This is how my old mem-controller works. There pages in lru are always
> charged.

As things stand, that would mean lock_page_cgroup() has to disable irqs
everywhere.  I'm not sure of the further ramifications of moving uncharge
to __page_cache_release() and release_pages().  I don't think a change
like that is out of the question, but it's certainly a bigger change
than I'd like to consider in this series.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
