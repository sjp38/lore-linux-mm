Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m6MGtKeS474538
	for <linux-mm@kvack.org>; Tue, 22 Jul 2008 16:55:20 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6MGtKpN2265220
	for <linux-mm@kvack.org>; Tue, 22 Jul 2008 17:55:20 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6MGtJBE014937
	for <linux-mm@kvack.org>; Tue, 22 Jul 2008 17:55:20 +0100
Subject: memory hotplug: hot-remove fails on lowest chunk in ZONE_MOVABLE
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Content-Type: text/plain
Date: Tue, 22 Jul 2008 18:55:19 +0200
Message-Id: <1216745719.4871.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

I've been testing memory hotplug on s390, on a system that starts w/o
memory in ZONE_MOVABLE at first, and then some memory chunks will be
added to ZONE_MOVABLE via memory hot-add. Now I observe the following
problem:

Memory hot-remove of the lowest memory chunk in ZONE_MOVABLE will fail
because of some reserved pages at the beginning of each zone
(MIGRATE_RESERVED).

During memory hot-add, setup_per_zone_pages_min() will be called from
online_pages() to redistribute/recalculate the reserved page blocks.
This will mark some page blocks at the beginning of each zone as
MIGRATE_RESERVE. Now, the memory chunk containing these blocks cannot
be set offline again, because only MIGRATE_MOVABLE pages can be isolated
(offline_pages -> start_isolate_page_range).

So you cannot remove all the memory chunks that have been added via
memory hotplug. I'm not sure if I am missing something here, or if this
really is a bug. Any thoughts?

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
