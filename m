Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 83EA56B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 14:51:26 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 7 Apr 2012 00:21:23 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q36IpK5c4399332
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 00:21:20 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q370Lm2k006500
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 10:21:48 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 00/14] memcg: Add memcg extension to control HugeTLB allocation
Date: Sat,  7 Apr 2012 00:20:46 +0530
Message-Id: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Hi,

This patchset implements a memory controller extension to control
HugeTLB allocations. The extension allows to limit the HugeTLB
usage per control group and enforces the controller limit during
page fault. Since HugeTLB doesn't support page reclaim, enforcing
the limit at page fault time implies that, the application will get
SIGBUS signal if it tries to access HugeTLB pages beyond its limit.
This requires the application to know beforehand how much HugeTLB
pages it would require for its use.

The goal is to control how many HugeTLB pages a group of task can
allocate. It can be looked at as an extension of the existing quota
interface which limits the number of HugeTLB pages per hugetlbfs
superblock. HPC job scheduler requires jobs to specify their resource
requirements in the job file. Once their requirements can be met,
job schedulers like (SLURM) will schedule the job. We need to make sure
that the jobs won't consume more resources than requested. If they do
we should either error out or kill the application.

Patches are on top of
git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.5

Changes from V4:
 * Add support for charge/uncharge during page migration
 * Drop the usage of page->lru in unmap_hugepage_range.

Changes from v3:
 * Address review feedback.
 * Fix a bug in cgroup removal related parent charging with use_hierarchy set

Changes from V2:
* Changed the implementation to limit the HugeTLB usage during page
  fault time. This simplifies the extension and keep it closer to
  memcg design. This also allows to support cgroup removal with less
  complexity. Only caveat is the application should ensure its HugeTLB
  usage doesn't cross the cgroup limit.

Changes from V1:
* Changed the implementation as a memcg extension. We still use
  the same logic to track the cgroup and range.

Changes from RFC post:
* Added support for HugeTLB cgroup hierarchy
* Added support for task migration
* Added documentation patch
* Other bug fixes

-aneesh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
