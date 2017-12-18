Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A6D146B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:55:17 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 194so7157566wmv.9
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 01:55:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p17si10065630wrp.296.2017.12.18.01.55.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 01:55:15 -0800 (PST)
Date: Mon, 18 Dec 2017 10:55:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: general protection fault in __list_del_entry_valid (2)
Message-ID: <20171218095508.GM16951@dhcp22.suse.cz>
References: <001a113f996099503a055e793dd3@google.com>
 <001a1140f57806ebef05608b25a5@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a1140f57806ebef05608b25a5@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+065a25551da6c9ab4283b7ae889c707a37ab2de3@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, david@fromorbit.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, minchan@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, shli@fb.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

On Sun 17-12-17 07:47:01, syzbot wrote:
> syzkaller has found reproducer for the following crash on
> 82bcf1def3b5f1251177ad47c44f7e17af039b4b
> git://git.cmpxchg.org/linux-mmots.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers

This is an unhandled register_shrinker failure in sget_userns (thiggered
by the allocation fault injection).
There has been a fix proposed http://lkml.kernel.org/r/20171123145540.GB21978@ZenIV.linux.org.uk
(this one depends on http://lkml.kernel.org/r/1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
or http://lkml.kernel.org/r/20171216192937.13549-1-akaraliou.dev@gmail.com).
 
> R13: 0000000000403940 R14: 0000000000000000 R15: 0000000000000000
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 1 PID: 3146 Comm: syzkaller259864 Not tainted 4.15.0-rc2-mm1+ #39
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:__list_del_entry_valid+0x7e/0x150 lib/list_debug.c:51
> RSP: 0018:ffff8801c4d97b48 EFLAGS: 00010246
> RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffff8801c4ac75d8 RDI: ffff8801c4ac75e0
> RBP: ffff8801c4d97b60 R08: ffff8801c4d975c0 R09: ffff8801c5bd2180
> R10: 000000000000000b R11: ffffed00389b2eba R12: 0000000000000000
> R13: dffffc0000000000 R14: 1ffff100389b2f8d R15: ffff8801c4ac75d8
> FS:  0000000001689940(0000) GS:ffff8801db300000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000207caf71 CR3: 00000001c5f99002 CR4: 00000000001606e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  __list_del_entry include/linux/list.h:117 [inline]
>  list_del include/linux/list.h:125 [inline]
>  unregister_shrinker+0x79/0x300 mm/vmscan.c:285
>  deactivate_locked_super+0x64/0xd0 fs/super.c:311
>  deactivate_super+0x141/0x1b0 fs/super.c:343
>  cleanup_mnt+0xb2/0x150 fs/namespace.c:1173
>  __cleanup_mnt+0x16/0x20 fs/namespace.c:1180
>  task_work_run+0x199/0x270 kernel/task_work.c:113
>  tracehook_notify_resume include/linux/tracehook.h:191 [inline]
>  exit_to_usermode_loop+0x275/0x2f0 arch/x86/entry/common.c:165
>  prepare_exit_to_usermode arch/x86/entry/common.c:195 [inline]
>  syscall_return_slowpath+0x490/0x550 arch/x86/entry/common.c:264
>  entry_SYSCALL_64_fastpath+0x94/0x96
> RIP: 0033:0x446679
> RSP: 002b:00007ffccb258058 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
> RAX: ffffffffffffffec RBX: 00007ffccb258000 RCX: 0000000000446679
> RDX: 0000000020f9effa RSI: 00000000202b9000 RDI: 0000000020b85ff8
> RBP: 0000000000000003 R08: 00000000207caf71 R09: 0000000000003531
> R10: 0000000000000000 R11: 0000000000000246 R12: ffffffffffffffff
> R13: 0000000000000006 R14: 0000000000000000 R15: 0000000000000000
> Code: 00 00 00 00 ad de 49 39 c4 74 66 48 b8 00 02 00 00 00 00 ad de 48 89
> da 48 39 c3 74 65 48 c1 ea 03 48 b8 00 00 00 00 00 fc ff df <80> 3c 02 00 75
> 7b 48 8b 13 48 39 f2 75 57 49 8d 7c 24 08 48 b8
> RIP: __list_del_entry_valid+0x7e/0x150 lib/list_debug.c:51 RSP:
> ffff8801c4d97b48
> ---[ end trace 422dd7d3477fece7 ]---
> Kernel panic - not syncing: Fatal exception
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
