Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 2805F6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 00:56:52 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4C8323EE0C1
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:56:50 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EB1A45DE50
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:56:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1605E45DE4F
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:56:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0801D1DB802F
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:56:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B08F71DB803E
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:56:49 +0900 (JST)
Date: Thu, 5 Jan 2012 14:55:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] memcg: fix split_huge_page_refcounts
Message-Id: <20120105145535.56c8c7fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112281618050.8257@eggly.anvils>
References: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
	<alpine.LSU.2.00.1112281618050.8257@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Wed, 28 Dec 2011 16:20:25 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> This patch started off as a cleanup: __split_huge_page_refcounts() has to
> cope with two scenarios, when the hugepage being split is already on LRU,
> and when it is not; but why does it have to split that accounting across
> three different sites?  Consolidate it in lru_add_page_tail(), handling
> evictable and unevictable alike, and use standard add_page_to_lru_list()
> when accounting is needed (when the head is not yet on LRU).
> 
> But a recent regression in -next, I guess the removal of PageCgroupAcctLRU
> test from mem_cgroup_split_huge_fixup(), makes this now a necessary fix:
> under load, the MEM_CGROUP_ZSTAT count was wrapping to a huge number,
> messing up reclaim calculations and causing a freeze at rmdir of cgroup.
> 
> Add a VM_BUG_ON to mem_cgroup_lru_del_list() when we're about to wrap
> that count - this has not been the only such incident.  Document that
> lru_add_page_tail() is for Transparent HugePages by #ifdef around it.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

seems saner.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
