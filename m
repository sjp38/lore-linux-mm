Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6B36B03E1
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 07:57:00 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id v186so65764881lfa.2
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 04:57:00 -0800 (PST)
Received: from special.m3.smtp.beget.ru (special.m3.smtp.beget.ru. [5.101.158.90])
        by mx.google.com with ESMTPS id p3si1833841lfa.229.2017.02.15.04.56.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 04:56:58 -0800 (PST)
Reply-To: apolyakov@beget.ru
Subject: Re: [Bug 192981] New: page allocation stalls
References: <bug-192981-27@https.bugzilla.kernel.org/>
 <20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org>
From: Alexander Polakov <apolyakov@beget.ru>
Message-ID: <8f450abd-4e05-92d3-2533-72b05fea2012@beget.ru>
Date: Wed, 15 Feb 2017 15:56:56 +0300
MIME-Version: 1.0
In-Reply-To: <20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-xfs@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On 01/24/2017 12:51 AM, Andrew Morton wrote:
>
>
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> A 2100 second page allocation stall!
>

I think we finally figured out the problem using Tetsuo Handa's mallocwd 
patch. It seems like it is in XFS direct reclaim path.

Here's how it goes:

memory is low, rsync goes into direct reclaim, locking xfs mutex in 
xfs_reclaim_inodes_nr():

