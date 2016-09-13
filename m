Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0AA26B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 04:39:52 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id mi5so1328314pab.2
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 01:39:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id yv3si26460643pab.56.2016.09.13.01.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 01:39:51 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8D8cG1Z050296
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 04:39:49 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25dxu43ads-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 04:39:49 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rui.teng@linux.vnet.ibm.com>;
	Tue, 13 Sep 2016 02:39:48 -0600
From: Rui Teng <rui.teng@linux.vnet.ibm.com>
Subject: [PATCH] memory-hotplug: Fix bad area access on dissolve_free_huge_pages()
Date: Tue, 13 Sep 2016 16:39:08 +0800
Message-Id: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>

Santhosh G reported that call traces occurs when memory-hotplug script is run
with 16Gb hugepages configured.

It was found that the page_hstate(page) will get 0 if the PageHead(page) return
false, Which will cause the bad area access.

Issue:
Call traces occurs when memory-hotplug script is run with 16Gb hugepages configured.

Environment:
ppc64le PowerVM Lpar

root@ltctuleta-lp1:~# uname -r
4.4.0-34-generic

root@ltctuleta-lp1:~# cat /proc/meminfo | grep -i huge
AnonHugePages:         0 kB
HugePages_Total:       2
HugePages_Free:        2
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:   16777216 kB

root@ltctuleta-lp1:~# free -h
              total        used        free      shared  buff/cache   available
Mem:            85G         32G         52G         16M        193M         52G
Swap:           43G          0B         43G

Steps to reproduce:
1 - Download kernel source and enter to the directory- tools/testing/selftests/memory-hotplug/
2 - Run  mem-on-off-test.sh script in it.

System gives call traces like:

offline_memory_expect_success 639: unexpected fail
online-offline 668
[   57.552964] Unable to handle kernel paging request for data at address 0x00000028
[   57.552977] Faulting instruction address: 0xc00000000029bc04
[   57.552987] Oops: Kernel access of bad area, sig: 11 [#1]
[   57.552992] SMP NR_CPUS=2048 NUMA pSeries
[   57.553002] Modules linked in: btrfs xor raid6_pq pseries_rng sunrpc autofs4 ses enclosure nouveau bnx2x i2c_algo_bit ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm vxlan ip6_udp_tunnel ipr udp_tunnel rtc_generic mdio libcrc32c
[   57.553050] CPU: 44 PID: 6518 Comm: mem-on-off-test Not tainted 4.4.0-34-generic #53-Ubuntu
[   57.553059] task: c00000072773c8e0 ti: c000000727780000 task.ti: c000000727780000
[   57.553067] NIP: c00000000029bc04 LR: c00000000029bbdc CTR: c0000000001107f0
[   57.553076] REGS: c000000727783770 TRAP: 0300   Not tainted  (4.4.0-34-generic)
[   57.553083] MSR: 8000000100009033 <SF,EE,ME,IR,DR,RI,LE>  CR: 24242882  XER: 00000002
[   57.553104] CFAR: c000000000008468 DAR: 0000000000000028 DSISR: 40000000 SOFTE: 1
GPR00: c00000000029bbdc c0000007277839f0 c0000000015b5d00 0000000000000000
GPR04: 000000000029d000 0000000000000800 0000000000000000 f00000000a000001
GPR08: f00000000a700020 0000000000000008 c00000000185e270 c000000e7e000050
GPR12: 0000000000002200 c00000000e6ea200 000000000029d000 0000000022000000
GPR16: 1000000000000000 c0000000015e2200 000000000a700000 0000000000000000
GPR20: 0000000000010000 0000000000000100 0000000000000200 c0000000015f16d0
GPR24: c000000001876510 0000000000000000 0000000000000001 c000000001872a00
GPR28: 000000000029d000 f000000000000000 f00000000a700000 000000000029c000
[   57.553211] NIP [c00000000029bc04] dissolve_free_huge_pages+0x154/0x220
[   57.553219] LR [c00000000029bbdc] dissolve_free_huge_pages+0x12c/0x220
[   57.553226] Call Trace:
[   57.553231] [c0000007277839f0] [c00000000029bbdc] dissolve_free_huge_pages+0x12c/0x220 (unreliable)
[   57.553244] [c000000727783a80] [c0000000002dcbc8] __offline_pages.constprop.6+0x3f8/0x900
[   57.553254] [c000000727783bd0] [c0000000006fbb38] memory_subsys_offline+0xa8/0x110
[   57.553265] [c000000727783c00] [c0000000006d6424] device_offline+0x104/0x140
[   57.553274] [c000000727783c40] [c0000000006fba80] store_mem_state+0x180/0x190
[   57.553283] [c000000727783c80] [c0000000006d1e58] dev_attr_store+0x68/0xa0
[   57.553293] [c000000727783cc0] [c000000000398110] sysfs_kf_write+0x80/0xb0
[   57.553302] [c000000727783d00] [c000000000397028] kernfs_fop_write+0x188/0x200
[   57.553312] [c000000727783d50] [c0000000002e190c] __vfs_write+0x6c/0xe0
[   57.553321] [c000000727783d90] [c0000000002e2640] vfs_write+0xc0/0x230
[   57.553329] [c000000727783de0] [c0000000002e367c] SyS_write+0x6c/0x110
[   57.553339] [c000000727783e30] [c000000000009204] system_call+0x38/0xb4
[   57.553346] Instruction dump:
[   57.553351] 7e831836 4bfff991 e91e0028 e8fe0020 7d32e82a f9070008 f8e80000 fabe0020
[   57.553366] fade0028 79294620 79291764 7d234a14 <e9030028> 3908ffff f9030028 81091458
[   57.553383] ---[ end trace 617f7bdd75bcfc10 ]---
[   57.557133]
Segmentation fault

Reported-by: Santhosh G <santhog4@in.ibm.com>
Signed-off-by: Rui Teng <rui.teng@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 87e11d8..64b5f81 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1442,7 +1442,7 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 static void dissolve_free_huge_page(struct page *page)
 {
 	spin_lock(&hugetlb_lock);
-	if (PageHuge(page) && !page_count(page)) {
+	if (PageHuge(page) && !page_count(page) && PageHead(page)) {
 		struct hstate *h = page_hstate(page);
 		int nid = page_to_nid(page);
 		list_del(&page->lru);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
