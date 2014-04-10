Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 073DC6B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 19:08:10 -0400 (EDT)
Received: by mail-yh0-f43.google.com with SMTP id b6so4587423yha.16
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 16:08:09 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id h22si6222055yhf.119.2014.04.10.16.08.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 16:08:09 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 10 Apr 2014 17:08:08 -0600
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8A5EC38C8027
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 19:08:05 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3AN852110224028
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 23:08:05 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3AN842K002344
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 19:08:05 -0400
Date: Thu, 10 Apr 2014 16:07:59 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH] hugetlb: ensure hugepage access is denied if hugepages are
 not supported
Message-ID: <20140410230758.GC4181@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akmp@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, linuxppc-dev@lists.ozlabs.org

In KVM guests on Power, in a guest not backed by hugepages, we see the
following:

AnonHugePages:         0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:         64 kB

HPAGE_SHIFT == 0 in this configuration, which indicates that hugepages
are not supported at boot-time, but this is only checked in
hugetlb_init(). Extract the check to a helper function, and use it in a
few relevant places.

Without this change, I am seeing the following when I `mount -t
hugetlbfs /none /dev/hugetlbfs`, and then simply do a `ls
/dev/hugetlbfs`. I think it's related to the fact that hugetlbfs is
properly not correctly setting itself up in this state?:

Unable to handle kernel paging request for data at address 0x00000031
Faulting instruction address: 0xc000000000245710
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=2048 NUMA pSeries
Modules linked in: pseries_rng rng_core virtio_net virtio_pci
virtio_ring virtio
CPU: 0 PID: 1807 Comm: ls Not tainted 3.14.0-rc7-00066-g774868c-dirty
task: c00000007e804520 ti: c00000007aed4000 task.ti: c00000007aed4000
NIP: c000000000245710 LR: c00000000024586c CTR: 0000000000000000
REGS: c00000007aed74f0 TRAP: 0300   Not tainted
+(3.14.0-rc7-00066-g774868c-dirty)
MSR: 8000000000009033 <SF,EE,ME,IR,DR,RI,LE>  CR: 24002484  XER: 00000000
CFAR: 00003fff91037760 DAR: 0000000000000031 DSISR: 40000000 SOFTE: 1
GPR00: c00000000024586c c00000007aed7770 c000000000d85420 c00000007d7a0010
GPR04: c000000000abcf20 c000000000ed7c78 0000000000000020 c000000000cbc880
GPR08: 0000000000000000 0000000000000000 0000000080000000 0000000000000002
GPR12: 0000000044002484 c00000000fe40000 0000000000000000 00000000100232f0
GPR16: 0000000000000001 0000000000000000 0000000000000000 c00000007d794a40
GPR20: 0000000000000000 0000000000000024 c00000007a49a200 c00000007a2bd000
GPR24: c00000007aed7bb8 c00000007d7a0090 0000000000014800 0000000000000000
GPR28: c00000007d7a0010 c00000007a49a210 c00000007d7a0150 0000000000000001
NIP [c000000000245710] .time_out_leases+0x30/0x100
LR [c00000000024586c] .__break_lease+0x8c/0x480
Call Trace:
[c00000007aed7770] [c0000000002434c0] .lease_alloc+0x20/0xe0 (unreliable)
[c00000007aed77f0] [c00000000024586c] .__break_lease+0x8c/0x480
[c00000007aed78e0] [c0000000001e0374] .do_dentry_open.isra.14+0xf4/0x370
[c00000007aed7980] [c0000000001e0624] .finish_open+0x34/0x60
[c00000007aed7a00] [c0000000001f519c] .do_last+0x56c/0xe40
[c00000007aed7b20] [c0000000001f5b68] .path_openat+0xf8/0x800
[c00000007aed7c40] [c0000000001f7810] .do_filp_open+0x40/0xb0
[c00000007aed7d70] [c0000000001e1f08] .do_sys_open+0x198/0x2e0
[c00000007aed7e30] [c00000000000a158] syscall_exit+0x0/0x98

Additionally, using hugepages in such guests eventually crashes the
guest kerenl, as hugepages aren't actually supported and we end up
corrupting various lists in the core MM.

This does make hugetlbfs not supported in this environment. I believe
this is fine, as there are no valid hugepages and that won't change at
runtime.

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Mel Gorman <mgorman@suse.de>

---

v1 -> v2: removed RFC
v2 -> v3: updated changelog to include hugetlbfs crash and other error
information, change hugetlbfs printk to KERN_INFO

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 2040275..ea8d677 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -1030,6 +1030,11 @@ static int __init init_hugetlbfs_fs(void)
 	int error;
 	int i;
 
+	if (!hugepages_supported()) {
+		printk(KERN_INFO "hugetlbfs: Disabling because there are no supported hugepage sizes\n");
+		return -ENOTSUPP;
+	}
+
 	error = bdi_init(&hugetlbfs_backing_dev_info);
 	if (error)
 		return error;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 5b337cf..b0f0a1c 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -460,4 +460,14 @@ static inline spinlock_t *huge_pte_lock(struct hstate *h,
 	return ptl;
 }
 
+static inline bool hugepages_supported(void)
+{
+	/*
+	 * Some platform decide whether they support huge pages at boot
+	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
+	 * there is no such support
+	 */
+	return HPAGE_SHIFT != 0;
+}
+
 #endif /* _LINUX_HUGETLB_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index dd30f22..fd43528 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1980,11 +1980,7 @@ static int __init hugetlb_init(void)
 {
 	int i;
 
-	/* Some platform decide whether they support huge pages at boot
-	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
-	 * there is no such support
-	 */
-	if (HPAGE_SHIFT == 0)
+	if (!hugepages_supported())
 		return 0;
 
 	if (!size_to_hstate(default_hstate_size)) {
@@ -2111,6 +2107,9 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
 	unsigned long tmp;
 	int ret;
 
+	if (!hugepages_supported())
+		return -ENOTSUPP;
+
 	tmp = h->max_huge_pages;
 
 	if (write && h->order >= MAX_ORDER)
@@ -2164,6 +2163,9 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 	unsigned long tmp;
 	int ret;
 
+	if (!hugepages_supported())
+		return -ENOTSUPP;
+
 	tmp = h->nr_overcommit_huge_pages;
 
 	if (write && h->order >= MAX_ORDER)
@@ -2189,6 +2191,8 @@ out:
 void hugetlb_report_meminfo(struct seq_file *m)
 {
 	struct hstate *h = &default_hstate;
+	if (!hugepages_supported())
+		return;
 	seq_printf(m,
 			"HugePages_Total:   %5lu\n"
 			"HugePages_Free:    %5lu\n"
@@ -2205,6 +2209,8 @@ void hugetlb_report_meminfo(struct seq_file *m)
 int hugetlb_report_node_meminfo(int nid, char *buf)
 {
 	struct hstate *h = &default_hstate;
+	if (!hugepages_supported())
+		return 0;
 	return sprintf(buf,
 		"Node %d HugePages_Total: %5u\n"
 		"Node %d HugePages_Free:  %5u\n"
@@ -2219,6 +2225,9 @@ void hugetlb_show_meminfo(void)
 	struct hstate *h;
 	int nid;
 
+	if (!hugepages_supported())
+		return;
+
 	for_each_node_state(nid, N_MEMORY)
 		for_each_hstate(h)
 			pr_info("Node %d hugepages_total=%u hugepages_free=%u hugepages_surp=%u hugepages_size=%lukB\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
