Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 564E06B005A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:17:29 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <e5a93cf7-c24c-4bfe-bc4c-c24eb8e0290d@default>
Date: Tue, 7 Jul 2009 09:18:18 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC PATCH 1/4] (Take 2): tmem: Core API between kernel and tmem
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Tmem [PATCH 1/4] (Take 2): Core API between kernel and tmem

Declares tmem_ops accessors and initializes them to be no-ops
(returning -ENOSYS).  By itself, this API is useless; it requires
a layer such as precache and/or preswap (or similar) on top to
make use of the API and a layer below to declare non-no-op tmem
accessors that interface to a tmem implementation (e.g. Xen hypercalls).
(Many thanks to Jeremy Fitzhardinge for suggesting this approach.)

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>


 Documentation/transcendent-memory.txt    |  175 +++++++++++++++++++++
 include/linux/tmem.h                     |   88 ++++++++++
 mm/Kconfig                               |   10 +
 mm/Makefile                              |    1=20
 mm/tmem.c                                |   62 +++++++
 5 files changed, 336 insertions(+)

--- linux-2.6.30/include/linux/tmem.h=091969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.30-tmem/include/linux/tmem.h=092009-06-23 14:37:24.000000000 =
-0600
@@ -0,0 +1,88 @@
+/*
+ * linux/tmem.h
+ *
+ * Interface to transcendent memory
+ *
+ * Copyright (C) 2008,2009 Dan Magenheimer, Oracle Corp.
+ */
+
+#include <linux/errno.h>
+
+struct tmem_pool_uuid {
+=09u64 uuid_lo;
+=09u64 uuid_hi;
+};
+
+#define TMEM_POOL_PRIVATE_UUID=09{ 0, 0 }
+
+struct tmem_ops {
+=09int (*new_pool)(struct tmem_pool_uuid uuid, u32 flags);
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
+extern void tmem_set_ops(struct tmem_ops *ops);
+
+/* flags for tmem_ops.new_pool */
+#define TMEM_POOL_PERSIST          1
+#define TMEM_POOL_SHARED           2
+
+static inline int tmem_new_pool(struct tmem_pool_uuid uuid, u32 flags)
+{
+=09int ret =3D -ENOSYS;
+#ifdef CONFIG_TMEM
+=09ret =3D (*tmem_ops->new_pool)(uuid, flags);
+#endif
+=09return ret;
+}
+
+static inline int tmem_put_page(u32 pool_id, u64 object, u32 index,
+=09unsigned long gmfn)
+{
+=09int ret =3D -ENOSYS;
+#ifdef CONFIG_TMEM
+=09ret =3D (*tmem_ops->put_page)(pool_id, object, index, gmfn);
+#endif
+=09return ret;
+}
+
+static inline int tmem_get_page(u32 pool_id, u64 object, u32 index,
+=09unsigned long gmfn)
+{
+=09int ret =3D -ENOSYS;
+#ifdef CONFIG_TMEM
+=09ret =3D (*tmem_ops->get_page)(pool_id, object, index, gmfn);
+#endif
+=09return ret;
+}
+
+static inline int tmem_flush_page(u32 pool_id, u64 object, u32 index)
+{
+=09int ret =3D -ENOSYS;
+#ifdef CONFIG_TMEM
+=09ret =3D (*tmem_ops->flush_page)(pool_id, object, index);
+#endif
+=09return ret;
+}
+
+static inline int tmem_flush_object(u32 pool_id, u64 object)
+{
+=09int ret =3D -ENOSYS;
+#ifdef CONFIG_TMEM
+=09ret =3D (*tmem_ops->flush_object)(pool_id, object);
+#endif
+=09return ret;
+}
+
+static inline int tmem_destroy_pool(u32 pool_id)
+{
+=09int ret =3D -ENOSYS;
+#ifdef CONFIG_TMEM
+=09ret =3D (*tmem_ops->destroy_pool)(pool_id);
+#endif
+=09return ret;
+}
--- linux-2.6.30/mm/tmem.c=091969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.30-tmem/mm/tmem.c=092009-06-24 09:54:05.000000000 -0600
@@ -0,0 +1,62 @@
+/*
+ * Default implementation for transcendent memory (tmem)
+ *
+ * Copyright (C) 2008, 2009 Dan Magenheimer, Oracle Corp.
+ */
+
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/tmem.h>
+#include <linux/bug.h>
+
+static int default_tmem_new_pool(struct tmem_pool_uuid uuid, u32 flags)
+{
+=09return -ENOSYS;
+}
+
+static int default_tmem_put_page(u32 pool_id, u64 object, u32 index,
+=09unsigned long gmfn)
+{
+=09return -ENOSYS;
+}
+
+static int default_tmem_get_page(u32 pool_id, u64 object, u32 index,
+=09unsigned long gmfn)
+{
+=09return -ENOSYS;
+}
+
+static int default_tmem_flush_page(u32 pool_id, u64 object, u32 index)
+{
+=09return -ENOSYS;
+}
+
+static int default_tmem_flush_object(u32 pool_id, u64 object)
+{
+=09return -ENOSYS;
+}
+
+static int default_tmem_destroy_pool(u32 pool_id)
+{
+=09return -ENOSYS;
+}
+
+static struct tmem_ops default_tmem_ops =3D {
+=09.new_pool =3D default_tmem_new_pool,
+=09.put_page =3D default_tmem_put_page,
+=09.get_page =3D default_tmem_get_page,
+=09.flush_page =3D default_tmem_flush_page,
+=09.flush_object =3D default_tmem_flush_object,
+=09.destroy_pool =3D default_tmem_destroy_pool
+};
+
+struct tmem_ops *tmem_ops =3D &default_tmem_ops;
+
+void __init tmem_set_ops(struct tmem_ops *ops)
+{
+=09/* should only ever be set once */
+=09WARN_ON(tmem_ops !=3D &default_tmem_ops);
+
+=09tmem_ops =3D ops;
+}
--- linux-2.6.30/mm/Kconfig=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem-tmem/mm/Kconfig=092009-07-06 16:36:31.000000000 -0600
@@ -253,3 +253,13 @@ config NOMMU_INITIAL_TRIM_EXCESS
 =09  of 1 says that all excess pages should be trimmed.
=20
 =09  See Documentation/nommu-mmap.txt for more information.
+
+#
+# support for transcendent memory
+#
+config TMEM
+=09bool "Transcendent memory support"
+=09help
+=09  In a virtualized environment, allows unused and underutilized
+=09  system physical memory to be made accessible through a narrow
+=09  well-defined page-copy-based API.
--- linux-2.6.30/mm/Makefile=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem-tmem/mm/Makefile=092009-07-06 16:36:52.000000000 -060=
0
@@ -16,6 +16,7 @@ obj-y=09=09=09:=3D bootmem.o filemap.o mempool.o
 obj-$(CONFIG_PROC_PAGE_MONITOR) +=3D pagewalk.o
 obj-$(CONFIG_BOUNCE)=09+=3D bounce.o
 obj-$(CONFIG_SWAP)=09+=3D page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_TMEM)=09+=3D tmem.o
 obj-$(CONFIG_HAS_DMA)=09+=3D dmapool.o
 obj-$(CONFIG_HUGETLBFS)=09+=3D hugetlb.o
 obj-$(CONFIG_NUMA) =09+=3D mempolicy.o
