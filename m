Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id EC8256B0078
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 19:27:09 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so12360874pdj.26
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 16:27:09 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id am7si16513748pad.165.2014.11.03.16.27.07
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 16:27:08 -0800 (PST)
Date: Tue, 4 Nov 2014 09:28:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4/5] mm, compaction: always update cached scanner
 positions
Message-ID: <20141104002850.GA8412@js1304-P5Q-DELUXE>
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
 <1412696019-21761-5-git-send-email-vbabka@suse.cz>
 <20141027073522.GB23379@js1304-P5Q-DELUXE>
 <544E12B5.5070008@suse.cz>
 <20141028070818.GA27813@js1304-P5Q-DELUXE>
 <5453B088.6080605@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5453B088.6080605@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Fri, Oct 31, 2014 at 04:53:44PM +0100, Vlastimil Babka wrote:
> On 10/28/2014 08:08 AM, Joonsoo Kim wrote:
> >>
> >>>And, I guess that pageblock skip feature effectively disable pageblock
> >>>rescanning if there is no freepage during rescan.
> >>
> >>If there's no freepage during rescan, then the cached free_pfn also
> >>won't be pointed to the pageblock anymore. Regardless of pageblock skip
> >>being set, there will not be second rescan. But there will still be the
> >>first rescan to determine there are no freepages.
> >
> >Yes, What I'd like to say is that these would work well. Just decreasing
> >few percent of scanning page doesn't look good to me to validate this
> >patch, because there is some facilities to reduce rescan overhead and
> 
> The mechanisms have a tradeoff, while this patch didn't seem to have
> negative consequences.
> 
> >compaction is fundamentally time-consuming process. Moreover, failure of
> >compaction could cause serious system crash in some cases.
> 
> Relying on successful high-order allocation for not crashing is
> dangerous, success is never guaranteed. Such critical allocation
> should try harder than fail due to a single compaction attempt. With
> this argument you could aim to remove all the overhead reducing
> heuristics.
> 
> >>>This patch would
> >>>eliminate effect of pageblock skip feature.
> >>
> >>I don't think so (as explained above). Also if free pages were isolated
> >>(and then returned and skipped over), the pageblock should remain
> >>without skip bit, so after scanners meet and positions reset (which
> >>doesn't go hand in hand with skip bit reset), the next round will skip
> >>over the blocks without freepages and find quickly the blocks where free
> >>pages were skipped in the previous round.
> >>
> >>>IIUC, compaction logic assume that there are many temporary failure
> >>>conditions. Retrying from others would reduce effect of this temporary
> >>>failure so implementation looks as is.
> >>
> >>The implementation of pfn caching was written at time when we did not
> >>keep isolated free pages between migration attempts in a single
> >>compaction run. And the idea of async compaction is to try with minimal
> >>effort (thus latency), and if there's a failure, try somewhere else.
> >>Making sure we don't skip anything doesn't seem productive.
> >
> >free_pfn is shared by async/sync compaction and unconditional updating
> >causes sync compaction to stop prematurely, too.
> >
> >And, if this patch makes migrate/freepage scanner meet more frequently,
> >there is one problematic scenario.
> 
> OK, so you don't find a problem with how this patch changes
> migration scanner caching, just the free scanner, right?
> So how about making release_freepages() return the highest freepage
> pfn it encountered (could perhaps do without comparing individual
> pfn's, the list should be ordered so it could be just the pfn of
> first or last page in the list, but need to check that) and updating
> cached free pfn with that? That should ensure rescanning only when
> needed.

Hello,

Updating cached free pfn in release_freepages() looks good to me.

In fact, I guess that migration scanner also has similar problems, but,
it's just my guess. I admit your following arguments in patch description.

  However, the downside is that potentially many pages are rescanned without
  successful isolation. At worst, there might be a page where isolation from LRU 
  succeeds but migration fails (potentially always).

So, I'm okay if you update cached free pfn in release_freepages().

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
