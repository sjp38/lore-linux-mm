Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 806266B000E
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:23:30 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x18-v6so4163992oie.7
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:23:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l191-v6si8144586oib.284.2018.07.24.06.23.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 06:23:29 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6ODIl7U008444
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:23:28 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ke3r5uy9a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:23:28 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Jul 2018 14:23:26 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/2] um: setup_physmem: stop using global variables
Date: Tue, 24 Jul 2018 16:23:13 +0300
In-Reply-To: <1532438594-4530-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532438594-4530-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532438594-4530-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>
Cc: Michal Hocko <mhocko@kernel.org>, linux-um@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The setup_physmem() function receives uml_physmem and uml_reserved as
parameters and still used these global variables. Replace such usage with
local variables.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/um/kernel/physmem.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/um/kernel/physmem.c b/arch/um/kernel/physmem.c
index f02596e..0eaec0e 100644
--- a/arch/um/kernel/physmem.c
+++ b/arch/um/kernel/physmem.c
@@ -86,7 +86,7 @@ void __init setup_physmem(unsigned long start, unsigned long reserve_end,
 	long map_size;
 	int err;
 
-	offset = uml_reserved - uml_physmem;
+	offset = reserve_end - start;
 	map_size = len - offset;
 	if(map_size <= 0) {
 		os_warn("Too few physical memory! Needed=%lu, given=%lu\n",
@@ -96,12 +96,12 @@ void __init setup_physmem(unsigned long start, unsigned long reserve_end,
 
 	physmem_fd = create_mem_file(len + highmem);
 
-	err = os_map_memory((void *) uml_reserved, physmem_fd, offset,
+	err = os_map_memory((void *) reserve_end, physmem_fd, offset,
 			    map_size, 1, 1, 1);
 	if (err < 0) {
 		os_warn("setup_physmem - mapping %ld bytes of memory at 0x%p "
 			"failed - errno = %d\n", map_size,
-			(void *) uml_reserved, err);
+			(void *) reserve_end, err);
 		exit(1);
 	}
 
-- 
2.7.4
