Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EA4326B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 08:47:20 -0500 (EST)
Received: by bke17 with SMTP id 17so745200bke.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 05:47:16 -0800 (PST)
Subject: [PATCH] mm: account reaped page cache on inode cache pruning
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 16 Nov 2011 17:47:13 +0300
Message-ID: <20111116134713.8933.34389.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>

Inode cache pruning indirectly reclaims page-cache by invalidating mapping pages.
Let's account them into reclaim-state to notice this progress in memory reclaimer.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 fs/inode.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index ee4e66b..1f6c48d 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -692,6 +692,8 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 	else
 		__count_vm_events(PGINODESTEAL, reap);
 	spin_unlock(&sb->s_inode_lru_lock);
+	if (current->reclaim_state)
+		current->reclaim_state->reclaimed_slab += reap;
 
 	dispose_list(&freeable);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
