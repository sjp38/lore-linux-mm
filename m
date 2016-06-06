Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 044C16B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 07:32:30 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id w16so64607853lfd.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 04:32:29 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id d83si18019176wmf.53.2016.06.06.04.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 04:32:28 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id c74so7497526wme.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 04:32:28 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/2] mm: give GFP_REPEAT a better semantic
Date: Mon,  6 Jun 2016 13:32:14 +0200
Message-Id: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
this is a follow up for __GFP_REPEAT clean up merged into mmotm just
recently [1]. The main motivation for the change is that the current
implementation of __GFP_REPEAT is not very much useful.

The documentation says:
 * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
 *   _might_ fail.  This depends upon the particular VM implementation.

It just fails to mention that this is true only for large (costly) high
order which has been the case since the flag was introduced. A similar
semantic would be really helpful for smal orders as well, though,
because we have places where a failure with a specific fallback error
handling is preferred to a potential endless loop inside the page
allocator.

The cleanup [1] dropped __GFP_REPEAT usage for low (!costly) order users
so only those which might use larger orders have stayed. Let's rename the
flag to something more verbose and use it for existing users. Semantic for
those will not change. Then implement low (!costly) orders failure path
which is hit after the page allocator is about to hit the oom killer
path again.  That means that the first OOM killer invocation and all the
retries after then haven't helped to move on. This seems like a good
indication that any further progress is highly unlikely.

Xfs code already has an existing annotation for allocations which are
allowed to fail and we can trivially map them to the new gfp flag
because it will provide the semantic KM_MAYFAIL wants.

I assume we will grow more users - e.g. GFP_USER sounds like it could
use the flag by default. But I haven't explored this path properly yet.

I am sending this as an RFC and would like to hear back about the
approach. We have discussed this at LSF this year and there were
different ideas how to achieve the semantic. I have decided to go
__GFP_RETRY_HARD way because it nicely fits into the existing scheme
where __GFP_NORETRY and __GFP_NOFAIL already modify the default behavior
of the page allocator and the new flag would fit nicely between the two
existing flags. The patch 1 is much more verbose about different modes
of operation of the page allocator.

Thanks
---
[1] http://lkml.kernel.org/r/1464599699-30131-1-git-send-email-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
