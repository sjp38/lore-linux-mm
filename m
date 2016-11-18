Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D21BA6B0409
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:55:22 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id v84so217596048oie.0
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:55:22 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c91si3067499otb.183.2016.11.18.03.55.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 03:55:21 -0800 (PST)
Subject: Re: [Bug 186671] New: OOM on system with just rsync running 32GB of
 ram 30GB of pagecache
References: <bug-186671-27@https.bugzilla.kernel.org/>
 <20161103115353.de87ff35756a4ca8b21d2c57@linux-foundation.org>
 <b5b0cef0-8482-e4de-cb81-69a4dd3410fb@suse.cz>
 <CAJtFHUQcJKSnyQ7t7-eDpiF2C+U23+iWpZ+X6fGEzN8qdbzmtA@mail.gmail.com>
 <a8cf869e-f527-9c65-d16d-ac70cf66472a@suse.cz>
 <CAJtFHUQgkvFaPdyRcoiV-m5hynDGo2qXfMXzZvGahoWp2LL_KA@mail.gmail.com>
 <bbcd6cb7-3b73-02e9-0409-4601a6f573f5@suse.cz>
 <CAJtFHUSka8nbaO5RNEcWVRi7VoQ7UORWkMu_7pNW3n_9iRRdew@mail.gmail.com>
 <CAJtFHUTn9Ejvyj3vJkqnsLoa6gci104-TPu5viG=epfJ9Rk_qg@mail.gmail.com>
 <4c85dfa5-9dbe-ea3c-7816-1ab321931e1c@suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <d0a4adfc-5017-71ba-c895-fc7603b54f7a@I-love.SAKURA.ne.jp>
Date: Fri, 18 Nov 2016 20:54:54 +0900
MIME-Version: 1.0
In-Reply-To: <4c85dfa5-9dbe-ea3c-7816-1ab321931e1c@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, E V <eliventer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, linux-btrfs <linux-btrfs@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 2016/11/18 6:49, Vlastimil Babka wrote:
> On 11/16/2016 02:39 PM, E V wrote:
>> System panic'd overnight running 4.9rc5 & rsync. Attached a photo of
>> the stack trace, and the 38 call traces in a 2 minute window shortly
>> before, to the bugzilla case for those not on it's e-mail list:
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=186671
> 
> The panic screenshot has only the last part, but the end marker says
> it's OOM with no killable processes. The DEBUG_VM config thus didn't
> trigger anything, and still there's tons of pagecache, mostly clean,
> that's not being reclaimed.
> 
> Could you now try this?
> - enable CONFIG_PAGE_OWNER
> - boot with kernel option: page_owner=on
> - after the first oom, "cat /sys/kernel/debug/page_owner > file"
> - provide the file (compressed, it will be quite large)

Excuse me for a noise, but do we really need to do
"cat /sys/kernel/debug/page_owner > file" after the first OOM killer
invocation? I worry that it might be too difficult to do.
Shouldn't we rather do "cat /sys/kernel/debug/page_owner > file"
hourly and compare tendency between the latest one and previous one?

This system has swap, and /var/log/messages before panic
reports that swapin was stalling at memory allocation.

