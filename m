Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 714BA6B0038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 14:32:59 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id y10so8833313wgg.30
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 11:32:58 -0700 (PDT)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [2001:4b98:c:538::196])
        by mx.google.com with ESMTPS id h4si11639264wib.20.2014.09.25.11.32.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 11:32:58 -0700 (PDT)
Date: Thu, 25 Sep 2014 11:32:54 -0700
From: josh@joshtriplett.org
Subject: [PATCHv2] mm: Support compiling out madvise and fadvise
Message-ID: <20140925183254.GA9575@cloud>
References: <20140922161109.GA25027@thin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140922161109.GA25027@thin>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org

Many embedded systems will not need these syscalls, and omitting them
saves space.  Add a new EXPERT config option CONFIG_ADVISE_SYSCALLS
(default y) to support compiling them out.

bloat-o-meter:
add/remove: 0/3 grow/shrink: 0/0 up/down: 0/-2250 (-2250)
function                                     old     new   delta
sys_fadvise64                                 57       -     -57
sys_fadvise64_64                             691       -    -691
sys_madvise                                 1502       -   -1502

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---

v2: Don't make fadvise depend on CONFIG_MMU.

 init/Kconfig    | 10 ++++++++++
 kernel/sys_ni.c |  3 +++
 mm/Makefile     |  8 ++++++--
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index e84c642..782a65b 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1537,6 +1537,16 @@ config AIO
 	  by some high performance threaded applications. Disabling
 	  this option saves about 7k.
 
+config ADVISE_SYSCALLS
+	bool "Enable madvise/fadvise syscalls" if EXPERT
+	default y
+	help
+	  This option enables the madvise and fadvise syscalls, used by
+	  applications to advise the kernel about their future memory or file
+	  usage, improving performance. If building an embedded system where no
+	  applications use these syscalls, you can disable this option to save
+	  space.
+
 config PCI_QUIRKS
 	default y
 	bool "Enable PCI quirk workarounds" if EXPERT
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 391d4dd..d4709d4 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -156,6 +156,9 @@ cond_syscall(sys_process_vm_writev);
 cond_syscall(compat_sys_process_vm_readv);
 cond_syscall(compat_sys_process_vm_writev);
 cond_syscall(sys_uselib);
+cond_syscall(sys_fadvise64);
+cond_syscall(sys_fadvise64_64);
+cond_syscall(sys_madvise);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
diff --git a/mm/Makefile b/mm/Makefile
index 632ae77..2ad574d 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -3,7 +3,7 @@
 #
 
 mmu-y			:= nommu.o
-mmu-$(CONFIG_MMU)	:= fremap.o gup.o highmem.o madvise.o memory.o mincore.o \
+mmu-$(CONFIG_MMU)	:= fremap.o gup.o highmem.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
 			   vmalloc.o pagewalk.o pgtable-generic.o
 
@@ -11,7 +11,7 @@ ifdef CONFIG_CROSS_MEMORY_ATTACH
 mmu-$(CONFIG_MMU)	+= process_vm_access.o
 endif
 
-obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
+obj-y			:= filemap.o mempool.o oom_kill.o \
 			   maccess.o page_alloc.o page-writeback.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
@@ -28,6 +28,10 @@ else
 	obj-y		+= bootmem.o
 endif
 
+obj-$(CONFIG_ADVISE_SYSCALLS)	+= fadvise.o
+ifdef CONFIG_MMU
+	obj-$(CONFIG_ADVISE_SYSCALLS)	+= madvise.o
+endif
 obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
