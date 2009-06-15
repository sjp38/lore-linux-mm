From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 21/22] HWPOISON: send uevent to report memory corruption
Date: Mon, 15 Jun 2009 10:45:41 +0800
Message-ID: <20090615031255.278184860@intel.com>
References: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D5A456B008C
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:34 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-uevent.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

This allows the user space to do some flexible policies.
For example, it may either do emergency sync/shutdown
or to schedule reboot at some convenient time, depending
on the severeness of the corruption.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/vm/memory-failure |   68 ++++++++++++++++++
 mm/memory-failure.c             |  110 +++++++++++++++++++++++++++++-
 2 files changed, 175 insertions(+), 3 deletions(-)

--- /dev/null
+++ sound-2.6/Documentation/vm/memory-failure
@@ -0,0 +1,68 @@
+Memory failure and hardware poison events
+
+Memory may have soft errors and the more memory you have the more errors.
+Normally hardware hides that from you by correcting it, but in some cases you
+can get multi-bit errors which lead to uncorrected errors the hardware cannot
+hide.
+
+This does not necessarily mean that the hardware is broken; for example it can
+be caused by cosmic particles hitting a unlucky transistor. So it can really
+happen in normal operation.
+
+Some hardwares (eg. Nehalem-EX) support background memory scrubbing in order to
+report the memory corruption before they are consumed. The kernel will then try
+to isolate the corrupted memory page, restore data, and finally send a uevent
+to the user space.
+
+A memory poison uevent will be
+
+  # udevadm monitor --environment --kernel
+  KERNEL[1245030313.702625] change   /kernel/mm/hwpoison/hwpoison (hwpoison)
+  UDEV_LOG=3
+  ACTION=change
+  DEVPATH=/kernel/mm/hwpoison/hwpoison
+  SUBSYSTEM=hwpoison
+  EVENT=poison
+  PHYS_ADDR=0x19e1c000
+  PAGE_FLAGS=0x80008083c
+  PAGE_COUNT=3
+  PAGE_MAPCOUNT=1
+  PAGE_DEV=8:2
+  PAGE_INODE=56169
+  PAGE_INDEX=9
+  PAGE_TYPE=file_data
+  PAGE_ISOLATED=1
+  DATA_RECOVERABLE=0
+  SEQNUM=2109
+
+where
+
+  PHYS_ADDR	the physical page address
+  PAGE_FLAGS	the kpageflags bits defined at Documentation/vm/pagemap.txt
+  PAGE_COUNT	the original page reference count
+  PAGE_MAPCOUNT	the original page map count
+
+  PAGE_TYPE	where the error lands, can be one of
+    "kernel"      - a kernel page that may contain some critical data structure
+    "fs_metadata" - a filesystem metadata page
+    "file_data"   - a file data page
+    "anon_data"   - a page belong to some process(es)
+    "swap_cache"  - it's in the swap cache; the kernel cannot tell if it was an
+                    anon_data page or a tmpfs' file_data page
+    "free"        - a free page; not used by anyone
+
+For "file_data" pages, the following three vars are available:
+
+  PAGE_DEV	the file's MAJOR:MINOR device numbers in decimal
+  PAGE_INODE	the file's inode number in decimal
+  PAGE_INDEX	the file offset in page size
+
+  PAGE_ISOLATED if 1, we are sure that the page won't be consumed in the future.
+                if 0, the error page is still referenced by someone, and may be
+		consumed at anytime, which will be detected/stopped by hardware,
+		and trigger instant machine reboot.
+
+  DATA_RECOVERABLE if 1, no data are lost. For example, it's a free page, or a
+                   clean page whose data can be reloaded from disk. In these
+		   cases, the user space will not see the error at all.
+
--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -330,7 +330,11 @@ static const char *hwpoison_page_type_na
 	[ PAGE_IS_FREE ]	= "free",
 };
 
