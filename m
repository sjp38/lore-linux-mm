Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33B506B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 08:53:48 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y82-v6so736462wmb.5
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 05:53:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b66-v6sor575559wmg.1.2018.06.01.05.53.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Jun 2018 05:53:46 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH 0/4] Small cleanup for memoryhotplug
Date: Fri,  1 Jun 2018 14:53:17 +0200
Message-Id: <20180601125321.30652-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>


Hi,

I wanted to give it a try and do a small cleanup in the memhotplug's code.
A lot more could be done, but I wanted to start somewhere.
I tried to unify/remove duplicated code.

The following is what this patchset does:

1) add_memory_resource() has code to allocate a node in case it was offline.
   Since try_online_node has some code for that as well, I just made add_memory_resource() to
   use that so we can remove duplicated code..
   This is better explained in patch 1/4.

2) register_mem_sect_under_node() will be called only from link_mem_sections()

3) Get rid of link_mem_sections() in favour of walk_memory_range() with a callback to
   register_mem_sect_under_node()

4) Drop unnecessary checks from register_mem_sect_under_node()


I have done some tests and I could not see anything broken because of 
this patchset.

Oscar Salvador (4):
  mm/memory_hotplug: Make add_memory_resource use __try_online_node
  mm/memory_hotplug: Call register_mem_sect_under_node
  mm/memory_hotplug: Get rid of link_mem_sections
  mm/memory_hotplug: Drop unnecessary checks from
    register_mem_sect_under_node

 drivers/base/memory.c |   2 -
 drivers/base/node.c   |  52 +++++---------------------
 include/linux/node.h  |  21 +++++------
 mm/memory_hotplug.c   | 101 ++++++++++++++++++++++++++------------------------
 4 files changed, 71 insertions(+), 105 deletions(-)

-- 
2.13.6
