Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 273376B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 05:59:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g141so10389596wmd.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 02:59:38 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id b75si2225517wma.30.2016.09.09.02.59.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 02:59:36 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 3FE38989CE
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 09:59:36 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [RFC PATCH 0/4] Reduce tree_lock contention during swap and reclaim of a single file v1
Date: Fri,  9 Sep 2016 10:59:31 +0100
Message-Id: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>

This is a follow-on series from the thread "[lkp] [xfs] 68a9f5e700:
aim7.jobs-per-min -13.6% regression" with active parties cc'd.  I've
pushed the series to git.kernel.org where the LKP robot should pick it
up automatically.

git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git mm-reclaim-contention-v1r15

The progression of this series has been unsatisfactory. Dave originally
reported a problem with tree_lock contention and while it can be fixed
by pushing reclaim to direct reclaim, it slows swap considerably and was
not a universal win. This series is the best balance I've found so far
between the swapping and large rewriter cases.

I never reliably produced the same contentions that Dave did so testing
is needed.  Dave, ideally you would test patches 1+2 and patches 1+4 but
a test of patches 1+3 would also be nice if you have the time. Minimally,
I'm expected that patches 1+2 will help the swapping-to-fast-storage case
(LKP to confirm independently) and may be worth considering on their own
even if Dave's test case is not helped.

 drivers/block/brd.c |   1 +
 mm/vmscan.c         | 209 +++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 182 insertions(+), 28 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
