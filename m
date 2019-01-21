Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2228E0008
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 12:43:17 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id w4so8537804otj.2
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 09:43:17 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id h22si6184263otm.149.2019.01.21.09.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 09:43:16 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 5/6] drivers/IB,usnic: reduce scope of mmap_sem
Date: Mon, 21 Jan 2019 09:42:19 -0800
Message-Id: <20190121174220.10583-6-dave@stgolabs.net>
In-Reply-To: <20190121174220.10583-1-dave@stgolabs.net>
References: <20190121174220.10583-1-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dledford@redhat.com, jgg@mellanox.com, jack@suse.de, ira.weiny@intel.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net, benve@cisco.com, neescoba@cisco.com, pkaustub@cisco.com, Davidlohr Bueso <dbueso@suse.de>

usnic_uiom_get_pages() uses gup_longterm() so we cannot really
get rid of mmap_sem altogether in the driver, but we can get
rid of some complexity that mmap_sem brings with only pinned_vm.
We can get rid of the wq altogether as we no longer need to
defer work to unpin pages as the counter is now atomic.

Cc: benve@cisco.com
Cc: neescoba@cisco.com
Cc: pkaustub@cisco.com
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/infiniband/hw/usnic/usnic_ib_main.c |  2 --
 drivers/infiniband/hw/usnic/usnic_uiom.c    | 54 +++--------------------------
 drivers/infiniband/hw/usnic/usnic_uiom.h    |  1 -
 3 files changed, 4 insertions(+), 53 deletions(-)

diff --git a/drivers/infiniband/hw/usnic/usnic_ib_main.c b/drivers/infiniband/hw/usnic/usnic_ib_main.c
index 3201dd1899c7..1d363b706314 100644
--- a/drivers/infiniband/hw/usnic/usnic_ib_main.c
+++ b/drivers/infiniband/hw/usnic/usnic_ib_main.c
@@ -691,7 +691,6 @@ static int __init usnic_ib_init(void)
 out_pci_unreg:
 	pci_unregister_driver(&usnic_ib_pci_driver);
 out_umem_fini:
-	usnic_uiom_fini();
 
 	return err;
 }
@@ -704,7 +703,6 @@ static void __exit usnic_ib_destroy(void)
 	unregister_inetaddr_notifier(&usnic_ib_inetaddr_notifier);
 	unregister_netdevice_notifier(&usnic_ib_netdevice_notifier);
 	pci_unregister_driver(&usnic_ib_pci_driver);
-	usnic_uiom_fini();
 }
 
 MODULE_DESCRIPTION("Cisco VIC (usNIC) Verbs Driver");
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 854436a2b437..505252298b52 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -47,8 +47,6 @@
 #include "usnic_uiom.h"
 #include "usnic_uiom_interval_tree.h"
 
-static struct workqueue_struct *usnic_uiom_wq;
-
 #define USNIC_UIOM_PAGE_CHUNK						\
 	((PAGE_SIZE - offsetof(struct usnic_uiom_chunk, page_list))	/\
 	((void *) &((struct usnic_uiom_chunk *) 0)->page_list[1] -	\
@@ -129,7 +127,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	uiomr->owning_mm = mm = current->mm;
 	down_write(&mm->mmap_sem);
 
-	locked = npages + atomic64_read(&current->mm->pinned_vm);
+	locked = atomic64_add_return(npages, &current->mm->pinned_vm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
@@ -184,12 +182,11 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	}
 
 out:
-	if (ret < 0)
+	if (ret < 0) {
 		usnic_uiom_put_pages(chunk_list, 0);
-	else {
-		atomic64_set(&mm->pinned_vm, locked);
+		atomic64_sub(npages, &current->mm->pinned_vm);
+	} else
 		mmgrab(uiomr->owning_mm);
-	}
 
 	up_write(&mm->mmap_sem);
 	free_page((unsigned long) page_list);
@@ -435,43 +432,12 @@ static inline size_t usnic_uiom_num_pages(struct usnic_uiom_reg *uiomr)
 	return PAGE_ALIGN(uiomr->length + uiomr->offset) >> PAGE_SHIFT;
 }
 
-static void usnic_uiom_release_defer(struct work_struct *work)
-{
-	struct usnic_uiom_reg *uiomr =
-		container_of(work, struct usnic_uiom_reg, work);
-
-	down_write(&uiomr->owning_mm->mmap_sem);
-	atomic64_sub(usnic_uiom_num_pages(uiomr), &uiomr->owning_mm->pinned_vm);
-	up_write(&uiomr->owning_mm->mmap_sem);
-
-	__usnic_uiom_release_tail(uiomr);
-}
-
 void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr,
 			    struct ib_ucontext *context)
 {
 	__usnic_uiom_reg_release(uiomr->pd, uiomr, 1);
 
-	/*
-	 * We may be called with the mm's mmap_sem already held.  This
-	 * can happen when a userspace munmap() is the call that drops
-	 * the last reference to our file and calls our release
-	 * method.  If there are memory regions to destroy, we'll end
-	 * up here and not be able to take the mmap_sem.  In that case
-	 * we defer the vm_locked accounting to a workqueue.
-	 */
-	if (context->closing) {
-		if (!down_write_trylock(&uiomr->owning_mm->mmap_sem)) {
-			INIT_WORK(&uiomr->work, usnic_uiom_release_defer);
-			queue_work(usnic_uiom_wq, &uiomr->work);
-			return;
-		}
-	} else {
-		down_write(&uiomr->owning_mm->mmap_sem);
-	}
 	atomic64_sub(usnic_uiom_num_pages(uiomr), &uiomr->owning_mm->pinned_vm);
-	up_write(&uiomr->owning_mm->mmap_sem);
-
 	__usnic_uiom_release_tail(uiomr);
 }
 
@@ -600,17 +566,5 @@ int usnic_uiom_init(char *drv_name)
 		return -EPERM;
 	}
 
-	usnic_uiom_wq = create_workqueue(drv_name);
-	if (!usnic_uiom_wq) {
-		usnic_err("Unable to alloc wq for drv %s\n", drv_name);
-		return -ENOMEM;
-	}
-
 	return 0;
 }
-
-void usnic_uiom_fini(void)
-{
-	flush_workqueue(usnic_uiom_wq);
-	destroy_workqueue(usnic_uiom_wq);
-}
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.h b/drivers/infiniband/hw/usnic/usnic_uiom.h
index b86a9731071b..c88cfa087e3a 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.h
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.h
@@ -93,5 +93,4 @@ struct usnic_uiom_reg *usnic_uiom_reg_get(struct usnic_uiom_pd *pd,
 void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr,
 			    struct ib_ucontext *ucontext);
 int usnic_uiom_init(char *drv_name);
-void usnic_uiom_fini(void);
 #endif /* USNIC_UIOM_H_ */
-- 
2.16.4
