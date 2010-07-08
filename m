Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 126026006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 12:43:43 -0400 (EDT)
Date: Thu, 8 Jul 2010 09:42:08 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH] Cleancache: shim to Xen Transcendent Memory
Message-ID: <20100708164208.GA11763@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com
List-ID: <linux-mm.kvack.org>

[PATCH] Cleancache: shim to Xen Transcendent Memory

This companion patch to the cleancache V3 patchset (see
http://lkml.org/lkml/2010/6/21/411) provides one consumer
for the proposed cleancache internal kernel API.  This
user is Xen Transcendent Memory ("tmem"), supported in Xen 4.0+.
(A second user, zcache, will be posted by Nitin Gupta soon.)

This patch affects Xen directories only; while broader review
is welcome, the patch is provided primarily to answer concerns
expressed about the apparent non-existence of consumers for
the proposed cleancache patch.

Xen tmem provides "hypervisor RAM" as an ephemeral page-oriented
pseudo-RAM store for cleancache pages, shared cleancache pages,
and frontswap pages.  Tmem provides enterprise-quality concurrency,
full save/restore and live migration support, compression
and deduplication.

A presentation showing up to 8% faster performance and up to 52%
reduction in sectors read on a kernel compile workload, despite
aggressive in-kernel page reclamation ("self-ballooning") can be
found at:

http://oss.oracle.com/projects/tmem/dist/documentation/presentations/TranscendentMemoryXenSummit2010.pdf

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 arch/x86/include/asm/xen/hypercall.h     |    7 
 drivers/xen/Makefile                     |    2 
 drivers/xen/tmem.c                       |  238 +++++++++++++++++++++
 include/xen/interface/xen.h              |   20 +
 4 files changed, 266 insertions(+), 1 deletion(-)

diff -Napur linux-2.6.35-rc4/arch/x86/include/asm/xen/hypercall.h linux-2.6.35-rc4-cleancache_tmem/arch/x86/include/asm/xen/hypercall.h
--- linux-2.6.35-rc4/arch/x86/include/asm/xen/hypercall.h	2010-07-04 21:22:50.000000000 -0600
+++ linux-2.6.35-rc4-cleancache_tmem/arch/x86/include/asm/xen/hypercall.h	2010-07-07 15:37:46.000000000 -0600
@@ -417,6 +417,13 @@ HYPERVISOR_nmi_op(unsigned long op, unsi
 	return _hypercall2(int, nmi_op, op, arg);
 }
 
+static inline int
+HYPERVISOR_tmem_op(
+	struct tmem_op *op)
+{
+	return _hypercall1(int, tmem_op, op);
+}
+
 static inline void
 MULTI_fpu_taskswitch(struct multicall_entry *mcl, int set)
 {
diff -Napur linux-2.6.35-rc4/drivers/xen/Makefile linux-2.6.35-rc4-cleancache_tmem/drivers/xen/Makefile
--- linux-2.6.35-rc4/drivers/xen/Makefile	2010-07-04 21:22:50.000000000 -0600
+++ linux-2.6.35-rc4-cleancache_tmem/drivers/xen/Makefile	2010-07-07 09:38:21.000000000 -0600
@@ -1,5 +1,6 @@
 obj-y	+= grant-table.o features.o events.o manage.o
 obj-y	+= xenbus/
+obj-y	+= tmem.o
 
 nostackp := $(call cc-option, -fno-stack-protector)
 CFLAGS_features.o			:= $(nostackp)
@@ -9,4 +10,4 @@ obj-$(CONFIG_XEN_XENCOMM)	+= xencomm.o
 obj-$(CONFIG_XEN_BALLOON)	+= balloon.o
 obj-$(CONFIG_XEN_DEV_EVTCHN)	+= evtchn.o
 obj-$(CONFIG_XENFS)		+= xenfs/
-obj-$(CONFIG_XEN_SYS_HYPERVISOR)	+= sys-hypervisor.o
\ No newline at end of file
+obj-$(CONFIG_XEN_SYS_HYPERVISOR)	+= sys-hypervisor.o
diff -Napur linux-2.6.35-rc4/drivers/xen/tmem.c linux-2.6.35-rc4-cleancache_tmem/drivers/xen/tmem.c
--- linux-2.6.35-rc4/drivers/xen/tmem.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.35-rc4-cleancache_tmem/drivers/xen/tmem.c	2010-07-07 16:24:08.000000000 -0600
@@ -0,0 +1,238 @@
+/*
+ * Xen implementation for transcendent memory (tmem)
+ *
+ * Copyright (C) 2009-2010 Oracle Corp.  All rights reserved.
+ * Author: Dan Magenheimer
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/pagemap.h>
+#include <linux/cleancache.h>
+
+#include <xen/xen.h>
+#include <xen/interface/xen.h>
+#include <asm/xen/hypercall.h>
+#include <asm/xen/page.h>
+#include <asm/xen/hypervisor.h>
+
+#define TMEM_CONTROL               0
+#define TMEM_NEW_POOL              1
+#define TMEM_DESTROY_POOL          2
+#define TMEM_NEW_PAGE              3
+#define TMEM_PUT_PAGE              4
+#define TMEM_GET_PAGE              5
+#define TMEM_FLUSH_PAGE            6
+#define TMEM_FLUSH_OBJECT          7
+#define TMEM_READ                  8
+#define TMEM_WRITE                 9
+#define TMEM_XCHG                 10
+
+/* Bits for HYPERVISOR_tmem_op(TMEM_NEW_POOL) */
+#define TMEM_POOL_PERSIST          1
+#define TMEM_POOL_SHARED           2
+#define TMEM_POOL_PAGESIZE_SHIFT   4
+
+
+struct tmem_pool_uuid {
+	u64 uuid_lo;
+	u64 uuid_hi;
+};
+
+#define TMEM_POOL_PRIVATE_UUID	{ 0, 0 }
+
+/* flags for tmem_ops.new_pool */
+#define TMEM_POOL_PERSIST          1
+#define TMEM_POOL_SHARED           2
+
+/* xen tmem foundation ops/hypercalls */
+
+static inline int xen_tmem_op(u32 tmem_cmd, u32 tmem_pool, u64 object,
+	u32 index, unsigned long gmfn, u32 tmem_offset, u32 pfn_offset, u32 len)
+{
+	struct tmem_op op;
+	int rc = 0;
+
+	op.cmd = tmem_cmd;
+	op.pool_id = tmem_pool;
+	op.u.gen.object = object;
+	op.u.gen.index = index;
+	op.u.gen.tmem_offset = tmem_offset;
+	op.u.gen.pfn_offset = pfn_offset;
+	op.u.gen.len = len;
+	set_xen_guest_handle(op.u.gen.gmfn, (void *)gmfn);
+	rc = HYPERVISOR_tmem_op(&op);
+	return rc;
+}
+
+static int xen_tmem_new_pool(struct tmem_pool_uuid uuid,
+				u32 flags, unsigned long pagesize)
+{
+	struct tmem_op op;
+	int rc = 0, pageshift;
+
+	for (pageshift = 0; pagesize != 1; pageshift++)
+		pagesize >>= 1;
+	flags |= (pageshift - 12) << TMEM_POOL_PAGESIZE_SHIFT;
+	op.cmd = TMEM_NEW_POOL;
+	op.u.new.uuid[0] = uuid.uuid_lo;
+	op.u.new.uuid[1] = uuid.uuid_hi;
+	op.u.new.flags = flags;
+	rc = HYPERVISOR_tmem_op(&op);
+	return rc;
+}
+
+/* xen generic tmem ops */
+
+static int xen_tmem_put_page(u32 pool_id, u64 object, u32 index,
+	unsigned long pfn)
+{
+	unsigned long gmfn = xen_pv_domain() ? pfn_to_mfn(pfn) : pfn;
+
+	return xen_tmem_op(TMEM_PUT_PAGE, pool_id, object, index,
+		gmfn, 0, 0, 0);
+}
+
+static int xen_tmem_get_page(u32 pool_id, u64 object, u32 index,
+	unsigned long pfn)
+{
+	unsigned long gmfn = xen_pv_domain() ? pfn_to_mfn(pfn) : pfn;
+
+	return xen_tmem_op(TMEM_GET_PAGE, pool_id, object, index,
+		gmfn, 0, 0, 0);
+}
+
+static int xen_tmem_flush_page(u32 pool_id, u64 object, u32 index)
+{
+	return xen_tmem_op(TMEM_FLUSH_PAGE, pool_id, object, index,
+		0, 0, 0, 0);
+}
+
+static int xen_tmem_flush_object(u32 pool_id, u64 object)
+{
+	return xen_tmem_op(TMEM_FLUSH_OBJECT, pool_id, object, 0, 0, 0, 0, 0);
+}
+
+static int xen_tmem_destroy_pool(u32 pool_id)
+{
+	return xen_tmem_op(TMEM_DESTROY_POOL, pool_id, 0, 0, 0, 0, 0, 0);
+}
+
+int tmem_enabled;
+
+static int __init enable_tmem(char *s)
+{
+	tmem_enabled = 1;
+	return 1;
+}
+
+__setup("tmem", enable_tmem);
+
+/* cleancache ops */
+
+static void tmem_cleancache_put_page(int pool, ino_t inode, pgoff_t index,
+				     struct page *page)
+{
+	u32 ind = (u32) index;
+	unsigned long pfn = page_to_pfn(page);
+
+	if (pool < 0)
+		return;
+	if (ind != index)
+		return;
+	mb(); /* ensure page is quiescent; tmem may address it with an alias */
+	(void)xen_tmem_put_page((u32)pool, (u64)inode, ind, pfn);
+}
+
+static int tmem_cleancache_get_page(int pool, ino_t inode, pgoff_t index,
+				    struct page *page)
+{
+	u32 ind = (u32) index;
+	unsigned long pfn = page_to_pfn(page);
+	int ret;
+
+	/* translate return values to linux semantics */
+	if (pool < 0)
+		return -1;
+	if (ind != index)
+		return -1;
+	ret = xen_tmem_get_page((u32)pool, (u64)inode, ind, pfn);
+	if (ret == 1)
+		return 0;
+	else
+		return -1;
+}
+
+static void tmem_cleancache_flush_page(int pool, ino_t inode, pgoff_t index)
+{
+	u32 ind = (u32) index;
+
+	if (pool < 0)
+		return;
+	if (ind != index)
+		return;
+	(void)xen_tmem_flush_page((u32)pool, (u64)inode, ind);
+}
+
+static void tmem_cleancache_flush_inode(int pool, ino_t inode)
+{
+	if (pool < 0)
+		return;
+	(void)xen_tmem_flush_object((u32)pool, (u64)inode);
+}
+
+static void tmem_cleancache_flush_fs(int pool)
+{
+	if (pool < 0)
+		return;
+	(void)xen_tmem_destroy_pool((u32)pool);
+}
+
+static int tmem_cleancache_init_fs(size_t pagesize)
+{
+	struct tmem_pool_uuid uuid_private = TMEM_POOL_PRIVATE_UUID;
+
+	return xen_tmem_new_pool(uuid_private, 0, pagesize);
+}
+
+static int tmem_cleancache_init_shared_fs(char *uuid, size_t pagesize)
+{
+	struct tmem_pool_uuid shared_uuid;
+
+	shared_uuid.uuid_lo = *(u64 *)uuid;
+	shared_uuid.uuid_hi = *(u64 *)(&uuid[8]);
+	return xen_tmem_new_pool(shared_uuid, TMEM_POOL_SHARED, pagesize);
+}
+
+static int use_cleancache = 1;
+
+static int __init no_cleancache(char *s)
+{
+	use_cleancache = 0;
+	return 1;
+}
+
+__setup("nocleancache", no_cleancache);
+
+static int __init xen_tmem_init(void)
+{
+	if (!xen_domain())
+		return 0;
+#ifdef CONFIG_CLEANCACHE
+	if (tmem_enabled && use_cleancache) {
+		cleancache_ops.put_page = tmem_cleancache_put_page;
+		cleancache_ops.get_page = tmem_cleancache_get_page;
+		cleancache_ops.flush_page = tmem_cleancache_flush_page;
+		cleancache_ops.flush_inode = tmem_cleancache_flush_inode;
+		cleancache_ops.flush_fs = tmem_cleancache_flush_fs;
+		cleancache_ops.init_shared_fs = tmem_cleancache_init_shared_fs;
+		cleancache_ops.init_fs = tmem_cleancache_init_fs;
+		printk(KERN_INFO "cleancache enabled, RAM provided by "
+				 "Xen Transcendent Memory\n");
+	}
+#endif
+	return 0;
+}
+
+module_init(xen_tmem_init)
diff -Napur linux-2.6.35-rc4/include/xen/interface/xen.h linux-2.6.35-rc4-cleancache_tmem/include/xen/interface/xen.h
--- linux-2.6.35-rc4/include/xen/interface/xen.h	2010-07-04 21:22:50.000000000 -0600
+++ linux-2.6.35-rc4-cleancache_tmem/include/xen/interface/xen.h	2010-07-07 16:24:06.000000000 -0600
@@ -58,6 +58,7 @@
 #define __HYPERVISOR_event_channel_op     32
 #define __HYPERVISOR_physdev_op           33
 #define __HYPERVISOR_hvm_op               34
+#define __HYPERVISOR_tmem_op              38
 
 /* Architecture-specific hypercall definitions. */
 #define __HYPERVISOR_arch_0               48
@@ -461,6 +462,25 @@ typedef uint8_t xen_domain_handle_t[16];
 #define __mk_unsigned_long(x) x ## UL
 #define mk_unsigned_long(x) __mk_unsigned_long(x)
 
+struct tmem_op {
+	uint32_t cmd;
+	int32_t pool_id;
+	union {
+		struct {  /* for cmd == TMEM_NEW_POOL */
+			uint64_t uuid[2];
+			uint32_t flags;
+		} new;
+		struct {
+			uint64_t object;
+			uint32_t index;
+			uint32_t tmem_offset;
+			uint32_t pfn_offset;
+			uint32_t len;
+			GUEST_HANDLE(void) gmfn; /* guest machine page frame */
+		} gen;
+	} u;
+};
+
 #else /* __ASSEMBLY__ */
 
 /* In assembly code we cannot use C numeric constant suffixes. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
