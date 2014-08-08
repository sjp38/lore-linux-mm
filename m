Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 627CE6B0036
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 17:38:23 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w62so6215347wes.15
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 14:38:22 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id fk6si5052724wib.75.2014.08.08.14.38.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 14:38:21 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/4] mm: memcontrol: populate unified hierarchy interface v2
Date: Fri,  8 Aug 2014 17:38:10 -0400
Message-Id: <1407533894-25845-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

memory cgroups are fundamentally broken when it comes to partitioning
the machine for many concurrent jobs.  In real life, workloads expand
and contract over time, and the hard limit is too static to reflect
this - it either wastes memory outside of the group, or wastes memory
inside the group.  As a result, the hard limit is mostly just used to
catch extreme consumption peaks, while workload trimming and balancing
is left to global reclaim and global OOM handling.  That in turn
requires more and more cgroup-awareness on the global level to make up
for the lack of useful policy enforcement on the cgroup level itself.

The ongoing versioning of the cgroup user interface gives us a chance
to fix such brokenness, and also clean up the interface and fix a lot
of the inconsistencies and ugliness that crept in over time.

This series adds a minimal set of control files to version 2 of the
memcg interface, implementing a new approach to machine partitioning.

Version 2 of this series is in response to feedback from Michal.  Some
of the changes are in code, but mostly it improves the documentation
and changelogs to describe the fundamental problems with the original
approach to machine partitioning and makes a case for the new model.

 Documentation/cgroups/unified-hierarchy.txt |  65 ++++++++
 include/linux/res_counter.h                 |  29 ++++
 include/linux/swap.h                        |   6 +-
 kernel/res_counter.c                        |   3 +
 mm/memcontrol.c                             | 250 +++++++++++++++++++---------
 mm/vmscan.c                                 |   7 +-
 6 files changed, 277 insertions(+), 83 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
