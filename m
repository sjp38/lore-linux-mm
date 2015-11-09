Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6320F6B0255
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 17:04:17 -0500 (EST)
Received: by wmnn186 with SMTP id n186so128761088wmn.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 14:04:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lk1si152505wjb.153.2015.11.09.14.04.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Nov 2015 14:04:16 -0800 (PST)
Subject: Re: [PATCH 1/3] tree wide: get rid of __GFP_REPEAT for order-0
 allocations part I
References: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
 <1446740160-29094-2-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5641185F.9020104@suse.cz>
Date: Mon, 9 Nov 2015 23:04:15 +0100
MIME-Version: 1.0
In-Reply-To: <1446740160-29094-2-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 5.11.2015 17:15, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_REPEAT has a rather weak semantic but since it has been introduced
> around 2.6.12 it has been ignored for low order allocations. Yet we have
> the full kernel tree with its usage for apparently order-0 allocations.
> This is really confusing because __GFP_REPEAT is explicitly documented
> to allow allocation failures which is a weaker semantic than the current
> order-0 has (basically nofail).
> 
> Let's simply reap out __GFP_REPEAT from those places. This would allow
> to identify place which really need allocator to retry harder and
> formulate a more specific semantic for what the flag is supposed to do
> actually.

So at first I thought "yeah that's obvious", but then after some more thinking,
I'm not so sure anymore.

I think we should formulate the semantic first, then do any changes. Also, let's
look at the flag description (which comes from pre-git):

 * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
 * _might_ fail.  This depends upon the particular VM implementation.

So we say it's implementation detail, and IIRC the same is said about which
orders are considered costly and which not, and the associated rules. So, can we
blame callers that happen to use __GFP_REPEAT essentially as a no-op in the
current implementation? And is it a problem that they do that?

So I think we should answer the following questions:

* What is the semantic of __GFP_REPEAT?
  - My suggestion would be something like "I would really like this allocation
to succeed. I still have some fallback but it's so suboptimal I'd rather wait
for this allocation." And then we could e.g. change some heuristics to take that
into account - e.g. direct compaction could ignore the deferred state and
pageblock skip bits, to make sure it's as thorough as possible. Right now, that
sort of happens, but not quite - given enough reclaim/compact attempts, the
compact attempts might break out of deferred state. But pages_reclaimed might
reach 1 << order before compaction "undefers", and then it breaks out of the
loop. Is any such heuristic change possible for reclaim as well?
As part of this question we should also keep in mind/rethink __GFP_NORETRY as
that's supposed to be the opposite flag to __GFP_REPEAT.

* Can it ever happen that __GFP_REPEAT could make some difference for order-0?
  - Certainly not wrt compaction, how about reclaim?
  - If it couldn't possibly affect order-0, then yeah proceed with Patch 1.

* Is PAGE_ALLOC_COSTLY_ORDER considered an implementation detail?
  - I would think so, and if yes, then we probably shouldn't remove
__GFP_NORETRY for order-1+ allocations that happen to be not costly in the
current implementation?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
