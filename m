Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 16D056B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 20:29:52 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 17-v6so30479615pgs.18
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 17:29:52 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id e13-v6si34522663pge.0.2018.10.22.17.29.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 17:29:49 -0700 (PDT)
Date: Tue, 23 Oct 2018 08:30:04 +0800
From: kernel test robot <rong.a.chen@intel.com>
Subject: [LKP] d50d82faa0 [ 33.671845] WARNING: possible circular locking
 dependency detected
Message-ID: <20181023003004.GH24195@shao2-debian>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="a7XSrSxqzVsaECgU"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>


--a7XSrSxqzVsaECgU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit d50d82faa0c964e31f7a946ba8aba7c715ca7ab0
Author:     Mikulas Patocka <mpatocka@redhat.com>
AuthorDate: Wed Jun 27 23:26:09 2018 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Thu Jun 28 11:16:44 2018 -0700

    slub: fix failure when we delete and create a slab cache
    
    In kernel 4.17 I removed some code from dm-bufio that did slab cache
    merging (commit 21bb13276768: "dm bufio: remove code that merges slab
    caches") - both slab and slub support merging caches with identical
    attributes, so dm-bufio now just calls kmem_cache_create and relies on
    implicit merging.
    
    This uncovered a bug in the slub subsystem - if we delete a cache and
    immediatelly create another cache with the same attributes, it fails
    because of duplicate filename in /sys/kernel/slab/.  The slub subsystem
    offloads freeing the cache to a workqueue - and if we create the new
    cache before the workqueue runs, it complains because of duplicate
    filename in sysfs.
    
    This patch fixes the bug by moving the call of kobject_del from
    sysfs_slab_remove_workfn to shutdown_cache.  kobject_del must be called
    while we hold slab_mutex - so that the sysfs entry is deleted before a
    cache with the same attributes could be created.
    
    Running device-mapper-test-suite with:
    
      dmtest run --suite thin-provisioning -n /commit_failure_causes_fallback/
    
    triggered:
    
      Buffer I/O error on dev dm-0, logical block 1572848, async page read
      device-mapper: thin: 253:1: metadata operation 'dm_pool_alloc_data_block' failed: error = -5
      device-mapper: thin: 253:1: aborting current metadata transaction
      sysfs: cannot create duplicate filename '/kernel/slab/:a-0000144'
      CPU: 2 PID: 1037 Comm: kworker/u48:1 Not tainted 4.17.0.snitm+ #25
      Hardware name: Supermicro SYS-1029P-WTR/X11DDW-L, BIOS 2.0a 12/06/2017
      Workqueue: dm-thin do_worker [dm_thin_pool]
      Call Trace:
       dump_stack+0x5a/0x73
       sysfs_warn_dup+0x58/0x70
       sysfs_create_dir_ns+0x77/0x80
       kobject_add_internal+0xba/0x2e0
       kobject_init_and_add+0x70/0xb0
       sysfs_slab_add+0xb1/0x250
       __kmem_cache_create+0x116/0x150
       create_cache+0xd9/0x1f0
       kmem_cache_create_usercopy+0x1c1/0x250
       kmem_cache_create+0x18/0x20
       dm_bufio_client_create+0x1ae/0x410 [dm_bufio]
       dm_block_manager_create+0x5e/0x90 [dm_persistent_data]
       __create_persistent_data_objects+0x38/0x940 [dm_thin_pool]
       dm_pool_abort_metadata+0x64/0x90 [dm_thin_pool]
       metadata_operation_failed+0x59/0x100 [dm_thin_pool]
       alloc_data_block.isra.53+0x86/0x180 [dm_thin_pool]
       process_cell+0x2a3/0x550 [dm_thin_pool]
       do_worker+0x28d/0x8f0 [dm_thin_pool]
       process_one_work+0x171/0x370
       worker_thread+0x49/0x3f0
       kthread+0xf8/0x130
       ret_from_fork+0x35/0x40
      kobject_add_internal failed for :a-0000144 with -EEXIST, don't try to register things with the same name in the same directory.
      kmem_cache_create(dm_bufio_buffer-16) failed with error -17
    
    Link: http://lkml.kernel.org/r/alpine.LRH.2.02.1806151817130.6333@file01.intranet.prod.int.rdu2.redhat.com
    Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
    Reported-by: Mike Snitzer <snitzer@redhat.com>
    Tested-by: Mike Snitzer <snitzer@redhat.com>
    Cc: Christoph Lameter <cl@linux.com>
    Cc: Pekka Enberg <penberg@kernel.org>
    Cc: David Rientjes <rientjes@google.com>
    Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
    Cc: <stable@vger.kernel.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

28557cc106  Revert mm/vmstat.c: fix vmstat_update() preemption BUG
d50d82faa0  slub: fix failure when we delete and create a slab cache
84df9525b0  Linux 4.19
8c60c36d0b  Add linux-next specific files for 20181019
+-------------------------------------------------------+------------+------------+-------+---------------+
|                                                       | 28557cc106 | d50d82faa0 | v4.19 | next-20181019 |
+-------------------------------------------------------+------------+------------+-------+---------------+
| boot_successes                                        | 228        | 67         | 72    | 0             |
| boot_failures                                         | 1          | 13         | 8     | 1             |
| BUG:kernel_hang_in_test_stage                         | 1          |            |       |               |
| WARNING:possible_circular_locking_dependency_detected | 0          | 12         | 8     | 1             |
| INFO:rcu_preempt_detected_stalls_on_CPUs/tasks        | 0          | 1          |       |               |
+-------------------------------------------------------+------------+------------+-------+---------------+

[   29.227068] random: get_random_bytes called from key_alloc+0x2b0/0x44d with crng_init=1
[   32.046253] random: get_random_bytes called from __ip_select_ident+0x45/0x93 with crng_init=1
[   33.592007] random: get_random_bytes called from key_alloc+0x2b0/0x44d with crng_init=1
[   33.670288] 
[   33.670642] ======================================================
[   33.671845] WARNING: possible circular locking dependency detected
[   33.673016] 4.18.0-rc2-00135-gd50d82f #1 Tainted: G                T
[   33.674215] ------------------------------------------------------
[   33.675386] trinity-c3/689 is trying to acquire lock:
[   33.676347] (____ptrval____) (slab_mutex){+.+.}, at: slab_attr_store+0x5a/0xd1
[   33.677710] 
[   33.677710] but task is already holding lock:
[   33.678812] (____ptrval____) (kn->count#32){++++}, at: kernfs_fop_write+0xf3/0x1b0
[   33.680230] 
[   33.680230] which lock already depends on the new lock.
[   33.680230] 
[   33.681766] 
[   33.681766] the existing dependency chain (in reverse order) is:
[   33.683151] 
[   33.683151] -> #1 (kn->count#32){++++}:
[   33.684170]        kernfs_remove+0x1f/0x2c
[   33.684968]        sysfs_remove_dir+0x5b/0x62
[   33.685797]        kobject_del+0x20/0x4c
[   33.686543]        shutdown_cache+0x116/0x12c
[   33.687364]        kmem_cache_destroy+0x19c/0x1d1
[   33.688277]        ovs_flow_exit+0x11/0x1d
[   33.689048]        dp_init+0x2a5/0x2fc
[   33.689766]        do_one_initcall+0xc8/0x296
[   33.690592]        kernel_init_freeable+0x16c/0x2c4
[   33.691534]        kernel_init+0xb/0x13d
[   33.692279]        ret_from_fork+0x3a/0x50
[   33.693046] 
[   33.693046] -> #0 (slab_mutex){+.+.}:
[   33.694022]        __mutex_lock+0x6e/0x257
[   33.694826]        slab_attr_store+0x5a/0xd1
[   33.695634]        sysfs_kf_write+0x58/0x73
[   33.696430]        kernfs_fop_write+0x149/0x1b0
[   33.697288]        __vfs_write+0x46/0x8d
[   33.698056]        vfs_write+0xd5/0x10a
[   33.698786]        ksys_pwrite64+0x77/0xa0
[   33.699564]        do_syscall_64+0x107/0x11c
[   33.700373]        entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   33.701438] 
[   33.701438] other info that might help us debug this:
[   33.701438] 
[   33.702922]  Possible unsafe locking scenario:
[   33.702922] 
[   33.704028]        CPU0                    CPU1
[   33.704904]        ----                    ----
[   33.705755]   lock(kn->count#32);
[   33.706393]                                lock(slab_mutex);
[   33.707451]                                lock(kn->count#32);
[   33.708566]   lock(slab_mutex);
[   33.709165] 
[   33.709165]  *** DEADLOCK ***
[   33.709165] 
[   33.710276] 3 locks held by trinity-c3/689:
[   33.711072]  #0: (____ptrval____) (sb_writers#5){.+.+}, at: file_start_write+0x3b/0x41
[   33.712562]  #1: (____ptrval____) (&of->mutex){+.+.}, at: kernfs_fop_write+0xeb/0x1b0
[   33.714021]  #2: (____ptrval____) (kn->count#32){++++}, at: kernfs_fop_write+0xf3/0x1b0
[   33.715546] 
[   33.715546] stack backtrace:
[   33.716371] CPU: 0 PID: 689 Comm: trinity-c3 Tainted: G                T 4.18.0-rc2-00135-gd50d82f #1
[   33.718083] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[   33.719629] Call Trace:
[   33.720111]  print_circular_bug+0x1c6/0x1d3
[   33.721043]  __lock_acquire+0xbb0/0xe59
[   33.721790]  ? lock_acquire+0x53/0x6f
[   33.722490]  lock_acquire+0x53/0x6f
[   33.723150]  ? slab_attr_store+0x5a/0xd1
[   33.723897]  __mutex_lock+0x6e/0x257
[   33.724604]  ? slab_attr_store+0x5a/0xd1
[   33.725350]  ? slab_attr_store+0x5a/0xd1
[   33.726089]  ? lock_acquire+0x53/0x6f
[   33.726785]  ? lock_acquire+0x53/0x6f
[   33.727480]  ? kernfs_fop_write+0xeb/0x1b0
[   33.728290]  ? slab_attr_store+0x5a/0xd1
[   33.729028]  ? alloc_node_mismatch_store+0x16/0x1a
[   33.729927]  slab_attr_store+0x5a/0xd1
[   33.730639]  sysfs_kf_write+0x58/0x73
[   33.731361]  kernfs_fop_write+0x149/0x1b0
[   33.732110]  ? sysfs_file_ops+0x6c/0x6c
[   33.732841]  ? copy_overflow+0x22/0x22
[   33.733555]  __vfs_write+0x46/0x8d
[   33.734216]  vfs_write+0xd5/0x10a
[   33.734862]  ksys_pwrite64+0x77/0xa0
[   33.735544]  do_syscall_64+0x107/0x11c
[   33.736260]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   33.737204] RIP: 0033:0x457389
[   33.737797] Code: 00 f3 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 2b 84 00 00 c3 66 2e 0f 1f 84 00 00 00 00 
[   33.741375] RSP: 002b:00007ffe1c922d48 EFLAGS: 00000246 ORIG_RAX: 0000000000000012
[   33.742776] RAX: ffffffffffffffda RBX: 0000000000000012 RCX: 0000000000457389
[   33.744108] RDX: 00000000000001c1 RSI: 0000000001344710 RDI: 000000000000010a
[   33.745463] RBP: 00007ffe1c922df0 R08: 00000000f4c64000 R09: bbed0ee996d421b9
[   33.746783] R10: 0000000000000800 R11: 0000000000000246 R12: 0000000000000002
[   33.748124] R13: 00007fcb40b97058 R14: 000000000104a830 R15: 00007fcb40b97000
[   35.830419] raw_sendmsg: trinity-c3 forgot to set AF_INET. Fix it!
[   54.240043] random: get_random_bytes called from __prandom_timer+0x15/0x5a with crng_init=1
[   58.674359] random: get_random_bytes called from key_alloc+0x2b0/0x44d with crng_init=1

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start v4.18 v4.17 --
git bisect good c81b995f00c7a1c2ca9ad67f5bb4a50d02f98f84  # 18:03  G     74     0    0   0  Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect  bad 47f7dc4b845a9fe60c53b84b8c88cf14efd0de7f  # 18:13  B     18     3    0   0  Merge tag 'for-linus' of git://git.kernel.org/pub/scm/virt/kvm/kvm
git bisect  bad 0fa3ecd87848c9c93c2c828ef4c3a8ca36ce46c7  # 18:35  B      7     1    0   0  Fix up non-directory creation in SGID directories
git bisect  bad 1904148a361a07fb2d7cba1261d1d2c2f33c8d2e  # 18:52  B      6     1    0   0  Merge tag 'powerpc-4.18-3' of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux
git bisect good a11e1d432b51f63ba698d044441284a661f01144  # 19:19  G     73     0    2   2  Revert changes to convert to ->poll_mask() and aio IOCB_CMD_POLL
git bisect  bad ff23908bb78bbc0999ff35e6f319f1648c4ded93  # 19:31  B      0     1   15   0  Merge tag 'for-4.18/dm-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/device-mapper/linux-dm
git bisect  bad e26aac3caeadc476b96a1f384715e96b4a607342  # 19:40  B      2     1    0   0  Merge tag 'sound-4.18-rc3' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect  bad ea5f39f2f994e6fb8cb8d0304aa5f422ae3bbf83  # 19:49  B      0     1   15   0  Merge branch 'akpm' (patches from Andrew)
git bisect  bad 124049decbb121ec32742c94fb5d9d6bed8f24d8  # 20:03  B      6     1    0   0  x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
git bisect good 28557cc106e6d2aa8b8c5c7687ea9f8055ff3911  # 20:33  G     74     0    1   1  Revert mm/vmstat.c: fix vmstat_update() preemption BUG
git bisect  bad d50d82faa0c964e31f7a946ba8aba7c715ca7ab0  # 20:53  B     18     1    0   0  slub: fix failure when we delete and create a slab cache
# first bad commit: [d50d82faa0c964e31f7a946ba8aba7c715ca7ab0] slub: fix failure when we delete and create a slab cache
git bisect good 28557cc106e6d2aa8b8c5c7687ea9f8055ff3911  # 21:23  G    219     0    0   1  Revert mm/vmstat.c: fix vmstat_update() preemption BUG
# extra tests with debug options
git bisect  bad d50d82faa0c964e31f7a946ba8aba7c715ca7ab0  # 21:43  B      6     1    0   0  slub: fix failure when we delete and create a slab cache
# extra tests on HEAD of linux-devel/devel-catchup-201810172056
git bisect  bad f64798c97c207879a5b2b2cc901f4903cb2663fd  # 21:43  B     21     2    0   0  0day head guard for 'devel-catchup-201810172056'
# extra tests on tree/branch linus/master
git bisect  bad 84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d  # 21:52  B      2     1    0   0  Linux 4.19
# extra tests with first bad commit reverted
git bisect good 55027183adca08c0fc99c4d7bd3733af80f11b75  # 22:25  G     80     0    0   0  Revert "slub: fix failure when we delete and create a slab cache"
# extra tests on tree/branch linux-next/master
git bisect  bad 8c60c36d0b8c92599b8f0ec391b5250bc40e8e05  # 22:33  B      0     1   15   0  Add linux-next specific files for 20181019

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--a7XSrSxqzVsaECgU
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-kbuild-52:20181022205317:x86_64-randconfig-a0-10172002:4.18.0-rc2-00135-gd50d82f:1.gz"
Content-Transfer-Encoding: base64

H4sICLHfzVsAA2RtZXNnLXlvY3RvLWtidWlsZC01MjoyMDE4MTAyMjIwNTMxNzp4ODZfNjQt
cmFuZGNvbmZpZy1hMC0xMDE3MjAwMjo0LjE4LjAtcmMyLTAwMTM1LWdkNTBkODJmOjEA7Fxt
c9rIsv588yv61n6IfdYCvSNRxamLbZxQNjZrnGzOSaUoIY1AayGxevHLVn787R4JAxLCyCH7
aUnFIGn6mWd6pnt6Ri0xK/KfwQ6DOPQZeAHELEkXeMJh71jxGntKIstOxvcsCpj/zgsWaTJ2
rMRqg/gkLj/KpKXItpFf9lmwcVU0mWSq8rswTfDyxiUp+8ovlSRl0TVd03iX1T5OwsTyx7H3
F9usXWsZBIJM54vQ9wI2VuSJt1kTsnCo0LtzZofzRcTi2AumcOUF6VOj0YChFfETvasLOnTC
gDXenYZhQieTGYOMQ+PdV8CP2Mgwv2UA8MBQOgxAbUhGQxQiWxawcYomTB1NdAzZhaP7Ser5
zv/59wshYE+ifgxHU9t+kWw1lIYIR+ds4ln5kSAdH8MvEgxve73B8A4GWOzGTkCWQRbbqtQW
NTgb3eGBZBRpnYXzuRU4QNpoQ4Tt6DQd9tBEFYkwS4PpOLHi+/HCCjy7I4HDJukUrAUeZD/j
5zj6c2z5j9ZzPGaBNfGZA5GdLrDvWQN/jO1FOo6xP7BbvDnDDuxgZ0LAkobnBtacxR0RFpEX
JPcNrPh+Hk87yD+rUJAgDt3ED+37dPFCIph740crsWdOOO3wkxCGizj/6YeWM0b6jhffd2SE
xl5MXk6I4EQTpzH3gjAa22EaJB2DGpGwudPwwykOrQfmd1gUgTfFMmyMJ/m55WjvJMmzCNwA
Mtp0YiSeSJImY8PWSq1OPkytDoLNLR+iR9L1fadps8XMjZtZdzejNBD+TFnKms+hnYRCfvrJ
0Me6KkTYRQjselPBwu4WpRaiyk2fxpTgELs2/yvYpJZ0IVBXZ8U0vZ0PLcsSbVNXmSK5LctU
9YllWBOrZbckzbZa1kRsT7yY2YmQwUpGs/Ewp99/Cfsi5PXKsiyqLdUUcOytN0fQZJhgW+xZ
Z416s5o6nN7c3I37g+6HXqe5uJ9mLX5FK2gtQqu5L+Xmso3VJrllxNAIZ5HbiGdp4oSPQUcs
GtZl7/a6dwVxuliEUYJGgXYQt4ulALqDc+im6DiCxLPxoGSgw09tNP7Awdo9B95/YEGKttoP
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
wvwbsa7RUf3yAAA=

--a7XSrSxqzVsaECgU
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-kbuild-15:20181022202354:x86_64-randconfig-a0-10172002:4.18.0-rc2-00134-g28557cc:1.gz"
Content-Transfer-Encoding: base64

H4sICK/fzVsAA2RtZXNnLXlvY3RvLWtidWlsZC0xNToyMDE4MTAyMjIwMjM1NDp4ODZfNjQt
cmFuZGNvbmZpZy1hMC0xMDE3MjAwMjo0LjE4LjAtcmMyLTAwMTM0LWcyODU1N2NjOjEA7Fzr
c9rIsv9881f0rf0Q+6wFGr0QVHHqYhsnlI3NGiebc1IpSkgj0BokVg8/tvLH3+6RMCAhjByy
n1Yuo9f0r3t6pnt6Ri1xK5w9gx34UTDj4PkQ8ThZ4AWHv+P5e/wpDi07Ht3z0Oezd56/SOKR
Y8VWC+Qnebmp44am2GZ2e8b9jbtykzNm6++CJMbbG7dYustuFSgV2W26lvwu5T6Kg9iajSLv
L77JXW+YBIKSzhfBzPP5SFXG3iYnlMKhQu/OuR3MFyGPIs+fwJXnJ0+1Wg0GVigudK8u6NQJ
fF57dxoEMV2MpxxSGWrvvgJuci3F/JYCwANH6sAHrcbMmiyFtiJh5VRNmiimrjdsG47ux4k3
c/4vClwpPZTZMRxN8NaSuFFTazIcnfOxZ2VnEjs+hl8YDG673f7gDvpY7MaOQVFAkVuy2ZJl
OBve4Qkz85KdBfO55TtACmlBiFVp1x3+UEctyTBN/MkotqL70cLyPbvNwOHjZALWAk/Sw+g5
Cv8cWbNH6zkacd8az7gDoZ0ssPl5DQ9G9iIZRdgk2DLenGMbtrE9wedxzXN9a86jtgyL0PPj
+xoyvp9HkzbKnzKUGKAq4llg3yeLFyH8uTd6tGJ76gSTtrgIQbCIssNZYDkjFN/xovu2gtDY
kPHLBRmccOzU5p4fhCM7SPy4bVIlYj53arNggr3rgc/aPAzBm2AZPsKL4tqyw7fj+FkGYQOp
2HRhKJ8wpitYsbVSq4sPE6uNYHNrBuEj6fq+Xbf5YupG9bSZ62HiS38mPOH158COg6z160+m
MTI0KcQmQmDXm0gWNrfMGoiq1GfUrSSHpGuJX8kmtSQLiZo6LaYbrax3MdnghqNYljk2bd1u
GGaDW03XlHXdddUmY62xF3E7llJYZtZrD3M6/kvaFyHjqyi4x19J1Vrr1ZGYDmOsiz1tr4le
LxcdTm9u7ka9fudDt11f3E/SGr+iFbQWqVHfV+T6so7lVrmlx1AP56Fbi6ZJ7ASPflvOG9Zl
9/a6ewVRslgEYYxGgXYQtfKlADr9c+gk6Dv82LPxpGCgg08tNH7fQe6eA+8/cD9BW+35MZ+9
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
/B8F7MQuefMBAA==

--a7XSrSxqzVsaECgU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-yocto-kbuild-52:20181022205317:x86_64-randconfig-a0-10172002:4.18.0-rc2-00135-gd50d82f:1"

#!/bin/bash

kernel=$1
initrd=yocto-trinity-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/yocto/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 1
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"

--a7XSrSxqzVsaECgU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.18.0-rc2-00135-gd50d82f"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.18.0-rc2 Kernel Configuration
#

#
# Compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_FILTER_PGPROT=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DYNAMIC_PHYSICAL_MASK=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=70300
CONFIG_CLANG_VERSION=0
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
# CONFIG_USELIB is not set
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_DEBUGFS=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_CONTEXT_TRACKING=y
CONFIG_CONTEXT_TRACKING_FORCE=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
# CONFIG_CGROUP_PIDS is not set
CONFIG_CGROUP_RDMA=y
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_BPF=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
# CONFIG_SYSFS_SYSCALL is not set
CONFIG_SYSCTL_SYSCALL=y
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_MEMBARRIER is not set
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
# CONFIG_USERFAULTFD is not set
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
# CONFIG_RSEQ is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
CONFIG_PC104=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_SLUB_DEBUG is not set
CONFIG_SLUB_MEMCG_SYSFS_ON=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_SLAB_MERGE_DEFAULT is not set
# CONFIG_SLAB_FREELIST_RANDOM is not set
CONFIG_SLAB_FREELIST_HARDENED=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_RSEQ=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_PLUGIN_HOSTCC="g++"
CONFIG_HAVE_GCC_PLUGINS=y
CONFIG_GCC_PLUGINS=y
# CONFIG_GCC_PLUGIN_CYC_COMPLEXITY is not set
CONFIG_GCC_PLUGIN_LATENT_ENTROPY=y
# CONFIG_GCC_PLUGIN_STRUCTLEAK is not set
CONFIG_GCC_PLUGIN_RANDSTRUCT=y
# CONFIG_GCC_PLUGIN_RANDSTRUCT_PERFORMANCE is not set
CONFIG_HAVE_STACKPROTECTOR=y
CONFIG_CC_HAS_STACKPROTECTOR_NONE=y
# CONFIG_STACKPROTECTOR is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_ISA_BUS_API=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
CONFIG_REFCOUNT_FULL=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_X2APIC is not set
# CONFIG_X86_MPPARSE is not set
CONFIG_GOLDFISH=y
CONFIG_RETPOLINE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
# CONFIG_IOSF_MBI is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
CONFIG_CPU_SUP_AMD=y
# CONFIG_CPU_SUP_CENTAUR is not set
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_NR_CPUS_RANGE_BEGIN=1
CONFIG_NR_CPUS_RANGE_END=1
CONFIG_NR_CPUS_DEFAULT=1
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCELOG_LEGACY=y
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_AMD_POWER=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_X86_5LEVEL is not set
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_AMD_MEM_ENCRYPT=y
CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y
CONFIG_ARCH_USE_MEMREMAP_PROT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_MEMORY_BALLOON=y
# CONFIG_BALLOON_COMPACTION is not set
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
CONFIG_MEM_SOFT_DIRTY=y
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=y
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
# CONFIG_PERCPU_STATS is not set
# CONFIG_GUP_BENCHMARK is not set
CONFIG_ARCH_HAS_PTE_SPECIAL=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
# CONFIG_X86_PAT is not set
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_KEXEC_FILE is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
# CONFIG_MODIFY_LDT_SYSCALL is not set
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_PM is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=y
CONFIG_ACPI_LPIT=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# CPU frequency scaling drivers
#
# CONFIG_CPUFREQ_DT is not set
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_MMCONF_FAM10H=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
CONFIG_PCI_LOCKLESS_CONFIG=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#
# CONFIG_PCIE_CADENCE_HOST is not set
# CONFIG_PCI_FTPCI100 is not set
# CONFIG_PCI_HOST_GENERIC is not set

#
# DesignWare PCI Core Support
#

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
CONFIG_ISA_BUS=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
# CONFIG_X86_X32 is not set
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_NET_INGRESS=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_TLS=y
CONFIG_TLS_DEVICE=y
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
CONFIG_XDP_SOCKETS=y
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IP_TUNNEL=y
CONFIG_NET_IPGRE=y
CONFIG_SYN_COOKIES=y
CONFIG_NET_IPVTI=y
CONFIG_NET_UDP_TUNNEL=y
CONFIG_NET_FOU=y
# CONFIG_NET_FOU_IP_TUNNELS is not set
CONFIG_INET_AH=y
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=y
# CONFIG_INET_RAW_DIAG is not set
CONFIG_INET_DIAG_DESTROY=y
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
# CONFIG_TCP_CONG_CUBIC is not set
# CONFIG_TCP_CONG_WESTWOOD is not set
CONFIG_TCP_CONG_HTCP=y
# CONFIG_TCP_CONG_HSTCP is not set
# CONFIG_TCP_CONG_HYBLA is not set
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_NV=y
CONFIG_TCP_CONG_SCALABLE=y
CONFIG_TCP_CONG_LP=y
CONFIG_TCP_CONG_VENO=y
# CONFIG_TCP_CONG_YEAH is not set
CONFIG_TCP_CONG_ILLINOIS=y
# CONFIG_TCP_CONG_DCTCP is not set
CONFIG_TCP_CONG_CDG=y
CONFIG_TCP_CONG_BBR=y
# CONFIG_DEFAULT_BIC is not set
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_VENO is not set
CONFIG_DEFAULT_CDG=y
# CONFIG_DEFAULT_BBR is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cdg"
CONFIG_TCP_MD5SIG=y
# CONFIG_IPV6 is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_FAMILY_ARP=y
CONFIG_NETFILTER_NETLINK_ACCT=y
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_LOG_COMMON=y
# CONFIG_NF_LOG_NETDEV is not set
CONFIG_NETFILTER_CONNCOUNT=y
CONFIG_NF_CONNTRACK_MARK=y
# CONFIG_NF_CONNTRACK_ZONES is not set
# CONFIG_NF_CONNTRACK_PROCFS is not set
CONFIG_NF_CONNTRACK_EVENTS=y
CONFIG_NF_CONNTRACK_TIMEOUT=y
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CONNTRACK_LABELS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
# CONFIG_NF_CT_PROTO_UDPLITE is not set
CONFIG_NF_CONNTRACK_AMANDA=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
# CONFIG_NF_CONNTRACK_IRC is not set
CONFIG_NF_CONNTRACK_BROADCAST=y
# CONFIG_NF_CONNTRACK_NETBIOS_NS is not set
CONFIG_NF_CONNTRACK_SNMP=y
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
# CONFIG_NF_CONNTRACK_TFTP is not set
CONFIG_NF_CT_NETLINK=y
CONFIG_NF_CT_NETLINK_TIMEOUT=y
CONFIG_NF_CT_NETLINK_HELPER=y
CONFIG_NETFILTER_NETLINK_GLUE_CT=y
CONFIG_NETFILTER_SYNPROXY=y
# CONFIG_NF_TABLES is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=y
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
# CONFIG_NETFILTER_XT_TARGET_CLASSIFY is not set
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
CONFIG_NETFILTER_XT_TARGET_HMARK=y
# CONFIG_NETFILTER_XT_TARGET_IDLETIMER is not set
CONFIG_NETFILTER_XT_TARGET_LED=y
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TPROXY=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_BPF=y
CONFIG_NETFILTER_XT_MATCH_CGROUP=y
# CONFIG_NETFILTER_XT_MATCH_CLUSTER is not set
# CONFIG_NETFILTER_XT_MATCH_COMMENT is not set
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNLABEL=y
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
CONFIG_NETFILTER_XT_MATCH_ECN=y
# CONFIG_NETFILTER_XT_MATCH_ESP is not set
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
# CONFIG_NETFILTER_XT_MATCH_HELPER is not set
CONFIG_NETFILTER_XT_MATCH_HL=y
# CONFIG_NETFILTER_XT_MATCH_IPCOMP is not set
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_IPVS=y
# CONFIG_NETFILTER_XT_MATCH_L2TP is not set
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
CONFIG_NETFILTER_XT_MATCH_NFACCT=y
# CONFIG_NETFILTER_XT_MATCH_OSF is not set
CONFIG_NETFILTER_XT_MATCH_OWNER=y
# CONFIG_NETFILTER_XT_MATCH_POLICY is not set
# CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
# CONFIG_NETFILTER_XT_MATCH_STRING is not set
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
# CONFIG_IP_SET is not set
CONFIG_IP_VS=y
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
# CONFIG_IP_VS_PROTO_TCP is not set
# CONFIG_IP_VS_PROTO_UDP is not set
CONFIG_IP_VS_PROTO_AH_ESP=y
# CONFIG_IP_VS_PROTO_ESP is not set
CONFIG_IP_VS_PROTO_AH=y
# CONFIG_IP_VS_PROTO_SCTP is not set

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
# CONFIG_IP_VS_WRR is not set
CONFIG_IP_VS_LC=y
CONFIG_IP_VS_WLC=y
# CONFIG_IP_VS_FO is not set
# CONFIG_IP_VS_OVF is not set
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
# CONFIG_IP_VS_DH is not set
# CONFIG_IP_VS_SH is not set
CONFIG_IP_VS_MH=y
CONFIG_IP_VS_SED=y
CONFIG_IP_VS_NQ=y

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS MH scheduler
#
CONFIG_IP_VS_MH_TAB_INDEX=12

#
# IPVS application helper
#
CONFIG_IP_VS_NFCT=y

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
# CONFIG_NF_CONNTRACK_IPV4 is not set
CONFIG_NF_SOCKET_IPV4=y
CONFIG_NF_TPROXY_IPV4=y
CONFIG_NF_DUP_IPV4=y
# CONFIG_NF_LOG_ARP is not set
CONFIG_NF_LOG_IPV4=y
CONFIG_NF_REJECT_IPV4=y
CONFIG_IP_NF_IPTABLES=y
# CONFIG_IP_NF_MATCH_AH is not set
CONFIG_IP_NF_MATCH_ECN=y
# CONFIG_IP_NF_MATCH_RPFILTER is not set
CONFIG_IP_NF_MATCH_TTL=y
# CONFIG_IP_NF_FILTER is not set
CONFIG_IP_NF_TARGET_SYNPROXY=y
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_IP_NF_RAW=y
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y

#
# DECnet: Netfilter Configuration
#
# CONFIG_DECNET_NF_GRABULATOR is not set
# CONFIG_BPFILTER is not set
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
# CONFIG_IP_DCCP_CCID3 is not set

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=y
CONFIG_SCTP_DBG_OBJCNT=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
# CONFIG_SCTP_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
CONFIG_INET_SCTP_DIAG=y
# CONFIG_RDS is not set
CONFIG_TIPC=y
CONFIG_TIPC_MEDIA_UDP=y
CONFIG_TIPC_DIAG=y
CONFIG_ATM=y
CONFIG_ATM_CLIP=y
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=y
# CONFIG_ATM_MPOA is not set
CONFIG_ATM_BR2684=y
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=y
# CONFIG_L2TP_DEBUGFS is not set
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=y
CONFIG_L2TP_ETH=y
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=y
# CONFIG_IPDDP_ENCAP is not set
CONFIG_X25=y
# CONFIG_LAPB is not set
CONFIG_PHONET=y
CONFIG_IEEE802154=y
CONFIG_IEEE802154_NL802154_EXPERIMENTAL=y
CONFIG_IEEE802154_SOCKET=y
CONFIG_MAC802154=y
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
# CONFIG_NET_SCH_CBQ is not set
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
# CONFIG_NET_SCH_ATM is not set
CONFIG_NET_SCH_PRIO=y
# CONFIG_NET_SCH_MULTIQ is not set
# CONFIG_NET_SCH_RED is not set
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=y
# CONFIG_NET_SCH_TEQL is not set
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_CBS=y
# CONFIG_NET_SCH_GRED is not set
CONFIG_NET_SCH_DSMARK=y
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_MQPRIO=y
# CONFIG_NET_SCH_CHOKE is not set
# CONFIG_NET_SCH_QFQ is not set
# CONFIG_NET_SCH_CODEL is not set
# CONFIG_NET_SCH_FQ_CODEL is not set
CONFIG_NET_SCH_FQ=y
CONFIG_NET_SCH_HHF=y
CONFIG_NET_SCH_PIE=y
CONFIG_NET_SCH_PLUG=y
# CONFIG_NET_SCH_DEFAULT is not set

#
# Classification
#
CONFIG_NET_CLS=y
# CONFIG_NET_CLS_BASIC is not set
CONFIG_NET_CLS_TCINDEX=y
# CONFIG_NET_CLS_ROUTE4 is not set
# CONFIG_NET_CLS_FW is not set
CONFIG_NET_CLS_U32=y
# CONFIG_CLS_U32_PERF is not set
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
# CONFIG_NET_CLS_RSVP6 is not set
# CONFIG_NET_CLS_FLOW is not set
# CONFIG_NET_CLS_CGROUP is not set
CONFIG_NET_CLS_BPF=y
# CONFIG_NET_CLS_FLOWER is not set
# CONFIG_NET_CLS_MATCHALL is not set
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=y
CONFIG_NET_EMATCH_NBYTE=y
CONFIG_NET_EMATCH_U32=y
# CONFIG_NET_EMATCH_META is not set
CONFIG_NET_EMATCH_TEXT=y
CONFIG_NET_EMATCH_CANID=y
CONFIG_NET_EMATCH_IPT=y
# CONFIG_NET_CLS_ACT is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=y
# CONFIG_OPENVSWITCH_GRE is not set
CONFIG_VSOCKETS=y
CONFIG_VSOCKETS_DIAG=y
# CONFIG_VIRTIO_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=y
CONFIG_MPLS_ROUTING=y
# CONFIG_MPLS_IPTUNNEL is not set
CONFIG_NET_NSH=y
CONFIG_HSR=y
# CONFIG_NET_SWITCHDEV is not set
CONFIG_NET_L3_MASTER_DEV=y
# CONFIG_NET_NCSI is not set
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_STREAM_PARSER is not set

#
# Network testing
#
CONFIG_NET_PKTGEN=y
# CONFIG_HAMRADIO is not set
CONFIG_CAN=y
# CONFIG_CAN_RAW is not set
# CONFIG_CAN_BCM is not set
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_VXCAN=y
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_CAN_LEDS is not set
CONFIG_CAN_GRCAN=y
# CONFIG_CAN_C_CAN is not set
CONFIG_CAN_CC770=y
# CONFIG_CAN_CC770_ISA is not set
# CONFIG_CAN_CC770_PLATFORM is not set
# CONFIG_CAN_IFI_CANFD is not set
CONFIG_CAN_M_CAN=y
# CONFIG_CAN_PEAK_PCIEFD is not set
CONFIG_CAN_SJA1000=y
CONFIG_CAN_SJA1000_ISA=y
# CONFIG_CAN_SJA1000_PLATFORM is not set
# CONFIG_CAN_EMS_PCI is not set
# CONFIG_CAN_PEAK_PCI is not set
# CONFIG_CAN_KVASER_PCI is not set
# CONFIG_CAN_PLX_PCI is not set
CONFIG_CAN_SOFTING=y

#
# CAN SPI interfaces
#
CONFIG_CAN_HI311X=y
CONFIG_CAN_MCP251X=y

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=y
CONFIG_CAN_ESD_USB2=y
# CONFIG_CAN_GS_USB is not set
CONFIG_CAN_KVASER_USB=y
CONFIG_CAN_PEAK_USB=y
# CONFIG_CAN_8DEV_USB is not set
CONFIG_CAN_MCBA_USB=y
# CONFIG_CAN_DEBUG_DEVICES is not set
# CONFIG_BT is not set
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_INJECT_LOSS=y
# CONFIG_AF_RXRPC_DEBUG is not set
# CONFIG_RXKAD is not set
CONFIG_AF_KCM=y
CONFIG_STREAM_PARSER=y
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
# CONFIG_RFKILL_INPUT is not set
CONFIG_RFKILL_GPIO=y
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
# CONFIG_CEPH_LIB is not set
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
CONFIG_NFC_NCI=y
CONFIG_NFC_NCI_SPI=y
# CONFIG_NFC_NCI_UART is not set
CONFIG_NFC_HCI=y
CONFIG_NFC_SHDLC=y

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_TRF7970A=y
# CONFIG_NFC_SIM is not set
CONFIG_NFC_PORT100=y
CONFIG_NFC_FDP=y
CONFIG_NFC_FDP_I2C=y
# CONFIG_NFC_PN544_I2C is not set
# CONFIG_NFC_PN533_USB is not set
# CONFIG_NFC_PN533_I2C is not set
CONFIG_NFC_MICROREAD=y
CONFIG_NFC_MICROREAD_I2C=y
# CONFIG_NFC_MRVL_USB is not set
CONFIG_NFC_ST21NFCA=y
CONFIG_NFC_ST21NFCA_I2C=y
CONFIG_NFC_ST_NCI=y
CONFIG_NFC_ST_NCI_I2C=y
CONFIG_NFC_ST_NCI_SPI=y
CONFIG_NFC_NXP_NCI=y
CONFIG_NFC_NXP_NCI_I2C=y
# CONFIG_NFC_S3FWRN5_I2C is not set
CONFIG_NFC_ST95HF=y
CONFIG_PSAMPLE=y
# CONFIG_NET_IFE is not set
CONFIG_LWTUNNEL=y
CONFIG_LWTUNNEL_BPF=y
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_SOCK_VALIDATE_XMIT=y
CONFIG_NET_DEVLINK=y
CONFIG_MAY_USE_DEVLINK=y
CONFIG_FAILOVER=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y

#
# Firmware loader
#
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_WANT_DEV_COREDUMP=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_W1=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
CONFIG_DTC=y
CONFIG_OF=y
# CONFIG_OF_UNITTEST is not set
CONFIG_OF_FLATTREE=y
CONFIG_OF_KOBJ=y
CONFIG_OF_DYNAMIC=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_RESOLVE=y
CONFIG_OF_OVERLAY=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# NVME Support
#

#
# Misc devices
#
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
CONFIG_SRAM=y
# CONFIG_PCI_ENDPOINT_TEST is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
CONFIG_EEPROM_93XX46=y
CONFIG_EEPROM_IDT_89HPESX=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# CONFIG_GENWQE is not set
CONFIG_ECHO=y
# CONFIG_MISC_RTSX_PCI is not set
# CONFIG_MISC_RTSX_USB is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
# CONFIG_FIREWIRE_OHCI is not set
# CONFIG_FIREWIRE_NET is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_IPVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_GENEVE is not set
# CONFIG_GTP is not set
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_TUN is not set
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
# CONFIG_VIRTIO_NET is not set
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set
CONFIG_ATM_DRIVERS=y
# CONFIG_ATM_DUMMY is not set
# CONFIG_ATM_TCP is not set
# CONFIG_ATM_LANAI is not set
# CONFIG_ATM_ENI is not set
# CONFIG_ATM_FIRESTREAM is not set
# CONFIG_ATM_ZATM is not set
# CONFIG_ATM_NICSTAR is not set
# CONFIG_ATM_IDT77252 is not set
# CONFIG_ATM_AMBASSADOR is not set
# CONFIG_ATM_HORIZON is not set
# CONFIG_ATM_IA is not set
# CONFIG_ATM_FORE200E is not set
# CONFIG_ATM_HE is not set
# CONFIG_ATM_SOLOS is not set

#
# CAIF transport drivers
#
# CONFIG_CAIF_TTY is not set
# CONFIG_CAIF_SPI_SLAVE is not set
# CONFIG_CAIF_HSI is not set
# CONFIG_CAIF_VIRTIO is not set

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_AMD_XGBE is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_VENDOR_AURORA=y
# CONFIG_AURORA_NB8800 is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BCMGENET is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
CONFIG_CAVIUM_PTP=y
# CONFIG_LIQUIDIO is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_GEMINI_ETHERNET is not set
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_EZCHIP_NPS_MANAGEMENT_ENET is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_HUAWEI=y
CONFIG_NET_VENDOR_I825XX=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MICROSEMI=y
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETRONOME=y
CONFIG_NET_VENDOR_NI=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_NE2K_PCI is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCA7000_SPI is not set
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_SOCIONEXT=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_ALE is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_MDIO_DEVICE is not set
# CONFIG_PHYLIB is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
CONFIG_USB_NET_DRIVERS=y
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_RTL8152 is not set
# CONFIG_USB_LAN78XX is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_HSO is not set
# CONFIG_USB_IPHETH is not set
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_WLAN_VENDOR_CISCO=y
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_WLAN_VENDOR_MEDIATEK=y
CONFIG_WLAN_VENDOR_RALINK=y
CONFIG_WLAN_VENDOR_REALTEK=y
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_WLAN_VENDOR_ST=y
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_WLAN_VENDOR_QUANTENNA=y

#
# WiMAX Wireless Broadband devices
#
# CONFIG_WIMAX_I2400M_USB is not set
# CONFIG_WAN is not set
CONFIG_IEEE802154_DRIVERS=y
# CONFIG_IEEE802154_FAKELB is not set
# CONFIG_IEEE802154_AT86RF230 is not set
# CONFIG_IEEE802154_MRF24J40 is not set
# CONFIG_IEEE802154_CC2520 is not set
# CONFIG_IEEE802154_ATUSB is not set
# CONFIG_IEEE802154_ADF7242 is not set
# CONFIG_IEEE802154_CA8210 is not set
# CONFIG_IEEE802154_MCR20A is not set
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_NETDEVSIM is not set
# CONFIG_NET_FAILOVER is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADC=y
CONFIG_KEYBOARD_ADP5588=y
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_DLINK_DIR685=y
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_GPIO=y
# CONFIG_KEYBOARD_GPIO_POLLED is not set
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=y
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_OMAP4=y
# CONFIG_KEYBOARD_TC3589X is not set
CONFIG_KEYBOARD_TM2_TOUCHKEY=y
# CONFIG_KEYBOARD_TWL4030 is not set
CONFIG_KEYBOARD_XTKBD=y
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
CONFIG_TOUCHSCREEN_88PM860X=y
# CONFIG_TOUCHSCREEN_ADS7846 is not set
CONFIG_TOUCHSCREEN_AD7877=y
CONFIG_TOUCHSCREEN_AD7879=y
CONFIG_TOUCHSCREEN_AD7879_I2C=y
# CONFIG_TOUCHSCREEN_AD7879_SPI is not set
CONFIG_TOUCHSCREEN_AR1021_I2C=y
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
CONFIG_TOUCHSCREEN_AUO_PIXCIR=y
CONFIG_TOUCHSCREEN_BU21013=y
# CONFIG_TOUCHSCREEN_CHIPONE_ICN8318 is not set
# CONFIG_TOUCHSCREEN_CHIPONE_ICN8505 is not set
CONFIG_TOUCHSCREEN_CY8CTMG110=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP_I2C=y
CONFIG_TOUCHSCREEN_CYTTSP_SPI=y
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP4_I2C=y
CONFIG_TOUCHSCREEN_CYTTSP4_SPI=y
CONFIG_TOUCHSCREEN_DA9052=y
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
# CONFIG_TOUCHSCREEN_EGALAX is not set
CONFIG_TOUCHSCREEN_EGALAX_SERIAL=y
# CONFIG_TOUCHSCREEN_EXC3000 is not set
CONFIG_TOUCHSCREEN_FUJITSU=y
CONFIG_TOUCHSCREEN_GOODIX=y
CONFIG_TOUCHSCREEN_HIDEEP=y
CONFIG_TOUCHSCREEN_ILI210X=y
CONFIG_TOUCHSCREEN_S6SY761=y
CONFIG_TOUCHSCREEN_GUNZE=y
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
CONFIG_TOUCHSCREEN_ELAN=y
CONFIG_TOUCHSCREEN_ELO=y
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=y
CONFIG_TOUCHSCREEN_MAX11801=y
# CONFIG_TOUCHSCREEN_MCS5000 is not set
CONFIG_TOUCHSCREEN_MMS114=y
CONFIG_TOUCHSCREEN_MELFAS_MIP4=y
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_IMX6UL_TSC=y
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WDT87XX_I2C=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC200X_CORE=y
# CONFIG_TOUCHSCREEN_TSC2004 is not set
CONFIG_TOUCHSCREEN_TSC2005=y
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_TSC2007_IIO is not set
CONFIG_TOUCHSCREEN_PCAP=y
CONFIG_TOUCHSCREEN_RM_TS=y
CONFIG_TOUCHSCREEN_SILEAD=y
CONFIG_TOUCHSCREEN_SIS_I2C=y
CONFIG_TOUCHSCREEN_ST1232=y
CONFIG_TOUCHSCREEN_STMFTS=y
CONFIG_TOUCHSCREEN_SURFACE3_SPI=y
CONFIG_TOUCHSCREEN_SX8654=y
CONFIG_TOUCHSCREEN_TPS6507X=y
# CONFIG_TOUCHSCREEN_ZET6223 is not set
CONFIG_TOUCHSCREEN_ZFORCE=y
# CONFIG_TOUCHSCREEN_COLIBRI_VF50 is not set
CONFIG_TOUCHSCREEN_ROHM_BU21023=y
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM860X_ONKEY=y
CONFIG_INPUT_AD714X=y
CONFIG_INPUT_AD714X_I2C=y
CONFIG_INPUT_AD714X_SPI=y
# CONFIG_INPUT_ATMEL_CAPTOUCH is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_MAX8997_HAPTIC=y
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_APANEL=y
CONFIG_INPUT_GP2A=y
# CONFIG_INPUT_GPIO_BEEPER is not set
CONFIG_INPUT_GPIO_DECODER=y
# CONFIG_INPUT_ATLAS_BTNS is not set
CONFIG_INPUT_ATI_REMOTE2=y
CONFIG_INPUT_KEYSPAN_REMOTE=y
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
CONFIG_INPUT_YEALINK=y
CONFIG_INPUT_CM109=y
CONFIG_INPUT_REGULATOR_HAPTIC=y
CONFIG_INPUT_RETU_PWRBUTTON=y
# CONFIG_INPUT_TPS65218_PWRBUTTON is not set
# CONFIG_INPUT_AXP20X_PEK is not set
CONFIG_INPUT_TWL4030_PWRBUTTON=y
# CONFIG_INPUT_TWL4030_VIBRA is not set
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PALMAS_PWRBUTTON=y
CONFIG_INPUT_PCF8574=y
CONFIG_INPUT_PWM_BEEPER=y
CONFIG_INPUT_PWM_VIBRA=y
CONFIG_INPUT_RK805_PWRKEY=y
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
# CONFIG_INPUT_DA9052_ONKEY is not set
CONFIG_INPUT_DA9055_ONKEY=y
CONFIG_INPUT_DA9063_ONKEY=y
# CONFIG_INPUT_PCAP is not set
CONFIG_INPUT_ADXL34X=y
# CONFIG_INPUT_ADXL34X_I2C is not set
CONFIG_INPUT_ADXL34X_SPI=y
CONFIG_INPUT_IMS_PCU=y
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
CONFIG_INPUT_SOC_BUTTON_ARRAY=y
CONFIG_INPUT_DRV260X_HAPTICS=y
CONFIG_INPUT_DRV2665_HAPTICS=y
CONFIG_INPUT_DRV2667_HAPTICS=y
CONFIG_RMI4_CORE=y
# CONFIG_RMI4_I2C is not set
# CONFIG_RMI4_SPI is not set
CONFIG_RMI4_SMB=y
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=y
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
CONFIG_RMI4_F34=y
CONFIG_RMI4_F54=y
CONFIG_RMI4_F55=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_APBPS2=y
# CONFIG_SERIO_GPIO_PS2 is not set
# CONFIG_USERIO is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
# CONFIG_GOLDFISH_TTY is not set
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
# CONFIG_SERIAL_8250_MEN_MCB is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_ASPEED_VUART is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set
# CONFIG_SERIAL_OF_PLATFORM is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_CONEXANT_DIGICOLOR is not set
# CONFIG_SERIAL_MEN_Z135 is not set
# CONFIG_SERIAL_DEV_BUS is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_DMI_DECODE=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
# CONFIG_IPMI_SSIF is not set
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_SPI=y
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
CONFIG_TCG_TIS_ST33ZP24_SPI=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_ARB_GPIO_CHALLENGE is not set
# CONFIG_I2C_MUX_GPIO is not set
CONFIG_I2C_MUX_GPMUX=y
CONFIG_I2C_MUX_LTC4306=y
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_REG=y
CONFIG_I2C_MUX_MLXCPLD=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EMEV2 is not set
CONFIG_I2C_GPIO=y
# CONFIG_I2C_GPIO_FAULT_INJECTOR is not set
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_RK3X is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
# CONFIG_I2C_DLN2 is not set
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
CONFIG_I2C_VIPERBOARD=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_MLXCPLD is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y
CONFIG_SPI_MEM=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_AXI_SPI_ENGINE=y
CONFIG_SPI_BITBANG=y
# CONFIG_SPI_CADENCE is not set
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set
CONFIG_SPI_DW_MMIO=y
CONFIG_SPI_DLN2=y
CONFIG_SPI_GPIO=y
CONFIG_SPI_FSL_LIB=y
CONFIG_SPI_FSL_SPI=y
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
CONFIG_SPI_ROCKCHIP=y
CONFIG_SPI_SC18IS602=y
CONFIG_SPI_XCOMM=y
# CONFIG_SPI_XILINX is not set
CONFIG_SPI_ZYNQMP_GQSPI=y

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
# CONFIG_SPI_TLE62X0 is not set
CONFIG_SPI_SLAVE=y
CONFIG_SPI_SLAVE_TIME=y
CONFIG_SPI_SLAVE_SYSTEM_CONTROL=y
# CONFIG_SPMI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PINCTRL is not set
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_74XX_MMIO is not set
CONFIG_GPIO_ALTERA=y
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_EXAR is not set
CONFIG_GPIO_FTGPIO010=y
# CONFIG_GPIO_GENERIC_PLATFORM is not set
CONFIG_GPIO_GRGPIO=y
CONFIG_GPIO_HLWD=y
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_LYNXPOINT is not set
# CONFIG_GPIO_MB86S7X is not set
CONFIG_GPIO_MENZ127=y
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_SYSCON is not set
# CONFIG_GPIO_VX855 is not set
CONFIG_GPIO_XILINX=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_104_DIO_48E=y
CONFIG_GPIO_104_IDIO_16=y
# CONFIG_GPIO_104_IDI_48 is not set
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_GPIO_MM=y
CONFIG_GPIO_IT87=y
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_WINBOND is not set
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y
CONFIG_GPIO_ADNP=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_BD9571MWV=y
CONFIG_GPIO_DA9052=y
# CONFIG_GPIO_DA9055 is not set
CONFIG_GPIO_DLN2=y
CONFIG_GPIO_KEMPLD=y
CONFIG_GPIO_LP873X=y
CONFIG_GPIO_LP87565=y
# CONFIG_GPIO_MAX77620 is not set
CONFIG_GPIO_PALMAS=y
# CONFIG_GPIO_RC5T583 is not set
# CONFIG_GPIO_TC3589X is not set
CONFIG_GPIO_TPS65086=y
CONFIG_GPIO_TPS65218=y
# CONFIG_GPIO_TPS65912 is not set
CONFIG_GPIO_TWL4030=y
# CONFIG_GPIO_WM8994 is not set

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_PCIE_IDIO_24 is not set
# CONFIG_GPIO_RDC321X is not set
# CONFIG_GPIO_SODAVILLE is not set

#
# SPI GPIO expanders
#
# CONFIG_GPIO_74X164 is not set
CONFIG_GPIO_MAX3191X=y
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MC33880=y
CONFIG_GPIO_PISOSR=y
CONFIG_GPIO_XRA1403=y

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2405 is not set
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
# CONFIG_W1_SLAVE_DS2406 is not set
# CONFIG_W1_SLAVE_DS2423 is not set
# CONFIG_W1_SLAVE_DS2805 is not set
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2438=y
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_DS28E17=y
CONFIG_POWER_AVS=y
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_88PM860X is not set
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_LEGO_EV3=y
CONFIG_BATTERY_SBS=y
CONFIG_CHARGER_SBS=y
CONFIG_MANAGER_SBS=y
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_DA9052=y
# CONFIG_CHARGER_DA9150 is not set
# CONFIG_BATTERY_DA9150 is not set
# CONFIG_AXP20X_POWER is not set
CONFIG_AXP288_CHARGER=y
# CONFIG_AXP288_FUEL_GAUGE is not set
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_MAX1721X=y
# CONFIG_BATTERY_TWL4030_MADC is not set
# CONFIG_BATTERY_RX51 is not set
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
# CONFIG_CHARGER_TWL4030 is not set
CONFIG_CHARGER_LP8727=y
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_LTC3651=y
CONFIG_CHARGER_DETECTOR_MAX14656=y
CONFIG_CHARGER_MAX8997=y
CONFIG_CHARGER_MAX8998=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24257=y
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
CONFIG_CHARGER_TPS65217=y
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_BATTERY_GOLDFISH=y
# CONFIG_BATTERY_RT5033 is not set
CONFIG_CHARGER_RT9455=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
CONFIG_SENSORS_ABITUGURU3=y
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=y
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=y
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ASPEED=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_G762=y
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
# CONFIG_SENSORS_LTC2945 is not set
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4222 is not set
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX31722 is not set
CONFIG_SENSORS_MAX6621=y
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_TC654=y
CONFIG_SENSORS_MENF21BMC_HWMON=y
# CONFIG_SENSORS_ADCXX is not set
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=y
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_IBM_CFFPS=y
CONFIG_SENSORS_IR35221=y
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_LTC2978_REGULATOR is not set
CONFIG_SENSORS_LTC3815=y
# CONFIG_SENSORS_MAX16064 is not set
CONFIG_SENSORS_MAX20751=y
CONFIG_SENSORS_MAX31785=y
CONFIG_SENSORS_MAX34440=y
# CONFIG_SENSORS_MAX8688 is not set
CONFIG_SENSORS_TPS40422=y
# CONFIG_SENSORS_TPS53679 is not set
CONFIG_SENSORS_UCD9000=y
CONFIG_SENSORS_UCD9200=y
# CONFIG_SENSORS_ZL6100 is not set
# CONFIG_SENSORS_PWM_FAN is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SHT3x is not set
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=y
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_STTS751 is not set
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_INA3221=y
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP108=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83773G=y
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_OF=y
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_MAX77620_THERMAL is not set
# CONFIG_QORIQ_THERMAL is not set
# CONFIG_DA9062_THERMAL is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
# CONFIG_GENERIC_ADC_THERMAL is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
# CONFIG_SSB_SDIOHOST is not set
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DRIVER_GPIO=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_ACT8945A is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_MFD_AS3722 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_ATMEL_FLEXCOM=y
CONFIG_MFD_ATMEL_HLCDC=y
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_BD9571MWV=y
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
CONFIG_MFD_DLN2=y
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_MFD_HI6421_PMIC=y
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
CONFIG_MFD_MAX77620=y
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_MT6397 is not set
CONFIG_MFD_MENF21BMC=y
CONFIG_EZX_PCAP=y
# CONFIG_MFD_CPCAP is not set
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RT5033=y
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RK808=y
CONFIG_MFD_RN5T618=y
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SKY81452 is not set
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP3943 is not set
CONFIG_MFD_LP8788=y
# CONFIG_MFD_TI_LMU is not set
CONFIG_MFD_PALMAS=y
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
CONFIG_MFD_TPS65086=y
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS68470 is not set
CONFIG_MFD_TI_LP873X=y
CONFIG_MFD_TI_LP87565=y
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS65912_SPI is not set
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_CS47L24=y
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
# CONFIG_REGULATOR_FIXED_VOLTAGE is not set
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PG86X=y
# CONFIG_REGULATOR_88PM8607 is not set
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
# CONFIG_REGULATOR_AXP20X is not set
CONFIG_REGULATOR_BCM590XX=y
CONFIG_REGULATOR_BD9571MWV=y
CONFIG_REGULATOR_DA9052=y
CONFIG_REGULATOR_DA9055=y
# CONFIG_REGULATOR_DA9062 is not set
# CONFIG_REGULATOR_DA9063 is not set
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_HI6421=y
CONFIG_REGULATOR_HI6421V530=y
CONFIG_REGULATOR_ISL9305=y
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP873X is not set
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP87565=y
# CONFIG_REGULATOR_LP8788 is not set
CONFIG_REGULATOR_LTC3589=y
# CONFIG_REGULATOR_LTC3676 is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX77620=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
CONFIG_REGULATOR_MAX8907=y
# CONFIG_REGULATOR_MAX8952 is not set
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8997=y
CONFIG_REGULATOR_MAX8998=y
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PCAP=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
# CONFIG_REGULATOR_PWM is not set
# CONFIG_REGULATOR_RC5T583 is not set
# CONFIG_REGULATOR_RK808 is not set
# CONFIG_REGULATOR_RN5T618 is not set
CONFIG_REGULATOR_RT5033=y
CONFIG_REGULATOR_SY8106A=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
# CONFIG_REGULATOR_TPS65086 is not set
CONFIG_REGULATOR_TPS65132=y
CONFIG_REGULATOR_TPS65217=y
# CONFIG_REGULATOR_TPS65218 is not set
CONFIG_REGULATOR_TPS6524X=y
CONFIG_REGULATOR_TPS65912=y
# CONFIG_REGULATOR_TPS80031 is not set
# CONFIG_REGULATOR_TWL4030 is not set
CONFIG_REGULATOR_VCTRL=y
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=y
CONFIG_CEC_CORE=y
CONFIG_RC_CORE=y
CONFIG_RC_MAP=y
# CONFIG_LIRC is not set
# CONFIG_RC_DECODERS is not set
CONFIG_RC_DEVICES=y
CONFIG_RC_ATI_REMOTE=y
CONFIG_IR_ENE=y
CONFIG_IR_HIX5HD2=y
CONFIG_IR_IMON=y
CONFIG_IR_IMON_RAW=y
# CONFIG_IR_MCEUSB is not set
CONFIG_IR_ITE_CIR=y
CONFIG_IR_FINTEK=y
CONFIG_IR_NUVOTON=y
CONFIG_IR_REDRAT3=y
CONFIG_IR_STREAMZAP=y
# CONFIG_IR_WINBOND_CIR is not set
CONFIG_IR_IGORPLUGUSB=y
# CONFIG_IR_IGUANA is not set
# CONFIG_IR_TTUSBIR is not set
CONFIG_RC_LOOPBACK=y
CONFIG_IR_GPIO_CIR=y
CONFIG_IR_SERIAL=y
# CONFIG_IR_SERIAL_TRANSMITTER is not set
CONFIG_IR_SIR=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
CONFIG_MEDIA_SDR_SUPPORT=y
CONFIG_MEDIA_CEC_SUPPORT=y
CONFIG_MEDIA_CEC_RC=y
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
# CONFIG_VIDEO_PCI_SKELETON is not set
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_V4L2_FWNODE=y
CONFIG_DVB_CORE=y
CONFIG_DVB_MMAP=y
CONFIG_DVB_NET=y
CONFIG_DVB_MAX_ADAPTERS=16
# CONFIG_DVB_DYNAMIC_MINORS is not set
CONFIG_DVB_DEMUX_SECTION_LOSS_LOG=y
# CONFIG_DVB_ULE_DEBUG is not set

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set
CONFIG_V4L_PLATFORM_DRIVERS=y
# CONFIG_VIDEO_CAFE_CCIC is not set
CONFIG_VIDEO_CADENCE=y
CONFIG_SOC_CAMERA=y
CONFIG_SOC_CAMERA_PLATFORM=y
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVID=y
CONFIG_VIDEO_VIVID_CEC=y
CONFIG_VIDEO_VIVID_MAX_DEVS=64
CONFIG_VIDEO_VIM2M=y
CONFIG_DVB_PLATFORM_DRIVERS=y
# CONFIG_CEC_PLATFORM_DRIVERS is not set
CONFIG_SDR_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#
# CONFIG_SMS_SDIO_DRV is not set

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=y
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_V4L2=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEO_V4L2_TPG=y

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
CONFIG_VIDEO_IR_I2C=y

#
# I2C Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=y
CONFIG_VIDEO_TDA7432=y
# CONFIG_VIDEO_TDA9840 is not set
# CONFIG_VIDEO_TEA6415C is not set
CONFIG_VIDEO_TEA6420=y
CONFIG_VIDEO_MSP3400=y
# CONFIG_VIDEO_CS3308 is not set
CONFIG_VIDEO_CS5345=y
# CONFIG_VIDEO_CS53L32A is not set
CONFIG_VIDEO_TLV320AIC23B=y
# CONFIG_VIDEO_UDA1342 is not set
# CONFIG_VIDEO_WM8775 is not set
CONFIG_VIDEO_WM8739=y
# CONFIG_VIDEO_VP27SMPX is not set
# CONFIG_VIDEO_SONY_BTF_MPX is not set

#
# RDS decoders
#
# CONFIG_VIDEO_SAA6588 is not set

#
# Video decoders
#
# CONFIG_VIDEO_ADV7183 is not set
# CONFIG_VIDEO_BT819 is not set
CONFIG_VIDEO_BT856=y
# CONFIG_VIDEO_BT866 is not set
CONFIG_VIDEO_KS0127=y
CONFIG_VIDEO_ML86V7667=y
CONFIG_VIDEO_SAA7110=y
# CONFIG_VIDEO_SAA711X is not set
# CONFIG_VIDEO_TVP514X is not set
# CONFIG_VIDEO_TVP5150 is not set
# CONFIG_VIDEO_TVP7002 is not set
CONFIG_VIDEO_TW2804=y
CONFIG_VIDEO_TW9903=y
CONFIG_VIDEO_TW9906=y
CONFIG_VIDEO_TW9910=y
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
# CONFIG_VIDEO_SAA717X is not set
# CONFIG_VIDEO_CX25840 is not set

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=y
# CONFIG_VIDEO_SAA7185 is not set
CONFIG_VIDEO_ADV7170=y
CONFIG_VIDEO_ADV7175=y
CONFIG_VIDEO_ADV7343=y
CONFIG_VIDEO_ADV7393=y
CONFIG_VIDEO_AK881X=y
# CONFIG_VIDEO_THS8200 is not set

#
# Camera sensor devices
#
CONFIG_VIDEO_OV2640=y
# CONFIG_VIDEO_OV2659 is not set
# CONFIG_VIDEO_OV6650 is not set
# CONFIG_VIDEO_OV5695 is not set
CONFIG_VIDEO_OV772X=y
CONFIG_VIDEO_OV7640=y
CONFIG_VIDEO_OV7670=y
CONFIG_VIDEO_OV7740=y
CONFIG_VIDEO_VS6624=y
CONFIG_VIDEO_MT9M111=y
CONFIG_VIDEO_MT9T112=y
# CONFIG_VIDEO_MT9V011 is not set
CONFIG_VIDEO_SR030PC30=y

#
# Flash devices
#

#
# Video improvement chips
#
# CONFIG_VIDEO_UPD64031A is not set
CONFIG_VIDEO_UPD64083=y

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=y

#
# SDR tuner chips
#
CONFIG_SDR_MAX2175=y

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=y
# CONFIG_VIDEO_M52790 is not set
CONFIG_VIDEO_I2C=y

#
# Sensors used on soc_camera driver
#

#
# soc_camera sensor drivers
#
CONFIG_SOC_CAMERA_MT9M001=y
CONFIG_SOC_CAMERA_MT9M111=y
CONFIG_SOC_CAMERA_MT9T112=y
CONFIG_SOC_CAMERA_MT9V022=y
CONFIG_SOC_CAMERA_OV5642=y
CONFIG_SOC_CAMERA_OV772X=y
# CONFIG_SOC_CAMERA_OV9640 is not set
CONFIG_SOC_CAMERA_OV9740=y
CONFIG_SOC_CAMERA_RJ54N1=y
# CONFIG_SOC_CAMERA_TW9910 is not set

#
# SPI helper chips
#

#
# Media SPI Adapters
#
# CONFIG_CXD2880_SPI_DRV is not set
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
# CONFIG_MEDIA_TUNER_SIMPLE is not set
CONFIG_MEDIA_TUNER_TDA18250=y
# CONFIG_MEDIA_TUNER_TDA8290 is not set
# CONFIG_MEDIA_TUNER_TDA827X is not set
# CONFIG_MEDIA_TUNER_TDA18271 is not set
CONFIG_MEDIA_TUNER_TDA9887=y
# CONFIG_MEDIA_TUNER_TEA5761 is not set
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MSI001=y
# CONFIG_MEDIA_TUNER_MT20XX is not set
CONFIG_MEDIA_TUNER_MT2060=y
# CONFIG_MEDIA_TUNER_MT2063 is not set
CONFIG_MEDIA_TUNER_MT2266=y
CONFIG_MEDIA_TUNER_MT2131=y
CONFIG_MEDIA_TUNER_QT1010=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
# CONFIG_MEDIA_TUNER_MXL5007T is not set
CONFIG_MEDIA_TUNER_MC44S803=y
# CONFIG_MEDIA_TUNER_MAX2165 is not set
CONFIG_MEDIA_TUNER_TDA18218=y
CONFIG_MEDIA_TUNER_FC0011=y
CONFIG_MEDIA_TUNER_FC0012=y
CONFIG_MEDIA_TUNER_FC0013=y
CONFIG_MEDIA_TUNER_TDA18212=y
# CONFIG_MEDIA_TUNER_E4000 is not set
CONFIG_MEDIA_TUNER_FC2580=y
# CONFIG_MEDIA_TUNER_M88RS6000T is not set
CONFIG_MEDIA_TUNER_TUA9001=y
# CONFIG_MEDIA_TUNER_SI2157 is not set
CONFIG_MEDIA_TUNER_IT913X=y
# CONFIG_MEDIA_TUNER_R820T is not set
CONFIG_MEDIA_TUNER_MXL301RF=y
# CONFIG_MEDIA_TUNER_QM1D1C0042 is not set
CONFIG_MEDIA_TUNER_QM1D1B0004=y

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
# CONFIG_DVB_STB0899 is not set
# CONFIG_DVB_STB6100 is not set
CONFIG_DVB_STV090x=y
CONFIG_DVB_STV0910=y
# CONFIG_DVB_STV6110x is not set
CONFIG_DVB_STV6111=y
# CONFIG_DVB_MXL5XX is not set
# CONFIG_DVB_M88DS3103 is not set

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
# CONFIG_DVB_TDA18271C2DD is not set
CONFIG_DVB_SI2165=y
CONFIG_DVB_MN88472=y
# CONFIG_DVB_MN88473 is not set

#
# DVB-S (satellite) frontends
#
# CONFIG_DVB_CX24110 is not set
# CONFIG_DVB_CX24123 is not set
CONFIG_DVB_MT312=y
CONFIG_DVB_ZL10036=y
# CONFIG_DVB_ZL10039 is not set
CONFIG_DVB_S5H1420=y
CONFIG_DVB_STV0288=y
CONFIG_DVB_STB6000=y
CONFIG_DVB_STV0299=y
# CONFIG_DVB_STV6110 is not set
CONFIG_DVB_STV0900=y
# CONFIG_DVB_TDA8083 is not set
CONFIG_DVB_TDA10086=y
CONFIG_DVB_TDA8261=y
CONFIG_DVB_VES1X93=y
CONFIG_DVB_TUNER_ITD1000=y
CONFIG_DVB_TUNER_CX24113=y
CONFIG_DVB_TDA826X=y
CONFIG_DVB_TUA6100=y
# CONFIG_DVB_CX24116 is not set
CONFIG_DVB_CX24117=y
CONFIG_DVB_CX24120=y
CONFIG_DVB_SI21XX=y
CONFIG_DVB_TS2020=y
# CONFIG_DVB_DS3000 is not set
CONFIG_DVB_MB86A16=y
CONFIG_DVB_TDA10071=y

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=y
# CONFIG_DVB_SP887X is not set
# CONFIG_DVB_CX22700 is not set
# CONFIG_DVB_CX22702 is not set
CONFIG_DVB_S5H1432=y
CONFIG_DVB_DRXD=y
CONFIG_DVB_L64781=y
CONFIG_DVB_TDA1004X=y
CONFIG_DVB_NXT6000=y
CONFIG_DVB_MT352=y
CONFIG_DVB_ZL10353=y
# CONFIG_DVB_DIB3000MB is not set
CONFIG_DVB_DIB3000MC=y
# CONFIG_DVB_DIB7000M is not set
# CONFIG_DVB_DIB7000P is not set
# CONFIG_DVB_DIB9000 is not set
# CONFIG_DVB_TDA10048 is not set
CONFIG_DVB_AF9013=y
# CONFIG_DVB_EC100 is not set
CONFIG_DVB_STV0367=y
CONFIG_DVB_CXD2820R=y
CONFIG_DVB_CXD2841ER=y
CONFIG_DVB_RTL2830=y
CONFIG_DVB_RTL2832=y
CONFIG_DVB_RTL2832_SDR=y
CONFIG_DVB_SI2168=y
# CONFIG_DVB_ZD1301_DEMOD is not set
CONFIG_DVB_CXD2880=y

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
CONFIG_DVB_TDA10021=y
CONFIG_DVB_TDA10023=y
# CONFIG_DVB_STV0297 is not set

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
# CONFIG_DVB_OR51211 is not set
CONFIG_DVB_OR51132=y
# CONFIG_DVB_BCM3510 is not set
CONFIG_DVB_LGDT330X=y
CONFIG_DVB_LGDT3305=y
CONFIG_DVB_LGDT3306A=y
CONFIG_DVB_LG2160=y
CONFIG_DVB_S5H1409=y
CONFIG_DVB_AU8522=y
# CONFIG_DVB_AU8522_DTV is not set
CONFIG_DVB_AU8522_V4L=y
CONFIG_DVB_S5H1411=y

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=y
CONFIG_DVB_DIB8000=y
CONFIG_DVB_MB86A20S=y

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=y

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
CONFIG_DVB_TUNER_DIB0070=y
CONFIG_DVB_TUNER_DIB0090=y

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=y
CONFIG_DVB_LNBH25=y
CONFIG_DVB_LNBP21=y
CONFIG_DVB_LNBP22=y
CONFIG_DVB_ISL6405=y
CONFIG_DVB_ISL6421=y
CONFIG_DVB_ISL6423=y
CONFIG_DVB_A8293=y
# CONFIG_DVB_LGS8GL5 is not set
CONFIG_DVB_LGS8GXX=y
CONFIG_DVB_ATBM8830=y
CONFIG_DVB_TDA665x=y
# CONFIG_DVB_IX2505V is not set
CONFIG_DVB_M88RS2000=y
CONFIG_DVB_AF9033=y
# CONFIG_DVB_HORUS3A is not set
CONFIG_DVB_ASCOT2E=y
CONFIG_DVB_HELENE=y

#
# Common Interface (EN50221) controller drivers
#
# CONFIG_DVB_CXD2099 is not set
CONFIG_DVB_SP2=y

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=y

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_SMSCUFX=y
# CONFIG_FB_UDL is not set
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_GOLDFISH=y
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_SIMPLE is not set
CONFIG_FB_SSD1307=y
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_L4F00242T03=y
CONFIG_LCD_LMS283GF05=y
CONFIG_LCD_LTV350QV=y
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=y
# CONFIG_LCD_LD9040 is not set
# CONFIG_LCD_AMS369FG06 is not set
CONFIG_LCD_LMS501KF03=y
CONFIG_LCD_HX8357=y
CONFIG_LCD_OTM3225A=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_PM8941_WLED is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_88PM860X is not set
# CONFIG_BACKLIGHT_LM3630A is not set
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_PANDORA=y
# CONFIG_BACKLIGHT_TPS65217 is not set
CONFIG_BACKLIGHT_GPIO=y
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
CONFIG_BACKLIGHT_ARCXCNN=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
CONFIG_HID_ACCUTOUCH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_APPLEIR is not set
CONFIG_HID_ASUS=y
CONFIG_HID_AUREAL=y
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_BETOP_FF is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CORSAIR is not set
CONFIG_HID_CMEDIA=y
# CONFIG_HID_CP2112 is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELAN is not set
CONFIG_HID_ELECOM=y
# CONFIG_HID_ELO is not set
# CONFIG_HID_EZKEY is not set
CONFIG_HID_GEMBIRD=y
CONFIG_HID_GFRM=y
CONFIG_HID_HOLTEK=y
CONFIG_HOLTEK_FF=y
# CONFIG_HID_GOOGLE_HAMMER is not set
# CONFIG_HID_GT683R is not set
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_ITE=y
CONFIG_HID_JABRA=y
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
CONFIG_HID_LOGITECH_HIDPP=y
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_REDRAGON=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTI is not set
CONFIG_HID_NTRIG=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PENMOUNT is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
# CONFIG_HID_RETRODE is not set
CONFIG_HID_ROCCAT=y
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SONY=y
# CONFIG_SONY_FF is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEAM is not set
CONFIG_HID_STEELSERIES=y
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_RMI=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_UDRAW_PS3=y
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y
CONFIG_HID_SENSOR_CUSTOM_SENSOR=y
CONFIG_HID_ALPS=y

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set

#
# Intel ISH HID support
#
# CONFIG_INTEL_ISH_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG_WHITELIST=y
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_LEDS_TRIGGER_USBPORT is not set
# CONFIG_USB_MON is not set
CONFIG_USB_WUSB_CBAF=y
CONFIG_USB_WUSB_CBAF_DEBUG=y

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
# CONFIG_USB_XHCI_DBGCAP is not set
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_MAX3421_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
CONFIG_USB_OHCI_HCD_SSB=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_SL811_HCD=y
CONFIG_USB_SL811_HCD_ISO=y
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_HCD_BCMA is not set
CONFIG_USB_HCD_SSB=y
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
CONFIG_USBIP_CORE=y
# CONFIG_USBIP_VHCI_HCD is not set
CONFIG_USBIP_HOST=y
# CONFIG_USBIP_VUDC is not set
# CONFIG_USBIP_DEBUG is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y
# CONFIG_USB_MUSB_GADGET is not set
# CONFIG_USB_MUSB_DUAL_ROLE is not set

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_HOST is not set
# CONFIG_USB_DWC3_GADGET is not set
CONFIG_USB_DWC3_DUAL_ROLE=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC3_OF_SIMPLE=y
CONFIG_USB_DWC2=y
# CONFIG_USB_DWC2_HOST is not set

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
CONFIG_USB_DWC2_PERIPHERAL=y
# CONFIG_USB_DWC2_DUAL_ROLE is not set
# CONFIG_USB_DWC2_PCI is not set
# CONFIG_USB_DWC2_DEBUG is not set
CONFIG_USB_DWC2_TRACK_MISSED_SOFS=y
# CONFIG_USB_CHIPIDEA is not set
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y
# CONFIG_USB_ISP1760_GADGET_ROLE is not set
# CONFIG_USB_ISP1760_DUAL_ROLE is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
# CONFIG_USB_LEGOTOWER is not set
CONFIG_USB_LCD=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_SISUSBVGA is not set
CONFIG_USB_LD=y
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=y
CONFIG_USB_EHSET_TEST_FIXTURE=y
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HUB_USB251XB is not set
CONFIG_USB_HSIC_USB3503=y
CONFIG_USB_HSIC_USB4604=y
CONFIG_USB_LINK_LAYER_TEST=y
CONFIG_USB_ATM=y
CONFIG_USB_SPEEDTOUCH=y
CONFIG_USB_CXACRU=y
# CONFIG_USB_UEAGLEATM is not set
# CONFIG_USB_XUSBATM is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_GPIO_VBUS=y
CONFIG_TAHVO_USB=y
# CONFIG_TAHVO_USB_HOST_BY_DEFAULT is not set
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=y
CONFIG_USB_GADGET_DEBUG=y
# CONFIG_USB_GADGET_VERBOSE is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_FOTG210_UDC=y
CONFIG_USB_GR_UDC=y
CONFIG_USB_R8A66597=y
# CONFIG_USB_PXA27X is not set
CONFIG_USB_MV_UDC=y
# CONFIG_USB_MV_U3D is not set
CONFIG_USB_SNP_CORE=y
CONFIG_USB_SNP_UDC_PLAT=y
# CONFIG_USB_M66592 is not set
CONFIG_USB_BDC_UDC=y

#
# Platform Support
#
CONFIG_USB_BDC_PCI=y
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
# CONFIG_USB_GADGET_XILINX is not set
# CONFIG_USB_DUMMY_HCD is not set
# CONFIG_USB_CONFIGFS is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_ROLES_INTEL_XHCI is not set
CONFIG_USB_LED_TRIG=y
# CONFIG_USB_ULPI_BUS is not set
CONFIG_USB_ROLE_SWITCH=y
# CONFIG_UWB is not set
CONFIG_MMC=y
CONFIG_PWRSEQ_EMMC=y
CONFIG_PWRSEQ_SIMPLE=y
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
CONFIG_MMC_GOLDFISH=y
CONFIG_MMC_SPI=y
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MMC_VUB300 is not set
CONFIG_MMC_USHC=y
# CONFIG_MMC_USDHI6ROL0 is not set
CONFIG_MMC_CQHCI=y
# CONFIG_MMC_TOSHIBA_PCI is not set
CONFIG_MMC_MTK=y
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_APU is not set
# CONFIG_LEDS_AS3645A is not set
CONFIG_LEDS_BCM6328=y
# CONFIG_LEDS_BCM6358 is not set
CONFIG_LEDS_CR0014114=y
CONFIG_LEDS_LM3530=y
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_LM3692X is not set
# CONFIG_LEDS_LM3601X is not set
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_LP8860=y
# CONFIG_LEDS_CLEVO_MAIL is not set
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA955X_GPIO is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_PWM=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_TLC591XX is not set
CONFIG_LEDS_MAX8997=y
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_MENF21BMC=y
CONFIG_LEDS_KTD2692=y
# CONFIG_LEDS_IS31FL319X is not set
# CONFIG_LEDS_IS31FL32XX is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_SYSCON=y
# CONFIG_LEDS_MLXCPLD is not set
CONFIG_LEDS_MLXREG=y
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_ACTIVITY is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_LEDS_TRIGGER_NETDEV is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set
CONFIG_RTC_NVMEM=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_INTF_DEV_UIE_EMUL=y
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM860X is not set
CONFIG_RTC_DRV_ABB5ZES3=y
CONFIG_RTC_DRV_ABX80X=y
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1307_HWMON=y
CONFIG_RTC_DRV_DS1307_CENTURY=y
CONFIG_RTC_DRV_DS1374=y
# CONFIG_RTC_DRV_DS1374_WDT is not set
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_HYM8563=y
CONFIG_RTC_DRV_LP8788=y
CONFIG_RTC_DRV_MAX6900=y
# CONFIG_RTC_DRV_MAX8907 is not set
CONFIG_RTC_DRV_MAX8998=y
# CONFIG_RTC_DRV_MAX8997 is not set
CONFIG_RTC_DRV_MAX77686=y
CONFIG_RTC_DRV_RK808=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
# CONFIG_RTC_DRV_ISL12026 is not set
# CONFIG_RTC_DRV_X1205 is not set
CONFIG_RTC_DRV_PCF8523=y
# CONFIG_RTC_DRV_PCF85063 is not set
CONFIG_RTC_DRV_PCF85363=y
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
# CONFIG_RTC_DRV_BQ32K is not set
CONFIG_RTC_DRV_TWL4030=y
# CONFIG_RTC_DRV_PALMAS is not set
CONFIG_RTC_DRV_TPS80031=y
CONFIG_RTC_DRV_RC5T583=y
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8010=y
CONFIG_RTC_DRV_RX8581=y
# CONFIG_RTC_DRV_RX8025 is not set
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV8803=y

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
CONFIG_RTC_DRV_M41T94=y
CONFIG_RTC_DRV_DS1302=y
# CONFIG_RTC_DRV_DS1305 is not set
CONFIG_RTC_DRV_DS1343=y
# CONFIG_RTC_DRV_DS1347 is not set
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_MAX6916=y
# CONFIG_RTC_DRV_R9701 is not set
CONFIG_RTC_DRV_RX4581=y
CONFIG_RTC_DRV_RX6110=y
# CONFIG_RTC_DRV_RS5C348 is not set
# CONFIG_RTC_DRV_MAX6902 is not set
CONFIG_RTC_DRV_PCF2123=y
# CONFIG_RTC_DRV_MCP795 is not set
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=y
# CONFIG_RTC_DRV_DS3232_HWMON is not set
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_RV3029C2=y
# CONFIG_RTC_DRV_RV3029_HWMON is not set

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1685_FAMILY=y
# CONFIG_RTC_DRV_DS1685 is not set
CONFIG_RTC_DRV_DS1689=y
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
# CONFIG_RTC_DRV_DS17885 is not set
# CONFIG_RTC_DS1685_PROC_REGS is not set
# CONFIG_RTC_DS1685_SYSFS_REGS is not set
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_DS2404=y
# CONFIG_RTC_DRV_DA9052 is not set
CONFIG_RTC_DRV_DA9055=y
# CONFIG_RTC_DRV_DA9063 is not set
CONFIG_RTC_DRV_STK17TA8=y
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=y
# CONFIG_RTC_DRV_M48T59 is not set
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_ZYNQMP=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_FTRTC010=y
CONFIG_RTC_DRV_PCAP=y
CONFIG_RTC_DRV_SNVS=y
CONFIG_RTC_DRV_R7301=y

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y
CONFIG_ALTERA_MSGDMA=y
CONFIG_DW_AXI_DMAC=y
# CONFIG_FSL_EDMA is not set
# CONFIG_INTEL_IDMA64 is not set
# CONFIG_INTEL_IOATDMA is not set
CONFIG_QCOM_HIDMA_MGMT=y
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
CONFIG_HSU_DMA=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=y
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_MENU=y
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_INPUT=y
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
CONFIG_COMEDI=y
CONFIG_COMEDI_DEBUG=y
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
CONFIG_COMEDI_MISC_DRIVERS=y
CONFIG_COMEDI_BOND=y
CONFIG_COMEDI_TEST=y
CONFIG_COMEDI_PARPORT=y
# CONFIG_COMEDI_SERIAL2002 is not set
# CONFIG_COMEDI_ISA_DRIVERS is not set
# CONFIG_COMEDI_PCI_DRIVERS is not set
CONFIG_COMEDI_USB_DRIVERS=y
# CONFIG_COMEDI_DT9812 is not set
# CONFIG_COMEDI_NI_USB6501 is not set
CONFIG_COMEDI_USBDUX=y
CONFIG_COMEDI_USBDUXFAST=y
# CONFIG_COMEDI_USBDUXSIGMA is not set
# CONFIG_COMEDI_VMK80XX is not set
CONFIG_COMEDI_8255=y
CONFIG_COMEDI_8255_SA=y
CONFIG_COMEDI_KCOMEDILIB=y
# CONFIG_R8712U is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16203=y
# CONFIG_ADIS16240 is not set

#
# Analog to digital converters
#
CONFIG_AD7606=y
# CONFIG_AD7606_IFACE_PARALLEL is not set
CONFIG_AD7606_IFACE_SPI=y
# CONFIG_AD7780 is not set
# CONFIG_AD7816 is not set
CONFIG_AD7192=y
CONFIG_AD7280=y

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
CONFIG_ADT7316_SPI=y
CONFIG_ADT7316_I2C=y

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
# CONFIG_AD7152 is not set
# CONFIG_AD7746 is not set

#
# Direct Digital Synthesis
#
# CONFIG_AD9832 is not set
CONFIG_AD9834=y

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16060 is not set

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y

#
# Active energy metering IC
#
CONFIG_ADE7854=y
# CONFIG_ADE7854_I2C is not set
CONFIG_ADE7854_SPI=y

#
# Resolver to digital converters
#
CONFIG_AD2S90=y
# CONFIG_AD2S1210 is not set
# CONFIG_FB_SM750 is not set
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
CONFIG_STAGING_MEDIA=y
CONFIG_SOC_CAMERA_IMX074=y
# CONFIG_SOC_CAMERA_MT9T031 is not set
# CONFIG_VIDEO_ZORAN is not set

#
# Android
#
# CONFIG_STAGING_BOARD is not set
# CONFIG_FIREWIRE_SERIAL is not set
CONFIG_GOLDFISH_AUDIO=y
# CONFIG_DGNC is not set
CONFIG_GS_FPGABOOT=y
# CONFIG_CRYPTO_SKEIN is not set
CONFIG_UNISYSSPAR=y
# CONFIG_COMMON_CLK_XLNX_CLKWZRD is not set
CONFIG_FB_TFT=y
# CONFIG_FB_TFT_AGM1264K_FL is not set
CONFIG_FB_TFT_BD663474=y
# CONFIG_FB_TFT_HX8340BN is not set
CONFIG_FB_TFT_HX8347D=y
# CONFIG_FB_TFT_HX8353D is not set
CONFIG_FB_TFT_HX8357D=y
CONFIG_FB_TFT_ILI9163=y
CONFIG_FB_TFT_ILI9320=y
CONFIG_FB_TFT_ILI9325=y
CONFIG_FB_TFT_ILI9340=y
# CONFIG_FB_TFT_ILI9341 is not set
CONFIG_FB_TFT_ILI9481=y
# CONFIG_FB_TFT_ILI9486 is not set
CONFIG_FB_TFT_PCD8544=y
CONFIG_FB_TFT_RA8875=y
CONFIG_FB_TFT_S6D02A1=y
CONFIG_FB_TFT_S6D1121=y
CONFIG_FB_TFT_SH1106=y
CONFIG_FB_TFT_SSD1289=y
CONFIG_FB_TFT_SSD1305=y
# CONFIG_FB_TFT_SSD1306 is not set
CONFIG_FB_TFT_SSD1331=y
# CONFIG_FB_TFT_SSD1351 is not set
# CONFIG_FB_TFT_ST7735R is not set
# CONFIG_FB_TFT_ST7789V is not set
CONFIG_FB_TFT_TINYLCD=y
# CONFIG_FB_TFT_TLS8204 is not set
# CONFIG_FB_TFT_UC1611 is not set
# CONFIG_FB_TFT_UC1701 is not set
CONFIG_FB_TFT_UPD161704=y
# CONFIG_FB_TFT_WATTEROTT is not set
# CONFIG_FB_FLEX is not set
# CONFIG_FB_TFT_FBTFT_DEVICE is not set
CONFIG_MOST=y
# CONFIG_MOST_CDEV is not set
# CONFIG_MOST_NET is not set
CONFIG_MOST_VIDEO=y
CONFIG_MOST_DIM2=y
CONFIG_MOST_I2C=y
CONFIG_MOST_USB=y
# CONFIG_KS7010 is not set
# CONFIG_GREYBUS is not set

#
# USB Power Delivery and Type-C drivers
#
CONFIG_PI433=y
CONFIG_MTK_MMC=y
# CONFIG_MTK_AEE_KDUMP is not set
# CONFIG_MTK_MMC_CD_POLL is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WIRELESS is not set
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_SMBIOS=y
# CONFIG_DELL_SMBIOS_SMM is not set
CONFIG_DELL_LAPTOP=y
# CONFIG_DELL_SMO8800 is not set
# CONFIG_DELL_RBTN is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
CONFIG_AMILO_RFKILL=y
# CONFIG_GPD_POCKET_FAN is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_COMPAL_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_IDEAPAD_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ASUS_WIRELESS is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_CHT_INT33FE is not set
# CONFIG_INTEL_INT0002_VGPIO is not set
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_INTEL_PMC_CORE is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=y
# CONFIG_INTEL_OAKTRAIL is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
# CONFIG_SURFACE_3_BUTTON is not set
CONFIG_INTEL_PUNIT_IPC=y
CONFIG_MLX_PLATFORM=y
# CONFIG_SILEAD_DMI is not set
CONFIG_PMC_ATOM=y
# CONFIG_GOLDFISH_BUS is not set
# CONFIG_GOLDFISH_PIPE is not set
# CONFIG_CHROME_PLATFORMS is not set
CONFIG_MELLANOX_PLATFORM=y
CONFIG_MLXREG_HOTPLUG=y
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_CLK_HSDK is not set
# CONFIG_COMMON_CLK_MAX77686 is not set
# CONFIG_COMMON_CLK_RK808 is not set
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI514 is not set
# CONFIG_COMMON_CLK_SI544 is not set
# CONFIG_COMMON_CLK_SI570 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CDCE925 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_COMMON_CLK_PALMAS is not set
# CONFIG_COMMON_CLK_PWM is not set
# CONFIG_COMMON_CLK_VC5 is not set
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_AMD_IOMMU is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#
# CONFIG_RPMSG_VIRTIO is not set
# CONFIG_SOUNDWIRE is not set

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
# CONFIG_SOC_TI is not set

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=y
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_ADC_JACK is not set
CONFIG_EXTCON_AXP288=y
# CONFIG_EXTCON_GPIO is not set
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_MAX3355 is not set
CONFIG_EXTCON_MAX8997=y
CONFIG_EXTCON_PALMAS=y
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_BUFFER_HW_CONSUMER=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
CONFIG_IIO_SW_DEVICE=y
CONFIG_IIO_SW_TRIGGER=y
CONFIG_IIO_TRIGGERED_EVENT=y

#
# Accelerometers
#
CONFIG_ADIS16201=y
CONFIG_ADIS16209=y
# CONFIG_BMA180 is not set
CONFIG_BMA220=y
# CONFIG_BMC150_ACCEL is not set
CONFIG_DA280=y
# CONFIG_DA311 is not set
CONFIG_DMARD06=y
# CONFIG_DMARD09 is not set
CONFIG_DMARD10=y
CONFIG_HID_SENSOR_ACCEL_3D=y
CONFIG_IIO_CROS_EC_ACCEL_LEGACY=y
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
CONFIG_KXSD9=y
CONFIG_KXSD9_SPI=y
CONFIG_KXSD9_I2C=y
# CONFIG_KXCJK1013 is not set
# CONFIG_MC3230 is not set
CONFIG_MMA7455=y
CONFIG_MMA7455_I2C=y
CONFIG_MMA7455_SPI=y
CONFIG_MMA7660=y
# CONFIG_MMA8452 is not set
# CONFIG_MMA9551 is not set
# CONFIG_MMA9553 is not set
# CONFIG_MXC4005 is not set
# CONFIG_MXC6255 is not set
# CONFIG_SCA3000 is not set
CONFIG_STK8312=y
# CONFIG_STK8BA50 is not set

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7291=y
# CONFIG_AD7298 is not set
# CONFIG_AD7476 is not set
CONFIG_AD7766=y
CONFIG_AD7791=y
CONFIG_AD7793=y
# CONFIG_AD7887 is not set
CONFIG_AD7923=y
# CONFIG_AD799X is not set
# CONFIG_AXP20X_ADC is not set
CONFIG_AXP288_ADC=y
# CONFIG_CC10001_ADC is not set
CONFIG_DA9150_GPADC=y
# CONFIG_DLN2_ADC is not set
CONFIG_ENVELOPE_DETECTOR=y
CONFIG_HI8435=y
# CONFIG_HX711 is not set
# CONFIG_LP8788_ADC is not set
CONFIG_LTC2471=y
CONFIG_LTC2485=y
CONFIG_LTC2497=y
# CONFIG_MAX1027 is not set
CONFIG_MAX11100=y
CONFIG_MAX1118=y
# CONFIG_MAX1363 is not set
CONFIG_MAX9611=y
CONFIG_MCP320X=y
CONFIG_MCP3422=y
CONFIG_MEN_Z188_ADC=y
CONFIG_NAU7802=y
CONFIG_PALMAS_GPADC=y
# CONFIG_SD_ADC_MODULATOR is not set
CONFIG_STX104=y
# CONFIG_TI_ADC081C is not set
CONFIG_TI_ADC0832=y
CONFIG_TI_ADC084S021=y
CONFIG_TI_ADC12138=y
CONFIG_TI_ADC108S102=y
# CONFIG_TI_ADC128S052 is not set
CONFIG_TI_ADC161S626=y
CONFIG_TI_ADS7950=y
CONFIG_TI_ADS8688=y
CONFIG_TI_AM335X_ADC=y
# CONFIG_TI_TLC4541 is not set
CONFIG_TWL4030_MADC=y
CONFIG_TWL6030_GPADC=y
CONFIG_VF610_ADC=y
# CONFIG_VIPERBOARD_ADC is not set

#
# Analog Front Ends
#
# CONFIG_IIO_RESCALE is not set

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=y
CONFIG_CCS811=y
CONFIG_IAQCORE=y
CONFIG_VZ89X=y

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
# CONFIG_IIO_SSP_SENSORHUB is not set
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Counters
#
CONFIG_104_QUAD_8=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5360=y
CONFIG_AD5380=y
CONFIG_AD5421=y
CONFIG_AD5446=y
CONFIG_AD5449=y
CONFIG_AD5592R_BASE=y
CONFIG_AD5592R=y
# CONFIG_AD5593R is not set
# CONFIG_AD5504 is not set
# CONFIG_AD5624R_SPI is not set
CONFIG_LTC2632=y
# CONFIG_AD5686_SPI is not set
# CONFIG_AD5696_I2C is not set
CONFIG_AD5755=y
CONFIG_AD5761=y
# CONFIG_AD5764 is not set
CONFIG_AD5791=y
CONFIG_AD7303=y
CONFIG_CIO_DAC=y
CONFIG_AD8801=y
CONFIG_DPOT_DAC=y
# CONFIG_DS4424 is not set
# CONFIG_M62332 is not set
# CONFIG_MAX517 is not set
CONFIG_MAX5821=y
CONFIG_MCP4725=y
CONFIG_MCP4922=y
# CONFIG_TI_DAC082S085 is not set
CONFIG_TI_DAC5571=y
CONFIG_VF610_DAC=y

#
# IIO dummy driver
#
# CONFIG_IIO_SIMPLE_DUMMY is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
# CONFIG_AD9523 is not set

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=y
CONFIG_ADIS16130=y
# CONFIG_ADIS16136 is not set
CONFIG_ADIS16260=y
CONFIG_ADXRS450=y
CONFIG_BMG160=y
CONFIG_BMG160_I2C=y
CONFIG_BMG160_SPI=y
CONFIG_HID_SENSOR_GYRO_3D=y
CONFIG_MPU3050=y
CONFIG_MPU3050_I2C=y
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=y

#
# Health Sensors
#

#
# Heart Rate Monitors
#
# CONFIG_AFE4403 is not set
# CONFIG_AFE4404 is not set
CONFIG_MAX30100=y
CONFIG_MAX30102=y

#
# Humidity sensors
#
CONFIG_AM2315=y
CONFIG_DHT11=y
CONFIG_HDC100X=y
# CONFIG_HID_SENSOR_HUMIDITY is not set
CONFIG_HTS221=y
CONFIG_HTS221_I2C=y
CONFIG_HTS221_SPI=y
# CONFIG_HTU21 is not set
# CONFIG_SI7005 is not set
# CONFIG_SI7020 is not set

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
CONFIG_ADIS16480=y
CONFIG_BMI160=y
CONFIG_BMI160_I2C=y
CONFIG_BMI160_SPI=y
CONFIG_KMX61=y
CONFIG_INV_MPU6050_IIO=y
CONFIG_INV_MPU6050_I2C=y
# CONFIG_INV_MPU6050_SPI is not set
CONFIG_IIO_ST_LSM6DSX=y
CONFIG_IIO_ST_LSM6DSX_I2C=y
CONFIG_IIO_ST_LSM6DSX_SPI=y
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
# CONFIG_ADJD_S311 is not set
# CONFIG_AL3320A is not set
CONFIG_APDS9300=y
# CONFIG_APDS9960 is not set
CONFIG_BH1750=y
CONFIG_BH1780=y
CONFIG_CM32181=y
CONFIG_CM3232=y
CONFIG_CM3323=y
# CONFIG_CM3605 is not set
CONFIG_CM36651=y
CONFIG_GP2AP020A00F=y
# CONFIG_SENSORS_ISL29018 is not set
CONFIG_SENSORS_ISL29028=y
CONFIG_ISL29125=y
CONFIG_HID_SENSOR_ALS=y
CONFIG_HID_SENSOR_PROX=y
# CONFIG_JSA1212 is not set
CONFIG_RPR0521=y
CONFIG_LTR501=y
# CONFIG_LV0104CS is not set
CONFIG_MAX44000=y
# CONFIG_OPT3001 is not set
# CONFIG_PA12203001 is not set
CONFIG_SI1145=y
CONFIG_STK3310=y
CONFIG_ST_UVIS25=y
CONFIG_ST_UVIS25_I2C=y
CONFIG_ST_UVIS25_SPI=y
CONFIG_TCS3414=y
# CONFIG_TCS3472 is not set
# CONFIG_SENSORS_TSL2563 is not set
CONFIG_TSL2583=y
CONFIG_TSL2772=y
# CONFIG_TSL4531 is not set
CONFIG_US5182D=y
CONFIG_VCNL4000=y
CONFIG_VEML6070=y
# CONFIG_VL6180 is not set
# CONFIG_ZOPT2201 is not set

#
# Magnetometer sensors
#
CONFIG_AK8974=y
CONFIG_AK8975=y
CONFIG_AK09911=y
CONFIG_BMC150_MAGN=y
CONFIG_BMC150_MAGN_I2C=y
CONFIG_BMC150_MAGN_SPI=y
CONFIG_MAG3110=y
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
CONFIG_MMC35240=y
# CONFIG_IIO_ST_MAGN_3AXIS is not set
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y
CONFIG_SENSORS_HMC5843_SPI=y

#
# Multiplexers
#
# CONFIG_IIO_MUX is not set

#
# Inclinometer sensors
#
# CONFIG_HID_SENSOR_INCLINOMETER_3D is not set
CONFIG_HID_SENSOR_DEVICE_ROTATION=y

#
# Triggers - standalone
#
CONFIG_IIO_HRTIMER_TRIGGER=y
CONFIG_IIO_INTERRUPT_TRIGGER=y
# CONFIG_IIO_TIGHTLOOP_TRIGGER is not set
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Digital potentiometers
#
CONFIG_AD5272=y
CONFIG_DS1803=y
CONFIG_MAX5481=y
# CONFIG_MAX5487 is not set
CONFIG_MCP4018=y
CONFIG_MCP4131=y
CONFIG_MCP4531=y
CONFIG_TPL0102=y

#
# Digital potentiostats
#
CONFIG_LMP91000=y

#
# Pressure sensors
#
CONFIG_ABP060MG=y
# CONFIG_BMP280 is not set
# CONFIG_HID_SENSOR_PRESS is not set
CONFIG_HP03=y
CONFIG_MPL115=y
CONFIG_MPL115_I2C=y
CONFIG_MPL115_SPI=y
CONFIG_MPL3115=y
CONFIG_MS5611=y
CONFIG_MS5611_I2C=y
# CONFIG_MS5611_SPI is not set
CONFIG_MS5637=y
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_IIO_ST_PRESS_SPI=y
# CONFIG_T5403 is not set
# CONFIG_HP206C is not set
CONFIG_ZPA2326=y
CONFIG_ZPA2326_I2C=y
CONFIG_ZPA2326_SPI=y

#
# Lightning sensors
#
CONFIG_AS3935=y

#
# Proximity and distance sensors
#
CONFIG_LIDAR_LITE_V2=y
CONFIG_RFD77402=y
CONFIG_SRF04=y
# CONFIG_SX9500 is not set
CONFIG_SRF08=y

#
# Resolver to digital converters
#
CONFIG_AD2S1200=y

#
# Temperature sensors
#
# CONFIG_MAXIM_THERMOCOUPLE is not set
CONFIG_HID_SENSOR_TEMP=y
CONFIG_MLX90614=y
CONFIG_MLX90632=y
# CONFIG_TMP006 is not set
CONFIG_TMP007=y
# CONFIG_TSYS01 is not set
CONFIG_TSYS02D=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_ATMEL_HLCDC_PWM is not set
CONFIG_PWM_FSL_FTM=y
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_PCA9685=y
# CONFIG_PWM_TWL is not set
# CONFIG_PWM_TWL_LED is not set

#
# IRQ chip support
#
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
CONFIG_RESET_TI_SYSCON=y
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
# CONFIG_FMC_TRIVIAL is not set
CONFIG_FMC_WRITE_EEPROM=y
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
CONFIG_PHY_PXA_28NM_USB2=y
# CONFIG_PHY_CPCAP_USB is not set
CONFIG_PHY_MAPPHONE_MDM6600=y
CONFIG_PHY_SAMSUNG_USB2=y
CONFIG_POWERCAP=y
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
CONFIG_MCB_LPC=y

#
# Performance monitor support
#
CONFIG_RAS=y
CONFIG_RAS_CEC=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_DAX is not set
CONFIG_NVMEM=y

#
# HW tracing support
#
# CONFIG_STM is not set
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
# CONFIG_INTEL_TH_ACPI is not set
# CONFIG_INTEL_TH_GTH is not set
CONFIG_INTEL_TH_MSU=y
CONFIG_INTEL_TH_PTI=y
CONFIG_INTEL_TH_DEBUG=y
CONFIG_FPGA=y
CONFIG_ALTERA_PR_IP_CORE=y
CONFIG_ALTERA_PR_IP_CORE_PLAT=y
CONFIG_FPGA_MGR_ALTERA_PS_SPI=y
# CONFIG_FPGA_MGR_ALTERA_CVP is not set
CONFIG_FPGA_MGR_XILINX_SPI=y
CONFIG_FPGA_MGR_ICE40_SPI=y
# CONFIG_FPGA_MGR_MACHXO2_SPI is not set
CONFIG_FPGA_BRIDGE=y
# CONFIG_XILINX_PR_DECOUPLER is not set
CONFIG_FPGA_REGION=y
CONFIG_OF_FPGA_REGION=y
# CONFIG_FSI is not set
CONFIG_MULTIPLEXER=y

#
# Multiplexer drivers
#
CONFIG_MUX_ADG792A=y
# CONFIG_MUX_GPIO is not set
CONFIG_MUX_MMIO=y
# CONFIG_UNISYS_VISORBUS is not set
CONFIG_SIOX=y
# CONFIG_SIOX_BUS_GPIO is not set
CONFIG_SLIMBUS=y
CONFIG_SLIM_QCOM_CTRL=y

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
CONFIG_FW_CFG_SYSFS_CMDLINE=y
CONFIG_GOOGLE_FIRMWARE=y
CONFIG_GOOGLE_COREBOOT_TABLE=y
# CONFIG_GOOGLE_COREBOOT_TABLE_ACPI is not set
CONFIG_GOOGLE_COREBOOT_TABLE_OF=y
# CONFIG_GOOGLE_MEMCONSOLE_X86_LEGACY is not set
# CONFIG_GOOGLE_MEMCONSOLE_COREBOOT is not set
CONFIG_GOOGLE_VPD=y

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
# CONFIG_FS_ENCRYPTION is not set
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
CONFIG_AUTOFS4_FS=y
CONFIG_AUTOFS_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=y
# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set
# CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW is not set
# CONFIG_OVERLAY_FS_INDEX is not set
CONFIG_OVERLAY_FS_XINO_AUTO=y

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_MEMFD_CREATE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ECRYPT_FS=y
CONFIG_ECRYPT_FS_MESSAGING=y
# CONFIG_CRAMFS is not set
# CONFIG_PSTORE is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=y
# CONFIG_NLS_MAC_CYRILLIC is not set
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y
CONFIG_DLM=y
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_STACK_VALIDATION=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=y
CONFIG_PAGE_POISONING=y
# CONFIG_PAGE_POISONING_NO_SANITY is not set
# CONFIG_PAGE_POISONING_ZERO is not set
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KASAN=y
# CONFIG_KASAN is not set
CONFIG_ARCH_HAS_KCOV=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
CONFIG_KCOV=y
CONFIG_KCOV_INSTRUMENT_ALL=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_SOFTLOCKUP_DETECTOR is not set
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
CONFIG_SCHED_STACK_END_CHECK=y
CONFIG_DEBUG_TIMEKEEPING=y
# CONFIG_DEBUG_PREEMPT is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
CONFIG_PROVE_LOCKING=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_WW_MUTEX_SELFTEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
CONFIG_WARN_ALL_UNSEEDED_RANDOM=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_OF_RECONFIG_NOTIFIER_ERROR_INJECT=y
CONFIG_NETDEV_NOTIFIER_ERROR_INJECT=y
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
# CONFIG_MEMTEST is not set
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
CONFIG_UBSAN_NULL=y
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_WX is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
CONFIG_DEBUG_ENTRY=y
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_FPU is not set
# CONFIG_PUNIT_ATOM_DEBUG is not set
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_PAGE_TABLE_ISOLATION=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
# CONFIG_HARDENED_USERCOPY is not set
# CONFIG_FORTIFY_SOURCE is not set
CONFIG_STATIC_USERMODEHELPER=y
CONFIG_STATIC_USERMODEHELPER_PATH="/sbin/usermode-helper"
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
# CONFIG_CRYPTO_RSA is not set
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_AEGIS128=y
CONFIG_CRYPTO_AEGIS128L=y
CONFIG_CRYPTO_AEGIS256=y
CONFIG_CRYPTO_AEGIS128_AESNI_SSE2=y
CONFIG_CRYPTO_AEGIS128L_AESNI_SSE2=y
CONFIG_CRYPTO_AEGIS256_AESNI_SSE2=y
CONFIG_CRYPTO_MORUS640=y
CONFIG_CRYPTO_MORUS640_GLUE=y
CONFIG_CRYPTO_MORUS640_SSE2=y
# CONFIG_CRYPTO_MORUS1280 is not set
CONFIG_CRYPTO_MORUS1280_GLUE=y
CONFIG_CRYPTO_MORUS1280_SSE2=y
CONFIG_CRYPTO_MORUS1280_AVX2=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CFB=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
CONFIG_CRYPTO_SHA256_SSSE3=y
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
# CONFIG_CRYPTO_SHA1_MB is not set
CONFIG_CRYPTO_SHA256_MB=y
# CONFIG_CRYPTO_SHA512_MB is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_SM3=y
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
# CONFIG_CRYPTO_ARC4 is not set
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
# CONFIG_CRYPTO_SM4 is not set
# CONFIG_CRYPTO_SPECK is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y
CONFIG_CRYPTO_ZSTD=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_USER_API_RNG=y
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
# CONFIG_CRYPTO_DEV_VIRTIO is not set
CONFIG_CRYPTO_DEV_CCREE=y
# CONFIG_ASYMMETRIC_KEY_TYPE is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_BLACKLIST_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_HASH_LIST=""
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC4 is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_XXHASH=y
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=y
CONFIG_ZSTD_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_SWIOTLB=y
CONFIG_SGL_ALLOC=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
CONFIG_LIBFDT=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_ARCH_HAS_UACCESS_MCSAFE=y
CONFIG_STACKDEPOT=y
CONFIG_STRING_SELFTEST=y

--a7XSrSxqzVsaECgU--
