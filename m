Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C66A0280256
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 13:18:33 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so49406070wmg.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 10:18:33 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id o21si32988949wmg.65.2016.09.21.10.18.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 10:18:32 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w84so9751258wmg.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 10:18:32 -0700 (PDT)
Date: Wed, 21 Sep 2016 19:18:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/4] reintroduce compaction feedback for OOM decisions
Message-ID: <20160921171830.GH24210@dhcp22.suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160906135258.18335-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>

On Tue 06-09-16 15:52:54, Vlastimil Babka wrote:
> After several people reported OOM's for order-2 allocations in 4.7 due to
> Michal Hocko's OOM rework, he reverted the part that considered compaction
> feedback [1] in the decisions to retry reclaim/compaction. This was to provide
> a fix quickly for 4.8 rc and 4.7 stable series, while mmotm had an almost
> complete solution that instead improved compaction reliability.
> 
> This series completes the mmotm solution and reintroduces the compaction
> feedback into OOM decisions. The first two patches restore the state of mmotm
> before the temporary solution was merged, the last patch should be the missing
> piece for reliability. The third patch restricts the hardened compaction to
> non-costly orders, since costly orders don't result in OOMs in the first place.
> 
> Some preliminary testing suggested that this approach should work, but I would
> like to ask all who experienced the regression to please retest this. You will
> need to apply this series on top of tag mmotm-2016-08-31-16-06 from the mmotm
> git tree [2]. Thanks in advance!

We still do not ignore fragindex in the full priority. This part has
always been quite unclear to me so I cannot really tell whether that
makes any difference or not but just to be on the safe side I would
preffer to have _all_ the shortcuts out of the way in the highest
priority. It is true that this will cause COMPACT_NOT_SUITABLE_ZONE
so keep retrying but still a complication to understand the workflow.

What do you think?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
