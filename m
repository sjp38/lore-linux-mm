Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EECEF6B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 06:38:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z6-v6so9957187pgu.20
        for <linux-mm@kvack.org>; Wed, 02 May 2018 03:38:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q14-v6si2740896pgc.620.2018.05.02.03.38.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 03:38:05 -0700 (PDT)
Subject: Re: general protection fault in kernfs_kill_sb
References: <94eb2c0546040ebb4d0568cc6bdb@google.com>
 <821c80d2-0b55-287a-09aa-d004f4ac4215@I-love.SAKURA.ne.jp>
 <20180402143415.GC30522@ZenIV.linux.org.uk>
 <20180420024440.GB686@sol.localdomain>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <45fa9e0d-a8d3-db91-9de4-b4e2977b7012@I-love.SAKURA.ne.jp>
Date: Wed, 2 May 2018 19:37:15 +0900
MIME-Version: 1.0
In-Reply-To: <20180420024440.GB686@sol.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>
Cc: syzbot <syzbot+151de3f2be6b40ac8026@syzkaller.appspotmail.com>, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-fsdevel@vger.kernel.org

On 2018/04/20 11:44, Eric Biggers wrote:
> Fix for the kernfs bug is now queued in vfs/for-linus:
> 
> #syz fix: kernfs: deal with early sget() failures

Well, the following patches

  rpc_pipefs: deal with early sget() failures
  kernfs: deal with early sget() failures
  procfs: deal with early sget() failures
  nfsd_umount(): deal with early sget() failures
  nfs: avoid double-free on early sget() failures

are dropped from vfs.git#for-linus while this report is marked
as "#syz fix: kernfs: deal with early sget() failures". The patch which
actually went to linux.git is 8e04944f0ea8b838.

#syz fix: mm,vmscan: Allow preallocating memory for register_shrinker().



By the way, we still have NULL pointer dereference (as of f2125992e7cb25ec
on linux.git) shown below due to calling deactivate_locked_super() without
successful fill_super().

----------
[  162.865231] BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
[  162.873678] PGD 130487067 P4D 130487067 PUD 138750067 PMD 0 
[  162.879845] Oops: 0000 [#1] SMP
[  162.883295] Modules linked in:
[  162.886648] CPU: 2 PID: 15505 Comm: a.out Kdump: loaded Tainted: G                T 4.17.0-rc3+ #522
[  162.894891] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  162.899415] RIP: 0010:__list_del_entry_valid+0x29/0x90
[  162.901609] RSP: 0018:ffffc90001e07ce0 EFLAGS: 00010207
[  162.903834] RAX: 0000000000000000 RBX: ffff880132359580 RCX: dead000000000200
[  162.906825] RDX: 0000000000000000 RSI: 00000000e85efffd RDI: ffff880132359598
[  162.909863] RBP: ffffc90001e07ce0 R08: ffffffff815269c5 R09: 0000000000000004
[  162.912923] R10: ffffc90001e07ce0 R11: ffffffff840f2060 R12: ffff880134c6e000
[  162.915929] R13: ffff88013a014f00 R14: ffff880134c6e000 R15: ffff880132359580
[  162.918927] FS:  00007f6525b13740(0000) GS:ffff88013a680000(0000) knlGS:0000000000000000
[  162.922325] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  162.924751] CR2: 0000000000000000 CR3: 0000000134b2e006 CR4: 00000000000606e0
[  162.927236] Call Trace:
[  162.928153]  kernfs_kill_sb+0x2e/0x90
[  162.929377]  sysfs_kill_sb+0x22/0x40
[  162.930571]  deactivate_locked_super+0x50/0x90
[  162.931958]  kernfs_mount_ns+0x283/0x290
[  162.933126]  sysfs_mount+0x74/0xf0
[  162.934146]  mount_fs+0x46/0x1a0
[  162.935137]  vfs_kern_mount.part.28+0x67/0x190
[  162.936449]  do_mount+0x7b0/0x11f0
[  162.937473]  ? memdup_user+0x5e/0x90
[  162.938541]  ? copy_mount_options+0x1a4/0x2d0
[  162.939828]  ksys_mount+0xab/0x120
[  162.940954]  __x64_sys_mount+0x26/0x30
[  162.942153]  do_syscall_64+0x7b/0x260
[  162.943274]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  162.944903] RIP: 0033:0x7f6525640aaa
[  162.946012] RSP: 002b:00007ffc4f4e6f78 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
[  162.948291] RAX: ffffffffffffffda RBX: 000000000000000e RCX: 00007f6525640aaa
[  162.950396] RDX: 0000000000400896 RSI: 000000000040089c RDI: 0000000000400896
[  162.952480] RBP: 0000000000000003 R08: 0000000000000000 R09: 0000000000000002
[  162.954545] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000400694
[  162.957760] R13: 00007ffc4f4e7080 R14: 0000000000000000 R15: 0000000000000000
[  162.963839] Code: 00 00 55 48 8b 07 48 b9 00 01 00 00 00 00 ad de 48 8b 57 08 48 89 e5 48 39 c8 74 27 48 b9 00 02 00 00 00 00 ad de 48 39 ca 74 2c <48> 8b 32 48 39 fe 75 35 48 8b 50 08 48 39 f2 75 40 b8 01 00 00 
[  162.974795] RIP: __list_del_entry_valid+0x29/0x90 RSP: ffffc90001e07ce0
[  162.976752] CR2: 0000000000000000
----------

