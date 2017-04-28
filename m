Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D24386B0317
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 17:56:51 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v1so18921034pgv.8
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 14:56:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id x3si7261036plb.1.2017.04.28.14.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 14:56:50 -0700 (PDT)
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: [PATCH 0/2] mm/memcontrol: fix reclaim bugs in mem_cgroup_iter
Date: Fri, 28 Apr 2017 14:55:45 -0700
Message-Id: <1493416547-19212-1-git-send-email-sean.j.christopherson@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, sean.j.christopherson@intel.com

This patch set contains two bug fixes for mem_cgroup_iter().  The bugs
were found by code inspection and were confirmed via synthetic testing
that forcefully setup the failing conditions.

Bug #1 is a race condition where mem_cgroup_iter() incorrectly returns
the same memcg to multiple threads reclaiming from the same root, zone,
priority and generation.  mem_cgroup_iter() doesn't check the result of
cmpxchg(iter->pos...) when setting the new pos, and so fails to detect
that it will return the same memcg as the thread that successfully set
iter->position.  If multiple threads read the same iter->position value,
then they will call css_next_descendant_pre() with the same css and will
compute the same memcg (unless they see different versions of the tree
due to an RCU update).

Bug #2 is also a race condition of sorts, with the same setup conditions
as bug #1.  If a reclaimer's initial call to mem_cgroup_iter() triggers
a restart of the hierarchy walk, i.e. css_next_descendant_pre() returns
NULL and prev == NULL, mem_cgroup_iter() fails to increment iter->gen...
even though it has started a new walk of the hierarchy.  This technically
isn't a bug for the thread that triggered the restart as it's reasonable
for that thread to perform a full walk of the tree, but other threads
in the current reclaim generation will incorrectly continue to walk the
tree since iter->generation won't be updated until one of the reclaimers
reaches the end of the hierarchy a second time.

The two patches can be applied independently, but I included them in a
single series as the fix for bug #1 can theoretically exacerbate bug #2,
and bug #2 is likely more serious as it results in a duplicate walk of
the entire tree as opposed to a duplicate reclaim of a single memcg.


Sean Christopherson (2):
  mm/memcontrol: check cmpxchg(iter->pos...) result in mem_cgroup_iter()
  mm/memcontrol: inc reclaim gen if restarting walk in mem_cgroup_iter()

 mm/memcontrol.c | 56 +++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 47 insertions(+), 9 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
