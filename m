Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id B28DA6B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 07:17:49 -0400 (EDT)
Date: Fri, 15 Mar 2013 20:04:11 +0900
From: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Subject: Re: [PATCH v2 7/8] mm, vmalloc: export vmap_area_list, instead of
 vmlist
Message-Id: <20130315200411.59edc3c7af0ffafdef2a9d4b@mxc.nes.nec.co.jp>
In-Reply-To: <87k3pbsst7.fsf@xmission.com>
References: <1363156381-2881-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1363156381-2881-8-git-send-email-iamjoonsoo.kim@lge.com>
	<87k3pbsst7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com, ebiederm@xmission.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, anderson@redhat.com, vgoyal@redhat.com, lliubbo@gmail.com, penberg@kernel.org, kexec@lists.infradead.org, js1304@gmail.com

Hello,

On Tue, 12 Mar 2013 23:43:48 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > From: Joonsoo Kim <js1304@gmail.com>
> >
> > Although our intention is to unexport internal structure entirely,
> > but there is one exception for kexec. kexec dumps address of vmlist
> > and makedumpfile uses this information.
> >
> > We are about to remove vmlist, then another way to retrieve information
> > of vmalloc layer is needed for makedumpfile. For this purpose,
> > we export vmap_area_list, instead of vmlist.
> 
> That seems entirely reasonable to me.  Usage by kexec should not limit
> the evoluion of the kernel especially usage by makedumpfile.
> 
> Atsushi Kumagai can you make makedumpfile work with this change?

Sure! I'm going to work with this change in the next version.
But, I noticed that necessary information is missed in this patch,
and sorry for too late reply.

Both OFFSET(vmap_area.va_start) and OFFSET(vmap_area.list) are
necessary to get vmalloc_start value from vmap_area_list, but
they aren't exported in this patch.
I understand that the policy of this patch series "to unexport
internal structure entirely", although the information is necessary
for makedumpfile.

Additionally, OFFSET(vm_struct.addr) is no longer used, should be
removed. It was added for the same purpose as vmlist in the commit
below. 

  commit acd99dbf54020f5c80b9aa2f2ea86f43cb285b02
  Author: Ken'ichi Ohmichi <oomichi@mxs.nes.nec.co.jp>
  Date:   Sat Oct 18 20:28:30 2008 -0700

      kdump: add vmlist.addr to vmcoreinfo for x86 vmalloc translation.

To sum it up, I would like to push the patch below.

Thanks
Atsushi Kumagai

--
From: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Date: Fri, 15 Mar 2013 14:19:28 +0900
Subject: [PATCH] kexec, vmalloc: Export additional information of
 vmalloc layer.

Now, vmap_area_list is exported as VMCOREINFO for makedumpfile
to get the start address of vmalloc region (vmalloc_start).
The address which contains vmalloc_start value is represented as
below:

  vmap_area_list.next - OFFSET(vmap_area.list) + OFFSET(vmap_area.va_start)

However, both OFFSET(vmap_area.va_start) and OFFSET(vmap_area.list)
aren't exported as VMCOREINFO.

So, this patch exports them externally with small cleanup.

Signed-off-by: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
---
 include/linux/vmalloc.h | 12 ++++++++++++
 kernel/kexec.c          |  3 ++-
 mm/vmalloc.c            | 11 -----------
 3 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 8a25f90..62e0354 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -4,6 +4,7 @@
 #include <linux/spinlock.h>
 #include <linux/init.h>
 #include <asm/page.h>		/* pgprot_t */
+#include <linux/rbtree.h>
 
 struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 
@@ -35,6 +36,17 @@ struct vm_struct {
 	const void		*caller;
 };
 
+struct vmap_area {
+	unsigned long va_start;
+	unsigned long va_end;
+	unsigned long flags;
+	struct rb_node rb_node;         /* address sorted rbtree */
+	struct list_head list;          /* address sorted list */
+	struct list_head purge_list;    /* "lazy purge" list */
+	struct vm_struct *vm;
+	struct rcu_head rcu_head;
+};
+
 /*
  *	Highlevel APIs for driver use
  */
diff --git a/kernel/kexec.c b/kernel/kexec.c
index d9bfc6c..5db0148 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -1527,7 +1527,8 @@ static int __init crash_save_vmcoreinfo_init(void)
 	VMCOREINFO_OFFSET(free_area, free_list);
 	VMCOREINFO_OFFSET(list_head, next);
 	VMCOREINFO_OFFSET(list_head, prev);
-	VMCOREINFO_OFFSET(vm_struct, addr);
+	VMCOREINFO_OFFSET(vmap_area, va_start);
+	VMCOREINFO_OFFSET(vmap_area, list);
 	VMCOREINFO_LENGTH(zone.free_area, MAX_ORDER);
 	log_buf_kexec_setup();
 	VMCOREINFO_LENGTH(free_area.free_list, MIGRATE_TYPES);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 151da8a..72043d6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -249,17 +249,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define VM_LAZY_FREEING	0x02
 #define VM_VM_AREA	0x04
 
-struct vmap_area {
-	unsigned long va_start;
-	unsigned long va_end;
-	unsigned long flags;
-	struct rb_node rb_node;		/* address sorted rbtree */
-	struct list_head list;		/* address sorted list */
-	struct list_head purge_list;	/* "lazy purge" list */
-	struct vm_struct *vm;
-	struct rcu_head rcu_head;
-};
-
 static DEFINE_SPINLOCK(vmap_area_lock);
 /* Export for kexec only */
 LIST_HEAD(vmap_area_list);
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
