Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 94D696B0033
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 14:27:13 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p5so1910137pgn.7
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 11:27:13 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTPS id e29si5207953plj.546.2017.09.18.11.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 11:27:12 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [RFC v2] oom: capture unreclaimable slab info in oom message when kernel panic
Date: Tue, 19 Sep 2017 02:26:47 +0800
Message-Id: <1505759209-102539-1-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Sorry, forgot send the cover letter with change log. Resent the patch series.

Recently we ran into a oom issue, kernel panic due to no killable process.
The dmesg shows huge unreclaimable slabs used almost 100% memory, but kdump doesn't capture vmcore due to some reason.

So, it may sound better to capture unreclaimable slab info in oom message when kernel panic to aid trouble shooting and cover the corner case.
Since kernel already panic, so capturing more information sounds worthy and doesn't bother normal oom killer.

With the patchset, tools/vm/slabinfo has a new option, "-U", to show unreclaimable slab only.

And, oom will print all non zero (num_objs * size != 0) unreclaimable slabs in oom killer message.

For details, please see the commit log for each commit.

Changelog v1 a??> v2:
* Removed the original patch 1 (a??mm: slab: output reclaimable flag in /proc/slabinfoa??) since Christopher suggested it might break the compatibility and /proc/slabinfo is legacy
* Added Christophera??s Acked-by
* Removed acquiring slab_mutex per Tetsuoa??s comment


Yang Shi (2):
      tools: slabinfo: add "-U" option to show unreclaimable slabs only
      mm: oom: show unreclaimable slab info when kernel panic

 mm/oom_kill.c       | 13 +++++++++++--
 mm/slab.c           |  1 +
 mm/slab.h           |  7 +++++++
 mm/slab_common.c    | 30 ++++++++++++++++++++++++++++++
 mm/slub.c           |  1 +
 tools/vm/slabinfo.c | 11 ++++++++++-
 6 files changed, 60 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
