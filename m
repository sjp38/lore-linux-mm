Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 903046B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 11:53:43 -0400 (EDT)
Message-ID: <4F996F8B.1020207@redhat.com>
Date: Thu, 26 Apr 2012 11:53:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: compaction: handle incorrect Unmovable type pageblocks
References: <201204261015.54449.b.zolnierkie@samsung.com> <20120426143620.GF15299@suse.de>
In-Reply-To: <20120426143620.GF15299@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On 04/26/2012 10:36 AM, Mel Gorman wrote:

> Hmm, at what point does COMPACT_ASYNC_FULL get used? I see it gets
> used for the proc interface but it's not used via the page allocator at
> all.

He is using COMPACT_SYNC for the proc interface, and
COMPACT_ASYNC_FULL from kswapd.

> Minimally I was expecting to see if being used from the page allocator.

Makes sense, especially if we get the CPU overhead
saving stuff that we talked about at LSF to work :)

> A better option might be to track the number of MIGRATE_UNMOVABLE blocks that
> were skipped over during COMPACT_ASYNC_PARTIAL and if it was a high
> percentage and it looked like compaction failed then to retry with
> COMPACT_ASYNC_FULL. If you took this option, try_to_compact_pages()
> would still only take sync as a parameter and keep the decision within
> compaction.c

This I don't get.

If we have a small number of MIGRATE_UNMOVABLE blocks,
is it worth skipping over them?

If we have really large number of MIGRATE_UNMOVABLE blocks,
did we let things get out of hand?    By giving the page
allocator this many unmovable blocks to choose from, we
could have ended up with actually non-compactable memory.

If we have a medium number of MIGRATE_UNMOVABLE blocks,
is it worth doing a restart and scanning all the movable
blocks again?

In other words, could it be better to always try to
rescue the unmovable blocks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
