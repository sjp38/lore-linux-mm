Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3E56B0256
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:49:42 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so166329365wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 08:49:41 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id go6si12390789wib.82.2015.09.22.08.49.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 08:49:41 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 6CF5698A4E
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:49:40 +0000 (UTC)
Date: Tue, 22 Sep 2015 16:49:38 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: hugetlbfs: Skip shared VMAs when unmapping private
 pages to satisfy a fault
Message-ID: <20150922154938.GE3068@techsingularity.net>
References: <20150922123151.GD3068@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150922123151.GD3068@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: SunDong <sund_sky@126.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 22, 2015 at 01:31:51PM +0100, Mel Gorman wrote:
> SunDong reported the following on https://bugzilla.kernel.org/show_bug.cgi?id=103841
> 

Michal Hocko correctly pointed out privately that this should have
checked VM_MAYSHARE for the reasons outlined in commit f83a275dbc5c ("mm:
account for MAP_SHARED mappings using VM_MAYSHARE and not VM_SHARED in
hugetlbfs"). Please take this version instead if it passes testing

---8<---
mm: hugetlbfs: Skip shared VMAs when unmapping private pages to satisfy a fault

SunDong reported the following on https://bugzilla.kernel.org/show_bug.cgi?id=103841

	I think I find a linux bug, I have the test cases is constructed. I
	can stable recurring problems in fedora22(4.0.4) kernel version,
	arch for x86_64.  I construct transparent huge page, when the parent
	and child process with MAP_SHARE, MAP_PRIVATE way to access the same
	huge page area, it has the opportunity to lead to huge page copy on
	write failure, and then it will munmap the child corresponding mmap
	area, but then the child mmap area with VM_MAYSHARE attributes, child
	process munmap this area can trigger VM_BUG_ON in set_vma_resv_flags
	functions (vma - > vm_flags & VM_MAYSHARE).

There were a number of problems with the report (e.g. it's hugetlbfs that
triggers this, not transparent huge pages) but it was fundamentally correct
in that a VM_BUG_ON in set_vma_resv_flags() can be triggered that looks
like this

	 vma ffff8804651fd0d0 start 00007fc474e00000 end 00007fc475e00000
	 next ffff8804651fd018 prev ffff8804651fd188 mm ffff88046b1b1800
	 prot 8000000000000027 anon_vma           (null) vm_ops ffffffff8182a7a0
	 pgoff 0 file ffff88106bdb9800 private_data           (null)
	 flags: 0x84400fb(read|write|shared|mayread|maywrite|mayexec|mayshare|dontexpand|hugetlb)
	 ------------
	 kernel BUG at mm/hugetlb.c:462!
	 SMP
	 Modules linked in: xt_pkttype xt_LOG xt_limit iscsi_ibft iscsi_boot_sysfs af_packet ip6t_REJECT nf_reject_ipv6
xt_tcpudp nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_raw ipt_REJECT nf_reject_ipv4 iptable_raw xt_CT iptable_filter ip6table_mangle
nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables xt_conntrack nf_conntrack ip6table_filter
ip6_tables x_tables intel_powerclamp coretemp kvm_intel kvm mgag200 ttm drm_kms_helper drm crct10dif_pclmul crc32_pclmul crc32c_intel
ghash_clmulni_intel aesni_intel aes_x86_64 lrw ipmi_devintf gf128mul iTCO_wdt gpio_ich iTCO_vendor_support glue_helper ablk_helper
dcdbas i7core_edac cryptd syscopyarea sysfillrect bnx2 sysimgblt lpc_ich serio_raw edac_core i2c_algo_bit shpchp mfd_core ipmi_si
tpm_tis tpm ipmi_msghandler wmi acpi_power_meter button acpi_cpufreq processor dm_mod sr_mod cdrom ata_generic hid_generic usbhid hid
uhci_hcd ehci_pci ehci_hcd usbcore ata_piix usb_common megaraid_sas sg
	 CPU: 38 PID: 26839 Comm: map Not tainted 4.0.4-default #1
	 Hardware name: Dell Inc. PowerEdge R810/0TT6JF, BIOS 2.7.4 04/26/2012
	 task: ffff88085ed10490 ti: ffff88085ed14000 task.ti: ffff88085ed14000
	 set_vma_resv_flags+0x2d/0x30

The VM_BUG_ON is correct because private and shared mappings have different
reservation accounting but the warning clearly shows that the VMA is shared.

When a private COW fails to allocate a new page then only the process that
created the VMA gets the page -- all the children unmap the page. If the
children access that data in the future then they get killed.

The problem is that the same file is mapped shared and private. During
the COW, the allocation fails, the VMAs are traversed to unmap the other
private pages but a shared VMA is found and the bug is triggered. This
patch identifies such VMAs and skips them.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Reported-by: SunDong <sund_sky@126.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 999fb0aef8f1..9cc773483624 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3202,6 +3202,14 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 			continue;
 
 		/*
+		 * Shared VMAs have their own reserves and do not affect
+		 * MAP_PRIVATE accounting but it is possible that a shared
+		 * VMA is using the same page so check and skip such VMAs.
+		 */
+		if (iter_vma->vm_flags & VM_MAYSHARE)
+			continue;
+
+		/*
 		 * Unmap the page from other VMAs without their own reserves.
 		 * They get marked to be SIGKILLed if they fault in these
 		 * areas. This is because a future no-page fault on this VMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
