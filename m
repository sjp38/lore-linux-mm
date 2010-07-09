Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C7806B02A7
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:12:23 -0400 (EDT)
Message-Id: <20100709190853.770833931@quilx.com>
Date: Fri, 09 Jul 2010 14:07:13 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q2 07/19] slub: Allow removal of slab caches during boot
References: <20100709190706.938177313@quilx.com>
Content-Disposition: inline; filename=slub_sysfs_remove_during_boot
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

If a slab cache is removed before we have setup sysfs then simply skip over
the sysfs handling.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Roland Dreier <rdreier@cisco.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-06 15:13:48.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-06 15:15:27.000000000 -0500
@@ -4507,6 +4507,13 @@ static int sysfs_slab_add(struct kmem_ca
 
 static void sysfs_slab_remove(struct kmem_cache *s)
 {
+	if (slab_state < SYSFS)
+		/*
+		 * Sysfs has not been setup yet so no need to remove the
+		 * cache from sysfs.
+		 */
+		return;
+
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);
 	kobject_put(&s->kobj);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
