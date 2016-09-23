Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB376B027E
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 08:10:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w84so15535373wmg.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:10:02 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id l2si7297611wjg.109.2016.09.23.05.10.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 05:10:01 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id b184so2481652wma.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:10:00 -0700 (PDT)
Date: Fri, 23 Sep 2016 14:09:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/4] reintroduce compaction feedback for OOM decisions
Message-ID: <20160923120958.GM4478@dhcp22.suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160921171830.GH24210@dhcp22.suse.cz>
 <56f2c2ed-8a58-cf9c-dd00-c0d0e274607a@suse.cz>
 <20160923082627.GE4478@dhcp22.suse.cz>
 <9194950c-06b5-31d7-de17-1f8710dd5682@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9194950c-06b5-31d7-de17-1f8710dd5682@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>

On Fri 23-09-16 12:55:23, Vlastimil Babka wrote:
> On 09/23/2016 10:26 AM, Michal Hocko wrote:
> >>  include/linux/compaction.h |  5 +++--
> >>  mm/compaction.c            | 44 +++++++++++++++++++++++---------------------
> >>  mm/internal.h              |  1 +
> >>  mm/vmscan.c                |  6 ++++--
> >>  4 files changed, 31 insertions(+), 25 deletions(-)
> > 
> > This is much more code churn than I expected. I was thiking about it
> > some more and I am really wondering whether it actually make any sense
> > to check the fragidx for !costly orders. Wouldn't it be much simpler to
> > just put it out of the way for those regardless of the compaction
> > priority. In other words does this check makes any measurable difference
> > for !costly orders?
> 
> I've did some stress tests and sampling
> /sys/kernel/debug/extfrag/extfrag_index once per second. The lowest
> value I've got for order-2 was 0.705. The default threshold is 0.5, so
> this would still result in compaction considered as suitable.
> 
> But it's sampling so I might not got to the interesting moments, most of
> the time it was -1.000 which means the page should be just available.
> Also we would be changing behavior for the user-controlled
> vm.extfrag_threshold, so I'm not entirely sure about that.

Does anybody depend on that or even use it out there? I strongly suspect
this is one of those dark corners people even do not know they exist...

> I could probably reduce the churn so that compaction_suitable() doesn't
> need a new parameter. We could just skip compaction_suitable() check
> from compact_zone() on the highest priority, and go on even without
> sufficient free page gap?

Whatever makes the code easier to understand. Please do not take me
wrong I do not want to push back on this too hard I just always love to
get rid of an obscure heuristic which even might not matter. And as your
testing suggests this might really be the case for !costly orders AFAIU.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
