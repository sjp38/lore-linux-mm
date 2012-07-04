Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 524166B0078
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 04:38:54 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 0/3 V1 resend] mm: add new migrate type and online_movable for hotplug
Date: Wed, 4 Jul 2012 16:38:55 +0800
Message-Id: <1341391138-9547-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andi Kleen <andi@firstfloor.org>, Julia Lawall <julia@diku.dk>, David Howells <dhowells@redhat.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kay Sievers <kay.sievers@vrfy.org>, Ingo Molnar <mingo@elte.hu>, Paul Gortmaker <paul.gortmaker@windriver.com>, Daniel Kiper <dkiper@net-space.pl>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Bjorn Helgaas <bhelgaas@google.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

This patchset adds a stable-movable-migrate-type for memory-management,
It is used for anti-fragmentation(hugepage, big-order allocation...),
hot-removal-of-memory(virtualization, power-conserve, move memory between systems
to make better utilities of memories).

it likes ZONE_MOVABLE, but it is more flexible.

o	The 1st patch fixes the allocation of CMA and do prepares
	for movable-like types.

o	The 2nd patch add a new migrate type which stands for the movable types
	which pages will not be changed to the other type.

	I chose the name MIGRATE_HOTREMOVE from MIGRATE_HOTREMOVE
	and MIGRATE_MOVABLE_STABLE, it just because the first usecase of
	this new type is for hotremove.

o	The 3th path introduces online_movable. When a memoryblock is onlined
	by "online_movable", the kernel will not have directly reference to
	the page of the memoryblock, thus we can remove that memory any time
	when needed.

	Different from ZONE_MOVABLE: it can be used for any given memroyblock.
	it can be set after boot(ZONE_MOVABLE zones are configured when booting)

Lai Jiangshan (3):
  use __rmqueue_smallest when borrow memory from MIGRATE_CMA
  add MIGRATE_HOTREMOVE type
  add online_movable

 arch/tile/mm/init.c            |    2 +-
 drivers/acpi/acpi_memhotplug.c |    3 +-
 drivers/base/memory.c          |   24 +++++++----
 include/linux/memory.h         |    1 +
 include/linux/memory_hotplug.h |    4 +-
 include/linux/mmzone.h         |   37 +++++++++++++++++
 include/linux/page-isolation.h |    2 +-
 mm/compaction.c                |    6 +-
 mm/memory-failure.c            |    8 +++-
 mm/memory_hotplug.c            |   36 +++++++++++++---
 mm/page_alloc.c                |   86 ++++++++++++++++-----------------------
 mm/vmstat.c                    |    3 +
 12 files changed, 136 insertions(+), 76 deletions(-)

-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
