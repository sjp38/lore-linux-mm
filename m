Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBB16B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 09:06:35 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 50so73404204uae.7
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 06:06:35 -0800 (PST)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id u68si10122697uau.20.2016.11.25.06.06.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 06:06:34 -0800 (PST)
Received: by mail-vk0-x241.google.com with SMTP id l126so1838575vkh.0
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 06:06:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <74787aa3-4140-2bae-ce59-5b67db33d811@suse.cz>
References: <bug-186671-27@https.bugzilla.kernel.org/> <20161103115353.de87ff35756a4ca8b21d2c57@linux-foundation.org>
 <b5b0cef0-8482-e4de-cb81-69a4dd3410fb@suse.cz> <CAJtFHUQcJKSnyQ7t7-eDpiF2C+U23+iWpZ+X6fGEzN8qdbzmtA@mail.gmail.com>
 <a8cf869e-f527-9c65-d16d-ac70cf66472a@suse.cz> <CAJtFHUQgkvFaPdyRcoiV-m5hynDGo2qXfMXzZvGahoWp2LL_KA@mail.gmail.com>
 <bbcd6cb7-3b73-02e9-0409-4601a6f573f5@suse.cz> <CAJtFHUSka8nbaO5RNEcWVRi7VoQ7UORWkMu_7pNW3n_9iRRdew@mail.gmail.com>
 <CAJtFHUTn9Ejvyj3vJkqnsLoa6gci104-TPu5viG=epfJ9Rk_qg@mail.gmail.com>
 <4c85dfa5-9dbe-ea3c-7816-1ab321931e1c@suse.cz> <d0a4adfc-5017-71ba-c895-fc7603b54f7a@I-love.SAKURA.ne.jp>
 <CAJtFHUT3qK_DA2xPbWpjeaeHyqksM7+bYvvrFtL5g0=uP0jrvg@mail.gmail.com>
 <CAJtFHURrPdJcLrB1sN6YUnJ4F-aH6oSbMY59gVwiEHPt+BL9KA@mail.gmail.com> <74787aa3-4140-2bae-ce59-5b67db33d811@suse.cz>
From: E V <eliventer@gmail.com>
Date: Fri, 25 Nov 2016 09:06:33 -0500
Message-ID: <CAJtFHUSt1q=YYQXGVg+bK2H4fpDT0c0kqaXj3odLo6KFdJcwfg@mail.gmail.com>
Subject: Re: [Bug 186671] New: OOM on system with just rsync running 32GB of
 ram 30GB of pagecache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, linux-btrfs <linux-btrfs@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

So I rebooted with 4.9rc6 with the patch inspired by the thread
"[PATCH] btrfs: limit the number of asynchronous delalloc pages to
reasonable value", but at 512K pages, ie:

 diff -u2 fs/btrfs/inode.c ../linux-4.9-rc6/fs/btrfs/
--- fs/btrfs/inode.c    2016-11-13 13:32:32.000000000 -0500
+++ ../linux-4.9-rc6/fs/btrfs/inode.c   2016-11-23 08:31:02.145669550 -0500
@@ -1159,5 +1159,5 @@
        unsigned long nr_pages;
        u64 cur_end;
