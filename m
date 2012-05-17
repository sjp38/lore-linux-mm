Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0FDE96B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 09:14:33 -0400 (EDT)
Message-ID: <4FB4F999.4010008@redhat.com>
Date: Thu, 17 May 2012 09:14:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: consider all swapped back pages in used-once logic
References: <1337246033-13719-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <1337246033-13719-1-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 05/17/2012 05:13 AM, Michal Hocko wrote:
> [64574746 vmscan: detect mapped file pages used only once] made mapped pages
> have another round in inactive list because they might be just short
> lived and so we could consider them again next time. This heuristic
> helps to reduce pressure on the active list with a streaming IO
> worklods.
> This patch fixes a regression introduced by this commit for heavy shmem
> based workloads because unlike Anon pages, which are excluded from this
> heuristic because they are usually long lived, shmem pages are handled
> as a regular page cache.
> This doesn't work quite well, unfortunately, if the workload is mostly
> backed by shmem (in memory database sitting on 80% of memory) with a
> streaming IO in the background (backup - up to 20% of memory). Anon
> inactive list is full of (dirty) shmem pages when watermarks are
> hit. Shmem pages are kept in the inactive list (they are referenced)
> in the first round and it is hard to reclaim anything else so we reach
> lower scanning priorities very quickly which leads to an excessive swap
> out.
>
> Let's fix this by excluding all swap backed pages (they tend to be long
> lived wrt. the regular page cache anyway) from used-once heuristic and
> rather activate them if they are referenced.
>
> CC: Johannes Weiner<hannes@cmpxchg.org>
> CC: Andrew Morton<akpm@linux-foundation.org>
> CC: Mel Gorman<mel@csn.ul.ie>
> CC: Minchan Kim<minchan@kernel.org>
> CC: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> CC: Rik van Riel<riel@redhat.com>
> CC: stable [2.6.34+]
> Signed-off-by: Michal Hocko<mhocko@suse.cz>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
