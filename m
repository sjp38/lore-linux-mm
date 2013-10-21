Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 075876B0312
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 04:58:46 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so5966814pdj.28
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 01:58:46 -0700 (PDT)
Received: from psmtp.com ([74.125.245.105])
        by mx.google.com with SMTP id ud7si8638044pac.4.2013.10.21.01.58.42
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 01:58:46 -0700 (PDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 21 Oct 2013 18:58:33 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 6E46F2CE8051
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 19:58:30 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9L8wIa258327174
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 19:58:18 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9L8wTHR019730
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 19:58:29 +1100
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 3/3] percpu: little optimization on calculating pcpu_unit_size
Date: Mon, 21 Oct 2013 16:58:13 +0800
Message-Id: <1382345893-6644-3-git-send-email-weiyang@linux.vnet.ibm.com>
In-Reply-To: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: weiyang@linux.vnet.ibm.com

pcpu_unit_size exactly equals to ai->unit_size.

This patch assign this value instead of calculating from pcpu_unit_pages. Also
it reorder them to make it looks more friendly to audience.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 mm/percpu.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 4f710a4f..74677e0 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1300,8 +1300,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	pcpu_unit_offsets = unit_off;
 
 	/* determine basic parameters */
-	pcpu_unit_pages = ai->unit_size >> PAGE_SHIFT;
-	pcpu_unit_size = pcpu_unit_pages << PAGE_SHIFT;
+	pcpu_unit_size = ai->unit_size;
+	pcpu_unit_pages = pcpu_unit_size >> PAGE_SHIFT;
 	pcpu_atom_size = ai->atom_size;
 	pcpu_chunk_struct_size = sizeof(struct pcpu_chunk) +
 		BITS_TO_LONGS(pcpu_unit_pages) * sizeof(unsigned long);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
