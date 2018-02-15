Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92E536B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 22:40:53 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id j185so6742905lfe.13
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 19:40:53 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y6sor1550419lfj.60.2018.02.14.19.40.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 19:40:51 -0800 (PST)
Message-ID: <1518666047.6070.24.camel@gmail.com>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
From: mikhail <mikhail.v.gavrilov@gmail.com>
Date: Thu, 15 Feb 2018 08:40:47 +0500
In-Reply-To: <20180214215245.GI7000@dastard>
References: <20180131022209.lmhespbauhqtqrxg@destitution>
	 <1517888875.7303.3.camel@gmail.com>
	 <20180206060840.kj2u6jjmkuk3vie6@destitution>
	 <CABXGCsOgcYyj8Xukn7Pi_M2qz2aJ1MJZTaxaSgYno7f_BtZH6w@mail.gmail.com>
	 <1517974845.4352.8.camel@gmail.com>
	 <20180207065520.66f6gocvxlnxmkyv@destitution>
	 <1518255240.31843.6.camel@gmail.com> <1518255352.31843.8.camel@gmail.com>
	 <20180211225657.GA6778@dastard> <1518643669.6070.21.camel@gmail.com>
	 <20180214215245.GI7000@dastard>
Content-Type: multipart/alternative; boundary="=-6IVPYzB0djSDDYdaJ9WE"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


--=-6IVPYzB0djSDDYdaJ9WE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Thu, 2018-02-15 at 08:52 +1100, Dave Chinner wrote:
> On Thu, Feb 15, 2018 at 02:27:49AM +0500, mikhail wrote:
> > On Mon, 2018-02-12 at 09:56 +1100, Dave Chinner wrote:
> > > IOWs, this is not an XFS problem. It's exactly what I'd expect
> > > to see when you try to run a very IO intensive workload on a
> > > cheap SATA drive that can't keep up with what is being asked of
> > > it....
> > > 
> > 
> > I am understand that XFS is not culprit here. But I am worried
> > about of interface freezing and various kernel messages with
> > traces which leads to XFS. This is my only clue, and I do not know
> > where to dig yet.
> 
> I've already told you the problem: sustained storage subsystem
> overload. You can't "tune" you way around that. i.e. You need a
> faster disk subsystem to maintian the load you are putting on your
> system - either add more disks (e.g. RAID 0/5/6) or to move to SSDs.
> 

I know that you are bored already, but:- But it not a reason send false positive messages in log, because next time when a real problems will occurs I would ignore all messages.
- I am not believe that for mouse pointer moving needed disk throughput. Very wildly that mouse pointer freeze I never seen this on Windows even I then I create such workload. So it look like on real
blocking vital processes for GUI.

