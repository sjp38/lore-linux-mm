Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 79E9C6B006E
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 11:23:04 -0500 (EST)
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH v3 3/3] slub: min order when debug_guardpage_minorder > 0
Date: Fri, 18 Nov 2011 17:25:07 +0100
Message-Id: <1321633507-13614-3-git-send-email-sgruszka@redhat.com>
In-Reply-To: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>, Stanislaw Gruszka <sgruszka@redhat.com>

Disable slub debug facilities and allocate slabs at minimal order when
debug_guardpage_minorder > 0 to increase probability to catch random
memory corruption by cpu exception.

v1 -> v2:
  - use slub_max_order to minimalize slub order

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 mm/slub.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 7d2a996..a66be56 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3645,6 +3645,9 @@ void __init kmem_cache_init(void)
 	struct kmem_cache *temp_kmem_cache_node;
 	unsigned long kmalloc_size;
 
+	if (debug_guardpage_minorder())
+		slub_max_order = 0;
+
 	kmem_size = offsetof(struct kmem_cache, node) +
 				nr_node_ids * sizeof(struct kmem_cache_node *);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
