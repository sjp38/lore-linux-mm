Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD196B0262
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:00:15 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p41so29628185lfi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:00:15 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id e8si24962wjy.122.2016.07.13.03.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 03:00:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id F1F621C2050
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:00:06 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 4/4] mm: move most file-based accounting to the node -fix
Date: Wed, 13 Jul 2016 11:00:04 +0100
Message-Id: <1468404004-5085-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

As noted by Johannes Weiner, NR_ZONE_WRITE_PENDING gets decremented twice
during migration instead of a dec(old) -> inc(new) cycle as intended.

This is a fix to mmotm patch
mm-move-most-file-based-accounting-to-the-node.patch

Note that it'll cause a conflict with
mm-vmstat-remove-zone-and-node-double-accounting-by-approximating-retries.patch
but that the resolution is trivial.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index c77997dc6ed7..ed0268268e93 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -515,7 +515,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 			__dec_node_state(oldzone->zone_pgdat, NR_FILE_DIRTY);
 			__dec_zone_state(oldzone, NR_ZONE_WRITE_PENDING);
 			__inc_node_state(newzone->zone_pgdat, NR_FILE_DIRTY);
-			__dec_zone_state(newzone, NR_ZONE_WRITE_PENDING);
+			__inc_zone_state(newzone, NR_ZONE_WRITE_PENDING);
 		}
 	}
 	local_irq_enable();
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