After receiving your message I got another lock message and it looking different:
[101309.501423] ======================================================[101309.501424] WARNING: possible circular locking dependency detected[101309.501425] 4.15.2-300.fc27.x86_64+debug #1 Not
tainted[101309.501426] ------------------------------------------------------[101309.501427] gnome-shell/1978 is trying to acquire lock:[101309.501428]  (sb_internal#2){.+.+}, at: [<00000000df1d676f>]
xfs_trans_alloc+0xe2/0x120 [xfs][101309.501465]                 but task is already holding lock:[101309.501466]  (fs_reclaim){+.+.}, at: [<000000002ed6959d>]
fs_reclaim_acquire.part.74+0x5/0x30[101309.501470]                 which lock already depends on the new lock.
[101309.501471]                 the existing dependency chain (in reverse order) is:[101309.501472]                 -> #1
(fs_reclaim){+.+.}:[101309.501476]        kmem_cache_alloc+0x29/0x2f0[101309.501496]        kmem_zone_alloc+0x61/0xe0 [xfs][101309.501513]        xfs_trans_alloc+0x67/0x120
[xfs][101309.501531]        xlog_recover_process_intents.isra.40+0x217/0x270 [xfs][101309.501550]        xlog_recover_finish+0x1f/0xb0 [xfs][101309.501573]        xfs_log_mount_finish+0x5b/0xe0
[xfs][101309.501597]        xfs_mountfs+0x62d/0xa30 [xfs][101309.501620]        xfs_fs_fill_super+0x49b/0x620
[xfs][101309.501623]        mount_bdev+0x17b/0x1b0[101309.501625]        mount_fs+0x35/0x150[101309.501628]        vfs_kern_mount.part.25+0x54/0x150[101309.501630]        do_mount+0x620/0xd60[101309.5
01633]        SyS_mount+0x80/0xd0[101309.501636]        do_syscall_64+0x7a/0x220[101309.501640]        entry_SYSCALL_64_after_hwframe+0x26/0x9b[101309.501641]                 -> #0
(sb_internal#2){.+.+}:[101309.501647]        __sb_start_write+0x125/0x1a0[101309.501662]        xfs_trans_alloc+0xe2/0x120 [xfs][101309.501678]        xfs_free_eofblocks+0x130/0x1f0
[xfs][101309.501693]        xfs_fs_destroy_inode+0xb6/0x2d0
[xfs][101309.501695]        dispose_list+0x51/0x80[101309.501697]        prune_icache_sb+0x52/0x70[101309.501699]        super_cache_scan+0x12a/0x1a0[101309.501700]        shrink_slab.part.48+0x202/0x
5a0[101309.501702]        shrink_node+0x123/0x300[101309.501703]        do_try_to_free_pages+0xca/0x350[101309.501705]        try_to_free_pages+0x140/0x350[101309.501707]        __alloc_pages_slowpath
+0x43c/0x1080[101309.501708]        __alloc_pages_nodemask+0x3af/0x440[101309.501711]        dma_generic_alloc_coherent+0x89/0x150[101309.501714]        x86_swiotlb_alloc_coherent+0x20/0x50[101309.501
718]        ttm_dma_pool_get_pages+0x21b/0x620 [ttm][101309.501720]        ttm_dma_populate+0x24d/0x340 [ttm][101309.501723]        ttm_tt_bind+0x29/0x60
[ttm][101309.501725]        ttm_bo_handle_move_mem+0x59a/0x5d0 [ttm][101309.501728]        ttm_bo_validate+0x1a2/0x1c0 [ttm][101309.501730]        ttm_bo_init_reserved+0x46b/0x520
[ttm][101309.501760]        amdgpu_bo_do_create+0x1b0/0x4f0 [amdgpu][101309.501776]        amdgpu_bo_create+0x50/0x2b0 [amdgpu][101309.501792]        amdgpu_gem_object_create+0x7f/0x110
[amdgpu][101309.501807]        amdgpu_gem_create_ioctl+0x1e8/0x280 [amdgpu][101309.501817]        drm_ioctl_kernel+0x5b/0xb0 [drm][101309.501822]        drm_ioctl+0x2d5/0x370
[drm][101309.501835]        amdgpu_drm_ioctl+0x49/0x80
[amdgpu][101309.501837]        do_vfs_ioctl+0xa5/0x6e0[101309.501838]        SyS_ioctl+0x74/0x80[101309.501840]        do_syscall_64+0x7a/0x220[101309.501841]        entry_SYSCALL_64_after_hwframe+0x2
6/0x9b[101309.501842]                 other info that might help us debug this:
[101309.501843]  Possible unsafe locking scenario:
[101309.501845]        CPU0                    CPU1[101309.501845]        ----                    --
--
[101309.501846]   lock(fs_reclaim);[101309.501847]                                lock(sb_internal#2);[101309.501849]                                lock(fs_reclaim);[101309.501850]   lock(sb_internal
#2);[101309.501852]                  *** DEADLOCK ***
[101309.501854] 4 locks held by gnome-shell/1978:[101309.501854]  #0:  (reservation_ww_class_mutex){+.+.}, at: [<0000000054425eb5>] ttm_bo_init_reserved+0x44d/0x520
[ttm][101309.501859]  #1:  (fs_reclaim){+.+.}, at: [<000000002ed6959d>] fs_reclaim_acquire.part.74+0x5/0x30[101309.501862]  #2:  (shrinker_rwsem){++++}, at: [<00000000e7c011bc>]
shrink_slab.part.48+0x5b/0x5a0[101309.501866]  #3:  (&type->s_umount_key#63){++++}, at: [<00000000192e0857>] trylock_super+0x16/0x50[101309.501870]                 stack backtrace:[101309.501872] CPU:
1 PID: 1978 Comm: gnome-shell Not tainted 4.15.2-300.fc27.x86_64+debug #1[101309.501873] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014[101309.501874] Call
Trace:[101309.501878]  dump_stack+0x85/0xbf[101309.501881]  print_circular_bug.isra.37+0x1ce/0x1db[101309.501883]  __lock_acquire+0x1299/0x1340[101309.501886]  ?
lock_acquire+0x9f/0x200[101309.501888]  lock_acquire+0x9f/0x200[101309.501906]  ? xfs_trans_alloc+0xe2/0x120 [xfs][101309.501908]  __sb_start_write+0x125/0x1a0[101309.501924]  ?
xfs_trans_alloc+0xe2/0x120 [xfs][101309.501939]  xfs_trans_alloc+0xe2/0x120 [xfs][101309.501956]  xfs_free_eofblocks+0x130/0x1f0 [xfs][101309.501972]  xfs_fs_destroy_inode+0xb6/0x2d0
[xfs][101309.501975]  dispose_list+0x51/0x80[101309.501977]  prune_icache_sb+0x52/0x70[101309.501979]  super_cache_scan+0x12a/0x1a0[101309.501981]  shrink_slab.part.48+0x202/0x5a0[101309.501984]  shri
nk_node+0x123/0x300[101309.501987]  do_try_to_free_pages+0xca/0x350[101309.501990]  try_to_free_pages+0x140/0x350[101309.501993]  __alloc_pages_slowpath+0x43c/0x1080[101309.501998]  __alloc_pages_node
mask+0x3af/0x440[101309.502001]  dma_generic_alloc_coherent+0x89/0x150[101309.502004]  x86_swiotlb_alloc_coherent+0x20/0x50[101309.502009]  ttm_dma_pool_get_pages+0x21b/0x620
[ttm][101309.502013]  ttm_dma_populate+0x24d/0x340 [ttm][101309.502017]  ttm_tt_bind+0x29/0x60 [ttm][101309.502021]  ttm_bo_handle_move_mem+0x59a/0x5d0
[ttm][101309.502025]  ttm_bo_validate+0x1a2/0x1c0 [ttm][101309.502029]  ? kmemleak_alloc_percpu+0x6d/0xd0[101309.502034]  ttm_bo_init_reserved+0x46b/0x520
[ttm][101309.502055]  amdgpu_bo_do_create+0x1b0/0x4f0 [amdgpu][101309.502076]  ? amdgpu_fill_buffer+0x310/0x310 [amdgpu][101309.502098]  amdgpu_bo_create+0x50/0x2b0
[amdgpu][101309.502120]  amdgpu_gem_object_create+0x7f/0x110 [amdgpu][101309.502136]  ? amdgpu_gem_object_close+0x210/0x210 [amdgpu][101309.502151]  amdgpu_gem_create_ioctl+0x1e8/0x280
[amdgpu][101309.502166]  ? amdgpu_gem_object_close+0x210/0x210 [amdgpu][101309.502172]  drm_ioctl_kernel+0x5b/0xb0 [drm][101309.502177]  drm_ioctl+0x2d5/0x370 [drm][101309.502191]  ?
amdgpu_gem_object_close+0x210/0x210 [amdgpu][101309.502194]  ? __pm_runtime_resume+0x54/0x90[101309.502196]  ? trace_hardirqs_on_caller+0xed/0x180[101309.502210]  amdgpu_drm_ioctl+0x49/0x80
[amdgpu][101309.502212]  do_vfs_ioctl+0xa5/0x6e0[101309.502214]  SyS_ioctl+0x74/0x80[101309.502216]  do_syscall_64+0x7a/0x220[101309.502218]  entry_SYSCALL_64_after_hwframe+0x26/0x9b[101309.502220]
RIP: 0033:0x7f51ddada8e7[101309.502221] RSP: 002b:00007ffd6c1855a8 EFLAGS: 00000246 ORIG_RAX: 0000000000000010[101309.502223] RAX: ffffffffffffffda RBX: 000056452ad39d50 RCX:
00007f51ddada8e7[101309.502224] RDX: 00007ffd6c1855f0 RSI: 00000000c0206440 RDI: 000000000000000c[101309.502225] RBP: 00007ffd6c1855f0 R08: 000056452ad39d50 R09: 0000000000000004[101309.502226] R10:
ffffffffffffffb0 R11: 0000000000000246 R12: 00000000c0206440[101309.502227] R13: 000000000000000c R14: 00007ffd6c185688 R15: 0000564535658220

Of course I am not ready for collect traces for such situations.
$ vmstat procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu----- r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st 2  0      0 2193440 298908
11193932    0    0    14  2511   13   18 25 12 61  2  0
$ free
-h              total        used        free      shared  buff/cache   availableMem:            30G         17G        2,1G        1,4G         10G         12GSwap:           59G          0B         
59G
--=-6IVPYzB0djSDDYdaJ9WE
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

<html><head></head><body><div>On Thu, 2018-02-15 at 08:52 +1100, Dave Chinn=
er wrote:</div><blockquote type=3D"cite" style=3D"margin:0 0 0 .8ex; border=
-left:2px #729fcf solid;padding-left:1ex"><pre>On Thu, Feb 15, 2018 at 02:2=
7:49AM +0500, mikhail wrote:
<blockquote type=3D"cite" style=3D"margin:0 0 0 .8ex; border-left:2px #729f=
cf solid;padding-left:1ex">
On Mon, 2018-02-12 at 09:56 +1100, Dave Chinner wrote:
<blockquote type=3D"cite" style=3D"margin:0 0 0 .8ex; border-left:2px #729f=
cf solid;padding-left:1ex">
IOWs, this is not an XFS problem. It's exactly what I'd expect
to see when you try to run a very IO intensive workload on a
cheap SATA drive that can't keep up with what is being asked of
it....

</blockquote>

I am understand that XFS is not culprit here. But I am worried
about of interface freezing and various kernel messages with
traces which leads to XFS. This is my only clue, and I do not know
where to dig yet.
</blockquote>

I've already told you the problem: sustained storage subsystem
overload. You can't "tune" you way around that. i.e. You need a
faster disk subsystem to maintian the load you are putting on your
system - either add more disks (e.g. RAID 0/5/6) or to move to SSDs.

</pre></blockquote><div><br></div><div><span style=3D"color: rgb(34, 34, 34=
); font-family: arial, sans-serif; font-size: small; font-variant-ligatures=
: normal; orphans: 2; white-space: normal; widows: 2;">I know that you are =
bored already, but:</span></div><div><span style=3D"color: rgb(34, 34, 34);=
 font-family: arial, sans-serif; font-size: small; font-variant-ligatures: =
normal; orphans: 2; white-space: normal; widows: 2;">- But it not a reason =
send false positive messages in log, because next time when a real problems=
 will occurs I would ignore all messages.</span><br style=3D"color: rgb(34,=
 34, 34); font-family: arial, sans-serif; font-size: small; font-variant-li=
gatures: normal; orphans: 2; white-space: normal; widows: 2;"><span style=
=3D"color: rgb(34, 34, 34); font-family: arial, sans-serif; font-size: smal=
l; font-variant-ligatures: normal; orphans: 2; white-space: normal; widows:=
 2;">- I am not believe that for mouse pointer moving needed disk throughpu=
t. Very wildly that mouse pointer freeze I never seen this on Windows even =
I then I create such workload. So it look like on real blocking vital proce=
sses for GUI.</span><br style=3D"color: rgb(34, 34, 34); font-family: arial=
, sans-serif; font-size: small; font-variant-ligatures: normal; orphans: 2;=
 white-space: normal; widows: 2;"><br style=3D"color: rgb(34, 34, 34); font=
-family: arial, sans-serif; font-size: small; font-variant-ligatures: norma=
l; orphans: 2; white-space: normal; widows: 2;"><span style=3D"color: rgb(3=
4, 34, 34); font-family: arial, sans-serif; font-size: small; font-variant-=
ligatures: normal; orphans: 2; white-space: normal; widows: 2;">After recei=
ving your message I got another lock message and it looking different:</spa=
n></div><div><br></div><div>[101309.501423] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</div><div>[101309=
.501424] WARNING: possible circular locking dependency detected</div><div>[=
101309.501425] 4.15.2-300.fc27.x86_64+debug #1 Not tainted</div><div>[10130=
9.501426] ------------------------------------------------------</div><div>=
[101309.501427] gnome-shell/1978 is trying to acquire lock:</div><div>[1013=
09.501428]&nbsp;&nbsp;(sb_internal#2){.+.+}, at: [&lt;00000000df1d676f&gt;]=
 xfs_trans_alloc+0xe2/0x120 [xfs]</div><div>[101309.501465]&nbsp;</div><div=
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;but task is already holding lock:</div><div>[101309.5=
01466]&nbsp;&nbsp;(fs_reclaim){+.+.}, at: [&lt;000000002ed6959d&gt;] fs_rec=
laim_acquire.part.74+0x5/0x30</div><div>[101309.501470]&nbsp;</div><div>&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;which lock already depends on the new lock.</div><div><br=
></div><div>[101309.501471]&nbsp;</div><div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;the existi=
ng dependency chain (in reverse order) is:</div><div>[101309.501472]&nbsp;<=
/div><div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt; #1 (fs_reclaim){+.+.}:</div><div>[1013=
09.501476]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kmem_cache_alloc+=
0x29/0x2f0</div><div>[101309.501496]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;kmem_zone_alloc+0x61/0xe0 [xfs]</div><div>[101309.501513]&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xfs_trans_alloc+0x67/0x120 [xfs]</di=
v><div>[101309.501531]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xlog_=
recover_process_intents.isra.40+0x217/0x270 [xfs]</div><div>[101309.501550]=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xlog_recover_finish+0x1f/0x=
b0 [xfs]</div><div>[101309.501573]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;xfs_log_mount_finish+0x5b/0xe0 [xfs]</div><div>[101309.501597]&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xfs_mountfs+0x62d/0xa30 [xfs]</di=
v><div>[101309.501620]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xfs_f=
s_fill_super+0x49b/0x620 [xfs]</div><div>[101309.501623]&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mount_bdev+0x17b/0x1b0</div><div>[101309.50162=
5]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mount_fs+0x35/0x150</div>=
<div>[101309.501628]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;vfs_ker=
n_mount.part.25+0x54/0x150</div><div>[101309.501630]&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;do_mount+0x620/0xd60</div><div>[101309.501633]&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SyS_mount+0x80/0xd0</div><div>[=
101309.501636]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;do_syscall_64=
+0x7a/0x220</div><div>[101309.501640]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;entry_SYSCALL_64_after_hwframe+0x26/0x9b</div><div>[101309.501641=
]&nbsp;</div><div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt; #0 (sb_internal#2){.+.+}:</div=
><div>[101309.501647]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__sb_s=
tart_write+0x125/0x1a0</div><div>[101309.501662]&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;xfs_trans_alloc+0xe2/0x120 [xfs]</div><div>[101309.501=
678]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xfs_free_eofblocks+0x13=
0/0x1f0 [xfs]</div><div>[101309.501693]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;xfs_fs_destroy_inode+0xb6/0x2d0 [xfs]</div><div>[101309.501695]=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dispose_list+0x51/0x80</div=
><div>[101309.501697]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;prune_=
icache_sb+0x52/0x70</div><div>[101309.501699]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;super_cache_scan+0x12a/0x1a0</div><div>[101309.501700]&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;shrink_slab.part.48+0x202/0x5a=
0</div><div>[101309.501702]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
shrink_node+0x123/0x300</div><div>[101309.501703]&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;do_try_to_free_pages+0xca/0x350</div><div>[101309.501=
705]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;try_to_free_pages+0x140=
/0x350</div><div>[101309.501707]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;__alloc_pages_slowpath+0x43c/0x1080</div><div>[101309.501708]&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__alloc_pages_nodemask+0x3af/0x440</=
div><div>[101309.501711]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dma=
_generic_alloc_coherent+0x89/0x150</div><div>[101309.501714]&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;x86_swiotlb_alloc_coherent+0x20/0x50</div>=
<div>[101309.501718]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ttm_dma=
_pool_get_pages+0x21b/0x620 [ttm]</div><div>[101309.501720]&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ttm_dma_populate+0x24d/0x340 [ttm]</div><di=
v>[101309.501723]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ttm_tt_bin=
d+0x29/0x60 [ttm]</div><div>[101309.501725]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;ttm_bo_handle_move_mem+0x59a/0x5d0 [ttm]</div><div>[101309.=
501728]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ttm_bo_validate+0x1a=
2/0x1c0 [ttm]</div><div>[101309.501730]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;ttm_bo_init_reserved+0x46b/0x520 [ttm]</div><div>[101309.501760=
]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;amdgpu_bo_do_create+0x1b0/=
0x4f0 [amdgpu]</div><div>[101309.501776]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;amdgpu_bo_create+0x50/0x2b0 [amdgpu]</div><div>[101309.501792]=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;amdgpu_gem_object_create+0x=
7f/0x110 [amdgpu]</div><div>[101309.501807]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;amdgpu_gem_create_ioctl+0x1e8/0x280 [amdgpu]</div><div>[101=
309.501817]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;drm_ioctl_kernel=
+0x5b/0xb0 [drm]</div><div>[101309.501822]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;drm_ioctl+0x2d5/0x370 [drm]</div><div>[101309.501835]&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;amdgpu_drm_ioctl+0x49/0x80 [amdgpu=
]</div><div>[101309.501837]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
do_vfs_ioctl+0xa5/0x6e0</div><div>[101309.501838]&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;SyS_ioctl+0x74/0x80</div><div>[101309.501840]&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;do_syscall_64+0x7a/0x220</div><div>=
[101309.501841]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;entry_SYSCAL=
L_64_after_hwframe+0x26/0x9b</div><div>[101309.501842]&nbsp;</div><div>&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;other info that might help us debug this:</div><div><br></=
div><div>[101309.501843]&nbsp;&nbsp;Possible unsafe locking scenario:</div>=
<div><br></div><div>[101309.501845]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;CPU0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CPU1</div><div>[10=
1309.501845]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;----&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;----</div><div>[101309.501846]&nbsp;&nbsp=
;&nbsp;lock(fs_reclaim);</div><div>[101309.501847]&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;lock(sb_internal#2);</div><div>[101309.501849]&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;lock(fs_reclaim);</div><div>[101309.501850]&n=
bsp;&nbsp;&nbsp;lock(sb_internal#2);</div><div>[101309.501852]&nbsp;</div><=
div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*** DEADLOCK ***</div><div><br></div><div>[1=
01309.501854] 4 locks held by gnome-shell/1978:</div><div>[101309.501854]&n=
bsp;&nbsp;#0:&nbsp;&nbsp;(reservation_ww_class_mutex){+.+.}, at: [&lt;00000=
00054425eb5&gt;] ttm_bo_init_reserved+0x44d/0x520 [ttm]</div><div>[101309.5=
01859]&nbsp;&nbsp;#1:&nbsp;&nbsp;(fs_reclaim){+.+.}, at: [&lt;000000002ed69=
59d&gt;] fs_reclaim_acquire.part.74+0x5/0x30</div><div>[101309.501862]&nbsp=
;&nbsp;#2:&nbsp;&nbsp;(shrinker_rwsem){++++}, at: [&lt;00000000e7c011bc&gt;=
] shrink_slab.part.48+0x5b/0x5a0</div><div>[101309.501866]&nbsp;&nbsp;#3:&n=
bsp;&nbsp;(&amp;type-&gt;s_umount_key#63){++++}, at: [&lt;00000000192e0857&=
gt;] trylock_super+0x16/0x50</div><div>[101309.501870]&nbsp;</div><div>&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;stack backtrace:</div><div>[101309.501872] CPU: 1 PID: 197=
8 Comm: gnome-shell Not tainted 4.15.2-300.fc27.x86_64+debug #1</div><div>[=
101309.501873] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D=
3H, BIOS F11 08/12/2014</div><div>[101309.501874] Call Trace:</div><div>[10=
1309.501878]&nbsp;&nbsp;dump_stack+0x85/0xbf</div><div>[101309.501881]&nbsp=
;&nbsp;print_circular_bug.isra.37+0x1ce/0x1db</div><div>[101309.501883]&nbs=
p;&nbsp;__lock_acquire+0x1299/0x1340</div><div>[101309.501886]&nbsp;&nbsp;?=
 lock_acquire+0x9f/0x200</div><div>[101309.501888]&nbsp;&nbsp;lock_acquire+=
