From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 12 Oct 2007 11:49:00 -0400
Message-Id: <20071012154900.8157.98550.sendpatchset@localhost>
In-Reply-To: <20071012154854.8157.51441.sendpatchset@localhost>
References: <20071012154854.8157.51441.sendpatchset@localhost>
Subject: [PATCH/RFC 1/4] Mem Policy:  fix mempolicy usage in pci driver
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@suse.de, mel@skynet.ie, eric.whitney@hp.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

PATCH 1/4 Fix memory policy usage in pci driver

Against:  2.6.23-rc8-mm2

In an attempt to ensure memory allocation from the local node,
the pci driver temporarily replaces the current task's memory
policy with the system default policy.  Trying to be a good
citizen, the driver then call's mpol_get() on the new policy.
When it's finished probing, it undoes the '_get by calling
mpol_free() [on the system default policy] and then restores
the current task's saved mempolicy.

A couple of issues here:

1) it's never necessary to set a task's mempolicy to the
   system default policy in order to get system default
   allocation behavior.  Simply set the current task's
   mempolicy to NULL and allocations will fall back to
   system default policy.

2) we should never [need to] call mpol_free() on the system
   default policy.  [I plan on trapping this with a VM_BUG_ON()
   in a subsequent patch.]

This patch removes the calls to mpol_get() and mpol_free()
and uses NULL for the temporary task mempolicy to effect
default allocation behavior.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 drivers/pci/pci-driver.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: Linux/drivers/pci/pci-driver.c
===================================================================
--- Linux.orig/drivers/pci/pci-driver.c	2007-10-09 14:31:57.000000000 -0400
+++ Linux/drivers/pci/pci-driver.c	2007-10-09 14:43:57.000000000 -0400
@@ -177,13 +177,11 @@ static int pci_call_probe(struct pci_dri
 	    set_cpus_allowed(current, node_to_cpumask(node));
 	/* And set default memory allocation policy */
 	oldpol = current->mempolicy;
-	current->mempolicy = &default_policy;
-	mpol_get(current->mempolicy);
+	current->mempolicy = NULL;	/* fall back to system default policy */
 #endif
 	error = drv->probe(dev, id);
 #ifdef CONFIG_NUMA
 	set_cpus_allowed(current, oldmask);
-	mpol_free(current->mempolicy);
 	current->mempolicy = oldpol;
 #endif
 	return error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