-       int limit = 10 * SZ_1M;
+       int limit = SZ_512K;

        clear_extent_bit(&BTRFS_I(inode)->io_tree, start, end, EXTENT_LOCKED,

System still OOM'd after a few hours of rsync copying & deleting
files, but it didn't panic this time which was nice ;-) I then set:
echo 500 >> /proc/sys/vm/watermark_scale_factor
echo 3 >> /proc/sys/vm/dirty_background_ratio

and system has been running rsync fine for most of a day. system
memory load is noticably different in sar -r after changing the vm
params, rsync during OOM:
12:00:01 AM kbmemfree kbmemused  %memused kbbuffers  kbcached
kbcommit   %commit  kbactive   kbinact   kbdirty
03:25:05 AM    158616  32836640     99.52     72376  30853268
2942644      3.62  26048876   4977872   4936488
03:30:36 AM    157700  32837556     99.52     72468  30944468
2940028      3.62  26070084   4957328   4957432
03:35:02 AM   1802144  31193112     94.54     72560  29266432
2944352      3.62  26184324   3182048    187784
03:40:32 AM    157272  32837984     99.52     72648  30934432
3007244      3.70  26102636   4930744   4927832
03:45:05 AM    158288  32836968     99.52     72896  30980504
412108      0.51  26089920   4959668   4977556
running rsync after tuning VM params:
08:35:01 AM   1903352  31091904     94.23    232772  26603624
2680952      3.30  24133864   5019748   1229964
08:40:01 AM   2878552  30116704     91.28    232800  25641520
2697356      3.32  24158248   4039372   2864656
08:45:01 AM   3482616  29512640     89.45    232656  25043068
2696144      3.32  24087376   3526164   1897192
08:50:01 AM   3590672  29404584     89.12    232856  24962856
2704196      3.33  24078188   3451400    666760
08:55:01 AM   2064900  30930356     93.74    234800  26480996
2730384      3.36  24009244   5044012     50028

On Tue, Nov 22, 2016 at 9:48 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 11/22/2016 02:58 PM, E V wrote:
>> System OOM'd several times last night with 4.8.10, I attached the
>> page_owner output from a morning cat ~8 hours after OOM's to the
>> bugzilla case, split and compressed to fit under the 5M attachment
>> limit. Let me know if you need anything else.
>
> Looks like for some reason, the stack saving produces garbage stacks
> that only repeat save_stack_trace and save_stack functions :/
>
> But judging from gfp flags and page flags, most pages seem to be
> allocated with:
>
> mask 0x2400840(GFP_NOFS|__GFP_NOFAIL)
>
> and page flags:
>
> 0x20000000000006c(referenced|uptodate|lru|active)
> or
> 0x20000000000016c(referenced|uptodate|lru|active|owner_priv_1)
> or
> 0x20000000000086c(referenced|uptodate|lru|active|private)
>
> While GFP_HIGHUSER_MOVABLE (which I would expect on lru) are less frequent.
>
> Example:
>> grep GFP_NOFS page_owner_after_af | wc -l
> 973596
>> grep GFP_HIGHUSER_MOVABLE page_owner_after_af | wc -l
> 158879
>> grep GFP_NOFAIL page_owner_after_af | wc -l
> 971442
>
> grepping for btrfs shows that at least some stacks for NOFS/NOFAIL pages
> imply it:
> clear_state_bit+0x135/0x1c0 [btrfs]
> or
> add_delayed_tree_ref+0xbf/0x170 [btrfs]
> or
> __btrfs_map_block+0x6a8/0x1200 [btrfs]
> or
> btrfs_buffer_uptodate+0x48/0x70 [btrfs]
> or
> btrfs_set_path_blocking+0x34/0x60 [btrfs]
>
> and some more variants.
>
> So looks like the pages contain btrfs metadata, are on file lru and from
> previous checks of /proc/kpagecount we know that they most likely have
> page_count() == 0 but are not freed. Could btrfs guys provide some
> insight here?
>
>> On Fri, Nov 18, 2016 at 10:02 AM, E V <eliventer@gmail.com> wrote:
>>> Yes, the short window between the stalls and the panic makes it
>>> difficult to manually check much. I could setup a cron every 5 minutes
>>> or so if you want. Also, I see the OOM's in 4.8, but it has yet to
>>> panic on me. Where as 4.9rc has panic'd both times I've booted it, so
>>> depending on what you want to look at it might be easier to
>>> investigate on 4.8. Let me know, I can turn on a couple of the DEBUG
>>> config's and build a new 4.8.8. Never looked into a netconsole or
>>> serial console. I think just getting the system to use a higher res
>>> console would be an improvement, but the OOM's seemed to be the root
>>> cause of the panic so I haven't spent any time looking into that as of
>>> yet,
>>>
>>> Thanks,
>>> -Eli
>>>
>>> On Fri, Nov 18, 2016 at 6:54 AM, Tetsuo Handa
>>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>>> On 2016/11/18 6:49, Vlastimil Babka wrote:
>>>>> On 11/16/2016 02:39 PM, E V wrote:
>>>>>> System panic'd overnight running 4.9rc5 & rsync. Attached a photo of
>>>>>> the stack trace, and the 38 call traces in a 2 minute window shortly
>>>>>> before, to the bugzilla case for those not on it's e-mail list:
>>>>>>
>>>>>> https://bugzilla.kernel.org/show_bug.cgi?id=186671
>>>>>
>>>>> The panic screenshot has only the last part, but the end marker says
>>>>> it's OOM with no killable processes. The DEBUG_VM config thus didn't
>>>>> trigger anything, and still there's tons of pagecache, mostly clean,
>>>>> that's not being reclaimed.
>>>>>
>>>>> Could you now try this?
>>>>> - enable CONFIG_PAGE_OWNER
>>>>> - boot with kernel option: page_owner=on
>>>>> - after the first oom, "cat /sys/kernel/debug/page_owner > file"
>>>>> - provide the file (compressed, it will be quite large)
>>>>
>>>> Excuse me for a noise, but do we really need to do
>>>> "cat /sys/kernel/debug/page_owner > file" after the first OOM killer
>>>> invocation? I worry that it might be too difficult to do.
>>>> Shouldn't we rather do "cat /sys/kernel/debug/page_owner > file"
>>>> hourly and compare tendency between the latest one and previous one?
>>>>
>>>> This system has swap, and /var/log/messages before panic
>>>> reports that swapin was stalling at memory allocation.
>>>>
>>>> ----------------------------------------
>>>> [130346.262510] dsm_sa_datamgrd: page allocation stalls for 52400ms, order:0, mode:0x24200ca(GFP_HIGHUSER_MOVABLE)
>>>> [130346.262572] CPU: 1 PID: 3622 Comm: dsm_sa_datamgrd Tainted: G        W I     4.9.0-rc5 #2
>>>> [130346.262662]  0000000000000000 ffffffff8129ba69 ffffffff8170e4c8 ffffc90003ccb8d8
>>>> [130346.262714]  ffffffff8113449f 024200ca1ca11b40 ffffffff8170e4c8 ffffc90003ccb880
>>>> [130346.262765]  ffffffff00000010 ffffc90003ccb8e8 ffffc90003ccb898 ffff88041f226e80
>>>> [130346.262817] Call Trace:
>>>> [130346.262843]  [<ffffffff8129ba69>] ? dump_stack+0x46/0x5d
>>>> [130346.262872]  [<ffffffff8113449f>] ? warn_alloc+0x11f/0x140
>>>> [130346.262899]  [<ffffffff81134d7b>] ? __alloc_pages_slowpath+0x84b/0xa80
>>>> [130346.262929]  [<ffffffff81135260>] ? __alloc_pages_nodemask+0x2b0/0x2f0
>>>> [130346.262960]  [<ffffffff8117f1be>] ? alloc_pages_vma+0xbe/0x260
>>>> [130346.262989]  [<ffffffff8112af02>] ? pagecache_get_page+0x22/0x280
>>>> [130346.263019]  [<ffffffff81171b68>] ? __read_swap_cache_async+0x118/0x1a0
>>>> [130346.263048]  [<ffffffff81171bff>] ? read_swap_cache_async+0xf/0x30
>>>> [130346.263077]  [<ffffffff81171d8e>] ? swapin_readahead+0x16e/0x1c0
>>>> [130346.263106]  [<ffffffff812a0f6e>] ? radix_tree_lookup_slot+0xe/0x20
>>>> [130346.263135]  [<ffffffff8112ac84>] ? find_get_entry+0x14/0x130
>>>> [130346.263162]  [<ffffffff8112af02>] ? pagecache_get_page+0x22/0x280
>>>> [130346.263193]  [<ffffffff8115cb1f>] ? do_swap_page+0x44f/0x5f0
>>>> [130346.263220]  [<ffffffff812a0f02>] ? __radix_tree_lookup+0x62/0xc0
>>>> [130346.263249]  [<ffffffff8115e91a>] ? handle_mm_fault+0x66a/0xf00
>>>> [130346.263277]  [<ffffffff8112ac84>] ? find_get_entry+0x14/0x130
>>>> [130346.263305]  [<ffffffff8104a245>] ? __do_page_fault+0x1c5/0x490
>>>> [130346.263336]  [<ffffffff8150e322>] ? page_fault+0x22/0x30
>>>> [130346.263364]  [<ffffffff812a7cac>] ? copy_user_generic_string+0x2c/0x40
>>>> [130346.263395]  [<ffffffff811adc1d>] ? set_fd_set+0x1d/0x30
>>>> [130346.263422]  [<ffffffff811ae905>] ? core_sys_select+0x1a5/0x260
>>>> [130346.263450]  [<ffffffff811a913a>] ? getname_flags+0x6a/0x1e0
>>>> [130346.263479]  [<ffffffff8119ef25>] ? cp_new_stat+0x115/0x130
>>>> [130346.263509]  [<ffffffff810bf01f>] ? ktime_get_ts64+0x3f/0xf0
>>>> [130346.263537]  [<ffffffff811aea65>] ? SyS_select+0xa5/0xe0
>>>> [130346.263564]  [<ffffffff8150c6a0>] ? entry_SYSCALL_64_fastpath+0x13/0x94
>>>> ----------------------------------------
>>>>
>>>> Under such situation, trying to login and execute /bin/cat could take minutes.
>>>> Also, writing to btrfs and ext4 seems to be stalling. The btrfs one is a
>>>> situation where WQ_MEM_RECLAIM kernel workqueue is unable to make progress.
>>>>
>>>> ----------------------------------------
>>>> [130420.008231] kworker/u34:21: page allocation stalls for 35028ms, order:0, mode:0x2400840(GFP_NOFS|__GFP_NOFAIL)
>>>> [130420.008287] CPU: 5 PID: 24286 Comm: kworker/u34:21 Tainted: G        W I     4.9.0-rc5 #2
>>>> [130420.008401] Workqueue: btrfs-extent-refs btrfs_extent_refs_helper [btrfs]
>>>> [130420.008432]  0000000000000000 ffffffff8129ba69 ffffffff8170e4c8 ffffc900087836a0
>>>> [130420.008483]  ffffffff8113449f 024008401e3f1b40 ffffffff8170e4c8 ffffc90008783648
>>>> [130420.008534]  ffffffff00000010 ffffc900087836b0 ffffc90008783660 ffff88041ecc4340
>>>> [130420.008586] Call Trace:
>>>> [130420.008611]  [<ffffffff8129ba69>] ? dump_stack+0x46/0x5d
>>>> [130420.008640]  [<ffffffff8113449f>] ? warn_alloc+0x11f/0x140
>>>> [130420.008667]  [<ffffffff81134d7b>] ? __alloc_pages_slowpath+0x84b/0xa80
>>>> [130420.008707]  [<ffffffffa020c432>] ? search_bitmap+0xc2/0x140 [btrfs]
>>>> [130420.008736]  [<ffffffff81135260>] ? __alloc_pages_nodemask+0x2b0/0x2f0
>>>> [130420.008766]  [<ffffffff8117dbda>] ? alloc_pages_current+0x8a/0x110
>>>> [130420.008796]  [<ffffffff8112afcc>] ? pagecache_get_page+0xec/0x280
>>>> [130420.008836]  [<ffffffffa01e9aa8>] ? alloc_extent_buffer+0x108/0x430 [btrfs]
>>>> [130420.008875]  [<ffffffffa01b4108>] ? btrfs_alloc_tree_block+0x118/0x4d0 [btrfs]
>>>> [130420.008927]  [<ffffffffa019ae38>] ? __btrfs_cow_block+0x148/0x5d0 [btrfs]
>>>> [130420.008964]  [<ffffffffa019b464>] ? btrfs_cow_block+0x114/0x1d0 [btrfs]
>>>> [130420.009001]  [<ffffffffa019f1d6>] ? btrfs_search_slot+0x206/0xa40 [btrfs]
>>>> [130420.009039]  [<ffffffffa01a6089>] ? lookup_inline_extent_backref+0xd9/0x620 [btrfs]
>>>> [130420.009095]  [<ffffffffa01e4e74>] ? set_extent_bit+0x24/0x30 [btrfs]
>>>> [130420.009124]  [<ffffffff8118567f>] ? kmem_cache_alloc+0x17f/0x1b0
>>>> [130420.009161]  [<ffffffffa01a7b1f>] ? __btrfs_free_extent.isra.69+0xef/0xd10 [btrfs]
>>>> [130420.009215]  [<ffffffffa0214346>] ? btrfs_merge_delayed_refs+0x56/0x6f0 [btrfs]
>>>> [130420.009269]  [<ffffffffa01ac545>] ? __btrfs_run_delayed_refs+0x745/0x1320 [btrfs]
>>>> [130420.009314]  [<ffffffff810801ef>] ? ttwu_do_wakeup+0xf/0xe0
>>>> [130420.009351]  [<ffffffffa01b0000>] ? btrfs_run_delayed_refs+0x90/0x2b0 [btrfs]
>>>> [130420.009404]  [<ffffffffa01b02a4>] ? delayed_ref_async_start+0x84/0xa0 [btrfs]
>>>> [130420.009459]  [<ffffffffa01f82a3>] ? normal_work_helper+0xc3/0x2f0 [btrfs]
>>>> [130420.009490]  [<ffffffff81071efb>] ? process_one_work+0x14b/0x400
>>>> [130420.009518]  [<ffffffff8107251d>] ? worker_thread+0x5d/0x470
>>>> [130420.009546]  [<ffffffff810724c0>] ? rescuer_thread+0x310/0x310
>>>> [130420.009573]  [<ffffffff8105ed54>] ? do_group_exit+0x34/0xb0
>>>> [130420.009601]  [<ffffffff810772bb>] ? kthread+0xcb/0xf0
>>>> [130420.009627]  [<ffffffff810771f0>] ? kthread_park+0x50/0x50
>>>> [130420.009655]  [<ffffffff8150c8d2>] ? ret_from_fork+0x22/0x30
>>>> ----------------------------------------
>>>>
>>>> ----------------------------------------
>>>> [130438.436025] jbd2/dm-0-8: page allocation stalls for 10492ms, order:0, mode:0x2420848(GFP_NOFS|__GFP_NOFAIL|__GFP_HARDWALL|__GFP_MOVABLE)
>>>> [130438.436095] CPU: 2 PID: 1838 Comm: jbd2/dm-0-8 Tainted: G        W I     4.9.0-rc5 #2
>>>> [130438.436184]  0000000000000000 ffffffff8129ba69 ffffffff8170e4c8 ffffc90003e13728
>>>> [130438.436237]  ffffffff8113449f 0242084800000200 ffffffff8170e4c8 ffffc90003e136d0
>>>> [130438.436289]  0000000100000010 ffffc90003e13738 ffffc90003e136e8 0000000000000001
>>>> [130438.436340] Call Trace:
>>>> [130438.436368]  [<ffffffff8129ba69>] ? dump_stack+0x46/0x5d
>>>> [130438.436399]  [<ffffffff8113449f>] ? warn_alloc+0x11f/0x140
>>>> [130438.436426]  [<ffffffff81134d7b>] ? __alloc_pages_slowpath+0x84b/0xa80
>>>> [130438.436455]  [<ffffffff81135260>] ? __alloc_pages_nodemask+0x2b0/0x2f0
>>>> [130438.436488]  [<ffffffff8117dbda>] ? alloc_pages_current+0x8a/0x110
>>>> [130438.436518]  [<ffffffff8112afcc>] ? pagecache_get_page+0xec/0x280
>>>> [130438.436549]  [<ffffffff811cc051>] ? __getblk_gfp+0xf1/0x320
>>>> [130438.436593]  [<ffffffffa02bc774>] ? ext4_get_branch+0xa4/0x130 [ext4]
>>>> [130438.436628]  [<ffffffffa02bd24b>] ? ext4_ind_map_blocks+0xcb/0xb10 [ext4]
>>>> [130438.436658]  [<ffffffff8108807e>] ? update_curr+0x7e/0x100
>>>> [130438.436688]  [<ffffffff810bfe61>] ? ktime_get+0x31/0xa0
>>>> [130438.436716]  [<ffffffff8112e329>] ? mempool_alloc+0x59/0x170
>>>> [130438.436743]  [<ffffffff8108807e>] ? update_curr+0x7e/0x100
>>>> [130438.436775]  [<ffffffffa0280813>] ? ext4_map_blocks+0x3c3/0x630 [ext4]
>>>> [130438.436808]  [<ffffffffa0280ae4>] ? _ext4_get_block+0x64/0xc0 [ext4]
>>>> [130438.436838]  [<ffffffff811ca6a7>] ? generic_block_bmap+0x37/0x50
>>>> [130438.436870]  [<ffffffffa027fc57>] ? ext4_bmap+0x37/0xd0 [ext4]
>>>> [130438.436901]  [<ffffffffa008a5e1>] ? jbd2_journal_bmap+0x21/0x70 [jbd2]
>>>> [130438.436932]  [<ffffffffa008a6be>] ? jbd2_journal_get_descriptor_buffer+0x1e/0xc0 [jbd2]
>>>> [130438.436979]  [<ffffffffa0086aa8>] ? jbd2_journal_write_revoke_records+0x198/0x2b0 [jbd2]
>>>> [130438.437026]  [<ffffffffa0083236>] ? jbd2_journal_commit_transaction+0x5d6/0x19f0 [jbd2]
>>>> [130438.437071]  [<ffffffff8108807e>] ? update_curr+0x7e/0x100
>>>> [130438.437099]  [<ffffffff8108c8fc>] ? dequeue_task_fair+0x5dc/0x1120
>>>> [130438.437127]  [<ffffffff8108f61c>] ? pick_next_task_fair+0x12c/0x420
>>>> [130438.437157]  [<ffffffffa00884e8>] ? kjournald2+0xc8/0x250 [jbd2]
>>>> [130438.437187]  [<ffffffff810948e0>] ? wake_up_atomic_t+0x30/0x30
>>>> [130438.437216]  [<ffffffffa0088420>] ? commit_timeout+0x10/0x10 [jbd2]
>>>> [130438.437247]  [<ffffffff810772bb>] ? kthread+0xcb/0xf0
>>>> [130438.437273]  [<ffffffff810771f0>] ? kthread_park+0x50/0x50
>>>> [130438.437304]  [<ffffffff8150c8d2>] ? ret_from_fork+0x22/0x30
>>>> ----------------------------------------
>>>>
>>>> Under such situation, saving /sys/kernel/debug/page_owner to a file might
>>>> be impossible. And, once the stalling started, it took less than 5 minutes
>>>> before the kernel panics due to "Out of memory and no killable process".
>>>> This could happen when E V is offline.
>>>>
>>>> Since rsyslogd is likely be killed by the OOM killer for situations like
>>>> this, E V might want to try serial console or netconsole for saving kernel
>>>> messages reliably.
>>>>
>>>> I don't know what we will find by analyzing /sys/kernel/debug/page_owner ,
>>>> but if something is wrong, can't we try whether
>>>> "echo 3 > /proc/sys/vm/drop_caches" before the stalling starts helps.
>>>>
>>>> I guess that this problem became visible by OOM detection rework which
>>>> went to Linux 4.7. I don't know what "free_pcp:0kB local_pcp:0kB" means
>>>> (get_page_from_freelist() for any order is failng?), but in general I think
>>>> this /var/log/messages showed that free_pcp: and local_pcp: remains small.
>>>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