2017-02-14T00:12:59.811447+03:00 storage9 [24646.497290] MemAlloc: 
rsync(19706) flags=0x404840 switches=8692 seq=340 
gfp=0x27080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK) order=0 
delay=6795
2017-02-14T00:12:59.811447+03:00 storage9 [24646.497550] rsync           R
2017-02-14T00:12:59.811579+03:00 storage9     0 19706   5000 0x00000000
2017-02-14T00:12:59.811579+03:00 storage9 [24646.497690]  ffffa4361dc36c00
2017-02-14T00:12:59.811591+03:00 storage9  0000000c1dc36c00
2017-02-14T00:12:59.811591+03:00 storage9  ffffa4361dc36c00
2017-02-14T00:12:59.811724+03:00 storage9  ffffa44347792580
2017-02-14T00:12:59.811841+03:00 storage9
2017-02-14T00:12:59.811841+03:00 storage9 [24646.497951]  0000000000000000
2017-02-14T00:12:59.811846+03:00 storage9  ffffb1cab6343458
2017-02-14T00:12:59.811885+03:00 storage9  ffffffffb383e799
2017-02-14T00:12:59.811987+03:00 storage9  0000000000000000
2017-02-14T00:12:59.812103+03:00 storage9
2017-02-14T00:12:59.812103+03:00 storage9 [24646.498208]  ffffa443ffff7a00
2017-02-14T00:12:59.812103+03:00 storage9  0000000000000001
2017-02-14T00:12:59.812104+03:00 storage9  ffffb1cab6343448
2017-02-14T00:12:59.812233+03:00 storage9  0000000000000002
2017-02-14T00:12:59.812350+03:00 storage9
2017-02-14T00:12:59.812475+03:00 storage9 [24646.498462] Call Trace:
2017-02-14T00:12:59.812610+03:00 storage9 [24646.498587] 
[<ffffffffb383e799>] ? __schedule+0x179/0x5c8
2017-02-14T00:12:59.812733+03:00 storage9 [24646.498718] 
[<ffffffffb383ecc2>] ? schedule+0x32/0x80
2017-02-14T00:12:59.812869+03:00 storage9 [24646.498846] 
[<ffffffffb3841229>] ? schedule_timeout+0x159/0x2a0
2017-02-14T00:12:59.812997+03:00 storage9 [24646.498977] 
[<ffffffffb30f1450>] ? add_timer_on+0x130/0x130
2017-02-14T00:12:59.813130+03:00 storage9 [24646.499108] 
[<ffffffffb318ff13>] ? __alloc_pages_nodemask+0xe73/0x16b0
2017-02-14T00:12:59.813263+03:00 storage9 [24646.499240] 
[<ffffffffb31deb2a>] ? alloc_pages_current+0x9a/0x120
2017-02-14T00:12:59.813388+03:00 storage9 [24646.499371] 
[<ffffffffb33d1a51>] ? xfs_buf_allocate_memory+0x171/0x2c0
2017-02-14T00:12:59.813564+03:00 storage9 [24646.499503] 
[<ffffffffb337c48b>] ? xfs_buf_get_map+0x18b/0x1d0
2017-02-14T00:12:59.813654+03:00 storage9 [24646.499634] 
[<ffffffffb337cdcb>] ? xfs_buf_read_map+0x3b/0x160
2017-02-14T00:12:59.813783+03:00 storage9 [24646.499765] 
[<ffffffffb33b71b0>] ? xfs_trans_read_buf_map+0x1f0/0x490
2017-02-14T00:12:59.813931+03:00 storage9 [24646.499897] 
[<ffffffffb3362859>] ? xfs_imap_to_bp+0x79/0x120
2017-02-14T00:12:59.814056+03:00 storage9 [24646.500029] 
[<ffffffffb3394a38>] ? xfs_iflush+0x118/0x380
2017-02-14T00:12:59.814196+03:00 storage9 [24646.500158] 
[<ffffffffb30d6130>] ? wake_atomic_t_function+0x40/0x40
2017-02-14T00:12:59.814314+03:00 storage9 [24646.500289] 
[<ffffffffb3385af4>] ? xfs_reclaim_inode+0x274/0x3f0
2017-02-14T00:12:59.814444+03:00 storage9 [24646.500421] 
[<ffffffffb3385e29>] ? xfs_reclaim_inodes_ag+0x1b9/0x2c0
2017-02-14T00:12:59.814573+03:00 storage9 [24646.500553] 
[<ffffffffb345c6b8>] ? radix_tree_next_chunk+0x108/0x2a0
2017-02-14T00:12:59.814701+03:00 storage9 [24646.500685] 
[<ffffffffb30f0e31>] ? lock_timer_base+0x51/0x70
2017-02-14T00:12:59.814846+03:00 storage9 [24646.500814] 
[<ffffffffb345ca4e>] ? radix_tree_gang_lookup_tag+0xae/0x180
2017-02-14T00:12:59.814966+03:00 storage9 [24646.500946] 
[<ffffffffb336f588>] ? xfs_perag_get_tag+0x48/0x100
2017-02-14T00:12:59.815104+03:00 storage9 [24646.501079] 
[<ffffffffb31b63c1>] ? __list_lru_walk_one.isra.7+0x31/0x120
2017-02-14T00:12:59.815231+03:00 storage9 [24646.501212] 
[<ffffffffb322aed0>] ? iget5_locked+0x240/0x240
2017-02-14T00:12:59.815360+03:00 storage9 [24646.501342] 
[<ffffffffb33873c1>] ? xfs_reclaim_inodes_nr+0x31/0x40
2017-02-14T00:12:59.815489+03:00 storage9 [24646.501472] 
[<ffffffffb3213160>] ? super_cache_scan+0x1a0/0x1b0
2017-02-14T00:12:59.815629+03:00 storage9 [24646.501603] 
[<ffffffffb319bf62>] ? shrink_slab+0x262/0x440
2017-02-14T00:12:59.815760+03:00 storage9 [24646.501734] 
[<ffffffffb319cc8b>] ? drop_slab_node+0x2b/0x60
2017-02-14T00:12:59.815891+03:00 storage9 [24646.501864] 
[<ffffffffb319cd02>] ? drop_slab+0x42/0x70
2017-02-14T00:12:59.816020+03:00 storage9 [24646.501994] 
[<ffffffffb318abc0>] ? out_of_memory+0x220/0x560
2017-02-14T00:12:59.816160+03:00 storage9 [24646.502122] 
[<ffffffffb31903b2>] ? __alloc_pages_nodemask+0x1312/0x16b0
2017-02-14T00:12:59.816285+03:00 storage9 [24646.502255] 
[<ffffffffb31deb2a>] ? alloc_pages_current+0x9a/0x120
2017-02-14T00:12:59.816407+03:00 storage9 [24646.502386] 
[<ffffffffb304b803>] ? pte_alloc_one+0x13/0x40
2017-02-14T00:12:59.816536+03:00 storage9 [24646.502517] 
[<ffffffffb31be21f>] ? handle_mm_fault+0xc7f/0x14b0
2017-02-14T00:12:59.816659+03:00 storage9 [24646.502648] 
[<ffffffffb30461ff>] ? __do_page_fault+0x1cf/0x5a0
2017-02-14T00:12:59.816851+03:00 storage9 [24646.502777] 
[<ffffffffb3843362>] ? page_fault+0x22/0x30

