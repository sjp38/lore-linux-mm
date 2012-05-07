Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id D9AB46B0083
	for <linux-mm@kvack.org>; Mon,  7 May 2012 07:38:10 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 01/10] mm: bootmem: fix checking the bitmap when finally freeing bootmem
Date: Mon,  7 May 2012 13:37:43 +0200
Message-Id: <1336390672-14421-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Gavin Shan <shangw@linux.vnet.ibm.com>

When bootmem releases an unaligned chunk of memory at the beginning of
a node to the page allocator, it iterates from that unaligned PFN but
checks an aligned word of the page bitmap.  The checked bits do not
correspond to the PFNs and, as a result, reserved pages can be freed.

Properly shift the bitmap word so that the lowest bit corresponds to
the starting PFN before entering the freeing loop.

This bug has been around since 41546c1 "bootmem: clean up
free_all_bootmem_core" (2.6.27) without known reports.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/bootmem.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 0131170..67872fc 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -203,6 +203,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 		} else {
 			unsigned long off = 0;
 
+			vec >>= start & (BITS_PER_LONG - 1);
 			while (vec && off < BITS_PER_LONG) {
 				if (vec & 1) {
 					page = pfn_to_page(start + off);
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