0x9f/0x200</div><div>[101309.501906]&nbsp;&nbsp;? xfs_trans_alloc+0xe2/0x12=
0 [xfs]</div><div>[101309.501908]&nbsp;&nbsp;__sb_start_write+0x125/0x1a0</=
div><div>[101309.501924]&nbsp;&nbsp;? xfs_trans_alloc+0xe2/0x120 [xfs]</div=
><div>[101309.501939]&nbsp;&nbsp;xfs_trans_alloc+0xe2/0x120 [xfs]</div><div=
>[101309.501956]&nbsp;&nbsp;xfs_free_eofblocks+0x130/0x1f0 [xfs]</div><div>=
[101309.501972]&nbsp;&nbsp;xfs_fs_destroy_inode+0xb6/0x2d0 [xfs]</div><div>=
[101309.501975]&nbsp;&nbsp;dispose_list+0x51/0x80</div><div>[101309.501977]=
&nbsp;&nbsp;prune_icache_sb+0x52/0x70</div><div>[101309.501979]&nbsp;&nbsp;=
super_cache_scan+0x12a/0x1a0</div><div>[101309.501981]&nbsp;&nbsp;shrink_sl=
ab.part.48+0x202/0x5a0</div><div>[101309.501984]&nbsp;&nbsp;shrink_node+0x1=
23/0x300</div><div>[101309.501987]&nbsp;&nbsp;do_try_to_free_pages+0xca/0x3=
50</div><div>[101309.501990]&nbsp;&nbsp;try_to_free_pages+0x140/0x350</div>=
<div>[101309.501993]&nbsp;&nbsp;__alloc_pages_slowpath+0x43c/0x1080</div><d=
iv>[101309.501998]&nbsp;&nbsp;__alloc_pages_nodemask+0x3af/0x440</div><div>=
[101309.502001]&nbsp;&nbsp;dma_generic_alloc_coherent+0x89/0x150</div><div>=
[101309.502004]&nbsp;&nbsp;x86_swiotlb_alloc_coherent+0x20/0x50</div><div>[=
101309.502009]&nbsp;&nbsp;ttm_dma_pool_get_pages+0x21b/0x620 [ttm]</div><di=
v>[101309.502013]&nbsp;&nbsp;ttm_dma_populate+0x24d/0x340 [ttm]</div><div>[=
101309.502017]&nbsp;&nbsp;ttm_tt_bind+0x29/0x60 [ttm]</div><div>[101309.502=
021]&nbsp;&nbsp;ttm_bo_handle_move_mem+0x59a/0x5d0 [ttm]</div><div>[101309.=
502025]&nbsp;&nbsp;ttm_bo_validate+0x1a2/0x1c0 [ttm]</div><div>[101309.5020=
29]&nbsp;&nbsp;? kmemleak_alloc_percpu+0x6d/0xd0</div><div>[101309.502034]&=
nbsp;&nbsp;ttm_bo_init_reserved+0x46b/0x520 [ttm]</div><div>[101309.502055]=
&nbsp;&nbsp;amdgpu_bo_do_create+0x1b0/0x4f0 [amdgpu]</div><div>[101309.5020=
76]&nbsp;&nbsp;? amdgpu_fill_buffer+0x310/0x310 [amdgpu]</div><div>[101309.=
502098]&nbsp;&nbsp;amdgpu_bo_create+0x50/0x2b0 [amdgpu]</div><div>[101309.5=
02120]&nbsp;&nbsp;amdgpu_gem_object_create+0x7f/0x110 [amdgpu]</div><div>[1=
01309.502136]&nbsp;&nbsp;? amdgpu_gem_object_close+0x210/0x210 [amdgpu]</di=
v><div>[101309.502151]&nbsp;&nbsp;amdgpu_gem_create_ioctl+0x1e8/0x280 [amdg=
pu]</div><div>[101309.502166]&nbsp;&nbsp;? amdgpu_gem_object_close+0x210/0x=
210 [amdgpu]</div><div>[101309.502172]&nbsp;&nbsp;drm_ioctl_kernel+0x5b/0xb=
0 [drm]</div><div>[101309.502177]&nbsp;&nbsp;drm_ioctl+0x2d5/0x370 [drm]</d=
iv><div>[101309.502191]&nbsp;&nbsp;? amdgpu_gem_object_close+0x210/0x210 [a=
mdgpu]</div><div>[101309.502194]&nbsp;&nbsp;? __pm_runtime_resume+0x54/0x90=
</div><div>[101309.502196]&nbsp;&nbsp;? trace_hardirqs_on_caller+0xed/0x180=
</div><div>[101309.502210]&nbsp;&nbsp;amdgpu_drm_ioctl+0x49/0x80 [amdgpu]</=
div><div>[101309.502212]&nbsp;&nbsp;do_vfs_ioctl+0xa5/0x6e0</div><div>[1013=
09.502214]&nbsp;&nbsp;SyS_ioctl+0x74/0x80</div><div>[101309.502216]&nbsp;&n=
bsp;do_syscall_64+0x7a/0x220</div><div>[101309.502218]&nbsp;&nbsp;entry_SYS=
CALL_64_after_hwframe+0x26/0x9b</div><div>[101309.502220] RIP: 0033:0x7f51d=
dada8e7</div><div>[101309.502221] RSP: 002b:00007ffd6c1855a8 EFLAGS: 000002=
46 ORIG_RAX: 0000000000000010</div><div>[101309.502223] RAX: ffffffffffffff=
da RBX: 000056452ad39d50 RCX: 00007f51ddada8e7</div><div>[101309.502224] RD=
X: 00007ffd6c1855f0 RSI: 00000000c0206440 RDI: 000000000000000c</div><div>[=
101309.502225] RBP: 00007ffd6c1855f0 R08: 000056452ad39d50 R09: 00000000000=
00004</div><div>[101309.502226] R10: ffffffffffffffb0 R11: 0000000000000246=
 R12: 00000000c0206440</div><div>[101309.502227] R13: 000000000000000c R14:=
 00007ffd6c185688 R15: 0000564535658220</div><div><br></div><div><br></div>=
