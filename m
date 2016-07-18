Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 354CF6B025F
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:39:32 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so109461512lfw.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:39:32 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 2si9839186wml.5.2016.07.18.01.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 01:39:31 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id o80so11569178wme.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:39:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/2] mempool vs. page allocator interaction
Date: Mon, 18 Jul 2016 10:39:22 +0200
Message-Id: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

Hi,
there have been two issues identified when investigating dm-crypt
backed swap recently [1]. The first one looks like a regression from
f9054c70d28b ("mm, mempool: only set __GFP_NOMEMALLOC if there are free
elements") because swapout path can now deplete all the available memory
reserves. The first patch tries to address that issue by dropping
__GFP_NOMEMALLOC only to TIF_MEMDIE tasks.

The second issue is that dm writeout path which relies on mempool
allocator gets throttled by the direct reclaim in throttle_vm_writeout
which just makes the whole memory pressure problem even worse. The
patch2 just makes sure that we annotate mempool users to be throttled
less by PF_LESS_THROTTLE flag and prevent from throttle_vm_writeout for
that path. mempool users are usually the IO path and throttle them less
sounds like a reasonable way to go.

I do not have any more complicated dm setup available so I would
appreciate if dm people (CCed) could give these two a try.

Also it would be great to iron out concerns from David. He has posted a
deadlock stack trace [2] which has led to f9054c70d28b which is bio
allocation lockup because the TIF_MEMDIE process cannot make a forward
progress without access to memory reserve. This case should be fixed by
patch 1 AFAICS. There are other potential cases when the stuck mempool
is called from PF_MEMALLOC context and blocks the oom victim indirectly
(over a lock) but I believe those are much less likely and we have the
oom reaper to make a forward progress.

Sorry of pulling the discussion outside of the original email thread
but there were more lines of dicussion there and I felt discussing
particualr solution with its justification has a greater chance of
moving towards a solution. I am sending this as an RFC because this
needs a deep review as there might be other side effects I do not see
(especially about patch 2).

Any comments, suggestions are welcome.

---
[1] http://lkml.kernel.org/r/alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com
[2] http://lkml.kernel.org/r/alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
