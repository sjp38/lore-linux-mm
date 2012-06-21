Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id D783B6B004D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 21:00:15 -0400 (EDT)
Received: by dakp5 with SMTP id p5so125295dak.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 18:00:15 -0700 (PDT)
Date: Wed, 20 Jun 2012 18:00:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3.5-rc3] mm, mempolicy: fix mbind() to do synchronous
 migration
Message-ID: <alpine.DEB.2.00.1206201758500.3068@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If the range passed to mbind() is not allocated on nodes set in the
nodemask, it migrates the pages to respect the constraint.

The final formal of migrate_pages() is a mode of type enum migrate_mode,
not a boolean.  do_mbind() is currently passing "true" which is the
equivalent of MIGRATE_SYNC_LIGHT.  This should instead be MIGRATE_SYNC
for synchronous page migration.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mempolicy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1177,7 +1177,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 		if (!list_empty(&pagelist)) {
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
 						(unsigned long)vma,
-						false, true);
+						false, MIGRATE_SYNC);
 			if (nr_failed)
 				putback_lru_pages(&pagelist);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