+static struct kset *hwpoison_kset;
+static struct kobject hwpoison_kobj;
+
 struct hwpoison_control {
+	struct kobj_uevent_env *env;
 	unsigned long pfn;
 	struct page *p;		/* corrupted page */
 	struct page *page;	/* compound page head */
@@ -340,6 +344,51 @@ struct hwpoison_control {
 	unsigned page_isolated:1;
 };
 
+static void hwpoison_uevent_page(struct hwpoison_control *hpc)
+{
+	struct page *p = hpc->page;
+
+	if (hpc->env == NULL)
+		return;
+
+	add_uevent_var(hpc->env, "EVENT=poison");
+	add_uevent_var(hpc->env, "PHYS_ADDR=%#lx", hpc->pfn << PAGE_SHIFT);
+	add_uevent_var(hpc->env, "PAGE_FLAGS=%#Lx", page_uflags(p));
+	add_uevent_var(hpc->env, "PAGE_COUNT=%d", page_count(p));
+	add_uevent_var(hpc->env, "PAGE_MAPCOUNT=%d", page_mapcount(p));
+}
+
+static void hwpoison_uevent_file(struct hwpoison_control *hpc)
+{
+	struct address_space *mapping = page_mapping(hpc->page);
+
+	if (hpc->env == NULL)
+		return;
+
+	if (!mapping || !mapping->host)
+		return;
+
+	add_uevent_var(hpc->env, "PAGE_DEV=%d:%d",
+		       MAJOR(mapping->host->i_sb->s_dev),
+		       MINOR(mapping->host->i_sb->s_dev));
+	add_uevent_var(hpc->env, "PAGE_INODE=%lu", mapping->host->i_ino);
+	add_uevent_var(hpc->env, "PAGE_INDEX=%lu", hpc->page->index);
+}
+
+static void hwpoison_uevent_send(struct hwpoison_control *hpc)
+{
+	if (hpc->env == NULL)
+		return;
+
+	add_uevent_var(hpc->env, "PAGE_TYPE=%s",
+		       hwpoison_page_type_name[hpc->page_type]);
+	add_uevent_var(hpc->env, "PAGE_ISOLATED=%d",
+		       hpc->page_isolated);
+	add_uevent_var(hpc->env, "DATA_RECOVERABLE=%d",
+		       hpc->data_recoverable);
+	kobject_uevent_env(&hwpoison_kobj, KOBJ_CHANGE, hpc->env->envp);
+}
+
 /*
  * Error hit kernel page.
  * Do nothing, try to be lucky and not touch this instead. For a few cases we
@@ -769,10 +818,19 @@ void memory_failure(unsigned long pfn, i
 		return;
 	}
 
+	hpc.env = kzalloc(sizeof(struct kobj_uevent_env), GFP_NOIO);
+	if (!hpc.env) {
+		printk(KERN_ERR
+		       "MCE %#lx: cannot allocate memory for uevent\n",
+		       pfn);
+	}
+
 	hpc.pfn  = pfn;
 	hpc.p    = p;
 	hpc.page = p = compound_head(p);
 
+	hwpoison_uevent_page(&hpc);
+
 	hpc.page_type = PAGE_IS_KERNEL;
 	hpc.data_recoverable = 0;
 	hpc.page_isolated = 0;
@@ -796,7 +854,7 @@ void memory_failure(unsigned long pfn, i
 			action_result(&hpc, "free buddy", DELAYED);
 		} else
 			action_result(&hpc, "high order kernel", IGNORED);
-		return;
+		goto out;
 	}
 
 	/*
@@ -825,16 +883,62 @@ void memory_failure(unsigned long pfn, i
 		if (!PageSwapCache(p) && p->mapping == NULL) {
 			action_result(&hpc, "already truncated LRU", IGNORED);
 			hpc.page_type = PAGE_IS_FREE;
-			goto out;
+			goto out_unlock;
 		}
 	}
 
+	hwpoison_uevent_file(&hpc);
+
 	for (ps = error_states;; ps++) {
 		if ((p->flags & ps->mask) == ps->res) {
 			page_action(ps, &hpc);
 			break;
 		}
 	}
-out:
+out_unlock:
 	unlock_page(p);
+out:
+	hwpoison_uevent_send(&hpc);
+}
+
+static void hwpoison_release(struct kobject *kobj)
+{
+}
+
+static struct kobj_type hwpoison_ktype = {
+	.release = hwpoison_release,
+};
+
+static int hwpoison_kobj_init(void)
+{
+	int err;
+
+	hwpoison_kset = kset_create_and_add("hwpoison", NULL, mm_kobj);
+	if (!hwpoison_kset)
+		return -ENOMEM;
+
+	hwpoison_kobj.kset = hwpoison_kset;
+
+	err = kobject_init_and_add(&hwpoison_kobj, &hwpoison_ktype, NULL,
+				   "hwpoison");
+	if (err)
+		return -ENOMEM;
+
+	kobject_uevent(&hwpoison_kobj, KOBJ_ADD);
+
+	return 0;
 }
+
+
+static int __init hwpoison_init(void)
+{
+	return hwpoison_kobj_init();
+}
+
+static void __exit hwpoison_exit(void)
+{
+	kset_unregister(hwpoison_kset);
+}
+
+module_init(hwpoison_init);
+module_exit(hwpoison_exit);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