----------------------------------------
[130346.262510] dsm_sa_datamgrd: page allocation stalls for 52400ms, order:0, mode:0x24200ca(GFP_HIGHUSER_MOVABLE)
[130346.262572] CPU: 1 PID: 3622 Comm: dsm_sa_datamgrd Tainted: G        W I     4.9.0-rc5 #2
[130346.262662]  0000000000000000 ffffffff8129ba69 ffffffff8170e4c8 ffffc90003ccb8d8
[130346.262714]  ffffffff8113449f 024200ca1ca11b40 ffffffff8170e4c8 ffffc90003ccb880
[130346.262765]  ffffffff00000010 ffffc90003ccb8e8 ffffc90003ccb898 ffff88041f226e80
[130346.262817] Call Trace:
[130346.262843]  [<ffffffff8129ba69>] ? dump_stack+0x46/0x5d
[130346.262872]  [<ffffffff8113449f>] ? warn_alloc+0x11f/0x140
[130346.262899]  [<ffffffff81134d7b>] ? __alloc_pages_slowpath+0x84b/0xa80
[130346.262929]  [<ffffffff81135260>] ? __alloc_pages_nodemask+0x2b0/0x2f0
[130346.262960]  [<ffffffff8117f1be>] ? alloc_pages_vma+0xbe/0x260
[130346.262989]  [<ffffffff8112af02>] ? pagecache_get_page+0x22/0x280
[130346.263019]  [<ffffffff81171b68>] ? __read_swap_cache_async+0x118/0x1a0
[130346.263048]  [<ffffffff81171bff>] ? read_swap_cache_async+0xf/0x30
[130346.263077]  [<ffffffff81171d8e>] ? swapin_readahead+0x16e/0x1c0
[130346.263106]  [<ffffffff812a0f6e>] ? radix_tree_lookup_slot+0xe/0x20
[130346.263135]  [<ffffffff8112ac84>] ? find_get_entry+0x14/0x130
[130346.263162]  [<ffffffff8112af02>] ? pagecache_get_page+0x22/0x280
[130346.263193]  [<ffffffff8115cb1f>] ? do_swap_page+0x44f/0x5f0
[130346.263220]  [<ffffffff812a0f02>] ? __radix_tree_lookup+0x62/0xc0
[130346.263249]  [<ffffffff8115e91a>] ? handle_mm_fault+0x66a/0xf00
[130346.263277]  [<ffffffff8112ac84>] ? find_get_entry+0x14/0x130
[130346.263305]  [<ffffffff8104a245>] ? __do_page_fault+0x1c5/0x490
[130346.263336]  [<ffffffff8150e322>] ? page_fault+0x22/0x30
[130346.263364]  [<ffffffff812a7cac>] ? copy_user_generic_string+0x2c/0x40
[130346.263395]  [<ffffffff811adc1d>] ? set_fd_set+0x1d/0x30
[130346.263422]  [<ffffffff811ae905>] ? core_sys_select+0x1a5/0x260
[130346.263450]  [<ffffffff811a913a>] ? getname_flags+0x6a/0x1e0
[130346.263479]  [<ffffffff8119ef25>] ? cp_new_stat+0x115/0x130
[130346.263509]  [<ffffffff810bf01f>] ? ktime_get_ts64+0x3f/0xf0
[130346.263537]  [<ffffffff811aea65>] ? SyS_select+0xa5/0xe0
[130346.263564]  [<ffffffff8150c6a0>] ? entry_SYSCALL_64_fastpath+0x13/0x94
----------------------------------------

Under such situation, trying to login and execute /bin/cat could take minutes.
Also, writing to btrfs and ext4 seems to be stalling. The btrfs one is a
situation where WQ_MEM_RECLAIM kernel workqueue is unable to make progress.

