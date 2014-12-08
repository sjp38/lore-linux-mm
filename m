Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A8DCA6B006C
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 06:07:19 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so4340280wiv.5
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 03:07:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si9283712wic.38.2014.12.08.03.07.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 03:07:18 -0800 (PST)
Date: Mon, 8 Dec 2014 11:07:14 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 1/3] mm: when stealing freepages, also take pages
 created by splitting buddy page
Message-ID: <20141208110714.GN6043@suse.de>
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz>
 <1417713178-10256-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1417713178-10256-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

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

Assuming the tracepoint issue Joonsoo pointed out gets corrected;

Acked-by: Mel Gorman <mgorman@suse.de>

I'm kicking myself that I missed the effect of 47118af076f6 when I was
reviewing it. I knew allocation success rates were worse than they used
to be but had been blaming changes in aggression of reclaim and
compaction.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
