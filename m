Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id A562D6B005C
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 20:37:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Apr 2013 10:29:26 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id E5E3C2BB0052
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 10:36:40 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3H0N41q11338048
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 10:23:05 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3H0achS000540
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 10:36:39 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 0/6] mm/hugetlb: gigantic hugetlb page pools shrink supporting
Date: Wed, 17 Apr 2013 08:36:28 +0800
Message-Id: <1366158995-3116-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 * add comments from Andi which indicate shrink gigantic hugetlb page pools make 
   sense to patchset description.

order >= MAX_ORDER pages are only allocated at boot stage using the 
bootmem allocator with the "hugepages=xxx" option. These pages are never 
free after boot by default since it would be a one-way street(>= MAX_ORDER
pages cannot be allocated later), but if administrator confirm not to 
use these gigantic pages any more, these pinned pages will waste memory
since other users can't grab free pages from gigantic hugetlb pool even
if OOM, it's not flexible.  The patchset add hugetlb gigantic page pools
shrink supporting. Administrator can enable knob exported in sysctl to
permit to shrink gigantic hugetlb pool.

http://marc.info/?l=linux-mm&m=136578016214512&w=2 
Andi thinks this idea make sense since he is working on a new patchkit to 
allocate GB pages from CMA. With that freeing actually makes sense, as the 
pages can be reallocated.

Testcase:
boot: hugepagesz=1G hugepages=10

[root@localhost hugepages]# free -m
             total       used       free     shared    buffers     cached
Mem:         36269      10836      25432          0         11        288
-/+ buffers/cache:      10537      25732
Swap:        35999          0      35999
[root@localhost hugepages]# echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
-bash: echo: write error: Invalid argument
[root@localhost hugepages]# echo 1 > /proc/sys/vm/hugetlb_shrink_gigantic_pool
[root@localhost hugepages]# echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
[root@localhost hugepages]# free -m
             total       used       free     shared    buffers     cached
Mem:         36269        597      35672          0         11        288
-/+ buffers/cache:        297      35972
Swap:        35999          0      35999

Wanpeng Li (6):
  introduce new sysctl knob which control gigantic page pools shrinking
  update_and_free_page gigantic pages awareness
  enable gigantic hugetlb page pools shrinking
  use already exist huge_page_order() instead of h->order
  remove redundant hugetlb_prefault 
  use already exist interface huge_page_shift

 Documentation/sysctl/vm.txt |   13 +++++++
 include/linux/hugetlb.h     |    5 +--
 kernel/sysctl.c             |    7 ++++
 mm/hugetlb.c                |   83 +++++++++++++++++++++++++++++--------------
 mm/internal.h               |    1 +
 mm/page_alloc.c             |    2 +-
 6 files changed, 82 insertions(+), 29 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
