Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7DAD36B00D1
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 14:09:13 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q58so619346wes.26
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 11:09:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id db6si12449471wib.25.2014.04.02.11.09.11
        for <linux-mm@kvack.org>;
        Wed, 02 Apr 2014 11:09:11 -0700 (PDT)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 0/4] hugetlb: add support gigantic page allocation at runtime
Date: Wed,  2 Apr 2014 14:08:44 -0400
Message-Id: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

The HugeTLB subsystem uses the buddy allocator to allocate hugepages during
runtime. This means that hugepages allocation during runtime is limited to
MAX_ORDER order. For archs supporting gigantic pages (that is, page sizes
greater than MAX_ORDER), this in turn means that those pages can't be
allocated at runtime.

HugeTLB supports gigantic page allocation during boottime, via the boot
allocator. To this end the kernel provides the command-line options
hugepagesz= and hugepages=, which can be used to instruct the kernel to
allocate N gigantic pages during boot.

For example, x86_64 supports 2M and 1G hugepages, but only 2M hugepages can
be allocated and freed at runtime. If one wants to allocate 1G gigantic pages,
this has to be done at boot via the hugepagesz= and hugepages= command-line
options.

Now, gigantic page allocation at boottime has two serious problems:

 1. Boottime allocation is not NUMA aware. On a NUMA machine the kernel
    evenly distributes boottime allocated hugepages among nodes.

    For example, suppose you have a four-node NUMA machine and want
    to allocate four 1G gigantic pages at boottime. The kernel will
    allocate one gigantic page per node.

    On the other hand, we do have users who want to be able to specify
    which NUMA node gigantic pages should allocated from. So that they
    can place virtual machines on a specific NUMA node.

 2. Gigantic pages allocated at boottime can't be freed

At this point it's important to observe that regular hugepages allocated
at runtime don't have those problems. This is so because HugeTLB interface
for runtime allocation in sysfs supports NUMA and runtime allocated pages
can be freed just fine via the buddy allocator.

This series adds support for allocating gigantic pages at runtime. It does
so by allocating gigantic pages via CMA instead of the buddy allocator.
Releasing gigantic pages is also supported via CMA. As this series builds
on top of the existing HugeTLB interface, it makes gigantic page allocation
and releasing just like regular sized hugepages. This also means that NUMA
support just works.

For example, to allocate two 1G gigantic pages on node 1, one can do:

 # echo 2 > \
   /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages

And, to release all gigantic pages on the same node:

 # echo 0 > \
   /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages

Please, refer to patch 4/4 for full technical details.

Finally, please note that this series is a follow up for a previous series
that tried to extend the command-line options set to be NUMA aware:

 http://marc.info/?l=linux-mm&m=139593335312191&w=2

During the discussion of that series it was agreed that having runtime
allocation support for gigantic pages was a better solution.

Luiz Capitulino (4):
  hugetlb: add hstate_is_gigantic()
  hugetlb: update_and_free_page(): don't clear PG_reserved bit
  hugetlb: move helpers up in the file
  hugetlb: add support for gigantic page allocation at runtime

 arch/x86/include/asm/hugetlb.h |  10 ++
 include/linux/hugetlb.h        |   5 +
 mm/hugetlb.c                   | 344 ++++++++++++++++++++++++++++++-----------
 3 files changed, 265 insertions(+), 94 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
