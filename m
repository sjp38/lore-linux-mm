Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8267F6B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 15:20:24 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so14625402pdj.11
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 12:20:24 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id t6si16858862pbg.275.2014.01.02.12.20.20
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 12:20:20 -0800 (PST)
Subject: [PATCH 3/3] Kconfig: organize memory-related config options
From: Dave Hansen <dave@sr71.net>
Date: Thu, 02 Jan 2014 12:20:17 -0800
References: <20140102202014.CA206E9B@viggo.jf.intel.com>
In-Reply-To: <20140102202014.CA206E9B@viggo.jf.intel.com>
Message-Id: <20140102202017.9D167747@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, linux-mm@kvack.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This continues in a series of patches to clean up the
configuration menus.  I believe they've become really hard to
navigate and there are some simple things we can do to make
things easier to find.

This creates a "Memory Options" menu and moves some things like
swap and slab configuration under them.  It also moves SLUB_DEBUG
to the debugging menu.

After this patch, the menu has the following options:

  [ ] Memory placement aware NUMA scheduler
  [*] Enable VM event counters for /proc/vmstat
  [ ] Disable heap randomization
  [*] Support for paging of anonymous memory (swap)
      Choose SLAB allocator (SLUB (Unqueued Allocator))
  [*] SLUB per cpu partial cache
  [*] SLUB: attempt to use double-cmpxchg operations

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-mm@kvack.org
---

 linux.git-davehans/init/Kconfig     |  243 ++++++++++++++++++------------------
 linux.git-davehans/mm/Kconfig.debug |   11 +
 2 files changed, 135 insertions(+), 119 deletions(-)

diff -puN init/Kconfig~organize-memory-config-options init/Kconfig
--- linux.git/init/Kconfig~organize-memory-config-options	2014-01-02 11:24:20.925790194 -0800
+++ linux.git-davehans/init/Kconfig	2014-01-02 11:24:20.931790464 -0800
@@ -208,16 +208,6 @@ config DEFAULT_HOSTNAME
 	  but you may wish to use a different default here to make a minimal
 	  system more usable with less configuration.
 
-config SWAP
-	bool "Support for paging of anonymous memory (swap)"
-	depends on MMU && BLOCK
-	default y
-	help
-	  This option allows you to choose whether you want to have support
-	  for so called swap devices or swap files in your kernel that are
-	  used to provide more virtual memory than the actual RAM present
-	  in your computer.  If unsure say Y.
-
 config SYSVIPC
 	bool "System V IPC"
 	---help---
@@ -760,6 +750,130 @@ endchoice
 
 endmenu # "RCU Subsystem"
 
