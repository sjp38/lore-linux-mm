Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 901A66B0257
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:50:40 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fi3so11057962pac.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:50:40 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id s63si11215041pfs.86.2016.03.03.02.50.39
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 02:50:39 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [RFC qemu 1/4] pc: Add code to get the lowmem form PCMachineState
Date: Thu,  3 Mar 2016 18:44:25 +0800
Message-Id: <1457001868-15949-2-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org
Cc: mst@redhat.com, akpm@linux-foundation.org, pbonzini@redhat.com, rth@twiddle.net, ehabkost@redhat.com, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, dgilbert@redhat.com, Liang Li <liang.z.li@intel.com>

The lowmem will be used by the following patch to get
a correct free pages bitmap.

Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 hw/i386/pc.c         | 5 +++++
 hw/i386/pc_piix.c    | 1 +
 hw/i386/pc_q35.c     | 1 +
 include/hw/i386/pc.h | 3 ++-
 4 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/hw/i386/pc.c b/hw/i386/pc.c
index 0aeefd2..f794a84 100644
--- a/hw/i386/pc.c
+++ b/hw/i386/pc.c
@@ -1115,6 +1115,11 @@ void pc_hot_add_cpu(const int64_t id, Error **errp)
     object_unref(OBJECT(cpu));
 }
 
+ram_addr_t pc_get_lowmem(PCMachineState *pcms)
+{
+   return pcms->lowmem;
+}
+
 void pc_cpus_init(PCMachineState *pcms)
 {
     int i;
diff --git a/hw/i386/pc_piix.c b/hw/i386/pc_piix.c
index 6f8c2cd..268a08c 100644
--- a/hw/i386/pc_piix.c
+++ b/hw/i386/pc_piix.c
@@ -113,6 +113,7 @@ static void pc_init1(MachineState *machine,
         }
     }
 
+    pcms->lowmem = lowmem;
     if (machine->ram_size >= lowmem) {
         pcms->above_4g_mem_size = machine->ram_size - lowmem;
         pcms->below_4g_mem_size = lowmem;
diff --git a/hw/i386/pc_q35.c b/hw/i386/pc_q35.c
index 46522c9..8d9bd39 100644
--- a/hw/i386/pc_q35.c
+++ b/hw/i386/pc_q35.c
@@ -101,6 +101,7 @@ static void pc_q35_init(MachineState *machine)
         }
     }
 
+    pcms->lowmem = lowmem;
     if (machine->ram_size >= lowmem) {
         pcms->above_4g_mem_size = machine->ram_size - lowmem;
         pcms->below_4g_mem_size = lowmem;
diff --git a/include/hw/i386/pc.h b/include/hw/i386/pc.h
index 8b3546e..3694c91 100644
--- a/include/hw/i386/pc.h
+++ b/include/hw/i386/pc.h
@@ -60,7 +60,7 @@ struct PCMachineState {
     bool nvdimm;
 
     /* RAM information (sizes, addresses, configuration): */
-    ram_addr_t below_4g_mem_size, above_4g_mem_size;
+    ram_addr_t below_4g_mem_size, above_4g_mem_size, lowmem;
 
     /* CPU and apic information: */
     bool apic_xrupt_override;
@@ -229,6 +229,7 @@ void pc_hot_add_cpu(const int64_t id, Error **errp);
 void pc_acpi_init(const char *default_dsdt);
 
 void pc_guest_info_init(PCMachineState *pcms);
+ram_addr_t pc_get_lowmem(PCMachineState *pcms);
 
 #define PCI_HOST_PROP_PCI_HOLE_START   "pci-hole-start"
 #define PCI_HOST_PROP_PCI_HOLE_END     "pci-hole-end"
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
