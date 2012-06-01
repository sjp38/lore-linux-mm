Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 27F556B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 18:18:14 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4503787pbb.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 15:18:13 -0700 (PDT)
Date: Fri, 1 Jun 2012 15:17:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
In-Reply-To: <20120601171606.GA3794@redhat.com>
Message-ID: <alpine.LSU.2.00.1206011511560.12839@eggly.anvils>
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com> <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils> <20120601161205.GA1918@redhat.com> <20120601171606.GA3794@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 1 Jun 2012, Dave Jones wrote:
> On Fri, Jun 01, 2012 at 12:12:05PM -0400, Dave Jones wrote:
>  
>  > So with this applied, I don't seem to be able to trigger it. It's been running two hours
>  > so far. I'll leave it running, but right now I don't know what to make of this.
> 
> I can trigger the list corruption still, but not the WARN.
> 
> 	Dave
> 
> [  551.980716] ------------[ cut here ]------------
> [  551.981646] WARNING: at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0()
> [  551.983461] list_del corruption. prev->next should be ffffea0004b305a0, but was ffffea0004f117e0
> [  551.984406] Modules linked in: tun fuse nfnetlink binfmt_misc ipt_ULOG sctp libcrc32c caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode usb_debug serio_raw pcspkr i2c_i801 e1000e nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]
> [  551.988121] Pid: 21459, comm: trinity-child2 Not tainted 3.4.0+ #49
> [  551.989063] Call Trace:
> [  551.990012]  [<ffffffff8104912f>] warn_slowpath_common+0x7f/0xc0
> [  551.990956]  [<ffffffff81049226>] warn_slowpath_fmt+0x46/0x50
> [  551.991902]  [<ffffffff81329171>] __list_del_entry+0xa1/0xd0
> [  551.992849]  [<ffffffff81145ad9>] move_freepages_block+0x159/0x190
> [  551.993800]  [<ffffffff81165be3>] suitable_migration_target.isra.15+0x1b3/0x1d0
> [  551.994761]  [<ffffffff81165e2e>] compaction_alloc+0x22e/0x2f0
> [  551.995731]  [<ffffffff81198547>] migrate_pages+0xc7/0x540
> [  551.996684]  [<ffffffff81165c00>] ? suitable_migration_target.isra.15+0x1d0/0x1d0
> [  551.997638]  [<ffffffff81166b86>] compact_zone+0x216/0x480
> [  551.998593]  [<ffffffff810b15f8>] ? trace_hardirqs_off_caller+0x28/0xc0
> [  551.999558]  [<ffffffff811670cd>] compact_zone_order+0x8d/0xd0
> [  552.000525]  [<ffffffff81149735>] ? get_page_from_freelist+0x565/0x970
> [  552.001502]  [<ffffffff811671d9>] try_to_compact_pages+0xc9/0x140
> [  552.002548]  [<ffffffff8163f491>] __alloc_pages_direct_compact+0xaa/0x1d0
> [  552.003592]  [<ffffffff8114a14b>] __alloc_pages_nodemask+0x60b/0xab0
> [  552.004650]  [<ffffffff810b15f8>] ? trace_hardirqs_off_caller+0x28/0xc0
> [  552.005708]  [<ffffffff810b4f00>] ? __lock_acquire+0x2d0/0x1aa0
> [  552.007332]  [<ffffffff81189ec6>] alloc_pages_vma+0xb6/0x190
> [  552.008953]  [<ffffffff8119cfb3>] do_huge_pmd_anonymous_page+0x133/0x310
> [  552.010584]  [<ffffffff8116c2e2>] handle_mm_fault+0x242/0x2e0
> [  552.012233]  [<ffffffff8116c592>] __get_user_pages+0x142/0x560
> [  552.013891]  [<ffffffff81171c58>] ? mmap_region+0x3f8/0x630
> [  552.015753]  [<ffffffff8116ca62>] get_user_pages+0x52/0x60
> [  552.017348]  [<ffffffff8116d952>] make_pages_present+0x92/0xc0
> [  552.018936]  [<ffffffff81171c06>] mmap_region+0x3a6/0x630
> [  552.021074]  [<ffffffff81050e2c>] ? do_setitimer+0x1cc/0x310
> [  552.022367]  [<ffffffff811721ed>] do_mmap_pgoff+0x35d/0x3b0
> [  552.023406]  [<ffffffff811722a6>] ? sys_mmap_pgoff+0x66/0x240
> [  552.024429]  [<ffffffff811722c4>] sys_mmap_pgoff+0x84/0x240
> [  552.025445]  [<ffffffff81322cbe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [  552.026466]  [<ffffffff81006ca2>] sys_mmap+0x22/0x30
> [  552.027486]  [<ffffffff81651c92>] system_call_fastpath+0x16/0x1b
> [  552.028521] ---[ end trace c092df1e14d11d14 ]---

Several distractions today, and I must rush out now for two or three
hours: but please check if this patch below makes sense (I've only
checked that it builds), and if so give it a run to see if it fixes
your list corruptions - thanks.

(Looks like there's an independent off-by-one in page_zone(end_page),
but that shouldn't do any harm.)

Hugh

--- 3.4.0+/mm/compaction.c	2012-05-30 08:17:19.396008280 -0700
+++ linux/mm/compaction.c	2012-06-01 15:04:18.612051243 -0700
@@ -369,6 +369,9 @@ static bool rescue_unmovable_pageblock(s
 {
 	unsigned long pfn, start_pfn, end_pfn;
 	struct page *start_page, *end_page;
+	struct zone *zone;
+	unsigned long flags;
+	bool rescued = false;
 
 	pfn = page_to_pfn(page);
 	start_pfn = pfn & ~(pageblock_nr_pages - 1);
@@ -378,9 +381,11 @@ static bool rescue_unmovable_pageblock(s
 	end_page = pfn_to_page(end_pfn);
 
 	/* Do not deal with pageblocks that overlap zones */
-	if (page_zone(start_page) != page_zone(end_page))
+	zone = page_zone(start_page);
+	if (zone != page_zone(end_page))
 		return false;
 
+	spin_lock_irqsave(&zone->lock, flags);
 	for (page = start_page, pfn = start_pfn; page < end_page; pfn++,
 								  page++) {
 		if (!pfn_valid_within(pfn))
@@ -396,12 +401,15 @@ static bool rescue_unmovable_pageblock(s
 		} else if (page_count(page) == 0 || PageLRU(page))
 			continue;
 
-		return false;
+		goto out;
 	}
 
 	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
-	return true;
+	move_freepages_block(zone, page, MIGRATE_MOVABLE);
+	rescued = true;
+out:
+	spin_unlock_irqrestore(&zone->lock, flags);
+	return rescued;
 }
 
 enum smt_result {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
