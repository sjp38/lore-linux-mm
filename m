Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 78E7F6B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 15:49:40 -0400 (EDT)
Date: Fri, 27 May 2011 12:49:25 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V4 4/4] mm: frontswap: config and doc files
Message-ID: <20110527194925.GA27229@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, dan.magenheimer@oracle.com

[PATCH V4 4/4] mm: frontswap: config and doc files

Add configuration and documentation files.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 Documentation/ABI/testing/sysfs-kernel-mm-frontswap |   16 
 Documentation/vm/frontswap.txt                      |  210 ++++++++++
 mm/Kconfig                                          |   16 
 mm/Makefile                                         |    1 
 4 files changed, 243 insertions(+)

--- linux-2.6.39/mm/Makefile	2011-05-18 22:06:34.000000000 -0600
+++ linux-2.6.39-frontswap/mm/Makefile	2011-05-26 15:37:25.262292918 -0600
@@ -25,6 +25,7 @@ obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
--- linux-2.6.39/mm/Kconfig	2011-05-18 22:06:34.000000000 -0600
+++ linux-2.6.39-frontswap/mm/Kconfig	2011-05-26 15:39:26.294884780 -0600
@@ -347,3 +347,19 @@ config NEED_PER_CPU_KM
 	depends on !SMP
 	bool
 	default y