+menu "Memory Options"
+
+config NUMA_BALANCING
+	bool "Memory placement aware NUMA scheduler"
+	depends on ARCH_SUPPORTS_NUMA_BALANCING
+	depends on !ARCH_WANT_NUMA_VARIABLE_LOCALITY
+	depends on SMP && NUMA && MIGRATION
+	help
+	  This option adds support for automatic NUMA aware memory/task placement.
+	  The mechanism is quite primitive and is based on migrating memory when
+	  it has references to the node the task is running on.
+
+	  This system will be inactive on UMA systems.
+
+config VM_EVENT_COUNTERS
+	default y
+	bool "Enable VM event counters for /proc/vmstat" if EXPERT
+	help
+	  VM event counters are needed for event counts to be shown.
+	  This option allows the disabling of the VM event counters
+	  on EXPERT systems.  /proc/vmstat will only show page counts
+	  if VM event counters are disabled.
+
+config COMPAT_BRK
+	bool "Disable heap randomization"
+	default y
+	help
+	  Randomizing heap placement makes heap exploits harder, but it
+	  also breaks ancient binaries (including anything libc5 based).
+	  This option changes the bootup default to heap randomization
+	  disabled, and can be overridden at runtime by setting
+	  /proc/sys/kernel/randomize_va_space to 2.
+
+	  On non-ancient distros (post-2000 ones) N is usually a safe choice.
+
+config SWAP
+	bool "Support for paging of anonymous memory (swap)"
+	depends on MMU && BLOCK
+	default y
+	help
+	  This option allows you to choose whether you want to have support
+	  for so called swap devices or swap files in your kernel that are
+	  used to provide more virtual memory than the actual RAM present
+	  in your computer.  If unsure say Y.
+
+choice
+	prompt "Choose SLAB allocator"
+	default SLUB
+	help
+	   This option allows to select a slab allocator.
+
+config SLAB
+	bool "SLAB"
+	help
+	  The regular slab allocator that is established and known to work
+	  well in all environments. It organizes cache hot objects in
+	  per cpu and per node queues.
+
+config SLUB
+	bool "SLUB (Unqueued Allocator)"
+	help
+	   SLUB is a slab allocator that minimizes cache line usage
+	   instead of managing queues of cached objects (SLAB approach).
+	   Per cpu caching is realized using slabs of objects instead
+	   of queues of objects. SLUB can use memory efficiently
+	   and has enhanced diagnostics. SLUB is the default choice for
+	   a slab allocator.
+
+config SLOB
+	depends on EXPERT
+	bool "SLOB (Simple Allocator)"
+	help
+	   SLOB replaces the stock allocator with a drastically simpler
+	   allocator. SLOB is generally more space efficient but
+	   does not perform as well on large systems.
+
+endchoice
+
+config SLUB_CPU_PARTIAL
+	default y
+	depends on SLUB && SMP
+	bool "SLUB per cpu partial cache"
+	help
+	  Per cpu partial caches accellerate objects allocation and freeing
+	  that is local to a processor at the price of more indeterminism
+	  in the latency of the free. On overflow these caches will be cleared
+	  which requires the taking of locks that may cause latency spikes.
+	  Typically one would choose no for a realtime system.
+
+config SLUB_ATTEMPT_CMPXCHG_DOUBLE
+	default y
+	depends on SLUB && HAVE_CMPXCHG_DOUBLE
+	bool "SLUB: attempt to use double-cmpxchg operations"
+	help
+	  Some CPUs support instructions that let you do a large double-word
+	  atomic cmpxchg operation.  This keeps the SLUB fastpath from
+	  needing to disable interrupts.
+
+	  If you are unsure, say y.
+
+config MMAP_ALLOW_UNINITIALIZED
+	bool "Allow mmapped anonymous memory to be uninitialized"
+	depends on EXPERT && !MMU
+	default n
+	help
+	  Normally, and according to the Linux spec, anonymous memory obtained
+	  from mmap() has it's contents cleared before it is passed to
+	  userspace.  Enabling this config option allows you to request that
+	  mmap() skip that if it is given an MAP_UNINITIALIZED flag, thus
+	  providing a huge performance boost.  If this option is not enabled,
+	  then the flag will be ignored.
+
+	  This is taken advantage of by uClibc's malloc(), and also by
+	  ELF-FDPIC binfmt's brk and stack allocator.
+
+	  Because of the obvious security issues, this option should only be
+	  enabled on embedded devices where you control what is run in
+	  userspace.  Since that isn't generally a problem on no-MMU systems,
+	  it is normally safe to say Y here.
+
+	  See Documentation/nommu-mmap.txt for more information.
+
+endmenu # "Memory Optionse
+
 config IKCONFIG
 	tristate "Kernel .config support"
 	---help---
@@ -840,18 +954,6 @@ config NUMA_BALANCING_DEFAULT_ENABLED
 	  If set, automatic NUMA balancing will be enabled if running on a NUMA
 	  machine.
 
-config NUMA_BALANCING
-	bool "Memory placement aware NUMA scheduler"
-	depends on ARCH_SUPPORTS_NUMA_BALANCING
-	depends on !ARCH_WANT_NUMA_VARIABLE_LOCALITY
-	depends on SMP && NUMA && MIGRATION
-	help
-	  This option adds support for automatic NUMA aware memory/task placement.
-	  The mechanism is quite primitive and is based on migrating memory when
-	  it has references to the node the task is running on.
-
-	  This system will be inactive on UMA systems.
-
 menuconfig CGROUPS
 	boolean "Control Group support"
 	depends on EVENTFD
@@ -1529,103 +1631,6 @@ config DEBUG_PERF_USE_VMALLOC
 
 endmenu
 
