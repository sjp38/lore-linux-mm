Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0B05C6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 02:46:04 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id 191so73018653wmq.0
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 23:46:03 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ey1si27166474wjd.157.2016.04.10.23.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Apr 2016 23:46:02 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id l6so18873779wml.3
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 23:46:02 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] oom detection rework followups
Date: Mon, 11 Apr 2016 08:45:49 +0200
Message-Id: <1460357151-25554-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
while playing with hugetlb test case described in [1] on a swapless
system I managed to get my machine in an endless look inside the
allocator. At first I found out the reclaim vs. compaction interaction
doesn't work quite well. See patch2 for more details but it still
bothered me why did_some_progress didn't break out of the loop. After
some more debugging it turned out that it is compaction_ready used in
the reclaim path which has been broken for quite some time. That's where
patch1 came in and which is something to apply regardless the rest of
the series.

I was thinking whether to mark it for stable but cannot decide one way
or the other. I think the fix is obvious but I am not so sure about all
the potential side effects. A wrong compaction_ready decision would
cause do_try_to_free_pages to break out early rather than dropping the
reclaim priority and spending more time scanning LRUs. I have hard time to
think about how good/bad this might be considering the compaction might
decide to defer or just to do something useful between reclaim rounds.

While patch 1 solved the issue I was seeing I still think that patch
2 is reasonable as well. It had fixed the issue as well but it is not
really needed (at least for the above mentioned load) right now. On the
other hand I like how it resembles the reclaim retry logic and puts some
bound to when it make some sense to retry.

So in short patch 1 should go regardless the oom detection rework which
might take some time to settle down (assuming I haven't missed something
and the fix is really correct), and patch 2 would be good to go on top of
the current series.

---
[1] http://lkml.kernel.org/r/1459855533-4600-12-git-send-email-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
