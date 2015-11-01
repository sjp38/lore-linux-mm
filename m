Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CC31282F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 00:51:17 -0400 (EDT)
Received: by pasz6 with SMTP id z6so113270492pas.2
        for <linux-mm@kvack.org>; Sat, 31 Oct 2015 21:51:17 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id di4si24038942pbc.31.2015.10.31.21.51.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 31 Oct 2015 21:51:17 -0700 (PDT)
Received: by padhy1 with SMTP id hy1so107254017pad.0
        for <linux-mm@kvack.org>; Sat, 31 Oct 2015 21:51:16 -0700 (PDT)
Date: Sat, 31 Oct 2015 21:51:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/8] MADV_FREE support
In-Reply-To: <1446188504-28023-1-git-send-email-minchan@kernel.org>
Message-ID: <alpine.DEB.2.10.1510312142560.10406@chino.kir.corp.google.com>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>

On Fri, 30 Oct 2015, Minchan Kim wrote:

> MADV_FREE is on linux-next so long time. The reason was two, I think.
> 
> 1. MADV_FREE code on reclaim path was really mess.
> 
> 2. Andrew really want to see voice of userland people who want to use
>    the syscall.
> 
> A few month ago, Daniel Micay(jemalloc active contributor) requested me
> to make progress upstreaming but I was busy at that time so it took
> so long time for me to revist the code and finally, I clean it up the
> mess recently so it solves the #2 issue.
> 
> As well, Daniel and Jason(jemalloc maintainer) requested it to Andrew
> again recently and they said it would be great to have even though
> it has swap dependency now so Andrew decided he will do that for v4.4.
> 

First, thanks very much for refreshing the patchset and reposting after a 
series of changes have been periodically added to -mm, it makes it much 
easier.

For tcmalloc, we can do some things in the allocator itself to increase 
the amount of memory backed by thp.  Specifically, we can prefer to 
release Spans to pageblocks that are already not backed by thp so there is 
no additional split on each scavenge.  This is somewhat easy if all memory 
is organized into hugepage-aligned pageblocks in the allocator itself.  
Second, we can prefer to release Spans of longer length on each scavenge 
so we can delay scavenging for as long as possible in a hope we can find 
more pages to coalesce.  Third, we can discount refaulted released memory 
from the scavenging period.

That significantly improves the amount of memory backed by thp for 
tcmalloc.  The problem, however, is that tcmalloc uses MADV_DONTNEED to 
release memory to the system and MADV_FREE wouldn't help at all in a 
swapless environment.

To combat that, I've proposed a new MADV bit that simply caches the 
ranges freed by the allocator per vma and places them on both a per-vma 
and per-memcg list.  During reclaim, this list is iterated and ptes are 
freed after thp split period to the normal directed reclaim.  Without 
memory pressure, this backs 100% of the heap with thp with a relatively 
lightweight kernel change (the majority is vma manipulation on split) and 
a couple line change to tcmalloc.  When pulling memory from the returned 
freelists, the memory that we have MADV_DONTNEED'd, we need to use another 
MADV bit to remove it from this cache, so there is a second madvise(2) 
syscall involved but the freeing call is much less expensive since there 
is no pagetable walk without memory pressure or synchronous thp split.

I've been looking at MADV_FREE to see if there is common ground that could 
be shared, but perhaps it's just easier to ask what your proposed strategy 
is so that tcmalloc users, especially those in swapless environments, 
would benefit from any of your work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
