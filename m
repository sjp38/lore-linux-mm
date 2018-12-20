Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3538E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:21:56 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w18so2916997qts.8
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:21:56 -0800 (PST)
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id a6si2715313qtj.202.2018.12.20.11.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:21:55 -0800 (PST)
Message-ID: <01000167cd1130c8-c9bebcb9-1f95-4f7c-b24a-90600d56c62f-000000@email.amazonses.com>
Date: Thu, 20 Dec 2018 19:21:55 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 0/7] Slab object migration for xarray V2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>

V1->V2:
	- Works now on top of 4.20-rc7
	- A couple of bug fixes


This is a patchset on top of Matthew Wilcox Xarray code and implements
slab object migration for xarray nodes. The migration is integrated into
the defragmetation and shrinking logic of the slab allocator.

Defragmentation will ensure that all xarray slab pages have
less objects available than specified by the slab defrag ratio.

Slab shrinking will create a slab cache with optimal object
density. Only one slab page will have available objects per node.

To test apply this patchset and run a workload that uses lots of radix tree objects


Then go to

/sys/kernel/slab/radix_tree_node

Inspect the number of total objects that the slab can handle

	cat total_objects

qmdr:/sys/kernel/slab/radix_tree_node# cat objects
868 N0=448 N1=168 N2=56 N3=196

And the number of slab pages used for those

	cat slabs

qmdr:/sys/kernel/slab/radix_tree_node# cat slabs
31 N0=16 N1=6 N2=2 N3=7


Perform a cache shrink operation

	echo 1 >shrink


Now see how the slab has changed:

qmdr:/sys/kernel/slab/radix_tree_node# cat slabs
30 N0=15 N1=6 N2=2 N3=7
qmdr:/sys/kernel/slab/radix_tree_node# cat objects
713 N0=349 N1=141 N2=52 N3=171


This is just a barebones approach using a special mode
of the slab migration patchset that does not require refcounts.



If this is acceptable then additional functionality can be added:

1. Migration of objects to a specific node. Not sure how to implement
   that. Using another sysfs field?

2. Dispersion of objects across all nodes (MPOL_INTERLEAVE)

3. Subsystems can request to move an object to a specific node.
   How to design such functionality best?

4. Tying into the page migration and page defragmentation logic so
   that so far unmovable pages that are in the way of creating a
   contiguous block of memory will become movable.
   This would mean checking for slab pages in the migration logic
   and calling slab to see if it can move the page by migrating
   all objects.

This is only possible for xarray for now but it would be worthwhile
to extend this to dentries and inodes.
