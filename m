Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 888556B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 04:53:09 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y84so35989012lfc.3
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:53:09 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id if5si3552563wjb.180.2016.05.04.01.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 01:53:08 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r12so9031897wme.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:53:08 -0700 (PDT)
Date: Wed, 4 May 2016 10:53:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 12/14] mm, oom: protect !costly allocations some more
Message-ID: <20160504085307.GD29978@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-13-git-send-email-mhocko@kernel.org>
 <20160504060123.GB10899@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504060123.GB10899@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 04-05-16 15:01:24, Joonsoo Kim wrote:
> On Wed, Apr 20, 2016 at 03:47:25PM -0400, Michal Hocko wrote:
[...]

Please try to trim your responses it makes it much easier to follow the
discussion

> > +static inline bool
> > +should_compact_retry(unsigned int order, enum compact_result compact_result,
> > +		     enum migrate_mode *migrate_mode,
> > +		     int compaction_retries)
> > +{
> > +	if (!order)
> > +		return false;
> > +
> > +	/*
> > +	 * compaction considers all the zone as desperately out of memory
> > +	 * so it doesn't really make much sense to retry except when the
> > +	 * failure could be caused by weak migration mode.
> > +	 */
> > +	if (compaction_failed(compact_result)) {
> 
> IIUC, this compaction_failed() means that at least one zone is
> compacted and failed. This is not same with your assumption in the
> comment. If compaction is done and failed on ZONE_DMA, it would be
> premature decision.

Not really, because if other zones are making some progress then their
result will override COMPACT_COMPLETE

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
