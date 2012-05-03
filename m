Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 1D0BB6B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 21:31:25 -0400 (EDT)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 2 May 2012 21:31:23 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 5EDA36E804D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 21:31:20 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q431VJQL21889092
	for <linux-mm@kvack.org>; Wed, 2 May 2012 21:31:19 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q431VJER005310
	for <linux-mm@kvack.org>; Wed, 2 May 2012 22:31:19 -0300
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2] MM: check limit while deallocating bootmem node
Date: Thu,  3 May 2012 09:31:14 +0800
Message-Id: <1336008674-10858-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hannes@cmpxchg.org, Gavin Shan <shangw@linux.vnet.ibm.com>

For the particular bootmem node, the minimal and maximal PFN (
Page Frame Number) have been traced in the instance of "struct
bootmem_data_t". On current implementation, the maximal PFN isn't
checked while deallocating a bunch (BITS_PER_LONG) of page frames.
So the current implementation won't work if the maximal PFN isn't
aligned with BITS_PER_LONG.

The patch will check the maximal PFN of the given bootmem node.
Also, we needn't check all the bits map when the starting PFN isn't
BITS_PER_LONG aligned. Actually, we should start from the offset
of the bits map, which indicated by the starting PFN. By the way,
V2 patch removed the duplicate check according to comments from
Johannes Weiner.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/bootmem.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 5a04536..b4f3ba5 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -201,9 +201,11 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 			count += BITS_PER_LONG;
 			start += BITS_PER_LONG;
 		} else {
-			unsigned long off = 0;
+			unsigned long cursor = start;
+			unsigned long off = cursor & (BITS_PER_LONG - 1);
 
-			while (vec && off < BITS_PER_LONG) {
+			vec >>= off;
+			while (vec) {
 				if (vec & 1) {
 					page = pfn_to_page(start + off);
 					__free_pages_bootmem(page, 0);
@@ -211,6 +213,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 				}
 				vec >>= 1;
 				off++;
+				cursor++;
 			}
 			start = ALIGN(start + 1, BITS_PER_LONG);
 		}
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
