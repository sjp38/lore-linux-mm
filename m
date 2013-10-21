Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 004116B030E
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 04:58:25 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so7740800pad.33
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 01:58:25 -0700 (PDT)
Received: from psmtp.com ([74.125.245.158])
        by mx.google.com with SMTP id gl1si8622039pac.111.2013.10.21.01.58.23
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 01:58:25 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 21 Oct 2013 14:28:20 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 09319125803F
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:28:50 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9L915TI44695696
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:31:06 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9L8wG63023958
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:28:16 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 1/3] percpu: stop the loop when a cpu belongs to a new group
Date: Mon, 21 Oct 2013 16:58:11 +0800
Message-Id: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: weiyang@linux.vnet.ibm.com

When a cpu belongs to a new group, there is no cpu has the same group id. This
means it can be assigned a new group id without checking with every others.

This patch does this optimiztion.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 mm/percpu.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 8c8e08f..536ca4f 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1488,7 +1488,10 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 			    (cpu_distance_fn(cpu, tcpu) > LOCAL_DISTANCE ||
 			     cpu_distance_fn(tcpu, cpu) > LOCAL_DISTANCE)) {
 				group++;
-				nr_groups = max(nr_groups, group + 1);
+				if (group == nr_groups) {
+					nr_groups++;
+					break;
+				}
 				goto next_group;
 			}
 		}
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