-config VM_EVENT_COUNTERS
-	default y
-	bool "Enable VM event counters for /proc/vmstat" if EXPERT
-	help
-	  VM event counters are needed for event counts to be shown.
-	  This option allows the disabling of the VM event counters
-	  on EXPERT systems.  /proc/vmstat will only show page counts
-	  if VM event counters are disabled.
-
-config SLUB_DEBUG
-	default y
-	bool "Enable SLUB debugging support" if EXPERT
-	depends on SLUB && SYSFS
-	help
-	  SLUB has extensive debug support features. Disabling these can
-	  result in significant savings in code size. This also disables
-	  SLUB sysfs support. /sys/slab will not exist and there will be
-	  no support for cache validation etc.
-
-config COMPAT_BRK
-	bool "Disable heap randomization"
-	default y
-	help
-	  Randomizing heap placement makes heap exploits harder, but it
-	  also breaks ancient binaries (including anything libc5 based).
-	  This option changes the bootup default to heap randomization
-	  disabled, and can be overridden at runtime by setting
-	  /proc/sys/kernel/randomize_va_space to 2.
-
-	  On non-ancient distros (post-2000 ones) N is usually a safe choice.
-
-choice
-	prompt "Choose SLAB allocator"
-	default SLUB
-	help
-	   This option allows to select a slab allocator.
-
-config SLAB
-	bool "SLAB"
-	help
-	  The regular slab allocator that is established and known to work
-	  well in all environments. It organizes cache hot objects in
-	  per cpu and per node queues.
-
-config SLUB
-	bool "SLUB (Unqueued Allocator)"
-	help
-	   SLUB is a slab allocator that minimizes cache line usage
-	   instead of managing queues of cached objects (SLAB approach).
-	   Per cpu caching is realized using slabs of objects instead
-	   of queues of objects. SLUB can use memory efficiently
-	   and has enhanced diagnostics. SLUB is the default choice for
-	   a slab allocator.
-
-config SLOB
-	depends on EXPERT
-	bool "SLOB (Simple Allocator)"
-	help
-	   SLOB replaces the stock allocator with a drastically simpler
-	   allocator. SLOB is generally more space efficient but
-	   does not perform as well on large systems.
-
-endchoice
-
-config SLUB_CPU_PARTIAL
-	default y
-	depends on SLUB && SMP
-	bool "SLUB per cpu partial cache"
-	help
-	  Per cpu partial caches accellerate objects allocation and freeing
-	  that is local to a processor at the price of more indeterminism
-	  in the latency of the free. On overflow these caches will be cleared
-	  which requires the taking of locks that may cause latency spikes.
-	  Typically one would choose no for a realtime system.
-
-config MMAP_ALLOW_UNINITIALIZED
-	bool "Allow mmapped anonymous memory to be uninitialized"
-	depends on EXPERT && !MMU
-	default n
-	help
-	  Normally, and according to the Linux spec, anonymous memory obtained
-	  from mmap() has it's contents cleared before it is passed to
-	  userspace.  Enabling this config option allows you to request that
-	  mmap() skip that if it is given an MAP_UNINITIALIZED flag, thus
-	  providing a huge performance boost.  If this option is not enabled,
-	  then the flag will be ignored.
-
-	  This is taken advantage of by uClibc's malloc(), and also by
-	  ELF-FDPIC binfmt's brk and stack allocator.
-
-	  Because of the obvious security issues, this option should only be
-	  enabled on embedded devices where you control what is run in
-	  userspace.  Since that isn't generally a problem on no-MMU systems,
-	  it is normally safe to say Y here.
-
-	  See Documentation/nommu-mmap.txt for more information.
-
 config PROFILING
 	bool "Profiling support"
 	help
diff -puN mm/Kconfig.debug~organize-memory-config-options mm/Kconfig.debug
--- linux.git/mm/Kconfig.debug~organize-memory-config-options	2014-01-02 11:24:20.927790284 -0800
+++ linux.git-davehans/mm/Kconfig.debug	2014-01-02 11:24:20.931790464 -0800
@@ -27,3 +27,14 @@ config PAGE_POISONING
 config PAGE_GUARD
 	bool
 	select WANT_PAGE_DEBUG_FLAGS
+
+config SLUB_DEBUG
+	default y
+	bool "Enable SLUB debugging support" if EXPERT
+	depends on SLUB && SYSFS
+	help
+	  SLUB has extensive debug support features. Disabling these can
+	  result in significant savings in code size. This also disables
+	  SLUB sysfs support. /sys/slab will not exist and there will be
+	  no support for cache validation etc.
+
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