Below patch can avoid NULL pointer dereference at kernfs_kill_sb().

----------
diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index 26dd9a5..498c044 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -314,6 +314,7 @@ struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
 	if (!info)
 		return ERR_PTR(-ENOMEM);
 
+	INIT_LIST_HEAD(&info->node);
 	info->root = root;
 	info->ns = ns;
 
----------

But there remains a refcount bug because deactivate_locked_super() from
kernfs_mount_ns() triggers kobj_ns_drop() from sysfs_kill_sb() via
sb->kill_sb() when kobj_ns_drop() is always called by sysfs_mount()
if kernfs_mount_ns() returned an error.

----------
 static void *net_grab_current_ns(void)
 {
        struct net *ns = current->nsproxy->net_ns;
 #ifdef CONFIG_NET_NS
        if (ns)
                refcount_inc(&ns->passive);
        if (ns && !strcmp(current->comm, "a.out"))
                printk("net_grab_current_ns: %px %d %d\n", ns,
                       refcount_read(&ns->passive), refcount_read(&ns->count));
 #endif
        return ns;
 }

 void net_drop_ns(void *p)
 {
        struct net *ns = p;
        if (ns && !strcmp(current->comm, "a.out")) {
                printk("net_drop_ns: %px %d %d\n", ns,
                       refcount_read(&ns->passive), refcount_read(&ns->count));
                dump_stack();
        }
        if (ns && refcount_dec_and_test(&ns->passive))
                net_free(ns);
 }
----------

----------
Normal case
[   79.283244] net_grab_current_ns: ffff88012e570080 2 1
[   79.299881] net_drop_ns: ffff88012e570080 2 1
[   79.303463] CPU: 0 PID: 15294 Comm: a.out Kdump: loaded Tainted: G                T 4.17.0-rc3+ #527
[   79.310509] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[   79.316055] Call Trace:
[   79.317367]  dump_stack+0xe9/0x148
[   79.319154]  net_drop_ns+0xa1/0xb0
[   79.320903]  ? get_net_ns_by_id+0x170/0x170
[   79.323053]  kobj_ns_drop+0x61/0x70
[   79.324856]  sysfs_kill_sb+0x2f/0x40
[   79.326750]  deactivate_locked_super+0x50/0x90
[   79.329053]  deactivate_super+0x61/0x90
[   79.331032]  cleanup_mnt+0x49/0x90
[   79.332794]  __cleanup_mnt+0x16/0x20
[   79.334641]  task_work_run+0xb3/0xf0
[   79.336485]  exit_to_usermode_loop+0x152/0x160
[   79.338785]  do_syscall_64+0x237/0x260
[   79.340710]  entry_SYSCALL_64_after_hwframe+0x49/0xbe

