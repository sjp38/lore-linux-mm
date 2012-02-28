Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 29F426B004D
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 07:25:30 -0500 (EST)
Date: Tue, 28 Feb 2012 13:25:27 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/6] memcg: fix performance of
 mem_cgroup_begin_update_page_stat()
Message-ID: <20120228122527.GD1702@cmpxchg.org>
References: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
 <20120217182851.2f8ee503.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120217182851.2f8ee503.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

On Fri, Feb 17, 2012 at 06:28:51PM +0900, KAMEZAWA Hiroyuki wrote:
> >From 07d3ce332ee4bc1eaef4b8fb2019b0c06bd7afb1 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Mon, 6 Feb 2012 12:14:47 +0900
> Subject: [PATCH 6/6] memcg: fix performance of mem_cgroup_begin_update_page_stat()
> 
> mem_cgroup_begin_update_page_stat() should be very fast because
> it's called very frequently. Now, it needs to look up page_cgroup
> and its memcg....this is slow.
> 
> This patch adds a global variable to check "any memcg is moving or not".
> With this, the caller doesn't need to visit page_cgroup and memcg.
> 
> Here is a test result. A test program makes page faults onto a file,
> MAP_SHARED and makes each page's page_mapcount(page) > 1, and free
> the range by madvise() and page fault again.  This program causes
> 26214400 times of page fault onto a file(size was 1G.) and shows
> shows the cost of mem_cgroup_begin_update_page_stat().
> 
> Before this patch for mem_cgroup_begin_update_page_stat()
> [kamezawa@bluextal test]$ time ./mmap 1G
> 
> real    0m21.765s
> user    0m5.999s
> sys     0m15.434s
> 
>     27.46%     mmap  mmap               [.] reader
>     21.15%     mmap  [kernel.kallsyms]  [k] page_fault
>      9.17%     mmap  [kernel.kallsyms]  [k] filemap_fault
>      2.96%     mmap  [kernel.kallsyms]  [k] __do_fault
>      2.83%     mmap  [kernel.kallsyms]  [k] __mem_cgroup_begin_update_page_stat
> 
> After this patch
> [root@bluextal test]# time ./mmap 1G
> 
> real    0m21.373s
> user    0m6.113s
> sys     0m15.016s
> 
> In usual path, calls to __mem_cgroup_begin_update_page_stat() goes away.
> 
> Note: we may be able to remove this optimization in future if
>       we can get pointer to memcg directly from struct page.
> 
> Acked-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
