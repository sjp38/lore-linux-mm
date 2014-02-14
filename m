Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id DA6EE6B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 20:07:46 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hn9so9446945wib.6
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:07:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 8si7503267eep.18.2014.02.13.17.07.44
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 17:07:45 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH v2 0/4] hugetlb: add hugepages_node= command-line option
Date: Thu, 13 Feb 2014 20:02:04 -0500
Message-Id: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, rientjes@google.com

On a NUMA system, HugeTLB provides support for allocating per-node huge pages
through sysfs. For example, to allocate 300 2M huge pages on node1, one can do:

  echo 300 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages

This works as long as you have enough contiguous pages. Which may work for
2M pages, but for 1G huge pages this is likely to fail due to fragmentation
or won't even work actually, as allocating more than MAX_ORDER pages at runtime
doesn't seem to work out of the box for some archs. For 1G huge pages it's
better or even required to reserve them during the kernel boot, which is when
the allocation is more likely to succeed.

To this end we have the hugepages= command-line option, which works but misses
the per node allocation support. This option evenly distributes huge pages
among nodes on a NUMA system. This behavior is very limiting and unflexible.
There are use-cases where users wants to be able to specify which nodes 1G
huge pages should be allocated from.

This series addresses this problem by adding a new kernel comand-line option
called hugepages_node=, which users can use to configure initial huge page
allocation on NUMA. The new option syntax is:

 hugepages_node=nid:nr_pages:size,...

For example, this command-line:

 hugepages_node=0:300:2M,1:4:1G

Allocates 300 2M huge pages from node0 and 4 1G huge pages from node1.

hugepages_node= is non-intrusive (it doesn't touch any core HugeTLB code).
Indeed, all functions and the array added by this series are run only once
and discarded after boot. All the hugepages_node= option does it to set
initial huge page allocation among NUMA nodes.

Changelog:

o v2

 - Change syntax to hugepages_node=nid:nr_pages:size,... [Andi Kleen]
 - Several small improvements [Andrew Morton]
 - Validate node index [Yasuaki Ishimatsu]
 - Use GFP_THISNODE [Mel Gorman]
 - Fold 2MB support patch with 1GB support patch
 - Improve logs and intro email

Luiz capitulino (4):
  memblock: memblock_virt_alloc_internal(): add __GFP_THISNODE flag
    support
  memblock: add memblock_virt_alloc_nid_nopanic()
  hugetlb: add parse_pagesize_str()
  hugetlb: add hugepages_node= command-line option

 Documentation/kernel-parameters.txt |   8 +++
 arch/x86/mm/hugetlbpage.c           |  77 ++++++++++++++++++++++++--
 include/linux/bootmem.h             |   4 ++
 include/linux/hugetlb.h             |   2 +
 mm/hugetlb.c                        | 106 ++++++++++++++++++++++++++++++++++++
 mm/memblock.c                       |  44 ++++++++++++++-
 6 files changed, 232 insertions(+), 9 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
