Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id B0C616B0002
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 09:52:41 -0500 (EST)
Date: Mon, 11 Feb 2013 14:52:36 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] x86: mm: Check if PUD is large when validating a kernel
 address
Message-ID: <20130211145236.GX21389@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A user reported the following oops when a backup process read
/proc/kcore.

 BUG: unable to handle kernel paging request at ffffbb00ff33b000
 IP: [<ffffffff8103157e>] kern_addr_valid+0xbe/0x110
 PGD 0
 Oops: 0000 [#1] SMP
 CPU 6
 Modules linked in: af_packet nfs lockd fscache auth_rpcgss nfs_acl sunrpc 8021q garp stp llc cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse nls_iso8859_1 nls_cp437 vfat fat loop dm_mod ioatdma ipv6 ipv6_lib igb dca i7core_edac edac_core i2c_i801 i2c_core cdc_ether usbnet bnx2 mii iTCO_wdt iTCO_vendor_support shpchp rtc_cmos pci_hotplug tpm_tis sg tpm pcspkr tpm_bios serio_raw button ext3 jbd mbcache uhci_hcd ehci_hcd usbcore sd_mod crc_t10dif usb_common processor thermal_sys hwmon scsi_dh_emc scsi_dh_rdac scsi_dh_alua scsi_dh_hp_sw scsi_dh ata_generic ata_piix libata megaraid_sas scsi_mod

 Pid: 16196, comm: Hibackp Not tainted 3.0.13-0.27-default #1 IBM System x3550 M3 -[7944 K3G]-/94Y7614
 RIP: 0010:[<ffffffff8103157e>]  [<ffffffff8103157e>] kern_addr_valid+0xbe/0x110
 RSP: 0018:ffff88094165fe80  EFLAGS: 00010246
 RAX: 00003300ff33b000 RBX: ffff880100000000 RCX: 0000000000000000
 RDX: 0000000100000000 RSI: ffff880000000000 RDI: ff32b300ff33b400
 RBP: 0000000000001000 R08: 00003ffffffff000 R09: 0000000000000000
 R10: 22302e31223d6e6f R11: 0000000000000246 R12: 0000000000001000
 R13: 0000000000003000 R14: 0000000000571be0 R15: ffff88094165ff50
 FS:  00007ff152d33700(0000) GS:ffff88097f2c0000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 CR2: ffffbb00ff33b000 CR3: 00000009405a3000 CR4: 00000000000006e0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process Hibackp (pid: 16196, threadinfo ffff88094165e000, task ffff8808eb9ba600)
 Stack:
  ffffffff811b8aaa 0000000000004000 ffff880943fea480 ffff8808ef2bae50
  ffff880943d32980 fffffffffffffffb ffff8808ef2bae40 ffff88094165ff50
  0000000000004000 000000000056ebe0 ffffffff811ad847 000000000056ebe0
 Call Trace:
  [<ffffffff811b8aaa>] read_kcore+0x17a/0x370
  [<ffffffff811ad847>] proc_reg_read+0x77/0xc0
  [<ffffffff81151687>] vfs_read+0xc7/0x130
  [<ffffffff811517f3>] sys_read+0x53/0xa0
  [<ffffffff81449692>] system_call_fastpath+0x16/0x1b

Investigation determined that the bug triggered when reading system RAM
at the 4G mark. On this system, that was the first address using 1G pages
for the virt->phys direct mapping so the PUD is pointing to a physical
address, not a PMD page.  The problem is that the page table walker in
kern_addr_valid() is not checking pud_large() and treats the physical
address as if it was a PMD.  If it happens to look like pmd_none then it'll
silently fail, probably returning zeros instead of real data. If the data
happens to look like a present PMD though, it will be walked resulting in
the oops above. This patch adds the necessary pud_large() check.

Unfortunately the problem was not readily reproducible and now they are
running the backup program without accessing /proc/kcore so the patch has
not been validated but I think it makes sense. If reviewers agree then it
should also be included in -stable back as far as 3.0-stable.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/include/asm/pgtable.h |    5 +++++
 arch/x86/mm/init_64.c          |    3 +++
 2 files changed, 8 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5199db2..1c1a955 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -142,6 +142,11 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
 	return (pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT;
 }
 
+static inline unsigned long pud_pfn(pud_t pud)
+{
+	return (pud_val(pud) & PTE_PFN_MASK) >> PAGE_SHIFT;
+}
+
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
 
 static inline int pmd_large(pmd_t pte)
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 2ead3c8..75c9a6a 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -831,6 +831,9 @@ int kern_addr_valid(unsigned long addr)
 	if (pud_none(*pud))
 		return 0;
 
+	if (pud_large(*pud))
+		return pfn_valid(pud_pfn(*pud));
+
 	pmd = pmd_offset(pud, addr);
 	if (pmd_none(*pmd))
 		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