[   79.357961] net_grab_current_ns: ffff88012e570080 2 1
[   79.360275] net_drop_ns: ffff88012e570080 2 1
[   79.362469] CPU: 0 PID: 15294 Comm: a.out Kdump: loaded Tainted: G                T 4.17.0-rc3+ #527
[   79.366436] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[   79.369596] Call Trace:
[   79.370363]  dump_stack+0xe9/0x148
[   79.371444]  net_drop_ns+0xa1/0xb0
[   79.372504]  ? get_net_ns_by_id+0x170/0x170
[   79.373836]  kobj_ns_drop+0x61/0x70
[   79.374912]  sysfs_mount+0xd2/0xf0
[   79.375976]  ? lockdep_init_map+0x9/0x10
[   79.377343]  mount_fs+0x46/0x1a0
[   79.378365]  vfs_kern_mount.part.28+0x67/0x190
[   79.379850]  do_mount+0x7b0/0x11f0
[   79.381001]  ? memdup_user+0x5e/0x90
[   79.382213]  ? copy_mount_options+0x1a4/0x2d0
[   79.383514]  ksys_mount+0xab/0x120
[   79.384544]  __x64_sys_mount+0x26/0x30
[   79.385761]  do_syscall_64+0x7b/0x260
[   79.386942]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
----------

