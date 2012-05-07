Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id B7B0B6B00EB
	for <linux-mm@kvack.org>; Mon,  7 May 2012 07:38:13 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 02/10] mm: bootmem: remove redundant offset check when finally freeing bootmem
Date: Mon,  7 May 2012 13:37:44 +0200
Message-Id: <1336390672-14421-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When bootmem releases an unaligned BITS_PER_LONG pages chunk of memory
to the page allocator, it checks the bitmap if there are still
unreserved pages in the chunk (set bits), but also if the offset in
the chunk indicates BITS_PER_LONG loop iterations already.

But since the consulted bitmap is only a one-word-excerpt of the full
per-node bitmap, there can not be more than BITS_PER_LONG bits set in
it.  The additional offset check is unnecessary.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/bootmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 67872fc..053ac3f 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -204,7 +204,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 			unsigned long off = 0;
 
 			vec >>= start & (BITS_PER_LONG - 1);
-			while (vec && off < BITS_PER_LONG) {
+			while (vec) {
 				if (vec & 1) {
 					page = pfn_to_page(start + off);
 					__free_pages_bootmem(page, 0);
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
