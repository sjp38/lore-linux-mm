Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 549846B006E
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 14:39:29 -0400 (EDT)
Date: Tue, 30 Oct 2012 14:42:04 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH RFC] mm,vmscan: only evict file pages when we have plenty
Message-ID: <20121030144204.0aa14d92@dull>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, klamm@yandex-team.ru, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org

If we have more inactive file pages than active file pages, we
skip scanning the active file pages alltogether, with the idea
that we do not want to evict the working set when there is
plenty of streaming IO in the cache.

However, the code forgot to also skip scanning anonymous pages
in that situation.  That lead to the curious situation of keeping
the active file pages protected from being paged out when there
are lots of inactive file pages, while still scanning and evicting
anonymous pages.

This patch fixes that situation, by only evicting file pages
when we have plenty of them and most are inactive.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2624edc..1a53fbb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1686,6 +1686,15 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 			fraction[1] = 0;
 			denominator = 1;
 			goto out;
+		} else if (!inactive_file_is_low_global(zone)) {
+			/*
+			 * There is enough inactive page cache, do not
+			 * reclaim anything from the working set right now.
+			 */
+			fraction[0] = 0;
+			fraction[1] = 1;
+			denominator = 1;
+			goto out;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