----------------------------------------
[130420.008231] kworker/u34:21: page allocation stalls for 35028ms, order:0, mode:0x2400840(GFP_NOFS|__GFP_NOFAIL)
[130420.008287] CPU: 5 PID: 24286 Comm: kworker/u34:21 Tainted: G        W I     4.9.0-rc5 #2
[130420.008401] Workqueue: btrfs-extent-refs btrfs_extent_refs_helper [btrfs]
[130420.008432]  0000000000000000 ffffffff8129ba69 ffffffff8170e4c8 ffffc900087836a0
[130420.008483]  ffffffff8113449f 024008401e3f1b40 ffffffff8170e4c8 ffffc90008783648
[130420.008534]  ffffffff00000010 ffffc900087836b0 ffffc90008783660 ffff88041ecc4340
[130420.008586] Call Trace:
[130420.008611]  [<ffffffff8129ba69>] ? dump_stack+0x46/0x5d
[130420.008640]  [<ffffffff8113449f>] ? warn_alloc+0x11f/0x140
[130420.008667]  [<ffffffff81134d7b>] ? __alloc_pages_slowpath+0x84b/0xa80
[130420.008707]  [<ffffffffa020c432>] ? search_bitmap+0xc2/0x140 [btrfs]
[130420.008736]  [<ffffffff81135260>] ? __alloc_pages_nodemask+0x2b0/0x2f0
[130420.008766]  [<ffffffff8117dbda>] ? alloc_pages_current+0x8a/0x110
[130420.008796]  [<ffffffff8112afcc>] ? pagecache_get_page+0xec/0x280
[130420.008836]  [<ffffffffa01e9aa8>] ? alloc_extent_buffer+0x108/0x430 [btrfs]
[130420.008875]  [<ffffffffa01b4108>] ? btrfs_alloc_tree_block+0x118/0x4d0 [btrfs]
[130420.008927]  [<ffffffffa019ae38>] ? __btrfs_cow_block+0x148/0x5d0 [btrfs]
[130420.008964]  [<ffffffffa019b464>] ? btrfs_cow_block+0x114/0x1d0 [btrfs]
[130420.009001]  [<ffffffffa019f1d6>] ? btrfs_search_slot+0x206/0xa40 [btrfs]
[130420.009039]  [<ffffffffa01a6089>] ? lookup_inline_extent_backref+0xd9/0x620 [btrfs]
[130420.009095]  [<ffffffffa01e4e74>] ? set_extent_bit+0x24/0x30 [btrfs]
[130420.009124]  [<ffffffff8118567f>] ? kmem_cache_alloc+0x17f/0x1b0
[130420.009161]  [<ffffffffa01a7b1f>] ? __btrfs_free_extent.isra.69+0xef/0xd10 [btrfs]
[130420.009215]  [<ffffffffa0214346>] ? btrfs_merge_delayed_refs+0x56/0x6f0 [btrfs]
[130420.009269]  [<ffffffffa01ac545>] ? __btrfs_run_delayed_refs+0x745/0x1320 [btrfs]
[130420.009314]  [<ffffffff810801ef>] ? ttwu_do_wakeup+0xf/0xe0
[130420.009351]  [<ffffffffa01b0000>] ? btrfs_run_delayed_refs+0x90/0x2b0 [btrfs]
[130420.009404]  [<ffffffffa01b02a4>] ? delayed_ref_async_start+0x84/0xa0 [btrfs]
[130420.009459]  [<ffffffffa01f82a3>] ? normal_work_helper+0xc3/0x2f0 [btrfs]
[130420.009490]  [<ffffffff81071efb>] ? process_one_work+0x14b/0x400
[130420.009518]  [<ffffffff8107251d>] ? worker_thread+0x5d/0x470
[130420.009546]  [<ffffffff810724c0>] ? rescuer_thread+0x310/0x310
[130420.009573]  [<ffffffff8105ed54>] ? do_group_exit+0x34/0xb0
[130420.009601]  [<ffffffff810772bb>] ? kthread+0xcb/0xf0
[130420.009627]  [<ffffffff810771f0>] ? kthread_park+0x50/0x50
[130420.009655]  [<ffffffff8150c8d2>] ? ret_from_fork+0x22/0x30
----------------------------------------

