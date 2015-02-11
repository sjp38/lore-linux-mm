Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 187A96B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 02:06:19 -0500 (EST)
Received: by pdbft15 with SMTP id ft15so2522496pdb.11
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 23:06:18 -0800 (PST)
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com. [209.85.192.178])
        by mx.google.com with ESMTPS id gp7si29728994pac.26.2015.02.10.23.06.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 23:06:18 -0800 (PST)
Received: by pdev10 with SMTP id v10so2519594pde.10
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 23:06:17 -0800 (PST)
Date: Tue, 10 Feb 2015 23:06:09 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix negative nr_isolated counts
Message-ID: <alpine.LSU.2.11.1502102303040.13607@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

The vmstat interfaces are good at hiding negative counts (at least
when CONFIG_SMP); but if you peer behind the curtain, you find that
nr_isolated_anon and nr_isolated_file soon go negative, and grow ever
more negative: so they can absorb larger and larger numbers of isolated
pages, yet still appear to be zero.

I'm happy to avoid a congestion_wait() when too_many_isolated() myself;
but I guess it's there for a good reason, in which case we ought to get
too_many_isolated() working again.

The imbalance comes from isolate_migratepages()'s ISOLATE_ABORT case:
putback_movable_pages() decrements the NR_ISOLATED counts, but we forgot
to call acct_isolated() to increment them.

Fixes: edc2ca612496 ("mm, compaction: move pageblock checks up from isolate_migratepages_range()")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org # v3.18+
---

 mm/compaction.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- v3.19/mm/compaction.c	2015-02-08 18:54:22.000000000 -0800
+++ linux/mm/compaction.c	2015-02-10 22:25:04.613907871 -0800
@@ -1015,8 +1015,10 @@ static isolate_migrate_t isolate_migrate
 		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
 								isolate_mode);
 
-		if (!low_pfn || cc->contended)
+		if (!low_pfn || cc->contended) {
+			acct_isolated(zone, cc);
 			return ISOLATE_ABORT;
+		}
 
 		/*
 		 * Either we isolated something and proceed with migration. Or

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
