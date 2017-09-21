Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 508D86B0069
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 16:52:44 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m30so13567786pgn.2
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 13:52:44 -0700 (PDT)
Received: from out0-199.mail.aliyun.com (out0-199.mail.aliyun.com. [140.205.0.199])
        by mx.google.com with ESMTPS id d196si1531802pfd.210.2017.09.21.13.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 13:52:43 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 0/2 v5] oom: capture unreclaimable slab info in oom message when kernel panic
Date: Fri, 22 Sep 2017 04:52:23 +0800
Message-Id: <1506027145-93950-1-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Recently we ran into a oom issue, kernel panic due to no killable process.
The dmesg shows huge unreclaimable slabs used almost 100% memory, but kdump doesn't capture vmcore due to some reason.

So, it may sound better to capture unreclaimable slab info in oom message when kernel panic to aid trouble shooting and cover the corner case.
Since kernel already panic, so capturing more information sounds worthy and doesn't bother normal oom killer.

With the patchset, tools/vm/slabinfo has a new option, "-U", to show unreclaimable slab only.

And, oom will print all non zero (num_objs * size != 0) unreclaimable slabs in oom killer message.

For details, please see the commit log for each commit.

Changelog v4 a??> v5:
* Solved the comments from David
* Build test SLABINFO = n

Changelog v3 a??> v4:
* Solved the comments from David
* Added Davida??s Acked-by in patch 1

Changelog v2 a??> v3:
* Show used size and total size of each kmem cache per Davida??s comment

Changelog v1 a??> v2:
* Removed the original patch 1 (a??mm: slab: output reclaimable flag in /proc/slabinfoa??) since Christoph suggested it might break the compatibility and /proc/slabinfo is legacy
* Added Christopha??s Acked-by
* Removed acquiring slab_mutex per Tetsuoa??s comment

Yang Shi (2):
      tools: slabinfo: add "-U" option to show unreclaimable slabs only
      mm: oom: show unreclaimable slab info when kernel panic

 mm/oom_kill.c       |  3 +++
 mm/slab.h           |  8 ++++++++
 mm/slab_common.c    | 29 +++++++++++++++++++++++++++++
 tools/vm/slabinfo.c | 11 ++++++++++-
 4 files changed, 50 insertions(+), 1 deletion(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
