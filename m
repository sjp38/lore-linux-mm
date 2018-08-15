Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07F996B0007
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 10:42:31 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id p12-v6so1018855wro.7
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 07:42:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u12-v6sor8237529wro.63.2018.08.15.07.42.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Aug 2018 07:42:29 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v3 0/4] Refactoring for remove_memory_section/unregister_mem_sect_under_nodes
Date: Wed, 15 Aug 2018 16:42:15 +0200
Message-Id: <20180815144219.6014-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

v2 -> v3:
        - NODEMASK_FREE can deal with NULL pointers, so do not
          make it conditional (by David).
        - Split up node_online's check patch (David's suggestion)
        - Added Reviewed-by from Andrew and David
        - Fix checkpath.pl warnings

This patchset does some cleanups and refactoring in the memory-hotplug code.

The first and the second patch are pretty straightforward, as they
only remove unused arguments/checks.

The third one refactors unregister_mem_sect_under_nodes.
This is needed to have a proper fallback in case we could not allocate
memory. (details can be seen in patch3).

The fourth patch removes a node_online check.
We are getting the nid from pages that are yet not removed, but a node
can only be offline when its memory/cpu's have been removed.
Therefore, we do not really need to check for the node to be online here.
Since this change has a patch for itself, we could quickly revert it
if we notice that something is wrong with it, or drop it if people
are concerned about it.

Oscar Salvador (4):
  mm/memory-hotplug: Drop unused args from remove_memory_section
  mm/memory_hotplug: Drop mem_blk check from
    unregister_mem_sect_under_nodes
  mm/memory_hotplug: Refactor unregister_mem_sect_under_nodes
  mm/memory_hotplug: Drop node_online check in
    unregister_mem_sect_under_nodes

 drivers/base/memory.c |  5 ++---
 drivers/base/node.c   | 29 +++++++++++++++--------------
 include/linux/node.h  |  5 ++---
 3 files changed, 19 insertions(+), 20 deletions(-)

-- 
2.13.6
