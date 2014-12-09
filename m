Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 06BF46B0032
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 22:01:58 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so6391531pdj.7
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 19:01:57 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id pm2si48447406pac.169.2014.12.08.19.01.54
        for <linux-mm@kvack.org>;
        Mon, 08 Dec 2014 19:01:55 -0800 (PST)
Date: Tue, 9 Dec 2014 12:02:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm: when stealing freepages, also take pages
 created by splitting buddy page
Message-ID: <20141209030243.GC3358@bbox>
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz>
 <1417713178-10256-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1417713178-10256-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Thu, Dec 04, 2014 at 06:12:56PM +0100, Vlastimil Babka wrote:
> When __rmqueue_fallback() is called to allocate a page of order X, it will
> find a page of order Y >= X of a fallback migratetype, which is different from
> the desired migratetype. With the help of try_to_steal_freepages(), it may
> change the migratetype (to the desired one) also of:
> 
> 1) all currently free pages in the pageblock containing the fallback page
> 2) the fallback pageblock itself
> 3) buddy pages created by splitting the fallback page (when Y > X)
> 
> These decisions take the order Y into account, as well as the desired
> migratetype, with the goal of preventing multiple fallback allocations that
> could e.g. distribute UNMOVABLE allocations among multiple pageblocks.
> 
> Originally, decision for 1) has implied the decision for 3). Commit
> 47118af076f6 ("mm: mmzone: MIGRATE_CMA migration type added") changed that
> (probably unintentionally) so that the buddy pages in case 3) are always
> changed to the desired migratetype, except for CMA pageblocks.
> 
> Commit fef903efcf0c ("mm/page_allo.c: restructure free-page stealing code and
> fix a bug") did some refactoring and added a comment that the case of 3) is
> intended. Commit 0cbef29a7821 ("mm: __rmqueue_fallback() should respect
> pageblock type") removed the comment and tried to restore the original behavior
> where 1) implies 3), but due to the previous refactoring, the result is instead
> that only 2) implies 3) - and the conditions for 2) are less frequently met
> than conditions for 1). This may increase fragmentation in situations where the
> code decides to steal all free pages from the pageblock (case 1)), but then
> gives back the buddy pages produced by splitting.
> 
> This patch restores the original intended logic where 1) implies 3). During
> testing with stress-highalloc from mmtests, this has shown to decrease the
> number of events where UNMOVABLE and RECLAIMABLE allocations steal from MOVABLE
> pageblocks, which can lead to permanent fragmentation. It has increased the
> number of events when MOVABLE allocations steal from UNMOVABLE or RECLAIMABLE
> pageblocks, but these are fixable by sync compaction and thus less harmful.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Minchan Kim <minchan@kernel.org>

I expect you will Cc -stable when you respin with fixing pointed out
by Joonsoo.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
