From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070720194120.16126.56046.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/1] Synchronous lumpy reclaim
Date: Fri, 20 Jul 2007 20:41:13 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

With ZONE_MOVABLE and lumpy reclaim merged for 2.6.23, I started testing
different scenarios based on just the zones. Previous testing scenarios
had assumed the presence of grouping pages by mobility and various other
-mm patches which might not be indicative of mainline behaviour. Previous
tests also aggressively tried to allocate the pages which is unlikely to
be typical behaviour.

I've included a script below for testing the behaviour of ZONE_MOVABLE in a
more reasonable fashion likely to be used by an application or the growing
of the huge page pool. The test fills physical memory with some data and
then uses SystemTap to allocate memory from just ZONE_MOVABLE. The expected
results were that the zone could be fully allocated as huge pages if the
system was at rest. Without systemtap, similar results can be found by using
nr_hugepages proc file but you have to guess from the values in buddyinfo on
whether the pages were coming from ZONE_MOVABLE or not so it's not as clear.

The results were not as expected. Even with lumpy reclaim, the system had
difficulty allocating huge pages from ZONE_MOVABLE unless the pages were
all the same age or the system inactive for quite some time. It also often
required that applications be exited or using tricks like dd'ing large
files and deleting them or using drop_caches. Trying to use the zone while X
apps were running was particularly difficult.

The problem is that reclaim moves on too easily to the next block of pages.
This means it queues up a number of pages but they are not reclaimed by
the time an allocation attempt is made so it appears to fail.  The patch
following after this mail teaches processes directly reclaiming contiguous
pages to wait for pages to free within an area before retrying the allocation.
I believe this patch or something like it will be needed in 2.6.23 because
this is a looks like buggy behaviour in lumpy reclaim even though strictly
speaking it is not wrong.

Test scenario is based on my desktop machine and looks like;

o i386 with 2GB of RAM
o ZONE_MOVABLE = 512MB of RAM (i.e. 4 active zones)
o Machine freshly booted
o X started - 9 terminals, two instances of konqueror
o Light load in the background due to some badly behaving daemons
o Test script runs

These are the results of the test script.

2.6.22-git13
============
Total huge pages:             122
Successfully allocated:       12 hugepages
Failed allocation at attempt: 12
Failed allocation at attempt: 12
Failed allocation at attempt: 12
Failed allocation at attempt: 12

2.6.22-git13-syncwriteback
==========================
Total huge pages:             122
Successfully allocated:       50 hugepages
Failed allocation at attempt: 14
Failed allocation at attempt: 14
Failed allocation at attempt: 18
Failed allocation at attempt: 50

I ran the SystemTap script a second time a few minues after the test completed
so that all IO would have completed and the system would be relatively idle
again. The results were

2.6.22-git13 after some idle time
=================================
Total huge pages:             122
Successfully allocated:       45 hugepages
Failed allocation at attempt: 45
Failed allocation at attempt: 45
Failed allocation at attempt: 45
Failed allocation at attempt: 45

2.6.22-git13-syncwriteback after some idle time
===============================================
Total huge pages:             122
Successfully allocated:       122 hugepages
Failed allocation at attempt: 78
Failed allocation at attempt: 80
Failed allocation at attempt: 112

The patches have been tested on i386, x86_64 and ppc64. This is the test
script I used to verify the problem for anyone wishing to reproduce the
results.

===> CUT HERE <===
#!/bin/bash
# This script is a simple regression test for the usage of ZONE_MOVABLE. It
# requires SystemTap to be installed to act as a trigger. The test is fairly
# simple but must be run as root. The actions of the test are;
# 
# 1. dd a file the size of physical memory from /dev/zero while updatedb runs
# 2. When step 1 completes, run the embedded systemtap script to allocate
#    huge pages from ZONE_MOVABLE
#
# The systemtap script is described more later but basically, it tries to
# allocate hugepages from ZONE_MOVABLE but gives up easily.
#
# If ZONE_MOVABLE and all associated code is working perfectly, this test will
# always successfully allocate all the hugepages from that ZONE with all the
# failures at the end. The expected behaviour for 2.6.23 is that the zone can
# be fully allocated when the system is at rest but will have difficulty
# under load
#
# Copyright (C) IBM Corporation, 2007
# Author: Mel Gorman <mel@csn.ul.ie>

LARGEFILE=$HOME/zonemovable_test_largefile
STAP=/usr/bin/stap

die() {
	echo "FATAL: $@"
	exit 1
}