----------
Error case
[   79.664326] net_grab_current_ns: ffff88012e570080 2 1
[   79.666073] net_drop_ns: ffff88012e570080 2 1
[   79.667504] CPU: 1 PID: 15294 Comm: a.out Kdump: loaded Tainted: G                T 4.17.0-rc3+ #527
[   79.670197] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[   79.673282] Call Trace:
[   79.674041]  dump_stack+0xe9/0x148
[   79.675064]  net_drop_ns+0xa1/0xb0
[   79.676085]  ? get_net_ns_by_id+0x170/0x170
[   79.677326]  kobj_ns_drop+0x61/0x70
[   79.678902]  sysfs_kill_sb+0x2f/0x40
[   79.680144]  deactivate_locked_super+0x50/0x90
[   79.681613]  kernfs_mount_ns+0x28f/0x2a0
[   79.682884]  sysfs_mount+0x74/0xf0
[   79.683906]  mount_fs+0x46/0x1a0
[   79.684879]  vfs_kern_mount.part.28+0x67/0x190
[   79.686193]  do_mount+0x7b0/0x11f0
[   79.687234]  ? memdup_user+0x5e/0x90
[   79.688305]  ? copy_mount_options+0x1a4/0x2d0
[   79.689592]  ksys_mount+0xab/0x120
[   79.690617]  __x64_sys_mount+0x26/0x30
[   79.691735]  do_syscall_64+0x7b/0x260
[   79.692833]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   79.694391] RIP: 0033:0x7fefaf3c4aaa
[   79.695744] RSP: 002b:00007ffe74af7fd8 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
[   79.698209] RAX: ffffffffffffffda RBX: 000000000000000e RCX: 00007fefaf3c4aaa
[   79.700386] RDX: 0000000000400896 RSI: 000000000040089c RDI: 0000000000400896
[   79.702472] RBP: 0000000000000003 R08: 0000000000000000 R09: 0000000000000002
[   79.704552] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000400694
[   79.706624] R13: 00007ffe74af80e0 R14: 0000000000000000 R15: 0000000000000000
[   79.708802] net_drop_ns: ffff88012e570080 1 1
[   79.710317] CPU: 1 PID: 15294 Comm: a.out Kdump: loaded Tainted: G                T 4.17.0-rc3+ #527
[   79.713255] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[   79.716704] Call Trace:
[   79.717463]  dump_stack+0xe9/0x148
[   79.718487]  net_drop_ns+0xa1/0xb0
[   79.719510]  ? get_net_ns_by_id+0x170/0x170
[   79.720771]  kobj_ns_drop+0x61/0x70
[   79.721818]  sysfs_mount+0xd2/0xf0
[   79.722840]  mount_fs+0x46/0x1a0
[   79.723815]  vfs_kern_mount.part.28+0x67/0x190
[   79.725178]  do_mount+0x7b0/0x11f0
[   79.726272]  ? memdup_user+0x5e/0x90
[   79.727361]  ? copy_mount_options+0x1a4/0x2d0
[   79.728811]  ksys_mount+0xab/0x120
[   79.730002]  __x64_sys_mount+0x26/0x30
[   79.731253]  do_syscall_64+0x7b/0x260
[   79.732477]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   79.734039] RIP: 0033:0x7fefaf3c4aaa
[   79.735136] RSP: 002b:00007ffe74af7fd8 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
[   79.737340] RAX: ffffffffffffffda RBX: 000000000000000e RCX: 00007fefaf3c4aaa
[   79.739427] RDX: 0000000000400896 RSI: 000000000040089c RDI: 0000000000400896
[   79.741576] RBP: 0000000000000003 R08: 0000000000000000 R09: 0000000000000002
[   79.743771] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000400694
[   79.746102] R13: 00007ffe74af80e0 R14: 0000000000000000 R15: 0000000000000000
[   79.748604] ------------[ cut here ]------------
[   79.750409] ODEBUG: free active (active state 0) object type: timer_list hint: can_stat_update+0x0/0x3b0
[   79.753308] WARNING: CPU: 1 PID: 15294 at lib/debugobjects.c:329 debug_print_object+0x6a/0x90
[   79.755786] Modules linked in:
[   79.756812] CPU: 1 PID: 15294 Comm: a.out Kdump: loaded Tainted: G                T 4.17.0-rc3+ #527
[   79.759725] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[   79.763120] RIP: 0010:debug_print_object+0x6a/0x90
[   79.764684] RSP: 0018:ffffc900070a3ca0 EFLAGS: 00010086
[   79.766384] RAX: 0000000000000000 RBX: ffff88012fabea00 RCX: ffffffff8126085e
[   79.768482] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff88013a6565b0
[   79.770537] RBP: ffffc900070a3cb8 R08: 0000000000000000 R09: 0000000000000001
[   79.772692] R10: ffffc900070a3c18 R11: ffff88012f350140 R12: ffffffff840c6e40
[   79.774883] R13: ffffffff83ca7711 R14: 0000000000000002 R15: ffff88012e5722c0
[   79.777012] FS:  00007fefaf897740(0000) GS:ffff88013a640000(0000) knlGS:0000000000000000
[   79.779762] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   79.779765] CR2: 00007f9542e78090 CR3: 000000012f336002 CR4: 00000000000606e0
[   79.779814] Call Trace:
[   79.779825]  debug_check_no_obj_freed+0x184/0x1ff
[   79.779831]  kmem_cache_free+0x228/0x280
[   79.779838]  net_drop_ns+0x74/0xb0
[   79.779845]  ? get_net_ns_by_id+0x170/0x170
[   79.790008]  kobj_ns_drop+0x61/0x70
[   79.791177]  sysfs_mount+0xd2/0xf0
[   79.792311]  mount_fs+0x46/0x1a0
[   79.793343]  vfs_kern_mount.part.28+0x67/0x190
[   79.794653]  do_mount+0x7b0/0x11f0
[   79.795796]  ? memdup_user+0x5e/0x90
[   79.796961]  ? copy_mount_options+0x1a4/0x2d0
[   79.798365]  ksys_mount+0xab/0x120
[   79.799502]  __x64_sys_mount+0x26/0x30
[   79.800780]  do_syscall_64+0x7b/0x260
[   79.801886]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
----------

Since sysfs_mount() is the only user who calls kernfs_mount_ns() with ns != NULL,
is it OK to do sysfs specific hack shown below? Or, should we avoid calling
deactivate_locked_super() when kernfs_fill_super() failed?

----------
diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index 26dd9a5..498c044 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -332,6 +333,9 @@ struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
 
 		error = kernfs_fill_super(sb, magic);
 		if (error) {
+			/* Avoid double kobj_ns_drop(KOBJ_NS_TYPE_NET, ns) */
+			if (ns)
+				kobj_ns_grab_current(KOBJ_NS_TYPE_NET);
 			deactivate_locked_super(sb);
 			return ERR_PTR(error);
 		}
----------
