Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38E686B0003
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 14:27:50 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id m21so12548908otl.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 11:27:50 -0700 (PDT)
Received: from scalemp.com (www.scalemp.com. [169.44.78.149])
        by mx.google.com with ESMTPS id s13-v6si6956235oih.203.2018.11.01.11.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 11:27:48 -0700 (PDT)
From: Eial Czerwacki <eial@scalemp.com>
Subject: [PATCH v2] x86/build: Build VSMP support only if CONFIG_PCI is
 selected
Message-ID: <2130cd90-2c8f-2fc4-0ac8-81a5aea153b2@scalemp.com>
Date: Thu, 1 Nov 2018 20:27:37 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Randy Dunlap <rdunlap@infradead.org>, "Shai Fultheim (Shai@ScaleMP.com)" <Shai@ScaleMP.com>, Andrew Morton <akpm@linux-foundation.org>, "broonie@kernel.org" <broonie@kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, X86 ML <x86@kernel.org>, Oren Twaig <oren@scalemp.com>

vsmp dependency on pv_irq_ops removed some years ago, so now let's clean
it up from vsmp_64.c.

In short, "cap & ctl & (1 << 4)" was always returning 0, as such we can
remove all the PARAVIRT/PARAVIRT_XXL code handling that.

However, the rest of the code depends on CONFIG_PCI, so fix it accordingly.
in addition, rename set_vsmp_pv_ops to set_vsmp_ctl.

Signed-off-by: Eial Czerwacki <eial@scalemp.com>
Acked-by: Shai Fultheim <shai@scalemp.com>
---
 arch/x86/Kconfig          |  1 -
 arch/x86/kernel/vsmp_64.c | 84
++++-------------------------------------------
 2 files changed, 7 insertions(+), 78 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index c51c989..4b187ca 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -524,7 +524,6 @@ config X86_VSMP
        bool "ScaleMP vSMP"
        select HYPERVISOR_GUEST
        select PARAVIRT
-       select PARAVIRT_XXL
        depends on X86_64 && PCI
        depends on X86_EXTENDED_PLATFORM
        depends on SMP
diff --git a/arch/x86/kernel/vsmp_64.c b/arch/x86/kernel/vsmp_64.c
index 1eae5af..4862576 100644
--- a/arch/x86/kernel/vsmp_64.c
+++ b/arch/x86/kernel/vsmp_64.c
@@ -26,65 +26,8 @@

 #define TOPOLOGY_REGISTER_OFFSET 0x10

-#if defined CONFIG_PCI && defined CONFIG_PARAVIRT_XXL
-/*
- * Interrupt control on vSMPowered systems:
- * ~AC is a shadow of IF.  If IF is 'on' AC should be 'off'
- * and vice versa.
- */
-
-asmlinkage __visible unsigned long vsmp_save_fl(void)
-{
-       unsigned long flags = native_save_fl();
-
-       if (!(flags & X86_EFLAGS_IF) || (flags & X86_EFLAGS_AC))
-               flags &= ~X86_EFLAGS_IF;
-       return flags;
-}
-PV_CALLEE_SAVE_REGS_THUNK(vsmp_save_fl);
-
-__visible void vsmp_restore_fl(unsigned long flags)
-{
-       if (flags & X86_EFLAGS_IF)
-               flags &= ~X86_EFLAGS_AC;
-       else
-               flags |= X86_EFLAGS_AC;
-       native_restore_fl(flags);
-}
-PV_CALLEE_SAVE_REGS_THUNK(vsmp_restore_fl);
-
-asmlinkage __visible void vsmp_irq_disable(void)
-{
-       unsigned long flags = native_save_fl();
-
-       native_restore_fl((flags & ~X86_EFLAGS_IF) | X86_EFLAGS_AC);
-}
-PV_CALLEE_SAVE_REGS_THUNK(vsmp_irq_disable);
-
-asmlinkage __visible void vsmp_irq_enable(void)
-{
-       unsigned long flags = native_save_fl();
-
-       native_restore_fl((flags | X86_EFLAGS_IF) & (~X86_EFLAGS_AC));
-}
-PV_CALLEE_SAVE_REGS_THUNK(vsmp_irq_enable);
-
-static unsigned __init vsmp_patch(u8 type, void *ibuf,
-                                 unsigned long addr, unsigned len)
-{
-       switch (type) {
-       case PARAVIRT_PATCH(irq.irq_enable):
-       case PARAVIRT_PATCH(irq.irq_disable):
-       case PARAVIRT_PATCH(irq.save_fl):
-       case PARAVIRT_PATCH(irq.restore_fl):
-               return paravirt_patch_default(type, ibuf, addr, len);
-       default:
-               return native_patch(type, ibuf, addr, len);
-       }
-
-}
-
-static void __init set_vsmp_pv_ops(void)
+#if defined CONFIG_PCI
+static void __init set_vsmp_ctl(void)
 {
        void __iomem *address;
        unsigned int cap, ctl, cfg;
@@ -109,28 +52,12 @@ static void __init set_vsmp_pv_ops(void)
        }
 #endif

-       if (cap & ctl & (1 << 4)) {
-               /* Setup irq ops and turn on vSMP  IRQ fastpath handling */
-               pv_ops.irq.irq_disable = PV_CALLEE_SAVE(vsmp_irq_disable);
-               pv_ops.irq.irq_enable = PV_CALLEE_SAVE(vsmp_irq_enable);
-               pv_ops.irq.save_fl = PV_CALLEE_SAVE(vsmp_save_fl);
-               pv_ops.irq.restore_fl = PV_CALLEE_SAVE(vsmp_restore_fl);
-               pv_ops.init.patch = vsmp_patch;
-               ctl &= ~(1 << 4);
-       }
        writel(ctl, address + 4);
        ctl = readl(address + 4);
        pr_info("vSMP CTL: control set to:0x%08x\n", ctl);

        early_iounmap(address, 8);
 }
-#else
-static void __init set_vsmp_pv_ops(void)
-{
-}
-#endif
-
-#ifdef CONFIG_PCI
 static int is_vsmp = -1;

 static void __init detect_vsmp_box(void)
@@ -164,11 +91,14 @@ static int is_vsmp_box(void)
 {
        return 0;
 }
+static void __init set_vsmp_ctl(void)
+{
+}
 #endif

 static void __init vsmp_cap_cpus(void)
 {
-#if !defined(CONFIG_X86_VSMP) && defined(CONFIG_SMP)
+#if !defined(CONFIG_X86_VSMP) && defined(CONFIG_SMP) && defined(CONFIG_PCI)
        void __iomem *address;
        unsigned int cfg, topology, node_shift, maxcpus;

@@ -221,6 +151,6 @@ void __init vsmp_init(void)

        vsmp_cap_cpus();

-       set_vsmp_pv_ops();
+       set_vsmp_ctl();
        return;
 }
-- 
2.7.4
