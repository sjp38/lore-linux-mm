Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5926B025F
	for <linux-mm@kvack.org>; Thu,  5 May 2016 03:54:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 77so154476677pfz.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 00:54:34 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id f63si9601304pfj.137.2016.05.05.00.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 00:54:33 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id zy2so8591557pac.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 00:54:33 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH v2 2/2] powerpc/mm: Ensure "special" zones are empty
Date: Thu,  5 May 2016 17:54:09 +1000
Message-Id: <1462434849-14935-2-git-send-email-oohall@gmail.com>
In-Reply-To: <1462434849-14935-1-git-send-email-oohall@gmail.com>
References: <1462434849-14935-1-git-send-email-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Oliver O'Halloran <oohall@gmail.com>, linux-mm@kvack.org

The mm zone mechanism was traditionally used by arch specific code to
partition memory into allocation zones. However there are several zones
that are managed by the mm subsystem rather than the architecture. Most
architectures set the max PFN of these special zones to zero, however on
powerpc we set them to ~0ul. This, in conjunction with a bug in
free_area_init_nodes() results in all of system memory being placed in
ZONE_DEVICE when enabled. Device memory cannot be used for regular kernel
memory allocations so this will cause a kernel panic at boot.

Given the planned addition of more mm managed zones (ZONE_CMA) we should
aim to be consistent with every other architecture and set the max PFN for
these zones to zero.

Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
Cc: linux-mm@kvack.org
---
 arch/powerpc/mm/mem.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 8f4c19789a38..f0a058ebb6d7 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -239,8 +239,14 @@ static int __init mark_nonram_nosave(void)
 
 static bool zone_limits_final;
 
+/*
+ * The memory zones past TOP_ZONE are managed by generic mm code.
+ * These should be set to zero since that's what every other
+ * architecture does.
+ */
 static unsigned long max_zone_pfns[MAX_NR_ZONES] = {
-	[0 ... MAX_NR_ZONES - 1] = ~0UL
+	[0        ... TOP_ZONE     - 1] = ~0UL,
+	[TOP_ZONE ... MAX_NR_ZONES - 1] = 0
 };
 
 /*
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