----------------------------------------
[130438.436025] jbd2/dm-0-8: page allocation stalls for 10492ms, order:0, mode:0x2420848(GFP_NOFS|__GFP_NOFAIL|__GFP_HARDWALL|__GFP_MOVABLE)
[130438.436095] CPU: 2 PID: 1838 Comm: jbd2/dm-0-8 Tainted: G        W I     4.9.0-rc5 #2
[130438.436184]  0000000000000000 ffffffff8129ba69 ffffffff8170e4c8 ffffc90003e13728
[130438.436237]  ffffffff8113449f 0242084800000200 ffffffff8170e4c8 ffffc90003e136d0
[130438.436289]  0000000100000010 ffffc90003e13738 ffffc90003e136e8 0000000000000001
[130438.436340] Call Trace:
[130438.436368]  [<ffffffff8129ba69>] ? dump_stack+0x46/0x5d
[130438.436399]  [<ffffffff8113449f>] ? warn_alloc+0x11f/0x140
[130438.436426]  [<ffffffff81134d7b>] ? __alloc_pages_slowpath+0x84b/0xa80
[130438.436455]  [<ffffffff81135260>] ? __alloc_pages_nodemask+0x2b0/0x2f0
[130438.436488]  [<ffffffff8117dbda>] ? alloc_pages_current+0x8a/0x110
[130438.436518]  [<ffffffff8112afcc>] ? pagecache_get_page+0xec/0x280
[130438.436549]  [<ffffffff811cc051>] ? __getblk_gfp+0xf1/0x320
[130438.436593]  [<ffffffffa02bc774>] ? ext4_get_branch+0xa4/0x130 [ext4]
[130438.436628]  [<ffffffffa02bd24b>] ? ext4_ind_map_blocks+0xcb/0xb10 [ext4]
[130438.436658]  [<ffffffff8108807e>] ? update_curr+0x7e/0x100
[130438.436688]  [<ffffffff810bfe61>] ? ktime_get+0x31/0xa0
[130438.436716]  [<ffffffff8112e329>] ? mempool_alloc+0x59/0x170
[130438.436743]  [<ffffffff8108807e>] ? update_curr+0x7e/0x100
[130438.436775]  [<ffffffffa0280813>] ? ext4_map_blocks+0x3c3/0x630 [ext4]
[130438.436808]  [<ffffffffa0280ae4>] ? _ext4_get_block+0x64/0xc0 [ext4]
[130438.436838]  [<ffffffff811ca6a7>] ? generic_block_bmap+0x37/0x50
[130438.436870]  [<ffffffffa027fc57>] ? ext4_bmap+0x37/0xd0 [ext4]
[130438.436901]  [<ffffffffa008a5e1>] ? jbd2_journal_bmap+0x21/0x70 [jbd2]
[130438.436932]  [<ffffffffa008a6be>] ? jbd2_journal_get_descriptor_buffer+0x1e/0xc0 [jbd2]
[130438.436979]  [<ffffffffa0086aa8>] ? jbd2_journal_write_revoke_records+0x198/0x2b0 [jbd2]
[130438.437026]  [<ffffffffa0083236>] ? jbd2_journal_commit_transaction+0x5d6/0x19f0 [jbd2]
[130438.437071]  [<ffffffff8108807e>] ? update_curr+0x7e/0x100
[130438.437099]  [<ffffffff8108c8fc>] ? dequeue_task_fair+0x5dc/0x1120
[130438.437127]  [<ffffffff8108f61c>] ? pick_next_task_fair+0x12c/0x420
[130438.437157]  [<ffffffffa00884e8>] ? kjournald2+0xc8/0x250 [jbd2]
[130438.437187]  [<ffffffff810948e0>] ? wake_up_atomic_t+0x30/0x30
[130438.437216]  [<ffffffffa0088420>] ? commit_timeout+0x10/0x10 [jbd2]
[130438.437247]  [<ffffffff810772bb>] ? kthread+0xcb/0xf0
[130438.437273]  [<ffffffff810771f0>] ? kthread_park+0x50/0x50
[130438.437304]  [<ffffffff8150c8d2>] ? ret_from_fork+0x22/0x30
----------------------------------------

Under such situation, saving /sys/kernel/debug/page_owner to a file might
be impossible. And, once the stalling started, it took less than 5 minutes
before the kernel panics due to "Out of memory and no killable process".
This could happen when E V is offline. 

Since rsyslogd is likely be killed by the OOM killer for situations like
this, E V might want to try serial console or netconsole for saving kernel
messages reliably.

I don't know what we will find by analyzing /sys/kernel/debug/page_owner ,
but if something is wrong, can't we try whether
"echo 3 > /proc/sys/vm/drop_caches" before the stalling starts helps.

I guess that this problem became visible by OOM detection rework which
went to Linux 4.7. I don't know what "free_pcp:0kB local_pcp:0kB" means
(get_page_from_freelist() for any order is failng?), but in general I think
this /var/log/messages showed that free_pcp: and local_pcp: remains small.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
