From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH 2/2] arm64: add faultaround mm hook
Date: Tue, 28 Nov 2017 10:37:50 +0530
Message-ID: <1511845670-12133-2-git-send-email-vinmenon@codeaurora.org>
References: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: riel@redhat.com, jack@suse.cz, catalin.marinas@arm.com, dave.hansen@linux.intel.com, will.deacon@arm.com, minchan@kernel.org, Vinayak Menon <vinmenon@codeaurora.org>, mgorman@suse.de, ying.huang@intel.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com
List-Id: linux-mm.kvack.org

The ptes produced by faultaround feature are by default young
and that is found to cause page reclaim issues [1]. But making
the ptes old results in a unixbench regression for some
architectures [2]. But arm64 doesn't show the regression.

unixbench shell8 scores (5 runs min, max, avg):
Base: (741,748,744)
With this patch: (739,748,743)

Add a faultaround mm hook to make the faultaround ptes old only for arm64.

[1] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmenon@codeaurora.org
[2] https://marc.info/?l=linux-kernel&m=146582237922378&w=2

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 arch/arm64/include/asm/Kbuild          |  1 -
 arch/arm64/include/asm/mm-arch-hooks.h | 20 ++++++++++++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)
 create mode 100644 arch/arm64/include/asm/mm-arch-hooks.h

diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index e63d0a8..0043f7c 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -13,7 +13,6 @@ generic-y += kmap_types.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += msi.h
 generic-y += preempt.h
 generic-y += qrwlock.h
diff --git a/arch/arm64/include/asm/mm-arch-hooks.h b/arch/arm64/include/asm/mm-arch-hooks.h
new file mode 100644
index 0000000..b34d730
--- /dev/null
+++ b/arch/arm64/include/asm/mm-arch-hooks.h
@@ -0,0 +1,20 @@
+#ifndef _ASM_MM_ARCH_HOOKS_H
+#define _ASM_MM_ARCH_HOOKS_H
+
+#ifdef CONFIG_ARM64_HW_AFDBM
+static inline void arch_faultaround_pte_mkold(struct vm_fault *vmf)
+{
+	if (vmf->address != vmf->fault_address)
+		vmf->flags |= FAULT_FLAG_MKOLD;
+	else
+		vmf->flags &= ~FAULT_FLAG_MKOLD;
+}
+#else
+static inline void arch_faultaround_pte_mkold(struct vm_fault *vmf)
+{
+}
+#endif
+
+#define arch_faultaround_pte_mkold arch_faultaround_pte_mkold
+
+#endif /* _ASM_MM_ARCH_HOOKS_H */
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation
