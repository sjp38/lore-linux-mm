Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38DED6B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:37:13 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q10so4788129pgq.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 20:37:13 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id o61si3227886plb.168.2016.11.22.20.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 20:37:12 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 144so131969pfv.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 20:37:12 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [mm v2 0/3] Support memory cgroup hotplug
Date: Wed, 23 Nov 2016 15:36:51 +1100
Message-Id: <1479875814-11938-1-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org
Cc: Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

In the absence of hotplug we use extra memory proportional to
(possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
to disable large consumption with large number of cgroups. This patch
adds hotplug support to memory cgroups and reverts the commit that
limited possible nodes to online nodes.

Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org> 
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

I've tested this patches under a VM with two nodes and movable
nodes enabled. I've offlined nodes and checked that the system
and cgroups with tasks deep in the hierarchy continue to work
fine.

These patches are on top of linux-next (20161117)

Changelog v2:
	Add get/put_online_mems() around node iteration
	Use MEM_OFFLINE/MEM_ONLINE instead of MEM_GOING_OFFLINE/ONLINE

Balbir Singh (3):
  mm: Add basic infrastructure for memcg hotplug support
  mm: Move operations to hotplug callbacks
  powerpc/mm: fix node_possible_map limitations

 arch/powerpc/mm/numa.c |   7 ----
 mm/memcontrol.c        | 107 +++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 94 insertions(+), 20 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
