Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 088E26B0655
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 01:47:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y129so4453570pgy.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 22:47:04 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id z20si21145747pgn.160.2017.08.02.22.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 22:47:03 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id t86so559783pfe.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 22:47:03 -0700 (PDT)
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH] mm: fix list corruptions on shmem shrinklist
Date: Wed,  2 Aug 2017 22:46:30 -0700
Message-Id: <20170803054630.18775-1-xiyou.wangcong@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, stable@kernel.org, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

We saw many list corruption warnings on shmem shrinklist:

 [45480.300911] ------------[ cut here ]------------
 [45480.305558] WARNING: CPU: 18 PID: 177 at lib/list_debug.c:59 __list_del_entry+0x9e/0xc0
 [45480.313622] list_del corruption. prev->next should be ffff9ae5694b82d8, but was ffff9ae5699ba960
 [45480.322435] Modules linked in: intel_rapl sb_edac edac_core x86_pkg_temp_thermal coretemp iTCO_wdt iTCO_vendor_support crct10dif_pclmul crc32_pclmul ghash_clmulni_intel raid0 dcdbas shpchp wmi hed i2c_i801 ioatdma lpc_ich i2c_smbus acpi_cpufreq tcp_diag inet_diag sch_fq_codel ipmi_si ipmi_devintf ipmi_msghandler igb ptp crc32c_intel pps_core i2c_algo_bit i2c_core dca ipv6 crc_ccitt
 [45480.357776] CPU: 18 PID: 177 Comm: kswapd1 Not tainted 4.9.34-t3.el7.twitter.x86_64 #1
 [45480.365679] Hardware name: Dell Inc. PowerEdge C6220/0W6W6G, BIOS 2.2.3 11/07/2013
 [45480.373416]  ffffb13c03ccbaf8 ffffffff9e36bc87 ffffb13c03ccbb48 0000000000000000
 [45480.380940]  ffffb13c03ccbb38 ffffffff9e08511b 0000003b7fffc000 0000000000000002
 [45480.388392]  ffff9ae5699ba960 ffffb13c03ccbbe8 ffffb13c03ccbbf8 ffff9ae5694b82d8
 [45480.395893] Call Trace:
 [45480.398214]  [<ffffffff9e36bc87>] dump_stack+0x4d/0x66
 [45480.403481]  [<ffffffff9e08511b>] __warn+0xcb/0xf0
 [45480.408322]  [<ffffffff9e08518f>] warn_slowpath_fmt+0x4f/0x60
 [45480.414095]  [<ffffffff9e38a6fe>] __list_del_entry+0x9e/0xc0
 [45480.419831]  [<ffffffff9e1a33aa>] shmem_unused_huge_shrink+0xfa/0x2e0
 [45480.426269]  [<ffffffff9e1a35b0>] shmem_unused_huge_scan+0x20/0x30
 [45480.432382]  [<ffffffff9e20a0d3>] super_cache_scan+0x193/0x1a0
 [45480.438238]  [<ffffffff9e19a9c3>] shrink_slab.part.41+0x1e3/0x3f0
 [45480.444370]  [<ffffffff9e19abf9>] shrink_slab+0x29/0x30
 [45480.449610]  [<ffffffff9e19ed39>] shrink_node+0xf9/0x2f0
 [45480.454858]  [<ffffffff9e19fbd8>] kswapd+0x2d8/0x6c0
 [45480.459896]  [<ffffffff9e19f900>] ? mem_cgroup_shrink_node+0x140/0x140
 [45480.466337]  [<ffffffff9e0a3b87>] kthread+0xd7/0xf0
 [45480.471231]  [<ffffffff9e0b519e>] ? vtime_account_idle+0xe/0x50
 [45480.477282]  [<ffffffff9e0a3ab0>] ? kthread_park+0x60/0x60
 [45480.482820]  [<ffffffff9e6d4c52>] ret_from_fork+0x22/0x30
 [45480.488234] ---[ end trace 66841eda03a967a0 ]---
 [45480.492834] ------------[ cut here ]------------
 [45480.497432] WARNING: CPU: 23 PID: 639 at lib/list_debug.c:33 __list_add+0x89/0xb0
 [45480.505020] list_add corruption. prev->next should be next (ffff9ae5699ba960), but was ffff9ae5694b82d8. (prev=ffff9ae5694b82d8).
 [45480.516716] Modules linked in: intel_rapl sb_edac edac_core x86_pkg_temp_thermal coretemp iTCO_wdt iTCO_vendor_support crct10dif_pclmul crc32_pclmul ghash_clmulni_intel raid0 dcdbas shpchp wmi hed i2c_i801 ioatdma lpc_ich i2c_smbus acpi_cpufreq tcp_diag inet_diag sch_fq_codel ipmi_si ipmi_devintf ipmi_msghandler igb ptp crc32c_intel pps_core i2c_algo_bit i2c_core dca ipv6 crc_ccitt
 [45480.551020] CPU: 23 PID: 639 Comm: systemd-udevd Tainted: G        W       4.9.34-t3.el7.twitter.x86_64 #1
 [45480.560706] Hardware name: Dell Inc. PowerEdge C6220/0W6W6G, BIOS 2.2.3 11/07/2013
 [45480.568299]  ffffb13c04913b30 ffffffff9e36bc87 ffffb13c04913b80 0000000000000000
 [45480.575628]  ffffb13c04913b70 ffffffff9e08511b 00000021699ba900 ffff9ae5694b82d8
 [45480.583080]  ffff9ae5694b82d8 ffff9ae5699ba960 ffff9ae5699ba900 0000000000000000
 [45480.590560] Call Trace:
 [45480.592937]  [<ffffffff9e36bc87>] dump_stack+0x4d/0x66
 [45480.598144]  [<ffffffff9e08511b>] __warn+0xcb/0xf0
 [45480.602978]  [<ffffffff9e08518f>] warn_slowpath_fmt+0x4f/0x60
 [45480.608718]  [<ffffffff9e38a639>] __list_add+0x89/0xb0
 [45480.613785]  [<ffffffff9e1a55d4>] shmem_setattr+0x204/0x230
 [45480.619340]  [<ffffffff9e2232ef>] notify_change+0x2ef/0x440
 [45480.624929]  [<ffffffff9e203bad>] do_truncate+0x5d/0x90
 [45480.630184]  [<ffffffff9e20393a>] ? do_dentry_open+0x27a/0x310
 [45480.635974]  [<ffffffff9e214101>] path_openat+0x331/0x1190
 [45480.641549]  [<ffffffff9e21680e>] do_filp_open+0x7e/0xe0
 [45480.646791]  [<ffffffff9e1bb3f4>] ? handle_mm_fault+0xa54/0x1340
 [45480.652888]  [<ffffffff9e1e6703>] ? kmem_cache_alloc+0xd3/0x1a0
 [45480.658778]  [<ffffffff9e215927>] ? getname_flags+0x37/0x190
 [45480.664527]  [<ffffffff9e22423f>] ? __alloc_fd+0x3f/0x170
 [45480.669918]  [<ffffffff9e205023>] do_sys_open+0x123/0x200
 [45480.675339]  [<ffffffff9e20511e>] SyS_open+0x1e/0x20
 [45480.680216]  [<ffffffff9e002aa1>] do_syscall_64+0x61/0x170
 [45480.685805]  [<ffffffff9e6d4ac6>] entry_SYSCALL64_slow_path+0x25/0x25
 [45480.692255] ---[ end trace 66841eda03a967a1 ]---
 [45480.696823] ------------[ cut here ]------------

