Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8BF8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:51:57 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id t10so6022715plo.13
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 02:51:57 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id g7si12245300plt.212.2018.12.11.02.51.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 11 Dec 2018 02:51:55 -0800 (PST)
Date: Tue, 11 Dec 2018 02:51:51 -0800
From: tip-bot for Michal Hocko <tipbot@zytor.com>
Message-ID: <tip-5b5e4d623ec8a34689df98e42d038a3b594d2ff9@git.kernel.org>
Reply-To: ak@linux.intel.com, linux-mm@kvack.org, tglx@linutronix.de,
        hpa@zytor.com, mhocko@suse.com, linux-kernel@vger.kernel.org,
        pasha.tatashin@soleen.com, dave.hansen@intel.com, jkosina@suse.cz,
        torvalds@linux-foundation.org, mingo@kernel.org, bp@suse.de
In-Reply-To: <20181113184910.26697-1-mhocko@kernel.org>
References: <20181113184910.26697-1-mhocko@kernel.org>
Subject: [tip:x86/pti] x86/speculation/l1tf: Drop the swap storage limit
 restriction when l1tf=off
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: tglx@linutronix.de, linux-mm@kvack.org, ak@linux.intel.com, pasha.tatashin@soleen.com, linux-kernel@vger.kernel.org, mhocko@suse.com, hpa@zytor.com, dave.hansen@intel.com, jkosina@suse.cz, bp@suse.de, mingo@kernel.org, torvalds@linux-foundation.org

Commit-ID:  5b5e4d623ec8a34689df98e42d038a3b594d2ff9
Gitweb:     https://git.kernel.org/tip/5b5e4d623ec8a34689df98e42d038a3b594d2ff9
Author:     Michal Hocko <mhocko@suse.com>
AuthorDate: Tue, 13 Nov 2018 19:49:10 +0100
Committer:  Thomas Gleixner <tglx@linutronix.de>
CommitDate: Tue, 11 Dec 2018 11:46:13 +0100

x86/speculation/l1tf: Drop the swap storage limit restriction when l1tf=off

Swap storage is restricted to max_swapfile_size (~16TB on x86_64) whenever
the system is deemed affected by L1TF vulnerability. Even though the limit
is quite high for most deployments it seems to be too restrictive for
deployments which are willing to live with the mitigation disabled.

We have a customer to deploy 8x 6,4TB PCIe/NVMe SSD swap devices which is
clearly out of the limit.

Drop the swap restriction when l1tf=off is specified. It also doesn't make
much sense to warn about too much memory for the l1tf mitigation when it is
forcefully disabled by the administrator.

[ tglx: Folded the documentation delta change ]

Fixes: 377eeaa8e11f ("x86/speculation/l1tf: Limit swap file size to MAX_PA/2")
Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Jiri Kosina <jkosina@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: <linux-mm@kvack.org>
Cc: stable@vger.kernel.org
Link: https://lkml.kernel.org/r/20181113184910.26697-1-mhocko@kernel.org

---
 Documentation/admin-guide/kernel-parameters.txt | 3 +++
 Documentation/admin-guide/l1tf.rst              | 6 +++++-
 arch/x86/kernel/cpu/bugs.c                      | 3 ++-
 arch/x86/mm/init.c                              | 2 +-
 4 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 05a252e5178d..835e422572eb 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2095,6 +2095,9 @@
 			off
 				Disables hypervisor mitigations and doesn't
 				emit any warnings.
+				It also drops the swap size and available
+				RAM limit restriction on both hypervisor and
+				bare metal.
 
 			Default is 'flush'.
 
diff --git a/Documentation/admin-guide/l1tf.rst b/Documentation/admin-guide/l1tf.rst
index b85dd80510b0..9af977384168 100644
--- a/Documentation/admin-guide/l1tf.rst
+++ b/Documentation/admin-guide/l1tf.rst
@@ -405,6 +405,9 @@ time with the option "l1tf=". The valid arguments for this option are:
 
   off		Disables hypervisor mitigations and doesn't emit any
 		warnings.
+		It also drops the swap size and available RAM limit restrictions
+		on both hypervisor and bare metal.
+
   ============  =============================================================
 
 The default is 'flush'. For details about L1D flushing see :ref:`l1d_flush`.
@@ -576,7 +579,8 @@ Default mitigations
   The kernel default mitigations for vulnerable processors are:
 
   - PTE inversion to protect against malicious user space. This is done
-    unconditionally and cannot be controlled.
+    unconditionally and cannot be controlled. The swap storage is limited
+    to ~16TB.
 
   - L1D conditional flushing on VMENTER when EPT is enabled for
     a guest.
diff --git a/arch/x86/kernel/cpu/bugs.c b/arch/x86/kernel/cpu/bugs.c
index a68b32cb845a..58689ac64440 100644
--- a/arch/x86/kernel/cpu/bugs.c
+++ b/arch/x86/kernel/cpu/bugs.c
@@ -1002,7 +1002,8 @@ static void __init l1tf_select_mitigation(void)
 #endif
 
 	half_pa = (u64)l1tf_pfn_limit() << PAGE_SHIFT;
-	if (e820__mapped_any(half_pa, ULLONG_MAX - half_pa, E820_TYPE_RAM)) {
+	if (l1tf_mitigation != L1TF_MITIGATION_OFF &&
+			e820__mapped_any(half_pa, ULLONG_MAX - half_pa, E820_TYPE_RAM)) {
 		pr_warn("System has more than MAX_PA/2 memory. L1TF mitigation not effective.\n");
 		pr_info("You may make it effective by booting the kernel with mem=%llu parameter.\n",
 				half_pa);
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index ef99f3892e1f..427a955a2cf2 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -931,7 +931,7 @@ unsigned long max_swapfile_size(void)
 
 	pages = generic_max_swapfile_size();
 
-	if (boot_cpu_has_bug(X86_BUG_L1TF)) {
+	if (boot_cpu_has_bug(X86_BUG_L1TF) && l1tf_mitigation != L1TF_MITIGATION_OFF) {
 		/* Limit the swap file size to MAX_PA/2 for L1TF workaround */
 		unsigned long long l1tf_limit = l1tf_pfn_limit();
 		/*