<div><span style=3D"color: rgb(34, 34, 34); font-family: arial, sans-serif;=
 font-size: small; font-variant-ligatures: normal; orphans: 2; white-space:=
 normal; widows: 2;">Of course I am not ready for collect traces for such s=
ituations.</span></div><div><span style=3D"color: rgb(34, 34, 34); font-fam=
ily: arial, sans-serif; font-size: small; font-variant-ligatures: normal; o=
rphans: 2; white-space: normal; widows: 2;"><br></span></div><div>$ vmstat&=
nbsp;</div><div>procs -----------memory---------- ---swap-- -----io---- -sy=
stem-- ------cpu-----</div><div>&nbsp;r&nbsp;&nbsp;b&nbsp;&nbsp;&nbsp;swpd&=
nbsp;&nbsp;&nbsp;free&nbsp;&nbsp;&nbsp;buff&nbsp;&nbsp;cache&nbsp;&nbsp;&nb=
sp;si&nbsp;&nbsp;&nbsp;so&nbsp;&nbsp;&nbsp;&nbsp;bi&nbsp;&nbsp;&nbsp;&nbsp;=
bo&nbsp;&nbsp;&nbsp;in&nbsp;&nbsp;&nbsp;cs us sy id wa st</div><div>&nbsp;2=
&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0 2193440 298908 11193932&=
nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;14=
&nbsp;&nbsp;2511&nbsp;&nbsp;&nbsp;13&nbsp;&nbsp;&nbsp;18 25 12 61&nbsp;&nbs=
p;2&nbsp;&nbsp;0</div><div><br></div><div>$ free -h</div><div>&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tota=
l&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;used&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;free&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;shared&nb=
sp;&nbsp;buff/cache&nbsp;&nbsp;&nbsp;available</div><div>Mem:&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;30G&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;17G&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;2,1G&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1,4G&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;10G&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;12G</div><div>Swap:&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;59G&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0B&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;59G</div><div></div></body></html>
--=-6IVPYzB0djSDDYdaJ9WE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
