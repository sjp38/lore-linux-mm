Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 581076B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 04:14:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so38866084wmw.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 01:14:42 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id kb10si37219110wjc.225.2016.05.16.01.14.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 01:14:41 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so16234488wmw.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 01:14:41 -0700 (PDT)
Date: Mon, 16 May 2016 10:14:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 12/13] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160516081439.GD23146@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-13-git-send-email-vbabka@suse.cz>
 <20160513141539.GR20141@dhcp22.suse.cz>
 <57397760.4060407@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57397760.4060407@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon 16-05-16 09:31:44, Vlastimil Babka wrote:
> On 05/13/2016 04:15 PM, Michal Hocko wrote:
> > On Tue 10-05-16 09:36:02, Vlastimil Babka wrote:
> > > 
> > > - should_compact_retry() is only called when should_reclaim_retry() returns
> > >    false. This means that compaction priority cannot get increased as long
> > >    as reclaim makes sufficient progress. Theoretically, reclaim should stop
> > >    retrying for high-order allocations as long as the high-order page doesn't
> > >    exist but due to races, this may result in spurious retries when the
> > >    high-order page momentarily does exist.
> > 
> > This is intentional behavior and I would like to preserve it if it is
> > possible. For higher order pages should_reclaim_retry retries as long
> > as there are some eligible high order pages present which are just hidden
> > by the watermark check. So this is mostly to get us over watermarks to
> > start carrying about fragmentation. If we race there then nothing really
> > terrible should happen and we should eventually converge to a terminal
> > state.
> > 
> > Does this make sense to you?
> 
> Yeah it should work, my only worry was that this may get subtly wrong (as
> experience shows us) and due to e.g. slightly different watermark checks
> and/or a corner-case zone such as ZONE_DMA, should_reclaim_retry() would
> keep returning true, even if reclaim couldn't/wouldn't help anything. Then
> compaction would be needlessly kept at ineffective priority.

watermark check for ZONE_DMA should always fail because it fails even
when is completely free to the lowmem reserves. I had a subtle bug in
the original code to check highzone_idx rather than classzone_idx but
that should the fix has been posted recently:
http://lkml.kernel.org/r/1463051677-29418-2-git-send-email-mhocko@kernel.org

> Also my understanding of the initial compaction priorities is to lower the
> latency if fragmentation is just light and there's enough memory. Once we
> start struggling, I don't see much point in not switching to the full
> compaction priority quickly.

That is true but why to compact when there are high order pages and they
are just hidden by the watermark check.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
