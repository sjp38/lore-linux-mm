Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B26796B0310
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 04:58:39 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so5925826pdj.14
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 01:58:39 -0700 (PDT)
Received: from psmtp.com ([74.125.245.146])
        by mx.google.com with SMTP id sw1si8017347pbc.282.2013.10.21.01.58.34
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 01:58:35 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 21 Oct 2013 14:28:31 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id B91A2E0053
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:29:58 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9L91HpD12386326
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:31:17 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9L8wQmU011660
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:28:27 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 2/3] percpu: merge two loops when setting up group info
Date: Mon, 21 Oct 2013 16:58:12 +0800
Message-Id: <1382345893-6644-2-git-send-email-weiyang@linux.vnet.ibm.com>
In-Reply-To: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: weiyang@linux.vnet.ibm.com

There are two loops setting up the group info of pcpu_alloc_info. They share
the same logic, so merge them could be time efficient when there are many
groups.

This patch merge these two loops into one.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 mm/percpu.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 536ca4f..4f710a4f 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1542,11 +1542,6 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 		return ERR_PTR(-ENOMEM);
 	cpu_map = ai->groups[0].cpu_map;
 
-	for (group = 0; group < nr_groups; group++) {
-		ai->groups[group].cpu_map = cpu_map;
-		cpu_map += roundup(group_cnt[group], upa);
-	}
-
 	ai->static_size = static_size;
 	ai->reserved_size = reserved_size;
 	ai->dyn_size = dyn_size;
@@ -1557,6 +1552,8 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 	for (group = 0, unit = 0; group_cnt[group]; group++) {
 		struct pcpu_group_info *gi = &ai->groups[group];
 
+		gi->cpu_map = cpu_map;
+
 		/*
 		 * Initialize base_offset as if all groups are located
 		 * back-to-back.  The caller should update this to
@@ -1568,6 +1565,7 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 			if (group_map[cpu] == group)
 				gi->cpu_map[gi->nr_units++] = cpu;
 		gi->nr_units = roundup(gi->nr_units, upa);
+		cpu_map += gi->nr_units;
 		unit += gi->nr_units;
 	}
 	BUG_ON(unit != nr_units);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