But it cannot get memory, because it's low (?). So it stays blocked.

Other processes do the same but they can't get past the mutex in 
xfs_reclaim_inodes_nr():

2017-02-14T00:12:59.817057+03:00 storage9 [24646.502909] MemAlloc: 
rsync(19707) flags=0x404840 switches=6344 seq=638 
gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=3257 
uninterruptible
2017-02-14T00:12:59.817062+03:00 storage9 [24646.503167] rsync           D
2017-02-14T00:12:59.817189+03:00 storage9     0 19707   5000 0x00000000
2017-02-14T00:12:59.817197+03:00 storage9 [24646.503299]  0000000000000000
2017-02-14T00:12:59.817197+03:00 storage9  ffffa44347793840
2017-02-14T00:12:59.817207+03:00 storage9  ffffa4277a36ec00
2017-02-14T00:12:59.817316+03:00 storage9  ffffa4361dc35100
2017-02-14T00:12:59.817446+03:00 storage9
2017-02-14T00:12:59.817446+03:00 storage9 [24646.503554]  ffffa4437a514300
2017-02-14T00:12:59.817461+03:00 storage9  ffffb1cab0823638
2017-02-14T00:12:59.817461+03:00 storage9  ffffffffb383e799
2017-02-14T00:12:59.817598+03:00 storage9  ffffa44365967b00
2017-02-14T00:12:59.817699+03:00 storage9
2017-02-14T00:12:59.817699+03:00 storage9 [24646.503809]  ffffb1cab0823680
2017-02-14T00:12:59.817717+03:00 storage9  0000000000000001
2017-02-14T00:12:59.817717+03:00 storage9  ffffa443424062a8
2017-02-14T00:12:59.817832+03:00 storage9  0000000000000000
2017-02-14T00:12:59.817948+03:00 storage9
2017-02-14T00:12:59.818078+03:00 storage9 [24646.504061] Call Trace:
2017-02-14T00:12:59.818211+03:00 storage9 [24646.504189] 
[<ffffffffb383e799>] ? __schedule+0x179/0x5c8
2017-02-14T00:12:59.818339+03:00 storage9 [24646.504321] 
[<ffffffffb383ecc2>] ? schedule+0x32/0x80
2017-02-14T00:12:59.818471+03:00 storage9 [24646.504451] 
[<ffffffffb383ee6e>] ? schedule_preempt_disabled+0xe/0x20
2017-02-14T00:12:59.818611+03:00 storage9 [24646.504582] 
[<ffffffffb38400aa>] ? __mutex_lock_slowpath+0x8a/0x100
2017-02-14T00:12:59.818737+03:00 storage9 [24646.504715] 
[<ffffffffb3840133>] ? mutex_lock+0x13/0x22
2017-02-14T00:12:59.818870+03:00 storage9 [24646.504846] 
[<ffffffffb3385e98>] ? xfs_reclaim_inodes_ag+0x228/0x2c0
2017-02-14T00:12:59.819024+03:00 storage9 [24646.504977] 
[<ffffffffb345c6b8>] ? radix_tree_next_chunk+0x108/0x2a0
2017-02-14T00:12:59.819124+03:00 storage9 [24646.505107] 
[<ffffffffb345ca4e>] ? radix_tree_gang_lookup_tag+0xae/0x180
2017-02-14T00:12:59.819273+03:00 storage9 [24646.505238] 
[<ffffffffb336f588>] ? xfs_perag_get_tag+0x48/0x100
2017-02-14T00:12:59.819397+03:00 storage9 [24646.505370] 
[<ffffffffb31b63c1>] ? __list_lru_walk_one.isra.7+0x31/0x120
2017-02-14T00:12:59.819528+03:00 storage9 [24646.505502] 
[<ffffffffb322aed0>] ? iget5_locked+0x240/0x240
2017-02-14T00:12:59.819657+03:00 storage9 [24646.505634] 
[<ffffffffb33873c1>] ? xfs_reclaim_inodes_nr+0x31/0x40
2017-02-14T00:12:59.819781+03:00 storage9 [24646.505766] 
[<ffffffffb3213160>] ? super_cache_scan+0x1a0/0x1b0
2017-02-14T00:12:59.819915+03:00 storage9 [24646.505897] 
[<ffffffffb319bf62>] ? shrink_slab+0x262/0x440
2017-02-14T00:12:59.820100+03:00 storage9 [24646.506028] 
[<ffffffffb319fa6f>] ? shrink_node+0xef/0x2d0
2017-02-14T00:12:59.820176+03:00 storage9 [24646.506158] 
[<ffffffffb319ff42>] ? do_try_to_free_pages+0xc2/0x2b0
2017-02-14T00:12:59.820300+03:00 storage9 [24646.506288] 
[<ffffffffb31a03e2>] ? try_to_free_pages+0xe2/0x1c0
2017-02-14T00:12:59.820442+03:00 storage9 [24646.506415] 
[<ffffffffb318c1a9>] ? __perform_reclaim.isra.80+0x79/0xc0
2017-02-14T00:12:59.820556+03:00 storage9 [24646.506542] 
[<ffffffffb318f901>] ? __alloc_pages_nodemask+0x861/0x16b0
2017-02-14T00:12:59.820683+03:00 storage9 [24646.506669] 
[<ffffffffb345d64b>] ? __radix_tree_lookup+0x7b/0xe0
2017-02-14T00:12:59.820851+03:00 storage9 [24646.506796] 
[<ffffffffb31deb2a>] ? alloc_pages_current+0x9a/0x120
2017-02-14T00:12:59.820942+03:00 storage9 [24646.506922] 
[<ffffffffb3188b56>] ? filemap_fault+0x396/0x540
2017-02-14T00:12:59.821072+03:00 storage9 [24646.507048] 
[<ffffffffb345c6b8>] ? radix_tree_next_chunk+0x108/0x2a0
2017-02-14T00:12:59.821192+03:00 storage9 [24646.507176] 
[<ffffffffb32a5bdf>] ? ext4_filemap_fault+0x3f/0x60
2017-02-14T00:12:59.821318+03:00 storage9 [24646.507303] 
[<ffffffffb31b8591>] ? __do_fault+0x71/0x120
2017-02-14T00:12:59.821441+03:00 storage9 [24646.507428] 
[<ffffffffb31be36d>] ? handle_mm_fault+0xdcd/0x14b0
2017-02-14T00:12:59.821574+03:00 storage9 [24646.507555] 
[<ffffffffb31ea9a4>] ? kmem_cache_free+0x204/0x220
2017-02-14T00:12:59.821697+03:00 storage9 [24646.507682] 
[<ffffffffb32114b9>] ? __fput+0x149/0x200
2017-02-14T00:12:59.821824+03:00 storage9 [24646.507806] 
[<ffffffffb30461ff>] ? __do_page_fault+0x1cf/0x5a0
2017-02-14T00:12:59.821954+03:00 storage9 [24646.507934] 
[<ffffffffb3843362>] ? page_fault+0x22/0x30

