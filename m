Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 098126B0081
	for <linux-mm@kvack.org>; Fri, 18 May 2012 16:42:24 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so3360915qcs.14
        for <linux-mm@kvack.org>; Fri, 18 May 2012 13:42:24 -0700 (PDT)
Date: Fri, 18 May 2012 16:42:12 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: [GIT] (frontswap.v16-tag)
Message-ID: <20120518204211.GA18571@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, riel@redhat.com, chris.mason@oracle.com, matthew@wil.cx, ngupta@vflare.org, hannes@cmpxchg.org, hughd@google.com, sjenning@linux.vnet.ibm.com, JBeulich@novell.com, dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org

Hey Linus,

Last time this patch was proposed for a merge a big technical discussion
came about (https://lkml.org/lkml/2011/10/27/206), and also about proper
linux-next procedures, how to deal with patches that distros are carrying,
some poems, and some heated discussion. Then at this year LFS/MM this
topic was proposed and the discussion was much more mellow (I wasn't there
but that is what I got from Dan's email). Feeling reinvigorated I've posted
these patches (http://lwn.net/Articles/493807/) on linux-mm but got no
comments back. In the prior reviews the issues were not with the hooks this
patch proposes but rather with the backends - and a couple of defects
in one backend (zcache - which we hope to promote from staging and to be
enabled by default) were identified and are being addressed.

There are three backends - two in staging and one in drivers/xen/tmem.c.
I am proposing this patch set that introduces the hooks for the
existing drivers and lays the foundation to emerge the ones in staging.
The functions are _not_ to be set in stone - I think as folks walk
through the zcache, ramster, and kvm-tmem (not yet in staging) TODOs,
there will be modifications and enhancements.

Not many - and mostly it will be in terms of figuring out what kind
of pages should be sent to the backends (or the backends telling
frontswap to stop sending).

Oracle and SUSE are both carrying these set of patches to allow
users better memory utilization. We found that irregardless of how much
memory the customers have (1GB up to 1TB), they still want more and
more memory in their guests. The frontswap is the ying-yang to the 
cleancache (which allows de-duplication on the filesystem layer of various
guests) - but does it on the swap pages. Depending on the backend
it allows de-duplication of swap pages (and compression). The zcache
is a backend that can run in embedded baremetal cases can compress
swap-pages benefiting even tiny embedded devices up to enterprise
server machines.

The git tree is here:

git://git.kernel.org/pub/scm/linux/kernel/git/konrad/mm.git stable/frontswap.v16-tag

And I am including the full diff for easier overview following the
credit list:

Dan Magenheimer (4):
      mm: frontswap: add frontswap header file
      mm: frontswap: core swap subsystem hooks and headers
      mm: frontswap: core frontswap functionality
      mm: frontswap: config and doc files

Konrad Rzeszutek Wilk (2):
      MAINTAINER: Add myself for the frontswap API
      frontswap: s/put_page/store/g s/get_page/load

 Documentation/vm/frontswap.txt        |  278 +++++++++++++++++++++++++++++
 MAINTAINERS                           |    7 +
 drivers/staging/ramster/zcache-main.c |    8 +-
 drivers/staging/zcache/zcache-main.c  |   10 +-
 drivers/xen/tmem.c                    |    8 +-
 include/linux/frontswap.h             |  127 +++++++++++++
 include/linux/swap.h                  |    4 +
 include/linux/swapfile.h              |   13 ++
 mm/Kconfig                            |   17 ++
 mm/Makefile                           |    1 +
 mm/frontswap.c                        |  314 +++++++++++++++++++++++++++++++++
 mm/page_io.c                          |   12 ++
 mm/swapfile.c                         |   54 +++++--
 13 files changed, 827 insertions(+), 26 deletions(-)

diff --git a/Documentation/vm/frontswap.txt b/Documentation/vm/frontswap.txt
new file mode 100644
index 0000000..37067cf
--- /dev/null
+++ b/Documentation/vm/frontswap.txt
@@ -0,0 +1,278 @@
+Frontswap provides a "transcendent memory" interface for swap pages.
+In some environments, dramatic performance savings may be obtained because
+swapped pages are saved in RAM (or a RAM-like device) instead of a swap disk.
+
+(Note, frontswap -- and cleancache (merged at 3.0) -- are the "frontends"
+and the only necessary changes to the core kernel for transcendent memory;
+all other supporting code -- the "backends" -- is implemented as drivers.
+See the LWN.net article "Transcendent memory in a nutshell" for a detailed
+overview of frontswap and related kernel parts:
+https://lwn.net/Articles/454795/ )
+
+Frontswap is so named because it can be thought of as the opposite of
+a "backing" store for a swap device.  The storage is assumed to be
+a synchronous concurrency-safe page-oriented "pseudo-RAM device" conforming
+to the requirements of transcendent memory (such as Xen's "tmem", or
+in-kernel compressed memory, aka "zcache", or future RAM-like devices);
+this pseudo-RAM device is not directly accessible or addressable by the
+kernel and is of unknown and possibly time-varying size.  The driver
+links itself to frontswap by calling frontswap_register_ops to set the
+frontswap_ops funcs appropriately and the functions it provides must
+conform to certain policies as follows:
+
+An "init" prepares the device to receive frontswap pages associated
+with the specified swap device number (aka "type").  A "store" will
+copy the page to transcendent memory and associate it with the type and
+offset associated with the page. A "load" will copy the page, if found,
+from transcendent memory into kernel memory, but will NOT remove the page
+from from transcendent memory.  An "invalidate_page" will remove the page
+from transcendent memory and an "invalidate_area" will remove ALL pages
+associated with the swap type (e.g., like swapoff) and notify the "device"
+to refuse further stores with that swap type.
+
+Once a page is successfully stored, a matching load on the page will normally
+succeed.  So when the kernel finds itself in a situation where it needs
+to swap out a page, it first attempts to use frontswap.  If the store returns
+success, the data has been successfully saved to transcendent memory and
+a disk write and, if the data is later read back, a disk read are avoided.
+If a store returns failure, transcendent memory has rejected the data, and the
+page can be written to swap as usual.
+
+If a backend chooses, frontswap can be configured as a "writethrough
+cache" by calling frontswap_writethrough().  In this mode, the reduction
+in swap device writes is lost (and also a non-trivial performance advantage)
+in order to allow the backend to arbitrarily "reclaim" space used to
+store frontswap pages to more completely manage its memory usage.
+
+Note that if a page is stored and the page already exists in transcendent memory
+(a "duplicate" store), either the store succeeds and the data is overwritten,
+or the store fails AND the page is invalidated.  This ensures stale data may
+never be obtained from frontswap.
+
+If properly configured, monitoring of frontswap is done via debugfs in
+the /sys/kernel/debug/frontswap directory.  The effectiveness of
+frontswap can be measured (across all swap devices) with:
+
+failed_stores	- how many store attempts have failed
+loads		- how many loads were attempted (all should succeed)
+succ_stores	- how many store attempts have succeeded
+invalidates	- how many invalidates were attempted
+
+A backend implementation may provide additional metrics.
+
+FAQ
+
+1) Where's the value?
+
+When a workload starts swapping, performance falls through the floor.
+Frontswap significantly increases performance in many such workloads by
+providing a clean, dynamic interface to read and write swap pages to
+"transcendent memory" that is otherwise not directly addressable to the kernel.
+This interface is ideal when data is transformed to a different form
+and size (such as with compression) or secretly moved (as might be
+useful for write-balancing for some RAM-like devices).  Swap pages (and
+evicted page-cache pages) are a great use for this kind of slower-than-RAM-
+but-much-faster-than-disk "pseudo-RAM device" and the frontswap (and
+cleancache) interface to transcendent memory provides a nice way to read
+and write -- and indirectly "name" -- the pages.
+
+Frontswap -- and cleancache -- with a fairly small impact on the kernel,
+provides a huge amount of flexibility for more dynamic, flexible RAM
+utilization in various system configurations:
+
+In the single kernel case, aka "zcache", pages are compressed and
+stored in local memory, thus increasing the total anonymous pages
+that can be safely kept in RAM.  Zcache essentially trades off CPU
+cycles used in compression/decompression for better memory utilization.
+Benchmarks have shown little or no impact when memory pressure is
+low while providing a significant performance improvement (25%+)
+on some workloads under high memory pressure.
+
+"RAMster" builds on zcache by adding "peer-to-peer" transcendent memory
+support for clustered systems.  Frontswap pages are locally compressed
+as in zcache, but then "remotified" to another system's RAM.  This
+allows RAM to be dynamically load-balanced back-and-forth as needed,
+i.e. when system A is overcommitted, it can swap to system B, and
+vice versa.  RAMster can also be configured as a memory server so
+many servers in a cluster can swap, dynamically as needed, to a single
+server configured with a large amount of RAM... without pre-configuring
+how much of the RAM is available for each of the clients!
+
+In the virtual case, the whole point of virtualization is to statistically
+multiplex physical resources acrosst the varying demands of multiple
+virtual machines.  This is really hard to do with RAM and efforts to do
+it well with no kernel changes have essentially failed (except in some
+well-publicized special-case workloads).
+Specifically, the Xen Transcendent Memory backend allows otherwise
+"fallow" hypervisor-owned RAM to not only be "time-shared" between multiple
+virtual machines, but the pages can be compressed and deduplicated to
+optimize RAM utilization.  And when guest OS's are induced to surrender
+underutilized RAM (e.g. with "selfballooning"), sudden unexpected
+memory pressure may result in swapping; frontswap allows those pages
+to be swapped to and from hypervisor RAM (if overall host system memory
+conditions allow), thus mitigating the potentially awful performance impact
+of unplanned swapping.
+
+A KVM implementation is underway and has been RFC'ed to lkml.  And,
+using frontswap, investigation is also underway on the use of NVM as
+a memory extension technology.
+
+2) Sure there may be performance advantages in some situations, but
+   what's the space/time overhead of frontswap?
+
+If CONFIG_FRONTSWAP is disabled, every frontswap hook compiles into
+nothingness and the only overhead is a few extra bytes per swapon'ed
+swap device.  If CONFIG_FRONTSWAP is enabled but no frontswap "backend"
+registers, there is one extra global variable compared to zero for
+every swap page read or written.  If CONFIG_FRONTSWAP is enabled
+AND a frontswap backend registers AND the backend fails every "store"
+request (i.e. provides no memory despite claiming it might),
+CPU overhead is still negligible -- and since every frontswap fail
+precedes a swap page write-to-disk, the system is highly likely
+to be I/O bound and using a small fraction of a percent of a CPU
+will be irrelevant anyway.
+
+As for space, if CONFIG_FRONTSWAP is enabled AND a frontswap backend
+registers, one bit is allocated for every swap page for every swap
+device that is swapon'd.  This is added to the EIGHT bits (which
+was sixteen until about 2.6.34) that the kernel already allocates
+for every swap page for every swap device that is swapon'd.  (Hugh
+Dickins has observed that frontswap could probably steal one of
+the existing eight bits, but let's worry about that minor optimization
+later.)  For very large swap disks (which are rare) on a standard
+4K pagesize, this is 1MB per 32GB swap.
+
+When swap pages are stored in transcendent memory instead of written
+out to disk, there is a side effect that this may create more memory
+pressure that can potentially outweigh the other advantages.  A
+backend, such as zcache, must implement policies to carefully (but
+dynamically) manage memory limits to ensure this doesn't happen.
+
+3) OK, how about a quick overview of what this frontswap patch does
+   in terms that a kernel hacker can grok?
+
+Let's assume that a frontswap "backend" has registered during
+kernel initialization; this registration indicates that this
+frontswap backend has access to some "memory" that is not directly
+accessible by the kernel.  Exactly how much memory it provides is
+entirely dynamic and random.
+
+Whenever a swap-device is swapon'd frontswap_init() is called,
+passing the swap device number (aka "type") as a parameter.
+This notifies frontswap to expect attempts to "store" swap pages
+associated with that number.
+
+Whenever the swap subsystem is readying a page to write to a swap
+device (c.f swap_writepage()), frontswap_store is called.  Frontswap
+consults with the frontswap backend and if the backend says it does NOT
+have room, frontswap_store returns -1 and the kernel swaps the page
+to the swap device as normal.  Note that the response from the frontswap
+backend is unpredictable to the kernel; it may choose to never accept a
+page, it could accept every ninth page, or it might accept every
+page.  But if the backend does accept a page, the data from the page
+has already been copied and associated with the type and offset,
+and the backend guarantees the persistence of the data.  In this case,
+frontswap sets a bit in the "frontswap_map" for the swap device
+corresponding to the page offset on the swap device to which it would
+otherwise have written the data.
+
+When the swap subsystem needs to swap-in a page (swap_readpage()),
+it first calls frontswap_load() which checks the frontswap_map to
+see if the page was earlier accepted by the frontswap backend.  If
+it was, the page of data is filled from the frontswap backend and
+the swap-in is complete.  If not, the normal swap-in code is
+executed to obtain the page of data from the real swap device.
+
+So every time the frontswap backend accepts a page, a swap device read
+and (potentially) a swap device write are replaced by a "frontswap backend
+store" and (possibly) a "frontswap backend loads", which are presumably much
+faster.
+
+4) Can't frontswap be configured as a "special" swap device that is
+   just higher priority than any real swap device (e.g. like zswap,
+   or maybe swap-over-nbd/NFS)?
+
+No.  First, the existing swap subsystem doesn't allow for any kind of
+swap hierarchy.  Perhaps it could be rewritten to accomodate a hierarchy,
+but this would require fairly drastic changes.  Even if it were
+rewritten, the existing swap subsystem uses the block I/O layer which
+assumes a swap device is fixed size and any page in it is linearly
+addressable.  Frontswap barely touches the existing swap subsystem,
+and works around the constraints of the block I/O subsystem to provide
+a great deal of flexibility and dynamicity.
+
+For example, the acceptance of any swap page by the frontswap backend is
+entirely unpredictable. This is critical to the definition of frontswap
+backends because it grants completely dynamic discretion to the
+backend.  In zcache, one cannot know a priori how compressible a page is.
+"Poorly" compressible pages can be rejected, and "poorly" can itself be
+defined dynamically depending on current memory constraints.
+
+Further, frontswap is entirely synchronous whereas a real swap
+device is, by definition, asynchronous and uses block I/O.  The
+block I/O layer is not only unnecessary, but may perform "optimizations"
+that are inappropriate for a RAM-oriented device including delaying
+the write of some pages for a significant amount of time.  Synchrony is
+required to ensure the dynamicity of the backend and to avoid thorny race
+conditions that would unnecessarily and greatly complicate frontswap
+and/or the block I/O subsystem.  That said, only the initial "store"
+and "load" operations need be synchronous.  A separate asynchronous thread
+is free to manipulate the pages stored by frontswap.  For example,
+the "remotification" thread in RAMster uses standard asynchronous
+kernel sockets to move compressed frontswap pages to a remote machine.
+Similarly, a KVM guest-side implementation could do in-guest compression
+and use "batched" hypercalls.
+
+In a virtualized environment, the dynamicity allows the hypervisor
+(or host OS) to do "intelligent overcommit".  For example, it can
+choose to accept pages only until host-swapping might be imminent,
+then force guests to do their own swapping.
+
+There is a downside to the transcendent memory specifications for
+frontswap:  Since any "store" might fail, there must always be a real
+slot on a real swap device to swap the page.  Thus frontswap must be
+implemented as a "shadow" to every swapon'd device with the potential
+capability of holding every page that the swap device might have held
+and the possibility that it might hold no pages at all.  This means
+that frontswap cannot contain more pages than the total of swapon'd
+swap devices.  For example, if NO swap device is configured on some
+installation, frontswap is useless.  Swapless portable devices
+can still use frontswap but a backend for such devices must configure
+some kind of "ghost" swap device and ensure that it is never used.
+
+5) Why this weird definition about "duplicate stores"?  If a page
+   has been previously successfully stored, can't it always be
+   successfully overwritten?
+
+Nearly always it can, but no, sometimes it cannot.  Consider an example
+where data is compressed and the original 4K page has been compressed
+to 1K.  Now an attempt is made to overwrite the page with data that
+is non-compressible and so would take the entire 4K.  But the backend
+has no more space.  In this case, the store must be rejected.  Whenever
+frontswap rejects a store that would overwrite, it also must invalidate
+the old data and ensure that it is no longer accessible.  Since the
+swap subsystem then writes the new data to the read swap device,
+this is the correct course of action to ensure coherency.
+
+6) What is frontswap_shrink for?
+
+When the (non-frontswap) swap subsystem swaps out a page to a real
+swap device, that page is only taking up low-value pre-allocated disk
+space.  But if frontswap has placed a page in transcendent memory, that
+page may be taking up valuable real estate.  The frontswap_shrink
+routine allows code outside of the swap subsystem to force pages out
+of the memory managed by frontswap and back into kernel-addressable memory.
+For example, in RAMster, a "suction driver" thread will attempt
+to "repatriate" pages sent to a remote machine back to the local machine;
+this is driven using the frontswap_shrink mechanism when memory pressure
+subsides.
+
+7) Why does the frontswap patch create the new include file swapfile.h?
+
+The frontswap code depends on some swap-subsystem-internal data
+structures that have, over the years, moved back and forth between
+static and global.  This seemed a reasonable compromise:  Define
+them as global but declare them in a new include file that isn't
+included by the large number of source files that include swap.h.
+
+Dan Magenheimer, last updated April 9, 2012
diff --git a/MAINTAINERS b/MAINTAINERS
index 2dcfca8..bc8905d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2876,6 +2876,13 @@ F:	Documentation/power/freezing-of-tasks.txt
 F:	include/linux/freezer.h
 F:	kernel/freezer.c
 
