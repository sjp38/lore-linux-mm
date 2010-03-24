Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A0ED36B01C3
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 04:18:34 -0400 (EDT)
Subject: [PATCH 2/2] powerpc/pseries: Flush lazy kernel mappings after
 unplug operations
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 24 Mar 2010 18:56:35 +1100
Message-ID: <1269417395.8599.189.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nathan Fontenot <nfont@austin.ibm.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

This ensures that the translations for unmapped IO mappings or
unmapped memory are properly removed from the MMU hash table
before such an unplug. Without this, the hypervisor refuses the
unplug operations due to those resources still being mapped by
the partition.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/powerpc/platforms/pseries/hotplug-memory.c |    7 +++++++
 drivers/pci/hotplug/rpadlpar_core.c             |    3 +++
 drivers/pci/hotplug/rpaphp_core.c               |    3 +++
 3 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/hotplug-memory.c b/arch/powerpc/platforms/pseries/hotplug-memory.c
index 9b21ee6..8a0a32e 100644
--- a/arch/powerpc/platforms/pseries/hotplug-memory.c
+++ b/arch/powerpc/platforms/pseries/hotplug-memory.c
@@ -11,6 +11,7 @@
 
 #include <linux/of.h>
 #include <linux/lmb.h>
+#include <linux/vmalloc.h>
 #include <asm/firmware.h>
 #include <asm/machdep.h>
 #include <asm/pSeries_reconfig.h>
@@ -54,6 +55,12 @@ static int pseries_remove_lmb(unsigned long base, unsigned int lmb_size)
 	 */
 	start = (unsigned long)__va(base);
 	ret = remove_section_mapping(start, start + lmb_size);
+
+	/* Ensure all vmalloc mappings are flushed in case they also
+	 * hit that section of memory
+	 */
+	purge_vmap_area_lazy();
+
 	return ret;
 }
 
diff --git a/drivers/pci/hotplug/rpadlpar_core.c b/drivers/pci/hotplug/rpadlpar_core.c
index 4e3e038..99cb3f9 100644
--- a/drivers/pci/hotplug/rpadlpar_core.c
+++ b/drivers/pci/hotplug/rpadlpar_core.c
@@ -20,6 +20,7 @@
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/string.h>
+#include <linux/vmalloc.h>
 
 #include <asm/pci-bridge.h>
 #include <linux/mutex.h>
@@ -430,6 +431,8 @@ int dlpar_remove_slot(char *drc_name)
 			rc = dlpar_remove_pci_slot(drc_name, dn);
 			break;
 	}
+	purge_vmap_area_lazy();
+
 	printk(KERN_INFO "%s: slot %s removed\n", DLPAR_MODULE_NAME, drc_name);
 exit:
 	mutex_unlock(&rpadlpar_mutex);
diff --git a/drivers/pci/hotplug/rpaphp_core.c b/drivers/pci/hotplug/rpaphp_core.c
index dcaae72..2394ec0 100644
--- a/drivers/pci/hotplug/rpaphp_core.c
+++ b/drivers/pci/hotplug/rpaphp_core.c
@@ -30,6 +30,7 @@
 #include <linux/slab.h>
 #include <linux/smp.h>
 #include <linux/init.h>
+#include <linux/vmalloc.h>
 #include <asm/eeh.h>       /* for eeh_add_device() */
 #include <asm/rtas.h>		/* rtas_call */
 #include <asm/pci-bridge.h>	/* for pci_controller */
@@ -419,6 +420,8 @@ static int disable_slot(struct hotplug_slot *hotplug_slot)
 		return -EINVAL;
 
 	pcibios_remove_pci_devices(slot->bus);
+	purge_vmap_area_lazy();
+
 	slot->state = NOT_CONFIGURED;
 	return 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