--- linux-2.6.30/Documentation/transcendent-memory.txt=091969-12-31 17:00:0=
0.000000000 -0700
+++ linux-2.6.30-tmem/Documentation/transcendent-memory.txt=092009-07-07 10=
:03:18.000000000 -0600
@@ -0,0 +1,175 @@
+Normal memory is directly addressable by the kernel, of a known
+normally-fixed size, synchronously accessible, and persistent (though
+not across a reboot).
+
+What if there was a class of memory that is of unknown and dynamically
+variable size, is addressable only indirectly by the kernel, can be
+configured either as persistent or as "ephemeral" (meaning it will be
+around for awhile, but might disappear without warning), and is still
+fast enough to be synchronously accessible?
+
+We call this latter class "transcendent memory" and it provides an
+interesting opportunity to more efficiently utilize RAM in a virtualized
+environment.  However this "memory but not really memory" may also have
+applications in NON-virtualized environments, such as hotplug-memory
+deletion, SSDs, and page cache compression.  Others have suggested ideas
+such as allowing use of highmem memory without a highmem kernel, or use
+of spare video memory.
+
+Transcendent memory, or "tmem" for short, provides a well-defined API to
+access this unusual class of memory.  (A summary of the API is provided
+below.)  The basic operations are page-copy-based and use a flexible
+object-oriented addressing mechanism.  Tmem assumes that some "privileged
+entity" is capable of executing tmem requests and storing pages of data;
+this entity is currently a hypervisor and operations are performed via
+hypercalls, but the entity could be a kernel policy, or perhaps a
+"memory node" in a cluster of blades connected by a high-speed
+interconnect such as hypertransport or QPI.
+
+Since tmem is not directly accessible and because page copying is done
+to/from physical pageframes, it more suitable for in-kernel memory needs
+than for userland applications.  However, there may be yet undiscovered
+userland possibilities.
+
+With the tmem concept outlined vaguely and its broader potential hinted,
+we will overview two existing examples of how tmem can be used by the
+kernel.
+
+"Precache" can be thought of as a page-granularity victim cache for clean
+pages that the kernel's pageframe replacement algorithm (PFRA) would like
+to keep around, but can't since there isn't enough memory.   So when the
+PFRA "evicts" a page, it first puts it into the precache via a call to
+tmem.  And any time a filesystem reads a page from disk, it first attempts
+to get the page from precache.  If it's there, a disk access is eliminated=
.
+If not, the filesystem just goes to the disk like normal.  Precache is
+"ephemeral" so whether a page is kept in precache (between the "put" and
+the "get") is dependent on a number of factors that are invisible to
+the kernel.
+
+"Preswap" IS persistent, but for various reasons may not always be
+available for use, again due to factors that may not be visible to the
+kernel (but, briefly, if the kernel is being "good" and has shared its
+resources nicely, then it will be able to use preswap, else it will not).
+Once a page is put, a get on the page will always succeed.  So when the
+kernel finds itself in a situation where it needs to swap out a page, it
+first attempts to use preswap.  If the put works, a disk write and
+(usually) a disk read are avoided.  If it doesn't, the page is written
+to swap as usual.  Unlike precache, whether a page is stored in preswap
+vs swap is recorded in kernel data structures, so when a page needs to
+be fetched, the kernel does a get if it is in preswap and reads from
+swap if it is not in preswap.
+
+Both precache and preswap may be optionally compressed, trading off 2x
+space reduction vs 10x performance for access.  Precache also has a
+sharing feature, which allows different nodes in a "virtual cluster"
+to share a local page cache.
+
+Tmem has some similarity to IBM's Collaborative Memory Management, but
+creates more of a partnership between the kernel and the "privileged
+entity" and is not very invasive.  Tmem may be applicable for KVM and
+containers; there is some disagreement on the extent of its value.
+Tmem is highly complementary to ballooning (aka page granularity hot
+plug) and memory deduplication (aka transparent content-based page
+sharing) but still has value when neither are present.
+
+Performance is difficult to quantify because some benchmarks respond
+very favorably to increases in memory and tmem may do quite well on
+those, depending on how much tmem is available which may vary widely
+and dynamically, depending on conditions completely outside of the
+system being measured.  Ideas on how best to provide useful metrics
+would be appreciated.
+
+Tmem is now supported in Xen's unstable tree (targeted for the Xen 3.5
+release) and in Xen's Linux 2.6.18-xen source tree.  Again, Xen is not
+necessarily a requirement, but currently provides the only existing
+implementation of tmem.
+
+Lots more information about tmem can be found at:
+http://oss.oracle.com/projects/tmem and there will be
+a talk about it on the first day of Linux Symposium in July 2009.
+Tmem is the result of a group effort, including Dan Magenheimer,
+Chris Mason, Dave McCracken, Kurt Hackel and Zhigang Wang, with helpful
+input from Jeremy Fitzhardinge, Keir Fraser, Ian Pratt, Sunil Mushran,
+Joel Becker, and Jan Beulich.
+
+THE TRANSCENDENT MEMORY API
+
+Transcendent memory is made up of a set of pools.  Each pool is made
+up of a set of objects.  And each object contains a set of pages.
+The combination of a 32-bit pool id, a 64-bit object id, and a 32-bit
+page id, uniquely identify a page of tmem data, and this tuple is called
+a "handle." Commonly, the three parts of a handle are used to address
+a filesystem, a file within that filesystem, and a page within that file;
+however an OS can use any values as long as they uniquely identify
+a page of data.
+
+When a tmem pool is created, it is given certain attributes: It can
+be private or shared, and it can be persistent or ephemeral.  Each
+combination of these attributes provides a different set of useful
+functionality and also defines a slightly different set of semantics
+for the various operations on the pool.  Other pool attributes include
+the size of the page and a version number.
+
+Once a pool is created, operations are performed on the pool.  Pages
+are copied between the OS and tmem and are addressed using a handle.
+Pages and/or objects may also be flushed from the pool.  When all
+operations are completed, a pool can be destroyed.
+
+The specific tmem functions are called in Linux through a set of=20
+accessor functions:
+
+int (*new_pool)(struct tmem_pool_uuid uuid, u32 flags);
+int (*destroy_pool)(u32 pool_id);
+int (*put_page)(u32 pool_id, u64 object, u32 index, unsigned long pfn);
+int (*get_page)(u32 pool_id, u64 object, u32 index, unsigned long pfn);
+int (*flush_page)(u32 pool_id, u64 object, u32 index);
+int (*flush_object)(u32 pool_id, u64 object);
+
+The new_pool accessor creates a new pool and returns a pool id
+which is a non-negative 32-bit integer.  If the flags parameter
+specifies that the pool is to be shared, the uuid is a 128-bit "shared
+secret" else it is ignored.  The destroy_pool accessor destroys the pool.
+(Note: shared pools are not supported until security implications
+are better understood.)
+
+The put_page accessor copies a page of data from the specified pageframe
+and associates it with the specified handle.
+
+The get_page accessor looks up a page of data in tmem associated with
+the specified handle and, if found, copies it to the specified pageframe.
+
+The flush_page accessor ensures that subsequent gets of a page with
+the specified handle will fail.  The flush_object accessor ensures
+that subsequent gets of any page matching the pool id and object
+will fail.
+
+There are many subtle but critical behaviors for get_page and put_page:
+- Any put_page (with one notable exception) may be rejected and the client
+  must be prepared to deal with that failure.  A put_page copies, NOT move=
s,
+  data; that is the data exists in both places.  Linux is responsible for
+  destroying or overwriting its own copy, or alternately managing any
+  coherency between the copies.
+- Every page successfully put to a persistent pool must be found by a
+  subsequent get_page that specifies the same handle.  A page successfully
+  put to an ephemeral pool has an indeterminate lifetime and even an
+  immediately subsequent get_page may fail.
+- A get_page to a private pool is destructive, that is it behaves as if
+  the get_page were atomically followed by a flush_page.  A get_page
+  to a shared pool is non-destructive.  A flush_page behaves just like
+  a get_page to a private pool except the data is thrown away.
+- Put-put-get coherency is guaranteed.  For example, after the sequence:
+        put_page(ABC,D1);
+        put_page(ABC,D2);
+        get_page(ABC,E)
+  E may never contain the data from D1.  However, even for a persistent
+  pool, the get_page may fail if the second put_page indicates failure.
+- Get-get coherency is guaranteed.  For example, in the sequence:
+        put_page(ABC,D);
+        get_page(ABC,E1);
+        get_page(ABC,E2)
+  if the first get_page fails, the second must also fail.
+- A tmem implementation provides no serialization guarantees (e.g. to
+  an SMP Linux).  So if different Linux threads are putting and flushing
+  the same page, the results are indeterminate.
+  guaranteed and must be synchronized by Linux.
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
