Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5545A6B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 11:57:18 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so27712151wjb.7
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 08:57:18 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.133])
        by mx.google.com with ESMTPS id r126si14946974wmb.109.2017.01.23.08.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 08:57:17 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: fix maybe-uninitialized warning in section_deactivate()
Date: Mon, 23 Jan 2017 17:51:17 +0100
Message-Id: <20170123165156.854464-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Fabian Frederick <fabf@skynet.be>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

gcc cannot track the combined state of the 'mask' variable across the
barrier in pgdat_resize_unlock() at compile time, so it warns that we
can run into undefined behavior:

mm/sparse.c: In function 'section_deactivate':
mm/sparse.c:802:7: error: 'early_section' may be used uninitialized in this function [-Werror=maybe-uninitialized]

We know that this can't happen because the spin_unlock() doesn't
affect the mask variable, so this is a false-postive warning, but
rearranging the code to bail out earlier here makes it obvious
to the compiler as well.

Fixes: mmotm ("mm: support section-unaligned ZONE_DEVICE memory ranges")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/sparse.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 4267d09b656b..dd0c2dd08ee2 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -807,23 +807,24 @@ static void section_deactivate(struct pglist_data *pgdat, unsigned long pfn,
 	unsigned long mask = section_active_mask(pfn, nr_pages), flags;
 
 	pgdat_resize_lock(pgdat, &flags);
-	if (!ms->usage) {
-		mask = 0;
-	} else if ((ms->usage->map_active & mask) != mask) {
-		WARN(1, "section already deactivated active: %#lx mask: %#lx\n",
-				ms->usage->map_active, mask);
-		mask = 0;
-	} else {
-		early_section = is_early_section(ms);
-		ms->usage->map_active ^= mask;
-		if (ms->usage->map_active == 0) {
-			usage = ms->usage;
-			ms->usage = NULL;
-			memmap = sparse_decode_mem_map(ms->section_mem_map,
-					section_nr);
-			ms->section_mem_map = 0;
-		}
+	if (!ms->usage ||
+	    WARN((ms->usage->map_active & mask) != mask,
+		 "section already deactivated active: %#lx mask: %#lx\n",
+			ms->usage->map_active, mask)) {
+		pgdat_resize_unlock(pgdat, &flags);
+		return;
 	}
+
+	early_section = is_early_section(ms);
+	ms->usage->map_active ^= mask;
+	if (ms->usage->map_active == 0) {
+		usage = ms->usage;
+		ms->usage = NULL;
+		memmap = sparse_decode_mem_map(ms->section_mem_map,
+				section_nr);
+		ms->section_mem_map = 0;
+	}
+
 	pgdat_resize_unlock(pgdat, &flags);
 
 	/*
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
