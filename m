Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D1AE06B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 00:29:17 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so39628137pac.2
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 21:29:17 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id uh9si10383129pac.58.2015.09.17.21.29.16
        for <linux-mm@kvack.org>;
        Thu, 17 Sep 2015 21:29:17 -0700 (PDT)
From: Dave Hansen <dave.hansen@intel.com>
Subject: 4.3-rc1 dirty page count underflow (cgroup-related?)
Message-ID: <55FB9319.2010000@intel.com>
Date: Thu, 17 Sep 2015 21:29:13 -0700
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020708070506070408020408"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <cgroups@vger.kernel.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>

This is a multi-part message in MIME format.
--------------020708070506070408020408
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

I've been seeing some strange behavior with 4.3-rc1 kernels on my Ubuntu
14.04.3 system.  The system will run fine for a few hours, but suddenly
start becoming horribly I/O bound.  A compile of perf for instance takes
20-30 minutes and the compile seems entirely I/O bound.  But, the SSD is
only seeing tens or hundreds of KB/s of writes.

Looking at some writeback tracepoints shows it hitting
balance_dirty_pages() pretty hard with a pretty large number of dirty
pages. :)

>               ld-27008 [000] ...1 88895.190770: balance_dirty_pages: bdi
> 8:0: limit=234545 setpoint=204851 dirty=18446744073709513951
> bdi_setpoint=184364 bdi_dirty=33 dirty_ratelimit=24 task_ratelimit=0
> dirtied=1 dirtied_pause=0 paused=0 pause=136 period=136 think=0
> cgroup=/user/1000.user/c2.session

So something is underflowing dirty.

I added the attached patch and got a warning pretty quickly, so this
looks pretty reproducible for me.

I'm not 100% sure this is from the 4.3 merge window.  I was running the
4.2-rcs, but they seemed to have their own issues.  Ubuntu seems to be
automatically creating some cgroups, so they're definitely in play here.

Any ideas what is going on?

> [   12.415472] ------------[ cut here ]------------
> [   12.415481] WARNING: CPU: 1 PID: 1684 at mm/page-writeback.c:2435 account_page_cleaned+0x101/0x110()
> [   12.415483] MEM_CGROUP_STAT_DIRTY bogus
> [   12.415484] Modules linked in: ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT nf_reject_ipv4 xt_CHECKSUM iptable_mangle xt_tcpudp bridge stp llc iptable_filter ip_tables ebtable_nat ebtables x_tables dm_crypt cmac rfcomm bnep arc4 iwldvm mac80211 btusb snd_hda_codec_hdmi iwlwifi btrtl btbcm btintel snd_hda_codec_realtek snd_hda_codec_generic bluetooth snd_hda_intel snd_hda_codec cfg80211 snd_hwdep snd_hda_core intel_rapl iosf_mbi hid_logitech_hidpp x86_pkg_temp_thermal snd_pcm coretemp ghash_clmulni_intel thinkpad_acpi joydev snd_seq_midi snd_seq_midi_event snd_rawmidi nvram snd_seq snd_timer snd_seq_device wmi snd soundcore mac_hid lpc_ich aesni_intel aes_x86_64 glue_helper lrw gf128mul ablk_helper cryptd kvm_intel kvm hid_logitech_dj sdhci_pci sdhci usbhid hid
> [   12.415538] CPU: 1 PID: 1684 Comm: indicator-keybo Not tainted 4.3.0-rc1-dirty #25
> [   12.415540] Hardware name: LENOVO 2325AR2/2325AR2, BIOS G2ETA4WW (2.64 ) 04/09/2015
> [   12.415542]  ffffffff81aa8172 ffff8800c926ba30 ffffffff8132e3e2 ffff8800c926ba78
> [   12.415544]  ffff8800c926ba68 ffffffff8105e386 ffffea000fca4700 ffff880409b96420
> [   12.415547]  ffff8803ef979490 ffff880403ff4800 0000000000000000 ffff8800c926bac8
> [   12.415550] Call Trace:
> [   12.415555]  [<ffffffff8132e3e2>] dump_stack+0x4b/0x69
> [   12.415560]  [<ffffffff8105e386>] warn_slowpath_common+0x86/0xc0
> [   12.415563]  [<ffffffff8105e40c>] warn_slowpath_fmt+0x4c/0x50
> [   12.415566]  [<ffffffff8115f951>] account_page_cleaned+0x101/0x110
> [   12.415568]  [<ffffffff8115fa1d>] cancel_dirty_page+0xbd/0xf0
> [   12.415571]  [<ffffffff811fc044>] try_to_free_buffers+0x94/0xb0
> [   12.415575]  [<ffffffff81296740>] jbd2_journal_try_to_free_buffers+0x100/0x130
> [   12.415578]  [<ffffffff812498b2>] ext4_releasepage+0x52/0xa0
> [   12.415582]  [<ffffffff81153765>] try_to_release_page+0x35/0x50
> [   12.415585]  [<ffffffff811fcc13>] block_invalidatepage+0x113/0x130
> [   12.415587]  [<ffffffff81249d5e>] ext4_invalidatepage+0x5e/0xb0
> [   12.415590]  [<ffffffff8124a6f0>] ext4_da_invalidatepage+0x40/0x310
> [   12.415593]  [<ffffffff81162b03>] truncate_inode_page+0x83/0x90
> [   12.415595]  [<ffffffff81162ce9>] truncate_inode_pages_range+0x199/0x730
> [   12.415598]  [<ffffffff8109c494>] ? __wake_up+0x44/0x50
> [   12.415600]  [<ffffffff812962ca>] ? jbd2_journal_stop+0x1ba/0x3b0
> [   12.415603]  [<ffffffff8125a754>] ? ext4_unlink+0x2f4/0x330
> [   12.415607]  [<ffffffff811eed3d>] ? __inode_wait_for_writeback+0x6d/0xc0
> [   12.415609]  [<ffffffff811632ec>] truncate_inode_pages_final+0x4c/0x60
> [   12.415612]  [<ffffffff81250736>] ext4_evict_inode+0x116/0x4c0
> [   12.415615]  [<ffffffff811e139c>] evict+0xbc/0x190
> [   12.415617]  [<ffffffff811e1d2d>] iput+0x17d/0x1e0
> [   12.415620]  [<ffffffff811d623b>] do_unlinkat+0x1ab/0x2b0
> [   12.415622]  [<ffffffff811d6cb6>] SyS_unlink+0x16/0x20
> [   12.415626]  [<ffffffff817d7f97>] entry_SYSCALL_64_fastpath+0x12/0x6a
> [   12.415628] ---[ end trace 6fba1ddd3d240e13 ]---
> [   12.418211] ------------[ cut here ]------------

