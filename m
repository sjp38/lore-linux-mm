Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id ECAA14405A3
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 07:07:40 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 203so66976353ith.3
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 04:07:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v14si61275ioi.10.2017.02.15.04.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 04:07:40 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1FC4JaW025362
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 07:07:39 -0500
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28mjx7h0uv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 07:07:39 -0500
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 15 Feb 2017 17:37:36 +0530
Received: from d28relay08.in.ibm.com (d28relay08.in.ibm.com [9.184.220.159])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 8C85AE0064
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:39:06 +0530 (IST)
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay08.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1FC6WW615859818
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:36:32 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1FC7WMh012591
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:37:33 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V3 0/4] Define coherent device memory node
Date: Wed, 15 Feb 2017 17:37:22 +0530
Message-Id: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

	This four patches define CDM node with HugeTLB & Buddy allocation
isolation. Please refer to the last RFC posting mentioned here for more
details. The RFC series has been split for easier review process. The next
part of the work like VM flags, auto NUMA and KSM interactions with tagged
VMAs will follow later.

RFC https://lkml.org/lkml/2017/1/29/198

Changes in V3:

* Changed is_coherent_node interface into is_cdm_node
* Fixed the CDM allocation leak problem when cpuset is enabled on the system
  which requires changes to get_page_from_freelist function and verifying
  that the non NULL nodemask is indeed the requested one not becuase of the
  cpuset override on the way

Changes in V2:	(https://lkml.org/lkml/2017/2/10/183)

* Removed redundant nodemask_has_cdm() check from zonelist iterator
* Dropped the nodemask_had_cdm() function itself
* Added node_set/clear_state_cdm() functions and removed bunch of #ifdefs
* Moved CDM helper functions into nodemask.h from node.h header file
* Fixed the build failure by additional CONFIG_NEED_MULTIPLE_NODES check

Previous V1:	(https://lkml.org/lkml/2017/2/8/329)

Anshuman Khandual (4):
  mm: Define coherent device memory (CDM) node
  mm: Enable HugeTLB allocation isolation for CDM nodes
  mm: Add new parameter to get_page_from_freelist() function
  mm: Enable Buddy allocation isolation for CDM nodes

 Documentation/ABI/stable/sysfs-devices-node |  7 +++
 arch/powerpc/Kconfig                        |  1 +
 arch/powerpc/mm/numa.c                      |  7 +++
 drivers/base/node.c                         |  6 +++
 include/linux/nodemask.h                    | 58 ++++++++++++++++++++-
 mm/Kconfig                                  |  4 ++
 mm/hugetlb.c                                | 25 +++++----
 mm/memory_hotplug.c                         |  3 ++
 mm/page_alloc.c                             | 81 +++++++++++++++++++++--------
 9 files changed, 160 insertions(+), 32 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
