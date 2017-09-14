Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3FAF6B0253
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 13:15:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e199so6211214pfh.3
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 10:15:13 -0700 (PDT)
Received: from out0-235.mail.aliyun.com (out0-235.mail.aliyun.com. [140.205.0.235])
        by mx.google.com with ESMTPS id e68si11492442pfb.300.2017.09.14.10.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 10:15:12 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [RFC] oom: capture unreclaimable slab info in oom message when kernel panic
Date: Fri, 15 Sep 2017 01:14:46 +0800
Message-Id: <1505409289-57031-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Recently we ran into a oom issue, kernel panic due to no killable process.
The dmesg shows huge unreclaimable slabs used almost 100% memory, but kdump
doesn't capture vmcore due to some reason.

So, it may sound better to capture unreclaimable slab info in oom message when
kernel panic to aid trouble shooting and cover the corner case.
Since kernel already panic, so capturing more information sounds worthy and
doesn't bother normal oom killer.

With the patchset, /proc/slabinfo can print an extra column for reclaimable
flag and tools/vm/slabinfo has a new option, "-U", to show unreclaimable
slab only.

And, oom will print all non zero (num_objs * size != 0) unreclaimable slabs in
oom killer message.

For details, please see the commit log for each commit.

Yang Shi (3):
      mm: slab: output reclaimable flag in /proc/slabinfo
      tools: slabinfo: add "-U" option to show unreclaimable slabs only
      mm: oom: show unreclaimable slab info when kernel panic

 mm/oom_kill.c       | 13 +++++++++++--
 mm/slab.c           |  1 +
 mm/slab.h           |  7 +++++++
 mm/slab_common.c    | 27 +++++++++++++++++++++++++++
 mm/slub.c           |  1 +
 tools/vm/slabinfo.c | 11 ++++++++++-
 6 files changed, 57 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
