Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id ADAB86B00EE
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 07:10:09 -0400 (EDT)
Subject: [PATCH RFC] mm: reverse lru scanning order
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 27 Jul 2011 15:10:02 +0400
Message-ID: <20110727111002.9985.94938.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

LRU scanning order was accidentially changed in commit v2.6.27-5584-gb69408e:
"vmscan: Use an indexed array for LRU variables".
Before that commit reclaimer always scan active lists first.

This patch just reverse it back.
This is just notice and question: "Does it affect something?"

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mmzone.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index be1ac8d..88fb49c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -141,7 +141,8 @@ enum lru_list {
 
 #define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
 
-#define for_each_evictable_lru(l) for (l = 0; l <= LRU_ACTIVE_FILE; l++)
+#define for_each_evictable_lru(l) \
+	for (l = LRU_ACTIVE_FILE; l >= LRU_INACTIVE_ANON; l--)
 
 static inline int is_file_lru(enum lru_list l)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
