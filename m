Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 19E2C6B004D
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 20:34:06 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7D57D3EE0C1
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:34:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6070B45DE54
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:34:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 487DE45DE52
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:34:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A78B1DB8042
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:34:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E0CBB1DB803A
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:34:03 +0900 (JST)
Date: Fri, 9 Mar 2012 10:32:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 5/7] mm: rework reclaim_stat counters
Message-Id: <20120309103231.03097798.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120308180419.27621.88710.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
	<20120308180419.27621.88710.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 08 Mar 2012 22:04:19 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Currently there is two types of reclaim-stat counters:
> recent_scanned (pages picked from from lru),
> recent_rotated (pages putted back to active lru).
> Reclaimer uses ratio recent_rotated / recent_scanned
> for balancing pressure between file and anon pages.
> 
> But if we pick page from lru we can either reclaim it or put it back to lru, thus:
> recent_scanned == recent_rotated[inactive] + recent_rotated[active] + reclaimed
> This can be called "The Law of Conservation of Memory" =)
> 
> Thus recent_rotated counters for each lru list is enough, reclaimed pages can be
> counted as rotatation into inactive lru. After that reclaimer can use this ratio:
> recent_rotated[active] / (recent_rotated[active] + recent_rotated[inactive])
> 
> After this patch struct zone_reclaimer_stat has only one array: recent_rotated,
> which is directly indexed by lru list index:
> 
> before patch:
> 
> LRU_ACTIVE_ANON   -> LRU_ACTIVE_ANON   : recent_scanned[ANON]++, recent_rotated[ANON]++
> LRU_INACTIVE_ANON -> LRU_ACTIVE_ANON   : recent_scanned[ANON]++, recent_rotated[ANON]++
> LRU_ACTIVE_ANON   -> LRU_INACTIVE_ANON : recent_scanned[ANON]++
> LRU_INACTIVE_ANON -> LRU_INACTIVE_ANON : recent_scanned[ANON]++
> 
> after patch:
> 
> LRU_ACTIVE_ANON   -> LRU_ACTIVE_ANON   : recent_rotated[LRU_ACTIVE_ANON]++
> LRU_INACTIVE_ANON -> LRU_ACTIVE_ANON   : recent_rotated[LRU_ACTIVE_ANON]++
> LRU_ACTIVE_ANON   -> LRU_INACTIVE_ANON : recent_rotated[LRU_INACTIVE_ANON]++
> LRU_INACTIVE_ANON -> LRU_INACTIVE_ANON : recent_rotated[LRU_INACTIVE_ANON]++
> 
> recent_scanned[ANON] === recent_rotated[LRU_ACTIVE_ANON] + recent_rotated[LRU_INACTIVE_ANON]
> recent_rotated[ANON] === recent_rotated[LRU_ACTIVE_ANON]
> 
> (and the same for FILE/LRU_ACTIVE_FILE/LRU_INACTIVE_FILE)
> 
> v5:
> * resolve conflict with "memcg: fix GPF when cgroup removal races with last exit"
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Nice description.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
