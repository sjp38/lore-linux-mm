Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id A272D6B0036
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:47:15 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Thu, 25 Jul 2013 00:08:09 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 6D2901258043
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 00:16:35 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6OIl6PU38010984
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 00:17:06 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6OIl9i5010807
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:47:09 +1000
Message-ID: <51F02129.8010506@linux.vnet.ibm.com>
Date: Wed, 24 Jul 2013 13:47:05 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 8/8] Remove no longer needed powerpc memory node update handler
References: <51F01E06.6090800@linux.vnet.ibm.com>
In-Reply-To: <51F01E06.6090800@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Remove the update_node handler for powerpc/pseries.

Now that we can do memory dlpar in the kernel we no longer need the of
update node notifier to update the ibm,dynamic-memory property of the
ibm,dynamic-reconfiguration-memory node. This work is now handled by
the memory notification handlers for powerpc/pseries.

This patch also conditionally registers the handler for of node remove
if we are not using the ibm,dynamic-reconfiguration-memory device tree
layout. That handler is only needed for handling memory@XXX nodes
in the device tree.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 arch/powerpc/platforms/pseries/hotplug-memory.c |   60 +++---------------------
 1 file changed, 8 insertions(+), 52 deletions(-)

Index: linux/arch/powerpc/platforms/pseries/hotplug-memory.c
===================================================================
--- linux.orig/arch/powerpc/platforms/pseries/hotplug-memory.c
+++ linux/arch/powerpc/platforms/pseries/hotplug-memory.c
@@ -166,67 +166,15 @@ static inline int pseries_remove_memory(
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-static int pseries_update_drconf_memory(struct of_prop_reconfig *pr)
-{
-	struct of_drconf_cell *new_drmem, *old_drmem;
-	unsigned long memblock_size;
-	u32 entries;
-	u32 *p;
-	int i, rc = -EINVAL;
-
-	memblock_size = get_memblock_size();
-	if (!memblock_size)
-		return -EINVAL;
-
-	p = (u32 *)of_get_property(pr->dn, "ibm,dynamic-memory", NULL);
-	if (!p)
-		return -EINVAL;
-
-	/* The first int of the property is the number of lmb's described
-	 * by the property. This is followed by an array of of_drconf_cell
-	 * entries. Get the niumber of entries and skip to the array of
-	 * of_drconf_cell's.
-	 */
-	entries = *p++;
-	old_drmem = (struct of_drconf_cell *)p;
-
-	p = (u32 *)pr->prop->value;
-	p++;
-	new_drmem = (struct of_drconf_cell *)p;
-
-	for (i = 0; i < entries; i++) {
-		if ((old_drmem[i].flags & DRCONF_MEM_ASSIGNED) &&
-		    (!(new_drmem[i].flags & DRCONF_MEM_ASSIGNED))) {
-			rc = pseries_remove_memblock(old_drmem[i].base_addr,
-						     memblock_size);
-			break;
-		} else if ((!(old_drmem[i].flags & DRCONF_MEM_ASSIGNED)) &&
-			   (new_drmem[i].flags & DRCONF_MEM_ASSIGNED)) {
-			rc = memblock_add(old_drmem[i].base_addr,
-					  memblock_size);
-			rc = (rc < 0) ? -EINVAL : 0;
-			break;
-		}
-	}
-
-	return rc;
-}
-
 static int pseries_memory_notifier(struct notifier_block *nb,
 				   unsigned long action, void *node)
 {
-	struct of_prop_reconfig *pr;
 	int err = 0;
 
 	switch (action) {
 	case OF_RECONFIG_DETACH_NODE:
 		err = pseries_remove_memory(node);
 		break;
-	case OF_RECONFIG_UPDATE_PROPERTY:
-		pr = (struct of_prop_reconfig *)node;
-		if (!strcmp(pr->prop->name, "ibm,dynamic-memory"))
-			err = pseries_update_drconf_memory(pr);
-		break;
 	}
 	return notifier_from_errno(err);
 }
@@ -237,6 +185,14 @@ static struct notifier_block pseries_mem
 
 static int __init pseries_memory_hotplug_init(void)
 {
+	struct device_node *dn;
+
+	dn = of_find_node_by_path("/ibm,dynamic-reconfiguration-memory");
+	if (dn) {
+		of_node_put(dn);
+		return 0;
+	}
+
 	if (firmware_has_feature(FW_FEATURE_LPAR))
 		of_reconfig_notifier_register(&pseries_mem_nb);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
