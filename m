Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94742280310
	for <linux-mm@kvack.org>; Sun, 20 Aug 2017 20:36:45 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q10so144883229pgc.15
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 17:36:45 -0700 (PDT)
Received: from mail-pg0-x22a.google.com (mail-pg0-x22a.google.com. [2607:f8b0:400e:c05::22a])
        by mx.google.com with ESMTPS id o27si5301920pgn.123.2017.08.20.17.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Aug 2017 17:36:44 -0700 (PDT)
Received: by mail-pg0-x22a.google.com with SMTP id m133so7268592pga.5
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 17:36:44 -0700 (PDT)
Date: Sun, 20 Aug 2017 17:36:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, compaction: persistently skip hugetlbfs pageblocks
 fix
In-Reply-To: <20170818084912.GA18513@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1708201734390.117182@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com> <alpine.DEB.2.10.1708151639130.106658@chino.kir.corp.google.com> <20170818084912.GA18513@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1113868975-761508760-1503275802=:117182"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1113868975-761508760-1503275802=:117182
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

Fix build:

mm/compaction.c: In function a??isolate_freepages_blocka??:
mm/compaction.c:469:4: error: implicit declaration of function a??pageblock_skip_persistenta?? [-Werror=implicit-function-declaration]
    if (pageblock_skip_persistent(page, order)) {
    ^
mm/compaction.c:470:5: error: implicit declaration of function a??set_pageblock_skipa?? [-Werror=implicit-function-declaration]
     set_pageblock_skip(page);
     ^

CMA doesn't guarantee pageblock skip will get reset when migration and 
freeing scanners meet, and pageblock skip is a CONFIG_COMPACTION only 
feature, so disable it when CONFIG_COMPACTION=n.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/pageblock-flags.h | 11 +++++++++++
 mm/compaction.c                 |  8 +++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -96,6 +96,17 @@ void set_pfnblock_flags_mask(struct page *page,
 #define set_pageblock_skip(page) \
 			set_pageblock_flags_group(page, 1, PB_migrate_skip,  \
 							PB_migrate_skip)
+#else
+static inline bool get_pageblock_skip(struct page *page)
+{
+	return false;
+}
+static inline void clear_pageblock_skip(struct page *page)
+{
+}
+static inline void set_pageblock_skip(struct page *page)
+{
+}
 #endif /* CONFIG_COMPACTION */
 
 #endif	/* PAGEBLOCK_FLAGS_H */
diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -322,7 +322,13 @@ static inline bool isolation_suitable(struct compact_control *cc,
 	return true;
 }
 
-static void update_pageblock_skip(struct compact_control *cc,
+static inline bool pageblock_skip_persistent(struct page *page,
+					     unsigned int order)
+{
+	return false;
+}
+
+static inline void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
 			bool migrate_scanner)
 {
--1113868975-761508760-1503275802=:117182--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
