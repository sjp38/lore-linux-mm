Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 739186B00B1
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:39:04 -0500 (EST)
Received: by ggnq1 with SMTP id q1so3043462ggn.14
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 03:39:02 -0800 (PST)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] mm/vmalloc.c: eliminate extra loop in pcpu_get_vm_areas error path
Date: Fri, 18 Nov 2011 17:13:50 +0530
Message-Id: <1321616630-28281-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

If either of the vas or vms arrays are not properly kzalloced,
then the code jumps to the err_free label.

The err_free label runs a loop to check and free each of the array
members of the vas and vms arrays which is not required for this
situation as none of the array members have been allocated till this
point.

Eliminate the extra loop we have to go through by introducing a new
label err_free2 and then jumping to it.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/vmalloc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b669aa6..1a0d4e2 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2352,7 +2352,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 	vms = kzalloc(sizeof(vms[0]) * nr_vms, GFP_KERNEL);
 	vas = kzalloc(sizeof(vas[0]) * nr_vms, GFP_KERNEL);
 	if (!vas || !vms)
-		goto err_free;
+		goto err_free2;
 
 	for (area = 0; area < nr_vms; area++) {
 		vas[area] = kzalloc(sizeof(struct vmap_area), GFP_KERNEL);
@@ -2455,6 +2455,7 @@ err_free:
 		if (vms)
 			kfree(vms[area]);
 	}
+err_free2:
 	kfree(vas);
 	kfree(vms);
 	return NULL;
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
