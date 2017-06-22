Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 782986B02C3
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 08:26:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u8so14088835pgo.11
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 05:26:17 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id l20si1077927pgu.585.2017.06.22.05.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 05:26:16 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/5] x86: Enable 5-level paging support
Date: Thu, 22 Jun 2017 15:26:04 +0300
Message-Id: <20170622122608.80435-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170622122608.80435-1-kirill.shutemov@linux.intel.com>
References: <20170622122608.80435-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Most of things are in place and we can enable support of 5-level paging.

The patch makes XEN_PV dependent on !X86_5LEVEL. XEN_PV is not ready to
work with 5-level paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
---
 Documentation/x86/x86_64/5level-paging.txt | 64 ++++++++++++++++++++++++++++++
 arch/x86/Kconfig                           | 18 +++++++++
 arch/x86/xen/Kconfig                       |  3 ++
 3 files changed, 85 insertions(+)
 create mode 100644 Documentation/x86/x86_64/5level-paging.txt

diff --git a/Documentation/x86/x86_64/5level-paging.txt b/Documentation/x86/x86_64/5level-paging.txt
new file mode 100644
index 000000000000..087251a0d99c
--- /dev/null
+++ b/Documentation/x86/x86_64/5level-paging.txt
@@ -0,0 +1,64 @@
+== Overview ==
+
+Original x86-64 was limited by 4-level paing to 256 TiB of virtual address
+space and 64 TiB of physical address space. We are already bumping into
+this limit: some vendors offers servers with 64 TiB of memory today.
+
+To overcome the limitation upcoming hardware will introduce support for
+5-level paging. It is a straight-forward extension of the current page
+table structure adding one more layer of translation.
+
+It bumps the limits to 128 PiB of virtual address space and 4 PiB of
+physical address space. This "ought to be enough for anybody" A(C).
+
+QEMU 2.9 and later support 5-level paging.
+
+Virtual memory layout for 5-level paging is described in
+Documentation/x86/x86_64/mm.txt
+
+== Enabling 5-level paging ==
+
+CONFIG_X86_5LEVEL=y enables the feature.
+
+So far, a kernel compiled with the option enabled will be able to boot
+only on machines that supports the feature -- see for 'la57' flag in
+/proc/cpuinfo.
+
+The plan is to implement boot-time switching between 4- and 5-level paging
+in the future.
+
+== User-space and large virtual address space ==
+
+On x86, 5-level paging enables 56-bit userspace virtual address space.
+Not all user space is ready to handle wide addresses. It's known that
+at least some JIT compilers use higher bits in pointers to encode their
+information. It collides with valid pointers with 5-level paging and
+leads to crashes.
+
+To mitigate this, we are not going to allocate virtual address space
+above 47-bit by default.
+
+But userspace can ask for allocation from full address space by
+specifying hint address (with or without MAP_FIXED) above 47-bits.
+
+If hint address set above 47-bit, but MAP_FIXED is not specified, we try
+to look for unmapped area by specified address. If it's already
+occupied, we look for unmapped area in *full* address space, rather than
+from 47-bit window.
+
+A high hint address would only affect the allocation in question, but not
+any future mmap()s.
+
+Specifying high hint address on older kernel or on machine without 5-level
+paging support is safe. The hint will be ignored and kernel will fall back
+to allocation from 47-bit address space.
+
+This approach helps to easily make application's memory allocator aware
+about large address space without manually tracking allocated virtual
+address space.
+
+One important case we need to handle here is interaction with MPX.
+MPX (without MAWA extension) cannot handle addresses above 47-bit, so we
+need to make sure that MPX cannot be enabled we already have VMA above
+the boundary and forbid creating such VMAs once MPX is enabled.
+
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 72028a16327b..dc91c1763736 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -320,6 +320,7 @@ config FIX_EARLYCON_MEM
 
 config PGTABLE_LEVELS
 	int
+	default 5 if X86_5LEVEL
 	default 4 if X86_64
 	default 3 if X86_PAE
 	default 2
@@ -1392,6 +1393,23 @@ config X86_PAE
 	  has the cost of more pagetable lookup overhead, and also
 	  consumes more pagetable space per process.
 
+config X86_5LEVEL
+	bool "Enable 5-level page tables support"
+	depends on X86_64
+	---help---
+	  5-level paging enables access to larger address space:
+	  upto 128 PiB of virtual address space and 4 PiB of
+	  physical address space.
+
+	  It will be supported by future Intel CPUs.
+
+	  Note: kernel with the option enabled can only be booted
+	  on machines that support the feature.
+
+	  See Documentation/x86/x86_64/5level-paging.txt for more info.
+
+	  Say N if unsure.
+
 config ARCH_PHYS_ADDR_T_64BIT
 	def_bool y
 	depends on X86_64 || X86_PAE
diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
index 027987638e98..72bd4c62b742 100644
--- a/arch/x86/xen/Kconfig
+++ b/arch/x86/xen/Kconfig
@@ -17,6 +17,9 @@ config XEN_PV
 	bool "Xen PV guest support"
 	default y
 	depends on XEN
+	# XEN_PV is not ready to work with 5-level paging.
+	# Changes to hypervisor are also required.
+	depends on !X86_5LEVEL
 	select XEN_HAVE_PVMMU
 	select XEN_HAVE_VPMU
 	help
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
