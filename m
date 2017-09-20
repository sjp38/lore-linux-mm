Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F0DF06B0038
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 15:09:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y29so6128628pff.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 12:09:47 -0700 (PDT)
Received: from out0-211.mail.aliyun.com (out0-211.mail.aliyun.com. [140.205.0.211])
        by mx.google.com with ESMTPS id t63si3519742pfg.124.2017.09.20.12.09.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 12:09:46 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [RFC v3] oom: capture unreclaimable slab info in oom message when kernel panic
Date: Thu, 21 Sep 2017 03:09:34 +0800
Message-Id: <1505934576-9749-1-git-send-email-yang.s@alibaba-inc.com>
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

Changelog v2 a??> v3:
* Show used size and total size of each kmem cache per Davida??s comment

Changelog v1 a??> v2:
* Removed the original patch 1 (a??mm: slab: output reclaimable flag in /proc/slabinfoa??) since Christoph suggested it might break the compatibility and /proc/slabinfo is legacy
* Added Christopha??s Acked-by
* Removed acquiring slab_mutex per Tetsuoa??s comment


Yang Shi (2):
      tools: slabinfo: add "-U" option to show unreclaimable slabs only
      mm: oom: show unreclaimable slab info when kernel panic

 mm/oom_kill.c       | 13 +++++++++++--
 mm/slab.c           |  1 +
 mm/slab.h           |  7 +++++++
 mm/slab_common.c    | 31 +++++++++++++++++++++++++++++++
 mm/slub.c           |  1 +
 tools/vm/slabinfo.c | 11 ++++++++++-
 6 files changed, 61 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
