Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E0DAB6B000A
	for <linux-mm@kvack.org>; Sun,  7 Oct 2018 04:32:07 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id c21-v6so13076989otf.9
        for <linux-mm@kvack.org>; Sun, 07 Oct 2018 01:32:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o8-v6si6369027oia.264.2018.10.07.01.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Oct 2018 01:32:06 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w978Uvjb139537
	for <linux-mm@kvack.org>; Sun, 7 Oct 2018 04:32:06 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2myepvg0xf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 07 Oct 2018 04:32:05 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 7 Oct 2018 09:32:03 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] percpu: stop leaking bitmap metadata blocks
Date: Sun,  7 Oct 2018 11:31:51 +0300
Message-Id: <1538901111-22823-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennis@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, stable@vger.kernel.org

The commit ca460b3c9627 ("percpu: introduce bitmap metadata blocks")
introduced bitmap metadata blocks. These metadata blocks are allocated
whenever a new chunk is created, but they are never freed. Fix it.

Fixes: ca460b3c9627 ("percpu: introduce bitmap metadata blocks")

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: stable@vger.kernel.org
---
 mm/percpu.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/percpu.c b/mm/percpu.c
index d21cb13..25104cd 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1212,6 +1212,7 @@ static void pcpu_free_chunk(struct pcpu_chunk *chunk)
 {
 	if (!chunk)
 		return;
+	pcpu_mem_free(chunk->md_blocks);
 	pcpu_mem_free(chunk->bound_map);
 	pcpu_mem_free(chunk->alloc_map);
 	pcpu_mem_free(chunk);
-- 
2.7.4