The problem is that shmem_unused_huge_shrink() moves entries
from the global sbinfo->shrinklist to its local lists and then
releases the spinlock. However, a parallel shmem_setattr()
could access one of these entries directly and add it back to
the global shrinklist if it is removed, with the spinlock held.

The logic itself looks solid since an entry could be either
in a local list or the global list, otherwise it is removed
from one of them by list_del_init(). So probably the race
condition is that, one CPU is in the middle of INIT_LIST_HEAD()
but the other CPU calls list_empty() which returns true
too early then the following list_add_tail() sees a corrupted
entry.

list_empty_careful() is designed to fix this situation.

Fixes: 779750d20b93 ("shmem: split huge pages beyond i_size under memory pressure")
Cc: linux-mm@kvack.org
Cc: stable@kernel.org
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 mm/shmem.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index b0aa6075d164..9c16b62ec6c9 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1022,7 +1022,7 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
 			 */
 			if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE)) {
 				spin_lock(&sbinfo->shrinklist_lock);
-				if (list_empty(&info->shrinklist)) {
+				if (list_empty_careful(&info->shrinklist)) {
 					list_add_tail(&info->shrinklist,
 							&sbinfo->shrinklist);
 					sbinfo->shrinklist_len++;
@@ -1817,7 +1817,7 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
 			 * to shrink under memory pressure.
 			 */
 			spin_lock(&sbinfo->shrinklist_lock);
-			if (list_empty(&info->shrinklist)) {
+			if (list_empty_careful(&info->shrinklist)) {
 				list_add_tail(&info->shrinklist,
 						&sbinfo->shrinklist);
 				sbinfo->shrinklist_len++;
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
