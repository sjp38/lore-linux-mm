Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BFDE76B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 11:23:02 -0500 (EST)
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH v2 2/3] PM / Hibernate : do not count debug pages as savable
Date: Fri, 18 Nov 2011 17:25:06 +0100
Message-Id: <1321633507-13614-2-git-send-email-sgruszka@redhat.com>
In-Reply-To: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>, Stanislaw Gruszka <sgruszka@redhat.com>

When debugging with CONFIG_DEBUG_PAGEALLOC and
debug_guardpage_minorder > 0, we have lot of free pages that are not
marked so. Snapshot code account them as savable, what cause hibernate
memory preallocation failure.

It is pretty hard to make hibernate allocation succeed with
debug_guardpage_minorder=1. This change at least make it possible when
system has relatively big amount of RAM.

v1 -> v2:
 - change "corrupt" name to guard page

Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 kernel/power/snapshot.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index cbe2c14..1cf8890 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -858,6 +858,9 @@ static struct page *saveable_highmem_page(struct zone *zone, unsigned long pfn)
 	    PageReserved(page))
 		return NULL;
 
+	if (page_is_guard(page))
+		return NULL;
+
 	return page;
 }
 
@@ -920,6 +923,9 @@ static struct page *saveable_page(struct zone *zone, unsigned long pfn)
 	    && (!kernel_page_present(page) || pfn_is_nosave(pfn)))
 		return NULL;
 
+	if (page_is_guard(page))
+		return NULL;
+
 	return page;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
