Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 4A0A96B004D
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 04:18:58 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 83A2F3EE0BC
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:18:56 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A33445DE58
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:18:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 44D7B45DE55
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:18:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 429571DB8043
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:18:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E62F91DB803F
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:18:54 +0900 (JST)
Date: Tue, 21 Feb 2012 18:17:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/10] mm/memcg: remove mem_cgroup_reset_owner
Message-Id: <20120221181728.3778b1fd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202201534340.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
	<alpine.LSU.2.00.1202201534340.23274@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Feb 2012 15:35:38 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> With mem_cgroup_reset_uncharged_to_root() now making sure that freed
> pages point to root_mem_cgroup (instead of to a stale and perhaps
> long-deleted memcg), we no longer need to initialize page memcg to
> root in those odd places which put a page on lru before charging. 
> Delete mem_cgroup_reset_owner().
> 
> But: we have no init_page_cgroup() nowadays (and even when we had,
> it was called before root_mem_cgroup had been allocated); so until
> a struct page has once entered the memcg lru cycle, its page_cgroup
> ->mem_cgroup will be NULL instead of root_mem_cgroup.
> 
> That could be fixed by reintroducing init_page_cgroup(), and ordering
> properly: in future we shall probably want root_mem_cgroup in kernel
> bss or data like swapper_space; but let's not get into that right now.
> 
> Instead allow for this in page_relock_lruvec(): treating NULL as
> root_mem_cgroup, and correcting pc->mem_cgroup before going further.
> 
> What?  Before even taking the zone->lru_lock?  Is that safe?
> Yes, because compaction and lumpy reclaim use __isolate_lru_page(),
> which refuses unless it sees PageLRU - which may be cleared at any
> instant, but we only need it to have been set once in the past for
> pc->mem_cgroup to be initialized properly.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Ok, this seems to be much better than current reset_owner().

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
