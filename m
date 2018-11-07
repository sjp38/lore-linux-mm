Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA56C6B057B
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 18:43:42 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id j9-v6so16726976pfn.20
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 15:43:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x5-v6si2323295pfx.74.2018.11.07.15.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 15:43:40 -0800 (PST)
Date: Wed, 7 Nov 2018 15:43:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [LKP] d50d82faa0 [ 33.671845] WARNING: possible circular
 locking dependency detected
Message-Id: <20181107154336.21e1f815226facdffd4a6c54@linux-foundation.org>
In-Reply-To: <20181023003004.GH24195@shao2-debian>
References: <20181023003004.GH24195@shao2-debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <rong.a.chen@intel.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>

On Tue, 23 Oct 2018 08:30:04 +0800 kernel test robot <rong.a.chen@intel.com> wrote:

> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> 
> commit d50d82faa0c964e31f7a946ba8aba7c715ca7ab0
> Author:     Mikulas Patocka <mpatocka@redhat.com>
> AuthorDate: Wed Jun 27 23:26:09 2018 -0700
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Thu Jun 28 11:16:44 2018 -0700
> 
>     slub: fix failure when we delete and create a slab cache

This is ugly.  Is there an alternative way of fixing the race which
Mikulas attempted to address?  Possibly cancel the work and reuse the
existing sysfs file, or is that too stupid to live?

3b7b314053d021 ("slub: make sysfs file removal asynchronous") was
pretty lame, really.  As mentioned,

: It'd be the cleanest to deal with the issue by removing sysfs files
: without holding slab_mutex before the rest of shutdown; however, given
: the current code structure, it is pretty difficult to do so.

Would be a preferable approach.

