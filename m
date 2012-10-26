Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 4C92A6B0075
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 18:47:56 -0400 (EDT)
Message-ID: <1351291667.6504.13.camel@MikesLinux.fc.hp.com>
Subject: [PATCH v2] mm: memmap_init_zone() performance improvement
From: Mike Yoknis <mike.yoknis@hp.com>
Reply-To: mike.yoknis@hp.com
Date: Fri, 26 Oct 2012 16:47:47 -0600
In-Reply-To: <20121025094410.GA2558@suse.de>
References: <1349276174-8398-1-git-send-email-mike.yoknis@hp.com>
	 <20121008151656.GM29125@suse.de>
	 <1349794597.29752.10.camel@MikesLinux.fc.hp.com>
	 <1350676398.1169.6.camel@MikesLinux.fc.hp.com>
	 <20121020082858.GA2698@suse.de>
	 <1351093667.1205.11.camel@MikesLinux.fc.hp.com>
	 <20121025094410.GA2558@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: mingo@redhat.com, akpm@linux-foundation.org, linux-arch@vger.kernel.org, mmarek@suse.cz, tglx@linutronix.de, hpa@zytor.com, arnd@arndb.de, sam@ravnborg.org, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

memmap_init_zone() loops through every Page Frame Number (pfn),
including pfn values that are within the gaps between existing
memory sections.  The unneeded looping will become a boot
performance issue when machines configure larger memory ranges
that will contain larger and more numerous gaps.

The code will skip across invalid pfn values to reduce the
number of loops executed.

Signed-off-by: Mike Yoknis <mike.yoknis@hp.com>
---
 mm/page_alloc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 45c916b..9f9c1a6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3857,8 +3857,11 @@ void __meminit memmap_init_zone(unsigned long
size, int nid, unsigned long zone,
 		 * exist on hotplugged memory.
 		 */
 		if (context == MEMMAP_EARLY) {
-			if (!early_pfn_valid(pfn))
+			if (!early_pfn_valid(pfn)) {
+				pfn = ALIGN(pfn + MAX_ORDER_NR_PAGES,
+						MAX_ORDER_NR_PAGES) - 1;
 				continue;
+			}
 			if (!early_pfn_in_nid(pfn, nid))
 				continue;
 		}
-- 
1.7.11.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
