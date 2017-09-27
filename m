Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0A776B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 20:53:46 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d8so24090715pgt.1
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 17:53:46 -0700 (PDT)
Received: from out0-243.mail.aliyun.com (out0-243.mail.aliyun.com. [140.205.0.243])
        by mx.google.com with ESMTPS id e62si6392796pfa.483.2017.09.26.17.53.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 17:53:45 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 0/3 v7] oom: capture unreclaimable slab info in oom message when kernel panic
Date: Wed, 27 Sep 2017 08:53:33 +0800
Message-Id: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
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

Changelog v6 -> v7:
* Added unreclaim_slabs_oom_ratio proc knob, unreclaimable slabs info will be dumped when unreclaimable slabs amount : all user memory > the ratio

Changelog v5 a??> v6:
* Fixed a checkpatch.pl warning for patch #2

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


Yang Shi (3):
      tools: slabinfo: add "-U" option to show unreclaimable slabs only
      mm: oom: show unreclaimable slab info when kernel panic
      doc: add description for unreclaim_slabs_oom_ratio

 Documentation/sysctl/vm.txt | 12 ++++++++++++
 include/linux/oom.h         |  1 +
 include/uapi/linux/sysctl.h |  1 +
 kernel/sysctl.c             |  9 +++++++++
 kernel/sysctl_binary.c      |  1 +
 mm/oom_kill.c               | 31 +++++++++++++++++++++++++++++++
 mm/slab.h                   |  8 ++++++++
 mm/slab_common.c            | 29 +++++++++++++++++++++++++++++
 tools/vm/slabinfo.c         | 11 ++++++++++-
 9 files changed, 102 insertions(+), 1 deletion(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
