Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF436B01AC
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 06:12:55 -0400 (EDT)
Date: Tue, 6 Jul 2010 11:12:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100706101235.GE13780@csn.ul.ie>
References: <20100702125155.69c02f85.akpm@linux-foundation.org> <20100705134949.GC13780@csn.ul.ie> <20100706093529.CCD1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100706093529.CCD1.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 06, 2010 at 09:36:41AM +0900, KOSAKI Motohiro wrote:
> Hello,
> 
> > Ok, that's reasonable as I'm still working on that patch. For example, the
> > patch disabled anonymous page writeback which is unnecessary as the stack
> > usage for anon writeback is less than file writeback. 
> 
> How do we examine swap-on-file?
> 

Anything in particular wrong with the following?

/*
 * For now, only kswapd can writeback filesystem pages as otherwise
 * there is a stack overflow risk
 */
static inline bool reclaim_can_writeback(struct scan_control *sc,
                                        struct page *page)
{
        return !page_is_file_cache(page) || current_is_kswapd();
}

Even if it is a swapfile, I didn't spot a case where the filesystems
writepage would be called. Did I miss something?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