>     In kernel 4.17 I removed some code from dm-bufio that did slab cache
>     merging (commit 21bb13276768: "dm bufio: remove code that merges slab
>     caches") - both slab and slub support merging caches with identical
>     attributes, so dm-bufio now just calls kmem_cache_create and relies on
>     implicit merging.
>     
>     This uncovered a bug in the slub subsystem - if we delete a cache and
>     immediatelly create another cache with the same attributes, it fails
>     because of duplicate filename in /sys/kernel/slab/.  The slub subsystem
>     offloads freeing the cache to a workqueue - and if we create the new
>     cache before the workqueue runs, it complains because of duplicate
>     filename in sysfs.
>     
>     This patch fixes the bug by moving the call of kobject_del from
>     sysfs_slab_remove_workfn to shutdown_cache.  kobject_del must be called
>     while we hold slab_mutex - so that the sysfs entry is deleted before a
>     cache with the same attributes could be created.
>     
>     Running device-mapper-test-suite with:
>     
>       dmtest run --suite thin-provisioning -n /commit_failure_causes_fallback/
>     
>     triggered:
>     
>       Buffer I/O error on dev dm-0, logical block 1572848, async page read
>       device-mapper: thin: 253:1: metadata operation 'dm_pool_alloc_data_block' failed: error = -5
>       device-mapper: thin: 253:1: aborting current metadata transaction
>       sysfs: cannot create duplicate filename '/kernel/slab/:a-0000144'
>       CPU: 2 PID: 1037 Comm: kworker/u48:1 Not tainted 4.17.0.snitm+ #25
>       Hardware name: Supermicro SYS-1029P-WTR/X11DDW-L, BIOS 2.0a 12/06/2017
>       Workqueue: dm-thin do_worker [dm_thin_pool]
>       Call Trace:
>        dump_stack+0x5a/0x73
>        sysfs_warn_dup+0x58/0x70
>        sysfs_create_dir_ns+0x77/0x80
>        kobject_add_internal+0xba/0x2e0
>        kobject_init_and_add+0x70/0xb0
>        sysfs_slab_add+0xb1/0x250
>        __kmem_cache_create+0x116/0x150
>        create_cache+0xd9/0x1f0
>        kmem_cache_create_usercopy+0x1c1/0x250
>        kmem_cache_create+0x18/0x20
>        dm_bufio_client_create+0x1ae/0x410 [dm_bufio]
>        dm_block_manager_create+0x5e/0x90 [dm_persistent_data]
>        __create_persistent_data_objects+0x38/0x940 [dm_thin_pool]
>        dm_pool_abort_metadata+0x64/0x90 [dm_thin_pool]
>        metadata_operation_failed+0x59/0x100 [dm_thin_pool]
>        alloc_data_block.isra.53+0x86/0x180 [dm_thin_pool]
>        process_cell+0x2a3/0x550 [dm_thin_pool]
>        do_worker+0x28d/0x8f0 [dm_thin_pool]
>        process_one_work+0x171/0x370
>        worker_thread+0x49/0x3f0
>        kthread+0xf8/0x130
>        ret_from_fork+0x35/0x40
>       kobject_add_internal failed for :a-0000144 with -EEXIST, don't try to register things with the same name in the same directory.
>       kmem_cache_create(dm_bufio_buffer-16) failed with error -17
>     
>     Link: http://lkml.kernel.org/r/alpine.LRH.2.02.1806151817130.6333@file01.intranet.prod.int.rdu2.redhat.com
>     Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
>     Reported-by: Mike Snitzer <snitzer@redhat.com>
>     Tested-by: Mike Snitzer <snitzer@redhat.com>
>     Cc: Christoph Lameter <cl@linux.com>
>     Cc: Pekka Enberg <penberg@kernel.org>
>     Cc: David Rientjes <rientjes@google.com>
>     Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>     Cc: <stable@vger.kernel.org>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> 28557cc106  Revert mm/vmstat.c: fix vmstat_update() preemption BUG
> d50d82faa0  slub: fix failure when we delete and create a slab cache
> 84df9525b0  Linux 4.19
> 8c60c36d0b  Add linux-next specific files for 20181019
> +-------------------------------------------------------+------------+------------+-------+---------------+
> |                                                       | 28557cc106 | d50d82faa0 | v4.19 | next-20181019 |
> +-------------------------------------------------------+------------+------------+-------+---------------+
> | boot_successes                                        | 228        | 67         | 72    | 0             |
> | boot_failures                                         | 1          | 13         | 8     | 1             |
> | BUG:kernel_hang_in_test_stage                         | 1          |            |       |               |
> | WARNING:possible_circular_locking_dependency_detected | 0          | 12         | 8     | 1             |
> | INFO:rcu_preempt_detected_stalls_on_CPUs/tasks        | 0          | 1          |       |               |
> +-------------------------------------------------------+------------+------------+-------+---------------+
> 
> [   29.227068] random: get_random_bytes called from key_alloc+0x2b0/0x44d with crng_init=1
> [   32.046253] random: get_random_bytes called from __ip_select_ident+0x45/0x93 with crng_init=1
> [   33.592007] random: get_random_bytes called from key_alloc+0x2b0/0x44d with crng_init=1
> [   33.670288] 
> [   33.670642] ======================================================
> [   33.671845] WARNING: possible circular locking dependency detected
> [   33.673016] 4.18.0-rc2-00135-gd50d82f #1 Tainted: G                T
> [   33.674215] ------------------------------------------------------
> [   33.675386] trinity-c3/689 is trying to acquire lock:
> [   33.676347] (____ptrval____) (slab_mutex){+.+.}, at: slab_attr_store+0x5a/0xd1
> [   33.677710] 
> [   33.677710] but task is already holding lock:
> [   33.678812] (____ptrval____) (kn->count#32){++++}, at: kernfs_fop_write+0xf3/0x1b0
> [   33.680230] 
> [   33.680230] which lock already depends on the new lock.
> [   33.680230] 
> [   33.681766] 
> [   33.681766] the existing dependency chain (in reverse order) is:
> [   33.683151] 
> [   33.683151] -> #1 (kn->count#32){++++}:
> [   33.684170]        kernfs_remove+0x1f/0x2c
> [   33.684968]        sysfs_remove_dir+0x5b/0x62
> [   33.685797]        kobject_del+0x20/0x4c
> [   33.686543]        shutdown_cache+0x116/0x12c
> [   33.687364]        kmem_cache_destroy+0x19c/0x1d1
> [   33.688277]        ovs_flow_exit+0x11/0x1d
> [   33.689048]        dp_init+0x2a5/0x2fc
> [   33.689766]        do_one_initcall+0xc8/0x296
> [   33.690592]        kernel_init_freeable+0x16c/0x2c4
> [   33.691534]        kernel_init+0xb/0x13d
> [   33.692279]        ret_from_fork+0x3a/0x50
> [   33.693046] 
> [   33.693046] -> #0 (slab_mutex){+.+.}:
> [   33.694022]        __mutex_lock+0x6e/0x257
> [   33.694826]        slab_attr_store+0x5a/0xd1
> [   33.695634]        sysfs_kf_write+0x58/0x73
> [   33.696430]        kernfs_fop_write+0x149/0x1b0
> [   33.697288]        __vfs_write+0x46/0x8d
> [   33.698056]        vfs_write+0xd5/0x10a
> [   33.698786]        ksys_pwrite64+0x77/0xa0
> [   33.699564]        do_syscall_64+0x107/0x11c
> [   33.700373]        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [   33.701438] 
> [   33.701438] other info that might help us debug this:
> [   33.701438] 
> [   33.702922]  Possible unsafe locking scenario:
> [   33.702922] 
> [   33.704028]        CPU0                    CPU1
> [   33.704904]        ----                    ----
> [   33.705755]   lock(kn->count#32);
> [   33.706393]                                lock(slab_mutex);
> [   33.707451]                                lock(kn->count#32);
> [   33.708566]   lock(slab_mutex);
> [   33.709165] 
> [   33.709165]  *** DEADLOCK ***
> [   33.709165] 
> [   33.710276] 3 locks held by trinity-c3/689:
> [   33.711072]  #0: (____ptrval____) (sb_writers#5){.+.+}, at: file_start_write+0x3b/0x41
> [   33.712562]  #1: (____ptrval____) (&of->mutex){+.+.}, at: kernfs_fop_write+0xeb/0x1b0
> [   33.714021]  #2: (____ptrval____) (kn->count#32){++++}, at: kernfs_fop_write+0xf3/0x1b0
> [   33.715546] 
> [   33.715546] stack backtrace:
> [   33.716371] CPU: 0 PID: 689 Comm: trinity-c3 Tainted: G                T 4.18.0-rc2-00135-gd50d82f #1
> [   33.718083] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [   33.719629] Call Trace:
> [   33.720111]  print_circular_bug+0x1c6/0x1d3
> [   33.721043]  __lock_acquire+0xbb0/0xe59
> [   33.721790]  ? lock_acquire+0x53/0x6f
> [   33.722490]  lock_acquire+0x53/0x6f
> [   33.723150]  ? slab_attr_store+0x5a/0xd1
> [   33.723897]  __mutex_lock+0x6e/0x257
> [   33.724604]  ? slab_attr_store+0x5a/0xd1
> [   33.725350]  ? slab_attr_store+0x5a/0xd1
> [   33.726089]  ? lock_acquire+0x53/0x6f
> [   33.726785]  ? lock_acquire+0x53/0x6f
> [   33.727480]  ? kernfs_fop_write+0xeb/0x1b0
> [   33.728290]  ? slab_attr_store+0x5a/0xd1
> [   33.729028]  ? alloc_node_mismatch_store+0x16/0x1a
> [   33.729927]  slab_attr_store+0x5a/0xd1
> [   33.730639]  sysfs_kf_write+0x58/0x73
> [   33.731361]  kernfs_fop_write+0x149/0x1b0
> [   33.732110]  ? sysfs_file_ops+0x6c/0x6c
> [   33.732841]  ? copy_overflow+0x22/0x22
> [   33.733555]  __vfs_write+0x46/0x8d
> [   33.734216]  vfs_write+0xd5/0x10a
> [   33.734862]  ksys_pwrite64+0x77/0xa0
> [   33.735544]  do_syscall_64+0x107/0x11c
> [   33.736260]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [   33.737204] RIP: 0033:0x457389
> [   33.737797] Code: 00 f3 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 2b 84 00 00 c3 66 2e 0f 1f 84 00 00 00 00 
> [   33.741375] RSP: 002b:00007ffe1c922d48 EFLAGS: 00000246 ORIG_RAX: 0000000000000012
> [   33.742776] RAX: ffffffffffffffda RBX: 0000000000000012 RCX: 0000000000457389
> [   33.744108] RDX: 00000000000001c1 RSI: 0000000001344710 RDI: 000000000000010a
> [   33.745463] RBP: 00007ffe1c922df0 R08: 00000000f4c64000 R09: bbed0ee996d421b9
> [   33.746783] R10: 0000000000000800 R11: 0000000000000246 R12: 0000000000000002
> [   33.748124] R13: 00007fcb40b97058 R14: 000000000104a830 R15: 00007fcb40b97000
> [   35.830419] raw_sendmsg: trinity-c3 forgot to set AF_INET. Fix it!
> [   54.240043] random: get_random_bytes called from __prandom_timer+0x15/0x5a with crng_init=1
> [   58.674359] random: get_random_bytes called from key_alloc+0x2b0/0x44d with crng_init=1
> 
>                                                           # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
> git bisect start v4.18 v4.17 --
> git bisect good c81b995f00c7a1c2ca9ad67f5bb4a50d02f98f84  # 18:03  G     74     0    0   0  Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> git bisect  bad 47f7dc4b845a9fe60c53b84b8c88cf14efd0de7f  # 18:13  B     18     3    0   0  Merge tag 'for-linus' of git://git.kernel.org/pub/scm/virt/kvm/kvm
> git bisect  bad 0fa3ecd87848c9c93c2c828ef4c3a8ca36ce46c7  # 18:35  B      7     1    0   0  Fix up non-directory creation in SGID directories
> git bisect  bad 1904148a361a07fb2d7cba1261d1d2c2f33c8d2e  # 18:52  B      6     1    0   0  Merge tag 'powerpc-4.18-3' of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux
> git bisect good a11e1d432b51f63ba698d044441284a661f01144  # 19:19  G     73     0    2   2  Revert changes to convert to ->poll_mask() and aio IOCB_CMD_POLL
> git bisect  bad ff23908bb78bbc0999ff35e6f319f1648c4ded93  # 19:31  B      0     1   15   0  Merge tag 'for-4.18/dm-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/device-mapper/linux-dm
> git bisect  bad e26aac3caeadc476b96a1f384715e96b4a607342  # 19:40  B      2     1    0   0  Merge tag 'sound-4.18-rc3' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
> git bisect  bad ea5f39f2f994e6fb8cb8d0304aa5f422ae3bbf83  # 19:49  B      0     1   15   0  Merge branch 'akpm' (patches from Andrew)
> git bisect  bad 124049decbb121ec32742c94fb5d9d6bed8f24d8  # 20:03  B      6     1    0   0  x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
> git bisect good 28557cc106e6d2aa8b8c5c7687ea9f8055ff3911  # 20:33  G     74     0    1   1  Revert mm/vmstat.c: fix vmstat_update() preemption BUG
> git bisect  bad d50d82faa0c964e31f7a946ba8aba7c715ca7ab0  # 20:53  B     18     1    0   0  slub: fix failure when we delete and create a slab cache
> # first bad commit: [d50d82faa0c964e31f7a946ba8aba7c715ca7ab0] slub: fix failure when we delete and create a slab cache
> git bisect good 28557cc106e6d2aa8b8c5c7687ea9f8055ff3911  # 21:23  G    219     0    0   1  Revert mm/vmstat.c: fix vmstat_update() preemption BUG
> # extra tests with debug options
> git bisect  bad d50d82faa0c964e31f7a946ba8aba7c715ca7ab0  # 21:43  B      6     1    0   0  slub: fix failure when we delete and create a slab cache
> # extra tests on HEAD of linux-devel/devel-catchup-201810172056
> git bisect  bad f64798c97c207879a5b2b2cc901f4903cb2663fd  # 21:43  B     21     2    0   0  0day head guard for 'devel-catchup-201810172056'
> # extra tests on tree/branch linus/master
> git bisect  bad 84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d  # 21:52  B      2     1    0   0  Linux 4.19
> # extra tests with first bad commit reverted
> git bisect good 55027183adca08c0fc99c4d7bd3733af80f11b75  # 22:25  G     80     0    0   0  Revert "slub: fix failure when we delete and create a slab cache"
> # extra tests on tree/branch linux-next/master
> git bisect  bad 8c60c36d0b8c92599b8f0ec391b5250bc40e8e05  # 22:33  B      0     1   15   0  Add linux-next specific files for 20181019
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/lkp                          Intel Corporation
