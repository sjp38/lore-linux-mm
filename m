Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4254C6B0071
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 19:39:02 -0500 (EST)
MIME-Version: 1.0
Message-ID: <5076ccb7-89d1-4837-bd48-7fff3b765bd0@default>
Date: Thu, 17 Dec 2009 16:38:40 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Tmem [PATCH 5/5] (Take 3): Build Xen interface under tmem layer
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: dan.magenheimer@oracle.com, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, linux-mm@kvack.org, Rusty@rcsinet15.oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

Tmem [PATCH 5/5] (Take 3): Build Xen interface under tmem layer.

Interface kernel tmem API to a Xen hypercall implementation of tmem
that conforms to the published Transcendent Memory API.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>


 arch/x86/include/asm/xen/hypercall.h     |    8 +
 drivers/xen/Makefile                     |    1=20
 drivers/xen/tmem.c                       |   97 +++++++++++++++++++++
 include/xen/interface/tmem.h             |   43 +++++++++
 include/xen/interface/xen.h              |   22 ++++
 5 files changed, 171 insertions(+)

--- linux-2.6.32/arch/x86/include/asm/xen/hypercall.h=092009-12-02 20:51:21=
.000000000 -0700
+++ linux-2.6.32-tmem/arch/x86/include/asm/xen/hypercall.h=092009-12-10 11:=
10:17.000000000 -0700
@@ -45,6 +45,7 @@
 #include <xen/interface/xen.h>
 #include <xen/interface/sched.h>
 #include <xen/interface/physdev.h>
+#include <xen/interface/tmem.h>
=20
 /*
  * The hypercall asms have to meet several constraints:
@@ -417,6 +418,13 @@ HYPERVISOR_nmi_op(unsigned long op, unsi
 =09return _hypercall2(int, nmi_op, op, arg);
 }
=20
+static inline int
+HYPERVISOR_tmem_op(
+=09struct tmem_op *op)
+{
+=09return _hypercall1(int, tmem_op, op);
+}
+
 static inline void
 MULTI_fpu_taskswitch(struct multicall_entry *mcl, int set)
 {
--- linux-2.6.32/drivers/xen/Makefile=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/drivers/xen/Makefile=092009-12-10 11:10:17.000000000 =
-0700
@@ -6,6 +6,7 @@ CFLAGS_features.o=09=09=09:=3D $(nostackp)
=20
 obj-$(CONFIG_HOTPLUG_CPU)=09+=3D cpu_hotplug.o
 obj-$(CONFIG_XEN_XENCOMM)=09+=3D xencomm.o
+obj-$(CONFIG_TMEM)=09=09+=3D tmem.o
 obj-$(CONFIG_XEN_BALLOON)=09+=3D balloon.o
 obj-$(CONFIG_XEN_DEV_EVTCHN)=09+=3D evtchn.o
 obj-$(CONFIG_XENFS)=09=09+=3D xenfs/
--- linux-2.6.32/include/xen/interface/tmem.h=091969-12-31 17:00:00.0000000=
00 -0700
+++ linux-2.6.32-tmem/include/xen/interface/tmem.h=092009-12-10 11:10:17.00=
0000000 -0700
@@ -0,0 +1,43 @@
+/*
+ * include/xen/interface/tmem.h
+ *
+ * Interface to Xen implementation of transcendent memory
+ *
+ * Copyright (C) 2009 Dan Magenheimer, Oracle Corp.
+ */
+
+#include <xen/interface/xen.h>
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
+/* Subops for HYPERVISOR_tmem_op(TMEM_CONTROL) */
+#define TMEMC_THAW                 0
+#define TMEMC_FREEZE               1
+#define TMEMC_FLUSH                2
+#define TMEMC_DESTROY              3
+#define TMEMC_LIST                 4
+#define TMEMC_SET_WEIGHT           5
+#define TMEMC_SET_CAP              6
+#define TMEMC_SET_COMPRESS         7
+
+/* Bits for HYPERVISOR_tmem_op(TMEM_NEW_POOL) */
+#define TMEM_POOL_PERSIST          1
+#define TMEM_POOL_SHARED           2
+#define TMEM_POOL_PAGESIZE_SHIFT   4
+#define TMEM_POOL_PAGESIZE_MASK  0xf
+#define TMEM_POOL_VERSION_SHIFT   24
+#define TMEM_POOL_VERSION_MASK  0xff
+
+/* Special errno values */
+#define EFROZEN                 1000
+#define EEMPTY                  1001
--- linux-2.6.32/include/xen/interface/xen.h=092009-12-02 20:51:21.00000000=
0 -0700
+++ linux-2.6.32-tmem/include/xen/interface/xen.h=092009-12-10 11:10:17.000=
000000 -0700
@@ -58,6 +58,7 @@
 #define __HYPERVISOR_event_channel_op     32
 #define __HYPERVISOR_physdev_op           33
 #define __HYPERVISOR_hvm_op               34
+#define __HYPERVISOR_tmem_op              38
=20
 /* Architecture-specific hypercall definitions. */
 #define __HYPERVISOR_arch_0               48
