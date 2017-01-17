Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED156B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 05:37:11 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id gt1so16093387wjc.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:37:11 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 36si24558883wrf.7.2017.01.17.02.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 02:37:09 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id r126so37420850wmr.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:37:09 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] follow up nodereclaim for 32b fix
Date: Tue, 17 Jan 2017 11:36:59 +0100
Message-Id: <20170117103702.28542-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
I have previously posted this as an RFC [1] but there didn't seem to be
any objections other than some requests to reorganize the changes in
a slightly different way so I am reposting the series and asking for
inclusion.

This is a follow up on top of [2]. The patch 1 cleans up the code a bit.
I haven't seen any real issues or bug reports but conceptualy ignoring
the maximum eligible zone in get_scan_count is wrong by definition. This
is what patch 2 does.  Patch 3 removes inactive_reclaimable_pages
which was a kind of hack around for the problem which should have been
addressed at get_scan_count.

There is one more place which needs a special handling which is not
a part of this series. too_many_isolated can get confused as well. I
already have some preliminary work but it still needs some testing so I
will post it separatelly.

Michal Hocko (3):
      mm, vmscan: cleanup lru size claculations
      mm, vmscan: consider eligible zones in get_scan_count
      Revert "mm: bail out in shrink_inactive_list()"

 include/linux/mmzone.h |   2 +-
 mm/vmscan.c            | 116 +++++++++++++++++++------------------------------
 mm/workingset.c        |   2 +-
 3 files changed, 46 insertions(+), 74 deletions(-)

[1] http://lkml.kernel.org/r/20170110125552.4170-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20170104100825.3729-1-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
