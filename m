Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9E16B016A
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 23:05:28 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
Date: Thu, 4 Aug 2011 11:09:48 +0800
Message-ID: <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com, Bob Liu <lliubbo@gmail.com>

This patch also add checking whether alloc frontswap_map memory
failed.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/swapfile.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index ffdd06a..8fe9e88 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2124,9 +2124,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	}
 	/* frontswap enabled? set up bit-per-page map for frontswap */
 	if (frontswap_enabled) {
-		frontswap_map = vmalloc(maxpages / sizeof(long));
-		if (frontswap_map)
-			memset(frontswap_map, 0, maxpages / sizeof(long));
+		frontswap_map = vzalloc(maxpages / sizeof(long));
+		if (!frontswap_map)
+			goto bad_swap;
 	}
 
 	if (p->bdev) {
-- 
1.6.3.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
