Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8BC6B026A
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 17:12:20 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id h4so5506507vkg.6
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 14:12:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m14si5194081uab.415.2017.10.05.14.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 14:12:19 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v10 08/10] arm64/kasan: use kasan_map_populate()
Date: Thu,  5 Oct 2017 17:11:22 -0400
Message-Id: <20171005211124.26524-9-pasha.tatashin@oracle.com>
In-Reply-To: <20171005211124.26524-1-pasha.tatashin@oracle.com>
References: <20171005211124.26524-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

To optimize the performance of struct page initialization,
vmemmap_populate() will no longer zero memory.

Therefore, we must use a new interface to allocate and map kasan shadow
memory, that also zeroes memory for us.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 arch/arm64/mm/kasan_init.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 81f03959a4ab..b6e92cfa3ea3 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -161,11 +161,11 @@ void __init kasan_init(void)
 
 	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
 
-	vmemmap_populate(kimg_shadow_start, kimg_shadow_end,
-			 pfn_to_nid(virt_to_pfn(lm_alias(_text))));
+	kasan_map_populate(kimg_shadow_start, kimg_shadow_end,
+			   pfn_to_nid(virt_to_pfn(lm_alias(_text))));
 
 	/*
-	 * vmemmap_populate() has populated the shadow region that covers the
+	 * kasan_map_populate() has populated the shadow region that covers the
 	 * kernel image with SWAPPER_BLOCK_SIZE mappings, so we have to round
 	 * the start and end addresses to SWAPPER_BLOCK_SIZE as well, to prevent
 	 * kasan_populate_zero_shadow() from replacing the page table entries
@@ -191,9 +191,9 @@ void __init kasan_init(void)
 		if (start >= end)
 			break;
 
-		vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
-				(unsigned long)kasan_mem_to_shadow(end),
-				pfn_to_nid(virt_to_pfn(start)));
+		kasan_map_populate((unsigned long)kasan_mem_to_shadow(start),
+				   (unsigned long)kasan_mem_to_shadow(end),
+				   pfn_to_nid(virt_to_pfn(start)));
 	}
 
 	/*
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