Even kswapd gets stuck:

2017-02-14T00:13:10.306351+03:00 storage9 [24656.991375] MemAlloc: 
kswapd0(114) flags=0xa40840 switches=22109 uninterruptible
2017-02-14T00:13:10.306351+03:00 storage9 [24656.991622] kswapd0         D
2017-02-14T00:13:10.306473+03:00 storage9     0   114      2 0x00000000
2017-02-14T00:13:10.306482+03:00 storage9 [24656.991753]  0000000000000000
2017-02-14T00:13:10.306482+03:00 storage9  ffffa43830be0f00
2017-02-14T00:13:10.306488+03:00 storage9  ffffa44342ff2880
2017-02-14T00:13:10.306601+03:00 storage9  ffffa443600e0d80
2017-02-14T00:13:10.306714+03:00 storage9
2017-02-14T00:13:10.306723+03:00 storage9 [24656.992000]  ffffa4437ad14300
2017-02-14T00:13:10.306723+03:00 storage9  ffffb1ca8d2737d8
2017-02-14T00:13:10.306731+03:00 storage9  ffffffffb383e799
2017-02-14T00:13:10.306846+03:00 storage9  ffffb1ca8d273788
2017-02-14T00:13:10.306956+03:00 storage9
2017-02-14T00:13:10.306957+03:00 storage9 [24656.992245]  ffffb1ca8d273788
2017-02-14T00:13:10.306957+03:00 storage9  ffffb1ca8d273798
2017-02-14T00:13:10.307011+03:00 storage9  ffffb1ca8d273798
2017-02-14T00:13:10.307087+03:00 storage9  0000000002400001
2017-02-14T00:13:10.307200+03:00 storage9
2017-02-14T00:13:10.307321+03:00 storage9 [24656.992489] Call Trace:
2017-02-14T00:13:10.307475+03:00 storage9 [24656.992611] 
[<ffffffffb383e799>] ? __schedule+0x179/0x5c8
2017-02-14T00:13:10.307572+03:00 storage9 [24656.992736] 
[<ffffffffb383ecc2>] ? schedule+0x32/0x80
2017-02-14T00:13:10.307703+03:00 storage9 [24656.992861] 
[<ffffffffb3841002>] ? rwsem_down_read_failed+0xb2/0x100
2017-02-14T00:13:10.307831+03:00 storage9 [24656.992987] 
[<ffffffffb3466004>] ? call_rwsem_down_read_failed+0x14/0x30
2017-02-14T00:13:10.307949+03:00 storage9 [24656.993114] 
[<ffffffffb3840443>] ? down_read+0x13/0x30
2017-02-14T00:13:10.308075+03:00 storage9 [24656.993239] 
[<ffffffffb3373420>] ? xfs_map_blocks+0x90/0x2f0
2017-02-14T00:13:10.308214+03:00 storage9 [24656.993366] 
[<ffffffffb3375256>] ? xfs_do_writepage+0x2b6/0x6a0
2017-02-14T00:13:10.308337+03:00 storage9 [24656.993496] 
[<ffffffffb3245589>] ? submit_bh_wbc+0x169/0x200
2017-02-14T00:13:10.308518+03:00 storage9 [24656.993627] 
[<ffffffffb337566c>] ? xfs_vm_writepage+0x2c/0x50
2017-02-14T00:13:10.308603+03:00 storage9 [24656.993760] 
[<ffffffffb319bb0b>] ? pageout.isra.60+0xeb/0x2e0
2017-02-14T00:13:10.308728+03:00 storage9 [24656.993891] 
[<ffffffffb319df06>] ? shrink_page_list+0x736/0xa50
2017-02-14T00:13:10.308935+03:00 storage9 [24656.994022] 
[<ffffffffb319eb52>] ? shrink_inactive_list+0x202/0x4b0
2017-02-14T00:13:10.308993+03:00 storage9 [24656.994152] 
[<ffffffffb319f4d1>] ? shrink_node_memcg+0x2e1/0x790
2017-02-14T00:13:10.309148+03:00 storage9 [24656.994282] 
[<ffffffffb319fa49>] ? shrink_node+0xc9/0x2d0
2017-02-14T00:13:10.309258+03:00 storage9 [24656.994416] 
[<ffffffffb31a0944>] ? kswapd+0x2e4/0x690
2017-02-14T00:13:10.309854+03:00 storage9 [24656.994546] 
[<ffffffffb31a0660>] ? mem_cgroup_shrink_node+0x1a0/0x1a0
2017-02-14T00:13:10.309854+03:00 storage9 [24656.994678] 
[<ffffffffb31a0660>] ? mem_cgroup_shrink_node+0x1a0/0x1a0
2017-02-14T00:13:10.309854+03:00 storage9 [24656.994808] 
[<ffffffffb30b4fc2>] ? kthread+0xc2/0xe0
2017-02-14T00:13:10.309854+03:00 storage9 [24656.994937] 
[<ffffffffb30b4f00>] ? __kthread_init_worker+0xb0/0xb0
2017-02-14T00:13:10.309910+03:00 storage9 [24656.995069] 
[<ffffffffb38425e2>] ? ret_from_fork+0x22/0x30

Which finally leads to "Kernel panic - not syncing: Out of memory and no 
killable processes..." as no process is able to proceed.

I quickly hacked this:

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 9ef152b..8adfb0a 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -1254,7 +1254,7 @@ struct xfs_inode *
         xfs_reclaim_work_queue(mp);
         xfs_ail_push_all(mp->m_ail);

-       return xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, 
&nr_to_scan);
+       return 0; // xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, 
&nr_to_scan);
  }


We ran 2 of our machines with this patch for a night, no more 
lockups/stalls were detected.

xfsaild does its work asynchronously, so xfs_inodes don't run wild as 
confirmed by slabtop.

I put netconsole logs here: http://aplkv.beget.tech/lkml/xfs/ for anyone 
interested.

-- 
Alexander Polakov | system software engineer | https://beget.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
