Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 29A9D6B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 05:14:39 -0400 (EDT)
From: Oskar Andero <oskar.andero@sonymobile.com>
Subject: [PATCH] mm: vmscan: add BUG_ON on illegal return values from scan_objects
Date: Mon, 20 May 2013 11:14:27 +0200
Message-ID: <1369041267-26424-1-git-send-email-oskar.andero@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Radovan Lekanovic <radovan.lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Oskar Andero <oskar.andero@sonymobile.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Add a BUG_ON to catch any illegal value from the shrinkers. This fixes a
potential bug if scan_objects returns a negative other than -1, which
would lead to undefined behaviour.

Cc: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Oskar Andero <oskar.andero@sonymobile.com>
---
 mm/vmscan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6bac41e..fbe6742 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -293,6 +293,7 @@ shrink_slab_one(struct shrinker *shrinker, struct shrink_control *shrinkctl,
 		ret = shrinker->scan_objects(shrinker, shrinkctl);
 		if (ret == -1)
 			break;
+		BUG_ON(ret < -1);
 		freed += ret;
 
 		count_vm_events(SLABS_SCANNED, nr_to_scan);
-- 
1.8.1.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
