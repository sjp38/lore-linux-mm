Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7559D6B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 01:57:20 -0500 (EST)
Received: by ggni2 with SMTP id i2so1882554ggn.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 22:57:19 -0800 (PST)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] vmalloc: purge_fragmented_blocks: Acquire spinlock before reading vmap_block
Date: Thu,  8 Dec 2011 12:32:12 +0530
Message-Id: <1323327732-30817-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

The purge_fragmented_blocks will loop over all vmap_blocks in the
vmap_block_queue to create the purge list.
Currently, the code in the loop does not acquire the &vb->lock before
reading the vb->free and vb->dirty.

Due to this, there might be a possibility of vb->free and vb->dirty being
changed in parallel which could lead to the current vmap_block not being
selected for purging.

Changing the code to acquire this spinlock before the check for vb->free
and vb->dirty.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/vmalloc.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3231bf3..2228971 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -855,11 +855,14 @@ static void purge_fragmented_blocks(int cpu)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(vb, &vbq->free, free_list) {
+		spin_lock(&vb->lock);
 
-		if (!(vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS))
+		if (!(vb->free + vb->dirty == VMAP_BBMAP_BITS &&
+			  vb->dirty != VMAP_BBMAP_BITS)) {
+			spin_unlock(&vb->lock);
 			continue;
+		}
 
-		spin_lock(&vb->lock);
 		if (vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS) {
 			vb->free = 0; /* prevent further allocs after releasing lock */
 			vb->dirty = VMAP_BBMAP_BITS; /* prevent purging it again */
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