+
+config FRONTSWAP
+	bool "Enable frontswap pseudo-RAM driver to cache swap pages"
+	default y
+	help
+ 	  Frontswap is so named because it can be thought of as the opposite of
+ 	  a "backing" store for a swap device.  The storage is assumed to be
+ 	  a synchronous concurrency-safe page-oriented pseudo-RAM device (such
+	  as Xen's Transcendent Memory, aka "tmem") which is not directly
+	  accessible or addressable by the kernel and is of unknown (and
+	  possibly time-varying) size.  When a pseudo-RAM device is available,
+	  a signficant swap I/O reduction may be achieved.  When none is
+	  available, all frontswap calls are reduced to a single pointer-
+	  compare-against-NULL resulting in a negligible performance hit.
+
+	  If unsure, say Y to enable frontswap.
--- linux-2.6.39/Documentation/ABI/testing/sysfs-kernel-mm-frontswap	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.39-frontswap/Documentation/ABI/testing/sysfs-kernel-mm-frontswap	2011-05-26 15:37:25.135819879 -0600
@@ -0,0 +1,16 @@
+What:		/sys/kernel/mm/frontswap/
+Date:		June 2010
+Contact:	Dan Magenheimer <dan.magenheimer@oracle.com>
+Description:
+		/sys/kernel/mm/frontswap/ contains a number of files which
+		record a count of various frontswap operations (sum across
+		all swap devices):
+			succ_puts
+			failed_puts
+			gets
+			flushes
+		In addition, reading the curr_pages file shows how many
+		pages are currently contained in frontswap and writing this
+		file with an integer performs a "partial swapoff", reducing
+		the number of frontswap pages to that integer if memory
+		constraints permit.
--- linux-2.6.39/Documentation/vm/frontswap.txt	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.39-frontswap/Documentation/vm/frontswap.txt	2011-05-27 12:16:26.888850337 -0600
@@ -0,0 +1,210 @@
+Frontswap provides a "transcendent memory" interface for swap pages.
+In some environments, dramatic performance savings may be obtained because
+swapped pages are saved in RAM (or a RAM-like device) instead of a swap disk.
+
+Frontswap is so named because it can be thought of as the opposite of
+a "backing" store for a swap device.  The storage is assumed to be
+a synchronous concurrency-safe page-oriented "pseudo-RAM device" conforming
+to the requirements of transcendent memory (such as Xen's "tmem", or
+in-kernel compressed memory, aka "zcache", or future RAM-like devices);
+this pseudo-RAM device is not directly accessible or addressable by the
+kernel and is of unknown and possibly time-varying size.  The "device"
+links itself to frontswap by calling frontswap_register_ops to set the
+frontswap_ops funcs appropriately and the functions it provides must
+conform to certain policies as follows:
+
+An "init" prepares the device to receive frontswap pages associated
+with the specified swap device number (aka "type").  A "put_page" will
+copy the page to transcendent memory and associate it with the type and
+offset associated with the page. A "get_page" will copy the page, if found,
+from transcendent memory into kernel memory, but will NOT remove the page
+from from transcendent memory.  A "flush_page" will remove the page from
+transcendent memory and a "flush_area" will remove ALL pages associated
+with the swap type (e.g., like swapoff) and notify the "device" to refuse
+further puts with that swap type.
+
+Once a page is successfully put, a matching get on the page will always
+succeed.  So when the kernel finds itself in a situation where it needs
+to swap out a page, it first attempts to use frontswap.  If the put returns
+non-zero, the data has been successfully saved to transcendent memory and
+a disk write and, if the data is later read back, a disk read are avoided.
+If a put returns zero, transcendent memory has rejected the data, and the
+page can be written to swap as usual.
+
+Note that if a page is put and the page already exists in transcendent memory
+(a "duplicate" put), either the put succeeds and the data is overwritten,
+or the put fails AND the page is flushed.  This ensures stale data may
+never be obtained from psuedo-RAM.
+
+Monitoring and control of frontswap is done by sysfs files in the
+/sys/kernel/mm/frontswap directory.  The effectiveness of frontswap can
+be measured (across all swap devices) with:
+
+curr_pages	- number of pages currently contained in frontswap
+failed_puts	- how many put attempts have failed
+gets		- how many gets were attempted (all should succeed)
+succ_puts	- how many put attempts have succeeded
+flushes		- how many flushes were attempted
+
+The number can be reduced by root by writing an integer target to curr_pages,
+which results in a "partial swapoff", thus reducing the number of frontswap
+pages to that target if memory constraints permit.
+
+FAQ
+
+1) Where's the value?
+
+When a workload starts swapping, performance falls through the floor.
+Frontswap significantly increases performance in many such workloads by
+providing a clean, dynamic interface to read and write swap pages to
+"transcendent" memory that is otherwise not directly addressable to the kernel.
+This interface is ideal when data is transformed to a different form
+and size (such as with compression) or secretly moved (as might be
+useful for write-balancing for some RAM-like devices).  Swap pages (and
+evicted page-cache pages) are a great use for this kind of slower-than-RAM-
+but-much-faster-than-disk "pseudo-RAM device" and the frontswap (and
+cleancache) interface to transcendent memory provides a nice way to read
+and write -- and indirectly "name" -- the pages.
+
+In the virtual case, the whole point of virtualization is to statistically
+multiplex physical resources acrosst the varying demands of multiple
+virtual machines.  This is really hard to do with RAM and efforts to do
+it well with no kernel changes have essentially failed (except in some
+well-publicized special-case workloads).  Frontswap -- and cleancache --
+with a fairly small impact on the kernel, provides a huge amount
+of flexibility for more dynamic, flexible RAM multiplexing.
+Specifically, the Xen Transcendent Memory backend allows otherwise
+"fallow" hypervisor-owned RAM to not only be "time-shared" between multiple
+virtual machines, but the pages can be compressed and deduplicated to
+optimize RAM utilization.  And when guest OS's are induced to surrender
+underutilized RAM (e.g. with "self-ballooning"), sudden unexpected
+memory pressure may result in swapping; frontswap allows those pages
+to be swapped to and from hypervisor RAM if overall host system memory
+conditions allow.
+
+2) Sure there may be performance advantages in some situations, but
+   what's the space/time overhead of frontswap?
+
+If CONFIG_FRONTSWAP is disabled, every frontswap hook compiles into
+nothingness and the only overhead is a few extra bytes per swapon'ed
+swap device.  If CONFIG_FRONTSWAP is enabled but no frontswap "backend"
+registers, there is one extra global variable compared to zero for
+every swap page read or written.  If CONFIG_FRONTSWAP is enabled
+AND a frontswap backend registers AND the backend fails every "put"
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
+This notifies frontswap to expect attempts to "put" swap pages
+associated with that number.
+
+Whenever the swap subsystem is readying a page to write to a swap
+device (c.f swap_writepage()), frontswap_put_page is called.  Frontswap
+consults with the frontswap backend and if the backend says
+it does NOT have room, frontswap_put_page returns 0 and the page is
+swapped as normal.  Note that the response from the frontswap
+backend is essentially random; it may choose to never accept a
+page, it could accept every ninth page, or it might accept every
+page.  But if the backend does accept a page, the data from the page
+has already been copied and associated with the type and offset,
+and the backend guarantees the persistence of the data.  In this case,
+frontswap sets a bit in the "frontswap_map" for the swap device
+corresponding to the page offset on the swap device to which it would
+otherwise have written the data.
+
+When the swap subsystem needs to swap-in a page (swap_readpage()),
+it first calls frontswap_get_page() which checks the frontswap_map to
+see if the page was earlier accepted by the frontswap backend.  If
+it was, the page of data is filled from the frontswap backend and
+the swap-in is complete.  If not, the normal swap-in code is
+executed to obtain the page of data from the real swap device.
+
+So every time the frontswap backend accepts a page, a swap device read
+and (potentially) a swap device write are replaced by a "frontswap backend
+put" and (possibly) a "frontswap backend get", which are presumably much
+faster.
+
+4) Can't frontswap be configured as a "special" swap device that is
+   just higher priority than any real swap device (e.g. like zswap)?
+
+No.  Recall that acceptance of any swap page by the frontswap
+backend is entirely unpredictable. This is critical to the definition
+of frontswap because it grants completely dynamic discretion to the
+backend.  But since any "put" might fail, there must always be a real
+slot on a real swap device to swap the page.  Thus frontswap must be
+implemented as a "shadow" to every swapon'd device with the potential
+capability of holding every page that the swap device might have held
+and the possibility that it might hold no pages at all.
+On the downside, this also means that frontswap cannot contain more
+pages than the total of swapon'd swap devices.  For example, if NO
+swap device is configured on some installation, frontswap is useless.
+
+Further, frontswap is entirely synchronous whereas a real swap
+device is, by definition, asynchronous and uses block I/O.  The
+block I/O layer is not only unnecessary, but may perform "optimizations"
+that are inappropriate for a RAM-oriented device including delaying
+the write of some pages for a significant amount of time.
+Synchrony is required to ensure the dynamicity of the backend.
+
+In a virtualized environment, the dynamicity allows the hypervisor
+(or host OS) to do "intelligent overcommit".  For example, it can
+choose to accept pages only until host-swapping might be imminent,
+then force guests to do their own swapping.
+
+5) Why this weird definition about "duplicate puts"?  If a page
+   has been previously successfully put, can't it always be
+   successfully overwritten?
+
+Nearly always it can, but no, sometimes it cannot.  Consider an example
+where data is compressed and the original 4K page has been compressed
+to 1K.  Now an attempt is made to overwrite the page with data that
+is non-compressible and so would take the entire 4K.  But the backend
+has no more space.  In this case, the put must be rejected.  Whenever
+frontswap rejects a put that would overwrite, it also must flush
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
+routine allows a process outside of the swap subsystem (such as
+a userland service via the sysfs interface, or a kernel thread)
+to force pages out of the memory managed by frontswap and back into
+kernel-addressable memory.
+
+7) Why does the frontswap patch create the new include file swapfile.h?
+
+The frontswap code depends on some swap-subsystem-internal data
+structures that have, over the years, moved back and forth between
+static and global.  This seemed a reasonable compromise:  Define
+them as global but declare them in a new include file that isn't
+included by the large number of source files that include swap.h.
+
+Dan Magenheimer, last updated May 27, 2011

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
