Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE8666B0005
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 17:36:03 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id k10-v6so988973ljc.4
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:36:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p20-v6sor851409lfp.41.2018.10.23.14.36.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 14:36:01 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 03/17] prmem: vmalloc support for dynamic allocation
Date: Wed, 24 Oct 2018 00:34:50 +0300
Message-Id: <20181023213504.28905-4-igor.stoppa@huawei.com>
In-Reply-To: <20181023213504.28905-1-igor.stoppa@huawei.com>
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chintan Pandya <cpandya@codeaurora.org>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Prepare vmalloc for:
- tagging areas used for dynamic allocation of protected memory
- supporting various tags, related to the property that an area might have
- extrapolating the pool containing a given area
- chaining the areas in each pool
- extrapolating the area containing a given memory address

NOTE:
Since there is a list_head structure that is used only when disposing of
the allocation (the field purge_list), there are two pointers for the take,
before it comes the time of freeing the allocation.
To avoid increasing the size of the vmap_area structure, instead of
using a standard doubly linked list for tracking the chain of
vmap_areas, only one pointer is spent for this purpose, in a single
linked list, while the other is used to provide a direct connection to the
parent pool.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
CC: Michal Hocko <mhocko@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Chintan Pandya <cpandya@codeaurora.org>
CC: Joe Perches <joe@perches.com>
CC: "Luis R. Rodriguez" <mcgrof@kernel.org>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Kate Stewart <kstewart@linuxfoundation.org>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: Philippe Ombredanne <pombredanne@nexb.com>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 include/linux/vmalloc.h | 12 +++++++++++-
 mm/vmalloc.c            |  2 +-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..4d14a3b8089e 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -21,6 +21,9 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+#define VM_PMALLOC		0x00000100	/* pmalloc area - see docs */
+#define VM_PMALLOC_WR		0x00000200	/* pmalloc write rare area */
+#define VM_PMALLOC_PROTECTED	0x00000400	/* pmalloc protected area */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
@@ -48,7 +51,13 @@ struct vmap_area {
 	unsigned long flags;
 	struct rb_node rb_node;         /* address sorted rbtree */
 	struct list_head list;          /* address sorted list */
-	struct llist_node purge_list;    /* "lazy purge" list */
+	union {
+		struct llist_node purge_list;    /* "lazy purge" list */
+		struct {
+			struct vmap_area *next;
+			struct pmalloc_pool *pool;
+		};
+	};
 	struct vm_struct *vm;
 	struct rcu_head rcu_head;
 };
@@ -134,6 +143,7 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
 					const void *caller);
 extern struct vm_struct *remove_vm_area(const void *addr);
 extern struct vm_struct *find_vm_area(const void *addr);
+extern struct vmap_area *find_vmap_area(unsigned long addr);
 
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page **pages);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a728fc492557..15850005fea5 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -742,7 +742,7 @@ static void free_unmap_vmap_area(struct vmap_area *va)
 	free_vmap_area_noflush(va);
 }
 
-static struct vmap_area *find_vmap_area(unsigned long addr)
+struct vmap_area *find_vmap_area(unsigned long addr)
 {
 	struct vmap_area *va;
 
-- 
2.17.1
