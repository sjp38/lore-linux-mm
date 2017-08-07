Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7D46B02F4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 16:39:50 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id u200so5410915vkd.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 13:39:50 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 123si3809745vkf.397.2017.08.07.13.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 13:39:49 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v6 14/15] mm: optimize early system hash allocations
Date: Mon,  7 Aug 2017 16:38:48 -0400
Message-Id: <1502138329-123460-15-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

Clients can call alloc_large_system_hash() with flag: HASH_ZERO to specify
that memory that was allocated for system hash needs to be zeroed,
otherwise the memory does not need to be zeroed, and client will initialize
it.

If memory does not need to be zero'd, call the new
memblock_virt_alloc_raw() interface, and thus improve the boot performance.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 mm/page_alloc.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4d32c1fa4c6c..000806298dfb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7354,18 +7354,17 @@ void *__init alloc_large_system_hash(const char *tablename,
 
 	log2qty = ilog2(numentries);
 
-	/*
-	 * memblock allocator returns zeroed memory already, so HASH_ZERO is
-	 * currently not used when HASH_EARLY is specified.
-	 */
 	gfp_flags = (flags & HASH_ZERO) ? GFP_ATOMIC | __GFP_ZERO : GFP_ATOMIC;
 	do {
 		size = bucketsize << log2qty;
-		if (flags & HASH_EARLY)
-			table = memblock_virt_alloc_nopanic(size, 0);
-		else if (hashdist)
+		if (flags & HASH_EARLY) {
+			if (flags & HASH_ZERO)
+				table = memblock_virt_alloc_nopanic(size, 0);
+			else
+				table = memblock_virt_alloc_raw(size, 0);
+		} else if (hashdist) {
 			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
-		else {
+		} else {
 			/*
 			 * If bucketsize is not a power-of-two, we may free
 			 * some pages at the end of hash table which
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
