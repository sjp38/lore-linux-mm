Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 25C446B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:22:13 -0500 (EST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 20 Feb 2012 11:15:50 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KBGfQY3477536
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:16:41 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KBLv9k019548
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:21:58 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 0/9] hugetlbfs: Add cgroup resource controller for hugetlbfs
Date: Mon, 20 Feb 2012 16:51:33 +0530
Message-Id: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@kernel.org

Hi,

This patchset implements a cgroup resource controller for HugeTLB pages.
It is similar to the existing hugetlb quota support in that the limit is
enforced at mmap(2) time and not at fault time. HugeTLB quota limit the
number of huge pages that can allocated per superblock.

For shared mapping we track the region mapped by a task along with the
hugetlb cgroup. We keep the hugetlb cgroup charged even after the task
that did mmap(2) exit. The uncharge happens during truncate. For Private
mapping we charge and uncharge from the current task cgroup.

A sample strace output for an application doing malloc with hugectl is given
below. libhugetlbfs will fallback to normal pagesize if the HugeTLB mmap fails.

open("/mnt/libhugetlbfs.tmp.uhLMgy", O_RDWR|O_CREAT|O_EXCL, 0600) = 3
unlink("/mnt/libhugetlbfs.tmp.uhLMgy")  = 0

.........

mmap(0x20000000000, 50331648, PROT_READ|PROT_WRITE, MAP_PRIVATE, 3, 0) = -1 ENOMEM (Cannot allocate memory)
write(2, "libhugetlbfs", 12libhugetlbfs)            = 12
write(2, ": WARNING: New heap segment map" ....
mmap(NULL, 42008576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xfff946c0000
....


Changes from RFC post:
* Added support for HugeTLB cgroup hierarchy
* Added support for task migration
* Added documentation patch
* Other Bug fixes

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
