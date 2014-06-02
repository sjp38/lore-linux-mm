Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B56DF6B009A
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 19:27:47 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id fp1so3926148pdb.3
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 16:27:47 -0700 (PDT)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id mn6si17653901pbc.17.2014.06.02.16.27.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 16:27:46 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so4665819pbc.26
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 16:27:46 -0700 (PDT)
Date: Mon, 2 Jun 2014 16:26:13 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swap: Delete  the "last_in_cluster < scan_base" loop in
 the body of scan_swap_map()
In-Reply-To: <1401710053-8460-1-git-send-email-slaoub@gmail.com>
Message-ID: <alpine.LSU.2.11.1406021603330.2584@eggly.anvils>
References: <1401710053-8460-1-git-send-email-slaoub@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: shli@kernel.org, hughd@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2 Jun 2014, Chen Yucong wrote:

> From commit ebc2a1a69111, we can find that all SWP_SOLIDSTATE "seek is cheap"(SSD case) 
> has already gone to si->cluster_info scan_swap_map_try_ssd_cluster() route. So that the
> "last_in_cluster < scan_base" loop in the body of scan_swap_map() has already become a 
> dead code snippet, and it should have been deleted.
> 
> This patch is to delete the redundant loop as Hugh and Shaohua suggested.
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>

That is very nice, thank you.

Acked-by: Hugh Dickins <hughd@google.com>

But it does beg for just a little more: perhaps Andrew can kindly fold in:
---

 mm/swapfile.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

--- chen/mm/swapfile.c	2014-06-02 15:55:44.812368186 -0700
+++ hugh/mm/swapfile.c	2014-06-02 16:15:20.344396124 -0700
@@ -505,13 +505,10 @@ static unsigned long scan_swap_map(struc
 		/*
 		 * If seek is expensive, start searching for new cluster from
 		 * start of partition, to minimize the span of allocated swap.
-		 * But if seek is cheap, search from our current position, so
-		 * that swap is allocated from all over the partition: if the
-		 * Flash Translation Layer only remaps within limited zones,
-		 * we don't want to wear out the first zone too quickly.
+		 * If seek is cheap, that is the SWP_SOLIDSTATE si->cluster_info
+		 * case, just handled by scan_swap_map_try_ssd_cluster() above.
 		 */
-		if (!(si->flags & SWP_SOLIDSTATE))
-			scan_base = offset = si->lowest_bit;
+		scan_base = offset = si->lowest_bit;
 		last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
 
 		/* Locate the first empty (unaligned) cluster */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