echo Checking SystemTap exists
if [ ! -x $STAP ]; then
	die SystemTap must be available at $STAP
fi

echo Checking largefile can be created
echo -n > $LARGEFILE || die Failed to create $LARGEFILE

echo Checking parameters
MEMKB=`grep MemTotal: /proc/meminfo | awk '{print $2}'`
if [ "$MEMKB" = "" ]; then
	die Failed to determine total amount of memory
fi
MEMMB=$(($MEMKB/1024))

echo Running dd of ${MEMMB}MB to $LARGEFILE while running updatedb
dd if=/dev/zero of=$LARGEFILE ibs=1048576 count=$MEMMB & updatedb

echo Running allocation test
TIME=`which time`
$TIME time /usr/bin/stap -g - <<EOFSTAP
# alloctrigger.stp
#
# This script is a test for the allocation of hugepages from ZONE_MOVABLE. It
# works by estimating how many hugepages there are contained in ZONE_MOVABLE
# and then creating a zonelists consisting of just ZONE_MOVABLE from each
# active node.
#
# It allows up to ABORT_AFTER_FAILCOUNT before stopping the test to prevent
# hammering allocation attempts. The results of the test is the number of
# hugepages that exist, the number that were successfully allocated and when
# each of the failures occured.
#
# WARNING: As this attempts allocations even after fails, the system may
#	   decide that it is OOM and start killing things. Arguably, the
#	   system should not consider itself OOM for high-order allocation
#	   failures.

function alloc_hugepages:long () %{

#define ABORT_AFTER_FAILCOUNT 4

	struct zonelist zonelist;
	struct page *page;
	struct page **pages;
	int freecount, nid;
	int nr_nodes = 0;
	int count = 0;
	int failcount = 0;
	int fails[ABORT_AFTER_FAILCOUNT];
	int max_hugepages = 0;

	/* Create a zonelist containing only ZONE_MOVABLE */
	_stp_printf("Building zonelist\n");
	for_each_online_node(nid) {
		struct zone *zone = &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
		if (populated_zone(zone)) {
			int hugepages;
			_stp_printf("  o Added ZONE_MOVABLE on node %d\n", nid);
			zonelist.zones[nr_nodes] = zone;
			nr_nodes++;

			/* Sum how many huge pages are possible to allocate */
			hugepages = (zone->present_pages - zone->pages_low);
			hugepages = (hugepages >> HUGETLB_PAGE_ORDER) - 1;
			hugepages--;
			if (hugepages > 0)
				max_hugepages += hugepages;
		}
	}
	zonelist.zones[nr_nodes] = NULL;

	/* Make sure ZONE_MOVABLE exists */
	if (nr_nodes == 0) {
		_stp_printf("No suitable ZONE_MOVABLE was found\n");
		return;
	}

	/* Allocate array for allocated pages pointers */
	pages = vmalloc(max_hugepages * sizeof(struct page *));
	if (!pages) {
		_stp_printf("Failed to allocate %d page pointers\n",
								max_hugepages);
		return;
	}

	/* Allocate pages in the zonelist until we start failing */
	_stp_printf("Attempting to allocate %d pages\n", max_hugepages);
	do {
		page = __alloc_pages(GFP_HIGHUSER_MOVABLE|__GFP_NOWARN,
					HUGETLB_PAGE_ORDER, &zonelist);
		if (page) {
			pages[count++] = page;
		} else {
			fails[failcount] = count;
			failcount++;
			_stp_printf(" o Failure %d after %d allocs\n",
							failcount, count);
			if (failcount >= ABORT_AFTER_FAILCOUNT ||
							count >= max_hugepages)
				break;

			/* Wait a little after failing */
			congestion_wait(WRITE, HZ/2);
		}
	} while (count < max_hugepages);

	/* Free pages */
	_stp_printf("Freeing %d huge pages\n", count);
	for (freecount = 0; freecount < count; freecount++)
		__free_pages(pages[freecount], HUGETLB_PAGE_ORDER);
	vfree(pages);

	_stp_printf("\nResults\n=======\n");
	_stp_printf("Total huge pages:             %d\n", max_hugepages);
	_stp_printf("Successfully allocated:       %d hugepages\n", count);
	for (count = 0; count < failcount; count++)
		_stp_printf("Failed allocation at attempt: %d\n", fails[count]);
	_stp_printf("\n");
%}

probe begin {
	print("\n\n")
	alloc_hugepages()
	print("\n\n")
	exit()
}
EOFSTAP

echo Cleaning up $LARGEFILE
rm $LARGEFILE
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
