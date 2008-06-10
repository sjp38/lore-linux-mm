Date: Tue, 10 Jun 2008 11:18:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.26-rc5-mm2 lockup up on Intel G33+ICH9R+Core2Duo, -mm1 okay
Message-Id: <20080610111832.736519d2.akpm@linux-foundation.org>
In-Reply-To: <73ls44tntnv8ro57chp1on2crsqkoilmkj@4ax.com>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
	<73ls44tntnv8ro57chp1on2crsqkoilmkj@4ax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Grant Coady <gcoady.lk@gmail.com>
Cc: Grant Coady <grant_lkml@dodo.com.au>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Keith Packard <keithp@keithp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 20:20:09 +1000 Grant Coady <grant_lkml@dodo.com.au> wrote:

> On Mon, 9 Jun 2008 22:31:45 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> >
> >ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm2/
> >
> >- This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
> >  vmscan.c bug which would have prevented testing of the other vmscan.c
> >  bugs^Wchanges.
> 
> No it's not :)
> 
> -mm1 worked fine here but -mm2 locks up just after saying:
> agpgart: Detected 7164K stolen memory.
> 
> Nothing in logs (session not recorded - hit reset to restart).
> 
> config and dmseg for -mm1 at (same .config for mm2):
> 
>   http://bugsplatter.mine.nu/test/boxen/pooh/config-2.6.26-rc5-mm1a.gz
>   http://bugsplatter.mine.nu/test/boxen/pooh/dmesg-2.6.26-rc5-mm1a.gz
> 
> Grant.

hm, intel-agp gtt stuff.

Can you please see whether reverting Keith's stuff fixes it?

 drivers/char/agp/agp.h       |    3 ---
 drivers/char/agp/backend.c   |    2 --
 drivers/char/agp/generic.c   |   28 ----------------------------
 drivers/char/agp/intel-agp.c |    5 -----
 include/linux/agp_backend.h  |    5 -----
 5 files changed, 43 deletions(-)

diff -puN drivers/char/agp/agp.h~revert-intel-agp-rewrite-gtt-on-resume drivers/char/agp/agp.h
--- a/drivers/char/agp/agp.h~revert-intel-agp-rewrite-gtt-on-resume
+++ a/drivers/char/agp/agp.h
@@ -148,9 +148,6 @@ struct agp_bridge_data {
 	char minor_version;
 	struct list_head list;
 	u32 apbase_config;
-	/* list of agp_memory mapped to the aperture */
-	struct list_head mapped_list;
-	spinlock_t mapped_lock;
 };
 
 #define KB(x)	((x) * 1024)
diff -puN drivers/char/agp/backend.c~revert-intel-agp-rewrite-gtt-on-resume drivers/char/agp/backend.c
--- a/drivers/char/agp/backend.c~revert-intel-agp-rewrite-gtt-on-resume
+++ a/drivers/char/agp/backend.c
@@ -183,8 +183,6 @@ static int agp_backend_initialize(struct
 		rc = -EINVAL;
 		goto err_out;
 	}
-	INIT_LIST_HEAD(&bridge->mapped_list);
-	spin_lock_init(&bridge->mapped_lock);
 
 	return 0;
 
diff -puN drivers/char/agp/generic.c~revert-intel-agp-rewrite-gtt-on-resume drivers/char/agp/generic.c
--- a/drivers/char/agp/generic.c~revert-intel-agp-rewrite-gtt-on-resume
+++ a/drivers/char/agp/generic.c
@@ -426,10 +426,6 @@ int agp_bind_memory(struct agp_memory *c
 
 	curr->is_bound = TRUE;
 	curr->pg_start = pg_start;
-	spin_lock(&agp_bridge->mapped_lock);
-	list_add(&curr->mapped_list, &agp_bridge->mapped_list);
-	spin_unlock(&agp_bridge->mapped_lock);
-
 	return 0;
 }
 EXPORT_SYMBOL(agp_bind_memory);
@@ -462,34 +458,10 @@ int agp_unbind_memory(struct agp_memory 
 
 	curr->is_bound = FALSE;
 	curr->pg_start = 0;
-	spin_lock(&curr->bridge->mapped_lock);
-	list_del(&curr->mapped_list);
-	spin_unlock(&curr->bridge->mapped_lock);
 	return 0;
 }
 EXPORT_SYMBOL(agp_unbind_memory);
 
-/**
- *	agp_rebind_emmory  -  Rewrite the entire GATT, useful on resume
- */
-int agp_rebind_memory(void)
-{
-	struct agp_memory *curr;
-	int ret_val = 0;
-
-	spin_lock(&agp_bridge->mapped_lock);
-	list_for_each_entry(curr, &agp_bridge->mapped_list, mapped_list) {
-		ret_val = curr->bridge->driver->insert_memory(curr,
-							      curr->pg_start,
-							      curr->type);
-		if (ret_val != 0)
-			break;
-	}
-	spin_unlock(&agp_bridge->mapped_lock);
-	return ret_val;
-}
-EXPORT_SYMBOL(agp_rebind_memory);
-
 /* End - Routines for handling swapping of agp_memory into the GATT */
 
 
diff -puN drivers/char/agp/intel-agp.c~revert-intel-agp-rewrite-gtt-on-resume drivers/char/agp/intel-agp.c
--- a/drivers/char/agp/intel-agp.c~revert-intel-agp-rewrite-gtt-on-resume
+++ a/drivers/char/agp/intel-agp.c
@@ -2176,7 +2176,6 @@ static void __devexit agp_intel_remove(s
 static int agp_intel_resume(struct pci_dev *pdev)
 {
 	struct agp_bridge_data *bridge = pci_get_drvdata(pdev);
-	int ret_val;
 
 	pci_restore_state(pdev);
 
@@ -2204,10 +2203,6 @@ static int agp_intel_resume(struct pci_d
 	else if (bridge->driver == &intel_i965_driver)
 		intel_i915_configure();
 
-	ret_val = agp_rebind_memory();
-	if (ret_val != 0)
-		return ret_val;
-
 	return 0;
 }
 #endif
diff -puN include/linux/agp_backend.h~revert-intel-agp-rewrite-gtt-on-resume include/linux/agp_backend.h
--- a/include/linux/agp_backend.h~revert-intel-agp-rewrite-gtt-on-resume
+++ a/include/linux/agp_backend.h
@@ -30,8 +30,6 @@
 #ifndef _AGP_BACKEND_H
 #define _AGP_BACKEND_H 1
 
-#include <linux/list.h>
-
 #ifndef TRUE
 #define TRUE 1
 #endif
@@ -88,8 +86,6 @@ struct agp_memory {
 	u8 is_bound;
 	u8 is_flushed;
         u8 vmalloc_flag;
-	/* list of agp_memory mapped to the aperture */
-	struct list_head mapped_list;
 };
 
 #define AGP_NORMAL_MEMORY 0
@@ -108,7 +104,6 @@ extern struct agp_memory *agp_allocate_m
 extern int agp_copy_info(struct agp_bridge_data *, struct agp_kern_info *);
 extern int agp_bind_memory(struct agp_memory *, off_t);
 extern int agp_unbind_memory(struct agp_memory *);
-extern int agp_rebind_memory(void);
 extern void agp_enable(struct agp_bridge_data *, u32);
 extern struct agp_bridge_data *agp_backend_acquire(struct pci_dev *);
 extern void agp_backend_release(struct agp_bridge_data *);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
