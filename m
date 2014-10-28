Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A73B9900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 03:07:02 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so76535pad.25
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 00:07:02 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id zu1si545651pac.119.2014.10.28.00.07.00
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 00:07:01 -0700 (PDT)
Date: Tue, 28 Oct 2014 16:08:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4/5] mm, compaction: always update cached scanner
 positions
Message-ID: <20141028070818.GA27813@js1304-P5Q-DELUXE>
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
 <1412696019-21761-5-git-send-email-vbabka@suse.cz>
 <20141027073522.GB23379@js1304-P5Q-DELUXE>
 <544E12B5.5070008@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <544E12B5.5070008@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Mon, Oct 27, 2014 at 10:39:01AM +0100, Vlastimil Babka wrote:
> On 10/27/2014 08:35 AM, Joonsoo Kim wrote:> On Tue, Oct 07, 2014 at
> 05:33:38PM +0200, Vlastimil Babka wrote:
> > Hmm... I'm not sure that this patch is good thing.
> >
> > In asynchronous compaction, compaction could be easily failed and
> > isolated freepages are returned to the buddy. In this case, next
> > asynchronous compaction would skip those returned freepages and
> > both scanners could meet prematurely.
> 
> If migration fails, free pages now remain isolated until next migration
> attempt, which should happen within the same compaction when it isolates
> new migratepages - it won't fail completely just because of failed
> migration. It might run out of time due to need_resched and then yeah,
> some free pages might be skipped. That's some tradeoff but at least my
> tests don't seem to show reduced success rates.

I thought later one, need_resched case.

Your test is about really high order allocation test, so it's success
rate wouldn't be affected by this skipping. But, different result could be
possible in mid order allocation.

> 
> > And, I guess that pageblock skip feature effectively disable pageblock
> > rescanning if there is no freepage during rescan.
> 
> If there's no freepage during rescan, then the cached free_pfn also
> won't be pointed to the pageblock anymore. Regardless of pageblock skip
> being set, there will not be second rescan. But there will still be the
> first rescan to determine there are no freepages.

Yes, What I'd like to say is that these would work well. Just decreasing
few percent of scanning page doesn't look good to me to validate this
patch, because there is some facilities to reduce rescan overhead and
compaction is fundamentally time-consuming process. Moreover, failure of
compaction could cause serious system crash in some cases.

> > This patch would
> > eliminate effect of pageblock skip feature.
> 
> I don't think so (as explained above). Also if free pages were isolated
> (and then returned and skipped over), the pageblock should remain
> without skip bit, so after scanners meet and positions reset (which
> doesn't go hand in hand with skip bit reset), the next round will skip
> over the blocks without freepages and find quickly the blocks where free
> pages were skipped in the previous round.
> 
> > IIUC, compaction logic assume that there are many temporary failure
> > conditions. Retrying from others would reduce effect of this temporary
> > failure so implementation looks as is.
> 
> The implementation of pfn caching was written at time when we did not
> keep isolated free pages between migration attempts in a single
> compaction run. And the idea of async compaction is to try with minimal
> effort (thus latency), and if there's a failure, try somewhere else.
> Making sure we don't skip anything doesn't seem productive.

free_pfn is shared by async/sync compaction and unconditional updating
causes sync compaction to stop prematurely, too.

And, if this patch makes migrate/freepage scanner meet more frequently,
there is one problematic scenario.

compact_finished() doesn't check how many work we did. It just check
if both scanners meet. Even if we failed to allocate high order page
due to little work, compaction would be deffered for later user.
This scenario wouldn't happen frequently if updating cached pfn is
limited. But, this patch may enlarge the possibility of this problem.

This is another problem of current logic, and, should be fixed, but,
there is now.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