--------------020708070506070408020408
Content-Type: text/x-patch;
 name="dirtywarn.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dirtywarn.patch"

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6ddaeba..f130d02 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3757,6 +3757,9 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pavail,
 	unsigned long file_pages;
 
 	*pdirty = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_DIRTY);
+	WARN(*pdirty > (1<<30), "%s() huge dirty: %ld\n", __func__, *pdirty);
+	if (*pdirty > (1<<30))
+		*pdirty = 0;
 
 	/* this should eventually include NR_UNSTABLE_NFS */
 	*pwriteback = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
@@ -4607,6 +4610,8 @@ static int mem_cgroup_move_account(struct page *page,
 				       nr_pages);
 			__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_DIRTY],
 				       nr_pages);
+			WARN_ONCE(__this_cpu_read(from->stat->count[MEM_CGROUP_STAT_DIRTY]) > (1UL<<30), "MEM_CGROUP_STAT_DIRTY bogus");
+			WARN_ONCE(__this_cpu_read(  to->stat->count[MEM_CGROUP_STAT_DIRTY]) > (1UL<<30), "MEM_CGROUP_STAT_DIRTY bogus");
 		}
 	}
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0a931cd..9dfd8fa 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1546,6 +1546,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 					global_page_state(NR_UNSTABLE_NFS);
 		gdtc->avail = global_dirtyable_memory();
 		gdtc->dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
+		WARN(gdtc->dirty > (1<<30), "%s() huge dirty: %ld\n", __func__, gdtc->dirty);
 
 		domain_dirty_limits(gdtc);
 
@@ -1570,6 +1571,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			 */
 			mem_cgroup_wb_stats(wb, &mdtc->avail, &mdtc->dirty,
 					    &writeback);
+			WARN(mdtc->dirty > (1<<30), "%s() huge dirty: %ld\n", __func__, mdtc->dirty);
 			mdtc_cap_avail(mdtc);
 			mdtc->dirty += writeback;
 
@@ -1884,6 +1886,7 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 	gdtc->avail = global_dirtyable_memory();
 	gdtc->dirty = global_page_state(NR_FILE_DIRTY) +
 		      global_page_state(NR_UNSTABLE_NFS);
+	WARN(gdtc->dirty > (1<<30), "%s() huge dirty: %ld\n", __func__, gdtc->dirty);
 	domain_dirty_limits(gdtc);
 
 	if (gdtc->dirty > gdtc->bg_thresh)
@@ -1896,6 +1899,7 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 		unsigned long writeback;
 
 		mem_cgroup_wb_stats(wb, &mdtc->avail, &mdtc->dirty, &writeback);
+		WARN(mdtc->dirty > (1<<30), "%s() huge dirty: %ld\n", __func__, mdtc->dirty);
 		mdtc_cap_avail(mdtc);
 		domain_dirty_limits(mdtc);	/* ditto, ignore writeback */
 
@@ -2404,7 +2408,9 @@ void account_page_dirtied(struct page *page, struct address_space *mapping,
 		inode_attach_wb(inode, page);
 		wb = inode_to_wb(inode);
 
+		WARN_ONCE(__this_cpu_read(memcg->stat->count[MEM_CGROUP_STAT_DIRTY]) > (1UL<<30), "MEM_CGROUP_STAT_DIRTY bogus");
 		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
+		WARN_ONCE(__this_cpu_read(memcg->stat->count[MEM_CGROUP_STAT_DIRTY]) > (1UL<<30), "MEM_CGROUP_STAT_DIRTY bogus");
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
@@ -2426,6 +2432,7 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
+		WARN_ONCE(__this_cpu_read(memcg->stat->count[MEM_CGROUP_STAT_DIRTY]) > (1UL<<30), "MEM_CGROUP_STAT_DIRTY bogus");
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_wb_stat(wb, WB_RECLAIMABLE);
 		task_io_account_cancelled_write(PAGE_CACHE_SIZE);
@@ -2686,6 +2693,7 @@ int clear_page_dirty_for_io(struct page *page)
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
 			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
+			WARN_ONCE(__this_cpu_read(memcg->stat->count[MEM_CGROUP_STAT_DIRTY]) > (1UL<<30), "MEM_CGROUP_STAT_DIRTY bogus");
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_wb_stat(wb, WB_RECLAIMABLE);
 			ret = 1;

--------------020708070506070408020408--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