+FRONTSWAP API
+M:	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
+L:	linux-kernel@vger.kernel.org
+S:	Maintained
+F:	mm/frontswap.c
+F:	include/linux/frontswap.h
+
 FS-CACHE: LOCAL CACHING FOR NETWORK FILESYSTEMS
 M:	David Howells <dhowells@redhat.com>
 L:	linux-cachefs@redhat.com
diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 68b2e05..2627b3d 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -3002,7 +3002,7 @@ static inline struct tmem_oid oswiz(unsigned type, u32 ind)
 	return oid;
 }
 
-static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
+static int zcache_frontswap_store(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -3025,7 +3025,7 @@ static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
 
 /* returns 0 if the page was successfully gotten from frontswap, -1 if
  * was not present (should never happen!) */
-static int zcache_frontswap_get_page(unsigned type, pgoff_t offset,
+static int zcache_frontswap_load(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -3080,8 +3080,8 @@ static void zcache_frontswap_init(unsigned ignored)
 }
 
 static struct frontswap_ops zcache_frontswap_ops = {
-	.put_page = zcache_frontswap_put_page,
-	.get_page = zcache_frontswap_get_page,
+	.store = zcache_frontswap_store,
+	.load = zcache_frontswap_load,
 	.invalidate_page = zcache_frontswap_flush_page,
 	.invalidate_area = zcache_frontswap_flush_area,
 	.init = zcache_frontswap_init
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 2734dac..784c796 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1835,7 +1835,7 @@ static int zcache_frontswap_poolid = -1;
  * Swizzling increases objects per swaptype, increasing tmem concurrency
  * for heavy swaploads.  Later, larger nr_cpus -> larger SWIZ_BITS
  * Setting SWIZ_BITS to 27 basically reconstructs the swap entry from
- * frontswap_get_page(), but has side-effects. Hence using 8.
+ * frontswap_load(), but has side-effects. Hence using 8.
  */
 #define SWIZ_BITS		8
 #define SWIZ_MASK		((1 << SWIZ_BITS) - 1)
@@ -1849,7 +1849,7 @@ static inline struct tmem_oid oswiz(unsigned type, u32 ind)
 	return oid;
 }
 
-static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
+static int zcache_frontswap_store(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -1870,7 +1870,7 @@ static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
 
 /* returns 0 if the page was successfully gotten from frontswap, -1 if
  * was not present (should never happen!) */
-static int zcache_frontswap_get_page(unsigned type, pgoff_t offset,
+static int zcache_frontswap_load(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -1919,8 +1919,8 @@ static void zcache_frontswap_init(unsigned ignored)
 }
 
 static struct frontswap_ops zcache_frontswap_ops = {
-	.put_page = zcache_frontswap_put_page,
-	.get_page = zcache_frontswap_get_page,
+	.store = zcache_frontswap_store,
+	.load = zcache_frontswap_load,
 	.invalidate_page = zcache_frontswap_flush_page,
 	.invalidate_area = zcache_frontswap_flush_area,
 	.init = zcache_frontswap_init
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index dcb7952..89f264c 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -269,7 +269,7 @@ static inline struct tmem_oid oswiz(unsigned type, u32 ind)
 }
 
 /* returns 0 if the page was successfully put into frontswap, -1 if not */
-static int tmem_frontswap_put_page(unsigned type, pgoff_t offset,
+static int tmem_frontswap_store(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -295,7 +295,7 @@ static int tmem_frontswap_put_page(unsigned type, pgoff_t offset,
  * returns 0 if the page was successfully gotten from frontswap, -1 if
  * was not present (should never happen!)
  */
-static int tmem_frontswap_get_page(unsigned type, pgoff_t offset,
+static int tmem_frontswap_load(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -362,8 +362,8 @@ static int __init no_frontswap(char *s)
 __setup("nofrontswap", no_frontswap);
 
 static struct frontswap_ops __initdata tmem_frontswap_ops = {
-	.put_page = tmem_frontswap_put_page,
-	.get_page = tmem_frontswap_get_page,
+	.store = tmem_frontswap_store,
+	.load = tmem_frontswap_load,
 	.invalidate_page = tmem_frontswap_flush_page,
 	.invalidate_area = tmem_frontswap_flush_area,
 	.init = tmem_frontswap_init
diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
new file mode 100644
index 0000000..0e4e2ee
--- /dev/null
+++ b/include/linux/frontswap.h
@@ -0,0 +1,127 @@
+#ifndef _LINUX_FRONTSWAP_H
+#define _LINUX_FRONTSWAP_H
+
+#include <linux/swap.h>
+#include <linux/mm.h>
+#include <linux/bitops.h>
+
+struct frontswap_ops {
+	void (*init)(unsigned);
+	int (*store)(unsigned, pgoff_t, struct page *);
+	int (*load)(unsigned, pgoff_t, struct page *);
+	void (*invalidate_page)(unsigned, pgoff_t);
+	void (*invalidate_area)(unsigned);
+};
+
+extern bool frontswap_enabled;
+extern struct frontswap_ops
+	frontswap_register_ops(struct frontswap_ops *ops);
+extern void frontswap_shrink(unsigned long);
+extern unsigned long frontswap_curr_pages(void);
+extern void frontswap_writethrough(bool);
+
+extern void __frontswap_init(unsigned type);
+extern int __frontswap_store(struct page *page);
+extern int __frontswap_load(struct page *page);
+extern void __frontswap_invalidate_page(unsigned, pgoff_t);
+extern void __frontswap_invalidate_area(unsigned);
+
+#ifdef CONFIG_FRONTSWAP
+
+static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
+{
+	bool ret = false;
+
+	if (frontswap_enabled && sis->frontswap_map)
+		ret = test_bit(offset, sis->frontswap_map);
+	return ret;
+}
+
+static inline void frontswap_set(struct swap_info_struct *sis, pgoff_t offset)
+{
+	if (frontswap_enabled && sis->frontswap_map)
+		set_bit(offset, sis->frontswap_map);
+}
+
+static inline void frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
+{
+	if (frontswap_enabled && sis->frontswap_map)
+		clear_bit(offset, sis->frontswap_map);
+}
+
+static inline void frontswap_map_set(struct swap_info_struct *p,
+				     unsigned long *map)
+{
+	p->frontswap_map = map;
+}
+
+static inline unsigned long *frontswap_map_get(struct swap_info_struct *p)
+{
+	return p->frontswap_map;
+}
+#else
+/* all inline routines become no-ops and all externs are ignored */
+
+#define frontswap_enabled (0)
+
+static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
+{
+	return false;
+}
+
+static inline void frontswap_set(struct swap_info_struct *sis, pgoff_t offset)
+{
+}
+
+static inline void frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
+{
+}
+
+static inline void frontswap_map_set(struct swap_info_struct *p,
+				     unsigned long *map)
+{
+}
+
+static inline unsigned long *frontswap_map_get(struct swap_info_struct *p)
+{
+	return NULL;
+}
+#endif
+
+static inline int frontswap_store(struct page *page)
+{
+	int ret = -1;
+
+	if (frontswap_enabled)
+		ret = __frontswap_store(page);
+	return ret;
+}
+
+static inline int frontswap_load(struct page *page)
+{
+	int ret = -1;
+
+	if (frontswap_enabled)
+		ret = __frontswap_load(page);
+	return ret;
+}
+
+static inline void frontswap_invalidate_page(unsigned type, pgoff_t offset)
+{
+	if (frontswap_enabled)
+		__frontswap_invalidate_page(type, offset);
+}
+
+static inline void frontswap_invalidate_area(unsigned type)
+{
+	if (frontswap_enabled)
+		__frontswap_invalidate_area(type);
+}
+
+static inline void frontswap_init(unsigned type)
+{
+	if (frontswap_enabled)
+		__frontswap_init(type);
+}
+
+#endif /* _LINUX_FRONTSWAP_H */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index b1fd5c7..50a55e2 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -197,6 +197,10 @@ struct swap_info_struct {
 	struct block_device *bdev;	/* swap device or bdev of swap file */
 	struct file *swap_file;		/* seldom referenced */
 	unsigned int old_block_size;	/* seldom referenced */
+#ifdef CONFIG_FRONTSWAP
+	unsigned long *frontswap_map;	/* frontswap in-use, one bit per page */
+	atomic_t frontswap_pages;	/* frontswap pages in-use counter */
+#endif
 };
 
 struct swap_list_t {
diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
new file mode 100644
index 0000000..e282624
--- /dev/null
+++ b/include/linux/swapfile.h
@@ -0,0 +1,13 @@
+#ifndef _LINUX_SWAPFILE_H
+#define _LINUX_SWAPFILE_H
+
+/*
+ * these were static in swapfile.c but frontswap.c needs them and we don't
+ * want to expose them to the dozens of source files that include swap.h
+ */
+extern spinlock_t swap_lock;
+extern struct swap_list_t swap_list;
+extern struct swap_info_struct *swap_info[];
+extern int try_to_unuse(unsigned int, bool, unsigned long);
+
+#endif /* _LINUX_SWAPFILE_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index e338407..2613c91 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -379,3 +379,20 @@ config CLEANCACHE
 	  in a negligible performance hit.
 
 	  If unsure, say Y to enable cleancache
+
+config FRONTSWAP
+	bool "Enable frontswap to cache swap pages if tmem is present"
+	depends on SWAP
+	default n
+	help
+	  Frontswap is so named because it can be thought of as the opposite
+	  of a "backing" store for a swap device.  The data is stored into
+	  "transcendent memory", memory that is not directly accessible or
+	  addressable by the kernel and is of unknown and possibly
+	  time-varying size.  When space in transcendent memory is available,
+	  a significant swap I/O reduction may be achieved.  When none is
+	  available, all frontswap calls are reduced to a single pointer-
+	  compare-against-NULL resulting in a negligible performance hit
+	  and swap data is stored as normal on the matching swap device.
+
+	  If unsure, say Y to enable frontswap.
diff --git a/mm/Makefile b/mm/Makefile
index 50ec00e..306742a 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -26,6 +26,7 @@ obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
diff --git a/mm/frontswap.c b/mm/frontswap.c
new file mode 100644
index 0000000..e250255
--- /dev/null
+++ b/mm/frontswap.c
@@ -0,0 +1,314 @@
+/*
+ * Frontswap frontend
+ *
+ * This code provides the generic "frontend" layer to call a matching
+ * "backend" driver implementation of frontswap.  See
+ * Documentation/vm/frontswap.txt for more information.
+ *
+ * Copyright (C) 2009-2012 Oracle Corp.  All rights reserved.
+ * Author: Dan Magenheimer
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ */
+
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/proc_fs.h>
+#include <linux/security.h>
+#include <linux/capability.h>
+#include <linux/module.h>
+#include <linux/uaccess.h>
+#include <linux/debugfs.h>
+#include <linux/frontswap.h>
+#include <linux/swapfile.h>
+
+/*
+ * frontswap_ops is set by frontswap_register_ops to contain the pointers
+ * to the frontswap "backend" implementation functions.
+ */
+static struct frontswap_ops frontswap_ops __read_mostly;
+
+/*
+ * This global enablement flag reduces overhead on systems where frontswap_ops
+ * has not been registered, so is preferred to the slower alternative: a
+ * function call that checks a non-global.
+ */
+bool frontswap_enabled __read_mostly;
+EXPORT_SYMBOL(frontswap_enabled);
+
+/*
+ * If enabled, frontswap_store will return failure even on success.  As
+ * a result, the swap subsystem will always write the page to swap, in
+ * effect converting frontswap into a writethrough cache.  In this mode,
+ * there is no direct reduction in swap writes, but a frontswap backend
+ * can unilaterally "reclaim" any pages in use with no data loss, thus
+ * providing increases control over maximum memory usage due to frontswap.
+ */
+static bool frontswap_writethrough_enabled __read_mostly;
+
+#ifdef CONFIG_DEBUG_FS
+/*
+ * Counters available via /sys/kernel/debug/frontswap (if debugfs is
+ * properly configured).  These are for information only so are not protected
+ * against increment races.
+ */
+static u64 frontswap_loads;
+static u64 frontswap_succ_stores;
+static u64 frontswap_failed_stores;
+static u64 frontswap_invalidates;
+
+static inline void inc_frontswap_loads(void) {
+	frontswap_loads++;
+}
+static inline void inc_frontswap_succ_stores(void) {
+	frontswap_succ_stores++;
+}
+static inline void inc_frontswap_failed_stores(void) {
+	frontswap_failed_stores++;
+}
+static inline void inc_frontswap_invalidates(void) {
+	frontswap_invalidates++;
+}
+#else
+static inline void inc_frontswap_loads(void) { }
+static inline void inc_frontswap_succ_stores(void) { }
+static inline void inc_frontswap_failed_stores(void) { }
+static inline void inc_frontswap_invalidates(void) { }
+#endif
+/*
+ * Register operations for frontswap, returning previous thus allowing
+ * detection of multiple backends and possible nesting.
+ */
+struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
+{
+	struct frontswap_ops old = frontswap_ops;
+
+	frontswap_ops = *ops;
+	frontswap_enabled = true;
+	return old;
+}
+EXPORT_SYMBOL(frontswap_register_ops);
+
+/*
+ * Enable/disable frontswap writethrough (see above).
+ */
+void frontswap_writethrough(bool enable)
+{
+	frontswap_writethrough_enabled = enable;
+}
+EXPORT_SYMBOL(frontswap_writethrough);
+
+/*
+ * Called when a swap device is swapon'd.
+ */
+void __frontswap_init(unsigned type)
+{
+	struct swap_info_struct *sis = swap_info[type];
+
+	BUG_ON(sis == NULL);
+	if (sis->frontswap_map == NULL)
+		return;
+	if (frontswap_enabled)
+		(*frontswap_ops.init)(type);
+}
+EXPORT_SYMBOL(__frontswap_init);
+
+/*
+ * "Store" data from a page to frontswap and associate it with the page's
+ * swaptype and offset.  Page must be locked and in the swap cache.
+ * If frontswap already contains a page with matching swaptype and
+ * offset, the frontswap implmentation may either overwrite the data and
+ * return success or invalidate the page from frontswap and return failure.
+ */
+int __frontswap_store(struct page *page)
+{
+	int ret = -1, dup = 0;
+	swp_entry_t entry = { .val = page_private(page), };
+	int type = swp_type(entry);
+	struct swap_info_struct *sis = swap_info[type];
+	pgoff_t offset = swp_offset(entry);
+
+	BUG_ON(!PageLocked(page));
+	BUG_ON(sis == NULL);
+	if (frontswap_test(sis, offset))
+		dup = 1;
+	ret = (*frontswap_ops.store)(type, offset, page);
+	if (ret == 0) {
+		frontswap_set(sis, offset);
+		inc_frontswap_succ_stores();
+		if (!dup)
+			atomic_inc(&sis->frontswap_pages);
+	} else if (dup) {
+		/*
+		  failed dup always results in automatic invalidate of
+		  the (older) page from frontswap
+		 */
+		frontswap_clear(sis, offset);
+		atomic_dec(&sis->frontswap_pages);
+		inc_frontswap_failed_stores();
+	} else
+		inc_frontswap_failed_stores();
+	if (frontswap_writethrough_enabled)
+		/* report failure so swap also writes to swap device */
+		ret = -1;
+	return ret;
+}
+EXPORT_SYMBOL(__frontswap_store);
+
+/*
+ * "Get" data from frontswap associated with swaptype and offset that were
+ * specified when the data was put to frontswap and use it to fill the
+ * specified page with data. Page must be locked and in the swap cache.
+ */
+int __frontswap_load(struct page *page)
+{
+	int ret = -1;
+	swp_entry_t entry = { .val = page_private(page), };
+	int type = swp_type(entry);
+	struct swap_info_struct *sis = swap_info[type];
+	pgoff_t offset = swp_offset(entry);
+
+	BUG_ON(!PageLocked(page));
+	BUG_ON(sis == NULL);
+	if (frontswap_test(sis, offset))
+		ret = (*frontswap_ops.load)(type, offset, page);
+	if (ret == 0)
+		inc_frontswap_loads();
+	return ret;
+}
+EXPORT_SYMBOL(__frontswap_load);
+
+/*
+ * Invalidate any data from frontswap associated with the specified swaptype
+ * and offset so that a subsequent "get" will fail.
+ */
+void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
+{
+	struct swap_info_struct *sis = swap_info[type];
+
+	BUG_ON(sis == NULL);
+	if (frontswap_test(sis, offset)) {
+		(*frontswap_ops.invalidate_page)(type, offset);
+		atomic_dec(&sis->frontswap_pages);
+		frontswap_clear(sis, offset);
+		inc_frontswap_invalidates();
+	}
+}
+EXPORT_SYMBOL(__frontswap_invalidate_page);
+
+/*
+ * Invalidate all data from frontswap associated with all offsets for the
+ * specified swaptype.
+ */
+void __frontswap_invalidate_area(unsigned type)
+{
+	struct swap_info_struct *sis = swap_info[type];
+
+	BUG_ON(sis == NULL);
+	if (sis->frontswap_map == NULL)
+		return;
+	(*frontswap_ops.invalidate_area)(type);
+	atomic_set(&sis->frontswap_pages, 0);
+	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
+}
+EXPORT_SYMBOL(__frontswap_invalidate_area);
+
+/*
+ * Frontswap, like a true swap device, may unnecessarily retain pages
+ * under certain circumstances; "shrink" frontswap is essentially a
+ * "partial swapoff" and works by calling try_to_unuse to attempt to
+ * unuse enough frontswap pages to attempt to -- subject to memory
+ * constraints -- reduce the number of pages in frontswap to the
+ * number given in the parameter target_pages.
+ */
+void frontswap_shrink(unsigned long target_pages)
+{
+	struct swap_info_struct *si = NULL;
+	int si_frontswap_pages;
+	unsigned long total_pages = 0, total_pages_to_unuse;
+	unsigned long pages = 0, pages_to_unuse = 0;
+	int type;
+	bool locked = false;
+
+	/*
+	 * we don't want to hold swap_lock while doing a very
+	 * lengthy try_to_unuse, but swap_list may change
+	 * so restart scan from swap_list.head each time
+	 */
+	spin_lock(&swap_lock);
+	locked = true;
+	total_pages = 0;
+	for (type = swap_list.head; type >= 0; type = si->next) {
+		si = swap_info[type];
+		total_pages += atomic_read(&si->frontswap_pages);
+	}
+	if (total_pages <= target_pages)
+		goto out;
+	total_pages_to_unuse = total_pages - target_pages;
+	for (type = swap_list.head; type >= 0; type = si->next) {
+		si = swap_info[type];
+		si_frontswap_pages = atomic_read(&si->frontswap_pages);
+		if (total_pages_to_unuse < si_frontswap_pages)
+			pages = pages_to_unuse = total_pages_to_unuse;
+		else {
+			pages = si_frontswap_pages;
+			pages_to_unuse = 0; /* unuse all */
+		}
+		/* ensure there is enough RAM to fetch pages from frontswap */
+		if (security_vm_enough_memory_mm(current->mm, pages))
+			continue;
+		vm_unacct_memory(pages);
+		break;
+	}
+	if (type < 0)
+		goto out;
+	locked = false;
+	spin_unlock(&swap_lock);
+	try_to_unuse(type, true, pages_to_unuse);
+out:
+	if (locked)
+		spin_unlock(&swap_lock);
+	return;
+}
+EXPORT_SYMBOL(frontswap_shrink);
+
+/*
+ * Count and return the number of frontswap pages across all
+ * swap devices.  This is exported so that backend drivers can
+ * determine current usage without reading debugfs.
+ */
+unsigned long frontswap_curr_pages(void)
+{
+	int type;
+	unsigned long totalpages = 0;
+	struct swap_info_struct *si = NULL;
+
+	spin_lock(&swap_lock);
+	for (type = swap_list.head; type >= 0; type = si->next) {
+		si = swap_info[type];
+		totalpages += atomic_read(&si->frontswap_pages);
+	}
+	spin_unlock(&swap_lock);
+	return totalpages;
+}
+EXPORT_SYMBOL(frontswap_curr_pages);
+
+static int __init init_frontswap(void)
+{
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *root = debugfs_create_dir("frontswap", NULL);
+	if (root == NULL)
+		return -ENXIO;
+	debugfs_create_u64("loads", S_IRUGO, root, &frontswap_loads);
+	debugfs_create_u64("succ_stores", S_IRUGO, root, &frontswap_succ_stores);
+	debugfs_create_u64("failed_stores", S_IRUGO, root,
+				&frontswap_failed_stores);
+	debugfs_create_u64("invalidates", S_IRUGO,
+				root, &frontswap_invalidates);
+#endif
+	return 0;
+}
+
+module_init(init_frontswap);
diff --git a/mm/page_io.c b/mm/page_io.c
index dc76b4d..34f0292 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -18,6 +18,7 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <linux/frontswap.h>
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags,
@@ -98,6 +99,12 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		unlock_page(page);
 		goto out;
 	}
+	if (frontswap_store(page) == 0) {
+		set_page_writeback(page);
+		unlock_page(page);
+		end_page_writeback(page);
+		goto out;
+	}
 	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
 	if (bio == NULL) {
 		set_page_dirty(page);
@@ -122,6 +129,11 @@ int swap_readpage(struct page *page)
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageUptodate(page));
+	if (frontswap_load(page) == 0) {
+		SetPageUptodate(page);
+		unlock_page(page);
+		goto out;
+	}
 	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
 	if (bio == NULL) {
 		unlock_page(page);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index fafc26d..9c7be87 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -31,6 +31,8 @@
 #include <linux/memcontrol.h>
 #include <linux/poll.h>
 #include <linux/oom.h>
+#include <linux/frontswap.h>
+#include <linux/swapfile.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -42,7 +44,7 @@ static bool swap_count_continued(struct swap_info_struct *, pgoff_t,
 static void free_swap_count_continuations(struct swap_info_struct *);
 static sector_t map_swap_entry(swp_entry_t, struct block_device**);
 
-static DEFINE_SPINLOCK(swap_lock);
+DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
 long nr_swap_pages;
 long total_swap_pages;
@@ -53,9 +55,9 @@ static const char Unused_file[] = "Unused swap file entry ";
 static const char Bad_offset[] = "Bad swap offset entry ";
 static const char Unused_offset[] = "Unused swap offset entry ";
 
-static struct swap_list_t swap_list = {-1, -1};
+struct swap_list_t swap_list = {-1, -1};
 
-static struct swap_info_struct *swap_info[MAX_SWAPFILES];
+struct swap_info_struct *swap_info[MAX_SWAPFILES];
 
 static DEFINE_MUTEX(swapon_mutex);
 
@@ -556,6 +558,7 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 			swap_list.next = p->type;
 		nr_swap_pages++;
 		p->inuse_pages--;
+		frontswap_invalidate_page(p->type, offset);
 		if ((p->flags & SWP_BLKDEV) &&
 				disk->fops->swap_slot_free_notify)
 			disk->fops->swap_slot_free_notify(p->bdev, offset);
@@ -1016,11 +1019,12 @@ static int unuse_mm(struct mm_struct *mm,
 }
 
 /*
- * Scan swap_map from current position to next entry still in use.
+ * Scan swap_map (or frontswap_map if frontswap parameter is true)
+ * from current position to next entry still in use.
  * Recycle to start on reaching the end, returning 0 when empty.
  */
 static unsigned int find_next_to_unuse(struct swap_info_struct *si,
-					unsigned int prev)
+					unsigned int prev, bool frontswap)
 {
 	unsigned int max = si->max;
 	unsigned int i = prev;
@@ -1046,6 +1050,12 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
 			prev = 0;
 			i = 1;
 		}
+		if (frontswap) {
+			if (frontswap_test(si, i))
+				break;
+			else
+				continue;
+		}
 		count = si->swap_map[i];
 		if (count && swap_count(count) != SWAP_MAP_BAD)
 			break;
@@ -1057,8 +1067,12 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
  * We completely avoid races by reading each swap page in advance,
  * and then search for the process using it.  All the necessary
  * page table adjustments can then be made atomically.
+ *
+ * if the boolean frontswap is true, only unuse pages_to_unuse pages;
+ * pages_to_unuse==0 means all pages; ignored if frontswap is false
  */
-static int try_to_unuse(unsigned int type)
+int try_to_unuse(unsigned int type, bool frontswap,
+		 unsigned long pages_to_unuse)
 {
 	struct swap_info_struct *si = swap_info[type];
 	struct mm_struct *start_mm;
@@ -1091,7 +1105,7 @@ static int try_to_unuse(unsigned int type)
 	 * one pass through swap_map is enough, but not necessarily:
 	 * there are races when an instance of an entry might be missed.
 	 */
-	while ((i = find_next_to_unuse(si, i)) != 0) {
+	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		if (signal_pending(current)) {
 			retval = -EINTR;
 			break;
@@ -1258,6 +1272,10 @@ static int try_to_unuse(unsigned int type)
 		 * interactive performance.
 		 */
 		cond_resched();
+		if (frontswap && pages_to_unuse > 0) {
+			if (!--pages_to_unuse)
+				break;
+		}
 	}
 
 	mmput(start_mm);
@@ -1517,7 +1535,8 @@ bad_bmap:
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
-				unsigned char *swap_map)
+				unsigned char *swap_map,
+				unsigned long *frontswap_map)
 {
 	int i, prev;
 
@@ -1527,6 +1546,7 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
+	frontswap_map_set(p, frontswap_map);
 	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += p->pages;
 	total_swap_pages += p->pages;
@@ -1543,6 +1563,7 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 		swap_list.head = swap_list.next = p->type;
 	else
 		swap_info[prev]->next = p->type;
+	frontswap_init(p->type);
 	spin_unlock(&swap_lock);
 }
 
@@ -1616,7 +1637,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	spin_unlock(&swap_lock);
 
 	oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
-	err = try_to_unuse(type);
+	err = try_to_unuse(type, false, 0); /* force all pages to be unused */
 	compare_swap_oom_score_adj(OOM_SCORE_ADJ_MAX, oom_score_adj);
 
 	if (err) {
@@ -1627,7 +1648,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		 * sys_swapoff for this swap_info_struct at this point.
 		 */
 		/* re-insert swap space back into swap_list */
-		enable_swap_info(p, p->prio, p->swap_map);
+		enable_swap_info(p, p->prio, p->swap_map, frontswap_map_get(p));
 		goto out_dput;
 	}
 
@@ -1653,9 +1674,11 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
 	p->flags = 0;
+	frontswap_invalidate_area(type);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
+	vfree(frontswap_map_get(p));
 	/* Destroy swap account informatin */
 	swap_cgroup_swapoff(type);
 
@@ -2019,6 +2042,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	sector_t span;
 	unsigned long maxpages;
 	unsigned char *swap_map = NULL;
+	unsigned long *frontswap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
 
@@ -2102,6 +2126,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		error = nr_extents;
 		goto bad_swap;
 	}
+	/* frontswap enabled? set up bit-per-page map for frontswap */
+	if (frontswap_enabled)
+		frontswap_map = vzalloc(maxpages / sizeof(long));
 
 	if (p->bdev) {
 		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
@@ -2117,14 +2144,15 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (swap_flags & SWAP_FLAG_PREFER)
 		prio =
 		  (swap_flags & SWAP_FLAG_PRIO_MASK) >> SWAP_FLAG_PRIO_SHIFT;
-	enable_swap_info(p, prio, swap_map);
+	enable_swap_info(p, prio, swap_map, frontswap_map);
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
-			"Priority:%d extents:%d across:%lluk %s%s\n",
+			"Priority:%d extents:%d across:%lluk %s%s%s\n",
 		p->pages<<(PAGE_SHIFT-10), name, p->prio,
 		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
 		(p->flags & SWP_SOLIDSTATE) ? "SS" : "",
-		(p->flags & SWP_DISCARDABLE) ? "D" : "");
+		(p->flags & SWP_DISCARDABLE) ? "D" : "",
+		(frontswap_map) ? "FS" : "");
 
 	mutex_unlock(&swapon_mutex);
 	atomic_inc(&proc_poll_event);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
