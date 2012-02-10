Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 6F43C6B13F3
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:42:36 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so3584330bkt.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 11:42:35 -0800 (PST)
Subject: [PATCH 4/4] mm: use swap readahead at swapoff
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 10 Feb 2012 23:42:33 +0400
Message-ID: <20120210194233.6492.86917.stgit@zurg>
In-Reply-To: <20120210193249.6492.18768.stgit@zurg>
References: <20120210193249.6492.18768.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

try_to_unuse() iterates over swap-entries sequentially,
thus readahead here will not hurt.

Test results:
Virtual machine: without patch 7 seconds, with patch 4 seconds.
Real hardware: without patch 100 seconds, with patch 70 seconds.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/swapfile.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index d999f09..4c99689 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1106,8 +1106,7 @@ static int try_to_unuse(unsigned int type)
 		 */
 		swap_map = &si->swap_map[i];
 		entry = swp_entry(type, i);
-		page = read_swap_cache_async(entry,
-					GFP_HIGHUSER_MOVABLE, NULL, 0);
+		page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE, NULL, 0);
 		if (!page) {
 			/*
 			 * Either swap_duplicate() failed because entry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
