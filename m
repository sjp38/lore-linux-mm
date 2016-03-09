Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 77DC06B0253
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 06:11:12 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l68so187583128wml.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 03:11:12 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id bo10si9326855wjb.163.2016.03.09.03.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 03:11:11 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id l68so9315373wml.3
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 03:11:10 -0800 (PST)
Date: Wed, 9 Mar 2016 12:11:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, oom: protect !costly allocations some more
Message-ID: <20160309111109.GG27018@dhcp22.suse.cz>
References: <20160307160838.GB5028@dhcp22.suse.cz>
 <1457444565-10524-1-git-send-email-mhocko@kernel.org>
 <1457444565-10524-4-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457444565-10524-4-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Joonsoo has pointed out that this attempt is still not sufficient
becasuse we might have invoked only a single compaction round which
is might be not enough. I fully agree with that. Here is my take on
that. It is again based on the number of retries loop.

I was also playing with an idea of doing something similar to the
reclaim retry logic:
	if (order) {
		if (compaction_made_progress(compact_result)
			no_compact_progress = 0;
		else if (compaction_failed(compact_result)
			no_compact_progress++;
	}
but it is compaction_failed() part which is not really
straightforward to define. Is it COMPACT_NO_SUITABLE_PAGE
resp. COMPACT_NOT_SUITABLE_ZONE sufficient? compact_finished and
compaction_suitable however hide this from compaction users so it
seems like we can never see it.

Maybe we can update the feedback mechanism from the compaction but
retries count seems reasonably easy to understand and pragmatic. If
we cannot form a order page after we tried for N times then it really
doesn't make much sense to continue and we are oom for this order. I am
holding my breath to hear from Hugh on this, though. In case it doesn't
then I would be really interested whether changing MAX_COMPACT_RETRIES
makes any difference.

I haven't preserved Tested-by from Sergey to be on the safe side even
though strictly speaking this should be less prone to high order OOMs
because we clearly retry more times.
---
