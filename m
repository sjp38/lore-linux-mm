Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8786B005A
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 21:34:37 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b6ebd2d7-7bac-4aa0-8910-991304979fb9@default>
Date: Fri, 19 Jun 2009 18:35:31 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC PATCH 1/4] tmem: infrastructure for tmem layer
In-Reply-To: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- linux-2.6.30/mm/Kconfig=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/mm/Kconfig=092009-06-19 09:36:41.000000000 -0600
@@ -253,3 +253,30 @@
 =09  of 1 says that all excess pages should be trimmed.
=20
 =09  See Documentation/nommu-mmap.txt for more information.
+
+#
+# support for transcendent memory
+#
+config TMEM
+=09bool "Transcendent memory support"
+=09depends on XEN # but in future may work without XEN
+=09help
+=09  In a virtualized environment, allows unused and underutilized
+=09  system physical memory to be made accessible through a narrow
+=09  well-defined page-copy-based API.  If unsure, say Y.
+
+config PRECACHE
+=09bool "Cache clean pages in transcendent memory"
+=09depends on TMEM
+=09help
+=09  Allows the transcendent memory pool to be used to store clean
+=09  page-cache pages which, under some circumstances, will greatly
+=09  reduce paging and thus improve performance.  If unsure, say Y.
+
+config PRESWAP
+=09bool "Swap pages to transcendent memory"
+=09depends on TMEM
+=09help
+=09  Allows the transcendent memory pool to be used as a pseudo-swap
+=09  device which, under some circumstances, will greatly reduce
+=09  swapping and thus improve performance.  If unsure, say Y.
--- linux-2.6.30/mm/Makefile=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/mm/Makefile=092009-06-19 09:33:59.000000000 -0600
@@ -16,6 +16,8 @@
 obj-$(CONFIG_PROC_PAGE_MONITOR) +=3D pagewalk.o
 obj-$(CONFIG_BOUNCE)=09+=3D bounce.o
 obj-$(CONFIG_SWAP)=09+=3D page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_PRESWAP)=09+=3D preswap.o
+obj-$(CONFIG_PRECACHE)=09+=3D precache.o
 obj-$(CONFIG_HAS_DMA)=09+=3D dmapool.o
 obj-$(CONFIG_HUGETLBFS)=09+=3D hugetlb.o
 obj-$(CONFIG_NUMA) =09+=3D mempolicy.o
--- linux-2.6.30/include/linux/tmem.h=091969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.30-tmem/include/linux/tmem.h=092009-06-19 11:21:58.000000000 =
-0600
@@ -0,0 +1,22 @@
+/*
+ * linux/tmem.h
+ *
+ * Interface to transcendent memory, used by mm/precache.c and mm/preswap.=
c
+ *
+ * Copyright (C) 2008,2009 Dan Magenheimer, Oracle Corp.
+ */
+
+struct tmem_ops {
+=09int (*new_pool)(u64 uuid_lo, u64 uuid_hi, u32 flags);
+=09int (*put_page)(u32 pool_id, u64 object, u32 index, unsigned long gmfn)=
;
+=09int (*get_page)(u32 pool_id, u64 object, u32 index, unsigned long gmfn)=
;
+=09int (*flush_page)(u32 pool_id, u64 object, u32 index);
+=09int (*flush_object)(u32 pool_id, u64 object);
+=09int (*destroy_pool)(u32 pool_id);
+};
+
+extern struct tmem_ops *tmem_ops;
+
+/* flags for tmem_ops.new_pool */
+#define TMEM_POOL_PERSIST          1
+#define TMEM_POOL_SHARED           2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
