Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 443D86B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 02:10:47 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so78948486pad.10
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 23:10:47 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ck3si1765683pad.80.2015.02.01.23.10.45
        for <linux-mm@kvack.org>;
        Sun, 01 Feb 2015 23:10:46 -0800 (PST)
Date: Mon, 2 Feb 2015 16:12:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 4/4] mm/compaction: enhance compaction finish condition
Message-ID: <20150202071223.GD6488@js1304-P5Q-DELUXE>
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1422621252-29859-5-git-send-email-iamjoonsoo.kim@lge.com>
 <BLU436-SMTP337E19C27F309D20380A81833E0@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLU436-SMTP337E19C27F309D20380A81833E0@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.ok@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Jan 31, 2015 at 11:58:03PM +0800, Zhang Yanfei wrote:
> At 2015/1/30 20:34, Joonsoo Kim wrote:
> > From: Joonsoo <iamjoonsoo.kim@lge.com>
> > 
> > Compaction has anti fragmentation algorithm. It is that freepage
> > should be more than pageblock order to finish the compaction if we don't
> > find any freepage in requested migratetype buddy list. This is for
> > mitigating fragmentation, but, there is a lack of migratetype
> > consideration and it is too excessive compared to page allocator's anti
> > fragmentation algorithm.
> > 
> > Not considering migratetype would cause premature finish of compaction.
> > For example, if allocation request is for unmovable migratetype,
> > freepage with CMA migratetype doesn't help that allocation and
> > compaction should not be stopped. But, current logic regards this
> > situation as compaction is no longer needed, so finish the compaction.
> > 
> > Secondly, condition is too excessive compared to page allocator's logic.
> > We can steal freepage from other migratetype and change pageblock
> > migratetype on more relaxed conditions in page allocator. This is designed
> > to prevent fragmentation and we can use it here. Imposing hard constraint
> > only to the compaction doesn't help much in this case since page allocator
> > would cause fragmentation again.
> 
> Changing both two behaviours in compaction may change the high order allocation
> behaviours in the buddy allocator slowpath, so just as Vlastimil suggested,
> some data from allocator should be necessary and helpful, IMHO.

As Vlastimil said, fragmentation effect should be checked. I will do
it and report the result on next version.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
