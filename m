Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2513E8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:02:38 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p5-v6so1162087pfh.11
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 07:02:38 -0700 (PDT)
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id e22-v6si1206381pgi.111.2018.09.12.07.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 07:02:36 -0700 (PDT)
Date: Wed, 12 Sep 2018 15:02:18 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: [RFC] mm/memory_hotplug: wrong node identified if memory was never
 on-lined.
Message-ID: <20180912150218.00002cbc@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linuxarm@huawei.com, Oscar Salvador <osalvador@techadventures.net>

Hi All,

I've been accidentally (i.e. due to a script bug) testing some odd corner
cases of memory hotplug and run into this issue.

If we hot add some memory we have carefully avoided the need to use
get_nid_for_pfn as it isn't set until we online the memory.

Unfortunately if we never online the memory but instead just remove it again
we don't have any such protection so in unregister_mem_sect_under_nodes
we end up trying to call sysfs_remove_link for memory on (typically) node0
instead of the intended node.

So the path to this problem is

add_memory(Node, addr, size);
-> add_memory_resource(Node ...)
---> link_mem_sections(Node ...)
------> register_mem_sect_under_node(
----------> sysfs_create_link_nowarn(&node_devices[Node]->dev.kobj,...
(which creates the link to say
/sys/bus/nodes/devices/node5/memory84

Note that in code we avoid checking the nid set for the pfn in hotplug
paths.

remove_memory(Node, addr, size);
-> arch_remove_memory(start, size, NULL);
---> __remove_pages
-----> __remove_section
-------> unregister_memory_section
----------> remove_memory_section(Node,... -- Node set to 0 but not used at all.
-------------> unregister_mem_sect_under_node() - node not passed in anyway
---------------->get_nid_for_pfn(pfn).  (try to get it back again)
-------------------->sysfs_remove_link (wrong node number)
tries to remove
/sys/bus/nodes/devices/node0/memory84 which doesn't exist.

So not tidy, but not critical - but you get BUG_ON when you try
to add the memory again as there is a left over link in the way.


Now I'm not sure what the preferred fix for this would be.
1) Actually set the nid for each pfn during hot add rather than waiting for
   online.
2) Modify the whole call chain to pass the nid through as we know it at the
   remove_memory call for hotplug cases...

I personally favour option 2 but don't really have a deep enough understanding
to know if this is going to cause trouble anywhere else.

I mocked up option 2 using some updated arm64 hotplug patches and it seems
superficially fine if fairly invasive.

The whole structure is a little odd in that in the probe path the sysfs links
are not called via architecture specific code whilst in the remove they are.

Jonathan
