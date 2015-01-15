Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 846E36B0038
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:49:15 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id ms9so15198631lab.10
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:49:14 -0800 (PST)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [2a02:6b8:b030::69])
        by mx.google.com with ESMTPS id jq5si886855lbc.39.2015.01.15.10.49.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 10:49:14 -0800 (PST)
Subject: [PATCHSET RFC 0/6] memcg: inode-based dirty-set controller
From: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 15 Jan 2015 21:49:10 +0300
Message-ID: <20150115180242.10450.92.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: Roman Gushchin <klamm@yandex-team.ru>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, koct9i@gmail.com

This is ressurection of my old RFC patch for dirty-set accounting cgroup [1]
Now it's merged into memory cgroup and got bandwidth controller as a bonus.

That shows alternative solution: less accurate but much less monstrous than
accurate page-based dirty-set controller from Tejun Heo.

Memory overhead: +1 pointer into struct address_space.
Perfomance overhead is almost zero, no new locks added.

Idea is stright forward: link each inode to some cgroup when first dirty
page appers and account all dirty pages to it. Writeback is implemented
as single per-bdi writeback work which writes only inodes which belong
to memory cgroups where amount of dirty memory is beyond thresholds.

Third patch adds trick for handling shared inodes which have dirty pages
from several cgroups: it marks whole inode as shared and alters writeback
filter for it.

The rest is an example of bandwith and iops controller build on top of that.
Design is completely original, I bet nobody ever used task-works for that =)

[1] [PATCH RFC] fsio: filesystem io accounting cgroup
http://marc.info/?l=linux-kernel&m=137331569501655&w=2

Patches also available here:
https://github.com/koct9i/linux.git branch memcg_dirty_control

---

Konstantin Khebnikov (6):
      memcg: inode-based dirty and writeback pages accounting
      memcg: dirty-set limiting and filtered writeback
      memcg: track shared inodes with dirty pages
      percpu_ratelimit: high-performance ratelimiting counter
      delay-injection: resource management via procrastination
      memcg: filesystem bandwidth controller


 block/blk-core.c                 |    2 
 fs/direct-io.c                   |    2 
 fs/fs-writeback.c                |   22 ++
 fs/inode.c                       |    1 
 include/linux/backing-dev.h      |    1 
 include/linux/fs.h               |   14 +
 include/linux/memcontrol.h       |   27 +++
 include/linux/percpu_ratelimit.h |   45 ++++
 include/linux/sched.h            |    7 +
 include/linux/writeback.h        |    1 
 include/trace/events/sched.h     |    7 +
 include/trace/events/writeback.h |    1 
 kernel/sched/core.c              |   66 +++++++
 kernel/sched/fair.c              |   12 +
 lib/Makefile                     |    1 
 lib/percpu_ratelimit.c           |  168 +++++++++++++++++
 mm/memcontrol.c                  |  381 ++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c              |   32 +++
 mm/readahead.c                   |    2 
 mm/truncate.c                    |    1 
 mm/vmscan.c                      |    4 
 21 files changed, 787 insertions(+), 10 deletions(-)
 create mode 100644 include/linux/percpu_ratelimit.h
 create mode 100644 lib/percpu_ratelimit.c

--
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
