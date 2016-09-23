Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 914906B0267
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 06:55:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so13730262wmg.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 03:55:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a139si2744786wme.30.2016.09.23.03.55.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 03:55:51 -0700 (PDT)
Subject: Re: [PATCH 0/4] reintroduce compaction feedback for OOM decisions
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160921171830.GH24210@dhcp22.suse.cz>
 <56f2c2ed-8a58-cf9c-dd00-c0d0e274607a@suse.cz>
 <20160923082627.GE4478@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9194950c-06b5-31d7-de17-1f8710dd5682@suse.cz>
Date: Fri, 23 Sep 2016 12:55:23 +0200
MIME-Version: 1.0
In-Reply-To: <20160923082627.GE4478@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>

On 09/23/2016 10:26 AM, Michal Hocko wrote:
>>  include/linux/compaction.h |  5 +++--
>>  mm/compaction.c            | 44 +++++++++++++++++++++++---------------------
>>  mm/internal.h              |  1 +
>>  mm/vmscan.c                |  6 ++++--
>>  4 files changed, 31 insertions(+), 25 deletions(-)
> 
> This is much more code churn than I expected. I was thiking about it
> some more and I am really wondering whether it actually make any sense
> to check the fragidx for !costly orders. Wouldn't it be much simpler to
> just put it out of the way for those regardless of the compaction
> priority. In other words does this check makes any measurable difference
> for !costly orders?

I've did some stress tests and sampling
/sys/kernel/debug/extfrag/extfrag_index once per second. The lowest
value I've got for order-2 was 0.705. The default threshold is 0.5, so
this would still result in compaction considered as suitable.

But it's sampling so I might not got to the interesting moments, most of
the time it was -1.000 which means the page should be just available.
Also we would be changing behavior for the user-controlled
vm.extfrag_threshold, so I'm not entirely sure about that.

I could probably reduce the churn so that compaction_suitable() doesn't
need a new parameter. We could just skip compaction_suitable() check
from compact_zone() on the highest priority, and go on even without
sufficient free page gap?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
