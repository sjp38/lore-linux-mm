Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7078E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 23:18:27 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u13-v6so2037463pfm.8
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 20:18:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1-v6sor3814515plg.92.2018.09.18.20.18.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 20:18:25 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCH 0/3] introduce a new state 'isolate' for memblock to split the isolation and migration steps
Date: Wed, 19 Sep 2018 11:17:43 +0800
Message-Id: <1537327066-27852-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@techsingularity.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Currently, offline pages in the unit of memblock, and normally, it is done
one by one on each memblock. If there is only one numa node, then the dst
pages may come from the next memblock to be offlined, which wastes time
during memory offline. For a system with multi numa node, if only replacing
part of mem on a node, and the migration dst page can be allocated from
local node (which is done by [3/3]), it also faces such issue.
This patch suggests to introduce a new state, named 'isolate', the state
transition can be isolate -> online or reversion. And another slight
benefit of "isolated" state is no further allocation on this memblock,
which can block potential unmovable page allocated again from this
memblock for a long time.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Pingfan Liu (3):
  mm/isolation: separate the isolation and migration ops in offline
    memblock
  drivers/base/memory: introduce a new state 'isolate' for memblock
  drivers/base/node: create a partial offline hints under each node

 drivers/base/memory.c           | 31 ++++++++++++++++++++++++++++++-
 drivers/base/node.c             | 33 +++++++++++++++++++++++++++++++++
 include/linux/memory.h          |  1 +
 include/linux/mmzone.h          |  1 +
 include/linux/page-isolation.h  |  4 ++--
 include/linux/pageblock-flags.h |  2 ++
 mm/memory_hotplug.c             | 37 ++++++++++++++++++++++---------------
 mm/page_alloc.c                 |  4 ++--
 mm/page_isolation.c             | 28 +++++++++++++++++++++++-----
 9 files changed, 116 insertions(+), 25 deletions(-)

-- 
2.7.4
