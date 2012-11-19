Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 32EAA6B0075
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 00:32:12 -0500 (EST)
From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCH 44/58] mm: Only define is_pageblock_removable_nolock when needed
Date: Sun, 18 Nov 2012 21:28:23 -0800
Message-Id: <1353302917-13995-45-git-send-email-josh@joshtriplett.org>
In-Reply-To: <1353302917-13995-1-git-send-email-josh@joshtriplett.org>
References: <1353302917-13995-1-git-send-email-josh@joshtriplett.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Josh Triplett <josh@joshtriplett.org>

mm/page_alloc.c defines is_pageblock_removable_nolock unconditionally,
but include/linux/memory_hotplug.h only prototypes it when
CONFIG_MEMORY_HOTPLUG=3Dy and CONFIG_MEMORY_HOTREMOVE=3Dy.  Add the
corresponding conditions around the definition, too.

This also eliminates warnings from GCC (-Wmissing-prototypes) and Sparse
(-Wdecl).

mm/page_alloc.c:5634:6: warning: no previous prototype for =E2=80=98is_pa=
geblock_removable_nolock=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/page_alloc.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d857953..706bd5f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5631,6 +5631,7 @@ bool has_unmovable_pages(struct zone *zone, struct =
page *page, int count)
 	return false;
 }
=20
+#if defined(CONFIG_MEMORY_HOTPLUG) && defined(CONFIG_MEMORY_HOTREMOVE)
 bool is_pageblock_removable_nolock(struct page *page)
 {
 	struct zone *zone;
@@ -5654,6 +5655,7 @@ bool is_pageblock_removable_nolock(struct page *pag=
e)
=20
 	return !has_unmovable_pages(zone, page, 0);
 }
+#endif /* defined(CONFIG_MEMORY_HOTPLUG) && defined(CONFIG_MEMORY_HOTREM=
OVE) */
=20
 #ifdef CONFIG_CMA
=20
--=20
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
