Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B56606B026C
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 194so440711086pgd.7
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:37:55 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l1si11392964pfb.107.2017.01.29.19.37.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:37:54 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YKlP130302
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:54 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 289ejuxj2j-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:54 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:37:51 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E4EA53578057
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:49 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3bfTN34603040
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:49 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3bHf5020279
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:17 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 05/12] cpuset: Add cpuset_inc() inside cpuset_init()
Date: Mon, 30 Jan 2017 09:05:46 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-6-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

Currently cpusets_enabled() wrongfully returns 0 even if we have a root
cpuset configured on the system. This got missed when jump level was
introduced in place of number_of_cpusets with the commit 664eeddeef65
("mm: page_alloc: use jump labels to avoid checking number_of_cpusets")
. This fixes the problem so that cpusets_enabled() returns positive even
for the root cpuset.

Fixes: 664eeddeef65 ("mm: page_alloc: use jump labels to avoid")
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 kernel/cpuset.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index b308888..be75f3f 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2133,6 +2133,8 @@ int __init cpuset_init(void)
 	set_bit(CS_SCHED_LOAD_BALANCE, &top_cpuset.flags);
 	top_cpuset.relax_domain_level = -1;
 
+	cpuset_inc();
+
 	err = register_filesystem(&cpuset_fs_type);
 	if (err < 0)
 		return err;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
