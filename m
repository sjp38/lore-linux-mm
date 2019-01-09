Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB73A8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 06:16:12 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so2778185edb.22
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 03:16:12 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id q10si1417106edd.257.2019.01.09.03.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 03:16:11 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 1937E1C29E0
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:16:11 +0000 (GMT)
Date: Wed, 9 Jan 2019 11:16:09 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, compaction: Round-robin the order while searching the
 free lists for a target -fix
Message-ID: <20190109111609.GW31517@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, Dan Carpenter <dan.carpenter@oracle.com>, kirill@shutemov.name, Linux-MM <linux-mm@kvack.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

Dan Carpenter reported the following static checker warning:

        mm/compaction.c:1252 next_search_order()
        warn: impossible condition '(cc->search_order < 0) => (0-u16max < 0)'

While a negative order never makes sense, the control flow is
easier if search_order is signed. This is a fix to the mmotm patch
broken-out/mm-compaction-round-robin-the-order-while-searching-the-free-lists-for-a-target.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/internal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/internal.h b/mm/internal.h
index d028abd8a8f3..e74dbc257550 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -192,7 +192,7 @@ struct compact_control {
 	unsigned long total_migrate_scanned;
 	unsigned long total_free_scanned;
 	unsigned short fast_search_fail;/* failures to use free list searches */
-	unsigned short search_order;	/* order to start a fast search at */
+	short search_order;		/* order to start a fast search at */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* migratetype of direct compactor */
