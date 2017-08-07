Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 206616B037C
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 16:39:51 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id l82so21854069ywc.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 13:39:51 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f126si2449892ybg.829.2017.08.07.13.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 13:39:50 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v6 15/15] mm: debug for raw alloctor
Date: Mon,  7 Aug 2017 16:38:49 -0400
Message-Id: <1502138329-123460-16-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

When CONFIG_DEBUG_VM is enabled, this patch sets all the memory that is
returned by memblock_virt_alloc_try_nid_raw() to ones to ensure that no
places excpect zeroed memory.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 mm/memblock.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 3fbf3bcb52d9..29fcb1dd8a81 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1363,12 +1363,19 @@ void * __init memblock_virt_alloc_try_nid_raw(
 			phys_addr_t min_addr, phys_addr_t max_addr,
 			int nid)
 {
+	void *ptr;
+
 	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
 
-	return memblock_virt_alloc_internal(size, align,
-					    min_addr, max_addr, nid);
+	ptr = memblock_virt_alloc_internal(size, align,
+					   min_addr, max_addr, nid);
+#ifdef CONFIG_DEBUG_VM
+	if (ptr && size > 0)
+		memset(ptr, 0xff, size);
+#endif
+	return ptr;
 }
 
 /**
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