@@ -461,6 +462,27 @@ typedef uint8_t xen_domain_handle_t[16];
 #define __mk_unsigned_long(x) x ## UL
 #define mk_unsigned_long(x) __mk_unsigned_long(x)
=20
+struct tmem_op {
+=09uint32_t cmd;
+=09int32_t pool_id;
+=09union {
+=09=09struct {  /* for cmd =3D=3D TMEM_NEW_POOL */
+=09=09=09uint64_t uuid[2];
+=09=09=09uint32_t flags;
+=09=09} new;
+=09=09struct {
+=09=09=09uint64_t object;
+=09=09=09uint32_t index;
+=09=09=09uint32_t tmem_offset;
+=09=09=09uint32_t pfn_offset;
+=09=09=09uint32_t len;
+=09=09=09GUEST_HANDLE(void) gmfn; /* guest machine page frame */
+=09=09} gen;
+=09} u;
+};
+typedef struct tmem_op tmem_op_t;
+DEFINE_GUEST_HANDLE_STRUCT(tmem_op_t);
+
 #else /* __ASSEMBLY__ */
=20
 /* In assembly code we cannot use C numeric constant suffixes. */
--- linux-2.6.32/drivers/xen/tmem.c=091969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.32-tmem/drivers/xen/tmem.c=092009-12-10 11:10:17.000000000 -0=
700
@@ -0,0 +1,97 @@
+/*
+ * Xen implementation for transcendent memory (tmem)
+ *
+ * Dan Magenheimer <dan.magenheimer@oracle.com> 2009
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/tmem.h>
+#include <xen/interface/xen.h>
+#include <xen/interface/tmem.h>
+#include <asm/xen/hypercall.h>
+#include <asm/xen/page.h>
+
+static inline int xen_tmem_op(u32 tmem_cmd, u32 tmem_pool, u64 object,
+=09u32 index, unsigned long gmfn, u32 tmem_offset, u32 pfn_offset, u32 len=
)
+{
+=09struct tmem_op op;
+=09int rc =3D 0;
+
+=09op.cmd =3D tmem_cmd;
+=09op.pool_id =3D tmem_pool;
+=09op.u.gen.object =3D object;
+=09op.u.gen.index =3D index;
+=09op.u.gen.tmem_offset =3D tmem_offset;
+=09op.u.gen.pfn_offset =3D pfn_offset;
+=09op.u.gen.len =3D len;
+=09set_xen_guest_handle(op.u.gen.gmfn, (void *)gmfn);
+=09rc =3D HYPERVISOR_tmem_op(&op);
+=09return rc;
+}
+
+static int xen_tmem_new_pool(struct tmem_pool_uuid uuid, u32 flags)
+{
+=09struct tmem_op op;
+=09int rc =3D 0;
+
+=09flags |=3D (PAGE_SHIFT - 12) << TMEM_POOL_PAGESIZE_SHIFT;
+=09op.cmd =3D TMEM_NEW_POOL;
+=09op.u.new.uuid[0] =3D uuid.uuid_lo;
+=09op.u.new.uuid[1] =3D uuid.uuid_hi;
+=09op.u.new.flags =3D flags;
+=09rc =3D HYPERVISOR_tmem_op(&op);
+=09return rc;
+}
+
+static int xen_tmem_put_page(u32 pool_id, u64 object, u32 index,
+=09unsigned long pfn)
+{
+=09unsigned long gmfn =3D pfn_to_mfn(pfn);
+
+=09return xen_tmem_op(TMEM_PUT_PAGE, pool_id, object, index,
+=09=09gmfn, 0, 0, 0);
+}
+
+static int xen_tmem_get_page(u32 pool_id, u64 object, u32 index,
+=09unsigned long pfn)
+{
+=09unsigned long gmfn =3D pfn_to_mfn(pfn);
+
+=09return xen_tmem_op(TMEM_GET_PAGE, pool_id, object, index,
+=09=09gmfn, 0, 0, 0);
+}
+
+static int xen_tmem_flush_page(u32 pool_id, u64 object, u32 index)
+{
+=09return xen_tmem_op(TMEM_FLUSH_PAGE, pool_id, object, index,
+=09=090, 0, 0, 0);
+}
+
+static int xen_tmem_flush_object(u32 pool_id, u64 object)
+{
+=09return xen_tmem_op(TMEM_FLUSH_OBJECT, pool_id, object, 0, 0, 0, 0, 0);
+}
+
+static int xen_tmem_destroy_pool(u32 pool_id)
+{
+=09return xen_tmem_op(TMEM_DESTROY_POOL, pool_id, 0, 0, 0, 0, 0, 0);
+}
+
+static struct tmem_ops xen_tmem_ops =3D {
+=09.new_pool =3D xen_tmem_new_pool,
+=09.put_page =3D xen_tmem_put_page,
+=09.get_page =3D xen_tmem_get_page,
+=09.flush_page =3D xen_tmem_flush_page,
+=09.flush_object =3D xen_tmem_flush_object,
+=09.destroy_pool =3D xen_tmem_destroy_pool
+};
+
+static int __init xen_tmem_init(void)
+{
+=09tmem_set_ops(&xen_tmem_ops);
+=09return 0;
+}
+core_initcall(xen_tmem_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
