Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F044F6B0003
	for <linux-mm@kvack.org>; Sun,  4 Mar 2018 00:57:18 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y20so7838260pfm.1
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 21:57:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m39-v6si7357942plg.151.2018.03.03.21.57.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 03 Mar 2018 21:57:17 -0800 (PST)
Subject: Re: WARNING: refcount bug in should_fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <001a113f6736499d1c0566363863@google.com>
In-Reply-To: <001a113f6736499d1c0566363863@google.com>
Message-Id: <201803041457.GBJ69774.OVOSOLFHQMJFFt@I-love.SAKURA.ne.jp>
Date: Sun, 4 Mar 2018 14:57:12 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, ebiederm@xmission.com
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

Switching from mm to fsdevel, for this report says that put_net(net) in
rpc_kill_sb() made net->count < 0 when mount_ns() failed due to
register_shrinker() failure.

Relevant commits will be
commit 9ee332d99e4d5a97 ("sget(): handle failures of register_shrinker()") and
commit d91ee87d8d85a080 ("vfs: Pass data, ns, and ns->userns to mount_ns.").

When sget_userns() in mount_ns() failed, mount_ns() returns an error code to
the caller without calling fill_super(). That is, get_net(sb->s_fs_info) was
not called by rpc_fill_super() (via fill_super callback passed to mount_ns())
but put_net(sb->s_fs_info) is called by rpc_kill_sb() (via fs->kill_sb() from
deactivate_locked_super()).

----------
static struct dentry *
rpc_mount(struct file_system_type *fs_type,
                int flags, const char *dev_name, void *data)
{
        struct net *net = current->nsproxy->net_ns;
        return mount_ns(fs_type, flags, data, net, net->user_ns, rpc_fill_super);
}
----------

syzbot wrote:
> Hello,
> 
> syzbot hit the following crash on bpf-next commit
> 6f1b5a2b58d8470e5a8b25ab29f5fdb4616ffff8 (Tue Feb 27 04:11:23 2018 +0000)
> Merge branch 'bpf-kselftest-improvements'
> 
> C reproducer is attached.
> syzkaller reproducer is attached.
> Raw console output is attached.
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+84371b6062cb639d797e@syzkaller.appspotmail.com
> It will help syzbot understand when the bug is fixed. See footer for  
> details.
> If you forward the report, please keep this part and the footer.
> 
> ------------[ cut here ]------------
> FAULT_INJECTION: forcing a failure.
> name failslab, interval 1, probability 0, space 0, times 0
> refcount_t: underflow; use-after-free.
> CPU: 1 PID: 4239 Comm: syzkaller149381 Not tainted 4.16.0-rc2+ #20
> WARNING: CPU: 0 PID: 4237 at lib/refcount.c:187  
> refcount_sub_and_test+0x167/0x1b0 lib/refcount.c:187
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> Google 01/01/2011
> Call Trace:
> Kernel panic - not syncing: panic_on_warn set ...
> 
>   __dump_stack lib/dump_stack.c:17 [inline]
>   dump_stack+0x194/0x24d lib/dump_stack.c:53
>   fail_dump lib/fault-inject.c:51 [inline]
>   should_fail+0x8c0/0xa40 lib/fault-inject.c:149
>   should_failslab+0xec/0x120 mm/failslab.c:32
>   slab_pre_alloc_hook mm/slab.h:422 [inline]
>   slab_alloc mm/slab.c:3365 [inline]
>   __do_kmalloc mm/slab.c:3703 [inline]
>   __kmalloc+0x63/0x760 mm/slab.c:3714
>   kmalloc include/linux/slab.h:517 [inline]
>   kzalloc include/linux/slab.h:701 [inline]
>   register_shrinker+0x10e/0x2d0 mm/vmscan.c:268
>   sget_userns+0xbbf/0xe40 fs/super.c:520
>   mount_ns+0x6d/0x190 fs/super.c:1029
>   rpc_mount+0x9e/0xd0 net/sunrpc/rpc_pipe.c:1451
>   mount_fs+0x66/0x2d0 fs/super.c:1222
>   vfs_kern_mount.part.26+0xc6/0x4a0 fs/namespace.c:1037
>   vfs_kern_mount fs/namespace.c:2509 [inline]
>   do_new_mount fs/namespace.c:2512 [inline]
>   do_mount+0xea4/0x2bb0 fs/namespace.c:2842
>   SYSC_mount fs/namespace.c:3058 [inline]
>   SyS_mount+0xab/0x120 fs/namespace.c:3035
>   do_syscall_64+0x280/0x940 arch/x86/entry/common.c:287
>   entry_SYSCALL_64_after_hwframe+0x42/0xb7
> RIP: 0033:0x4460f9
> RSP: 002b:00007fbcd769ad78 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
> RAX: ffffffffffffffda RBX: 00000000006dcc6c RCX: 00000000004460f9
> RDX: 0000000020000080 RSI: 0000000020000040 RDI: 0000000020000000
> RBP: 00007fbcd769ad80 R08: 00000000200000c0 R09: 0000000000003131
> R10: 0000000000000000 R11: 0000000000000246 R12: 00000000006dcc68
> R13: ffffffffffffffff R14: 0000000000000037 R15: 0030656c69662f2e
> CPU: 0 PID: 4237 Comm: syzkaller149381 Not tainted 4.16.0-rc2+ #20
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> Google 01/01/2011
> Call Trace:
>   __dump_stack lib/dump_stack.c:17 [inline]
>   dump_stack+0x194/0x24d lib/dump_stack.c:53
>   panic+0x1e4/0x41c kernel/panic.c:183
>   __warn+0x1dc/0x200 kernel/panic.c:547
>   report_bug+0x211/0x2d0 lib/bug.c:184
>   fixup_bug.part.11+0x37/0x80 arch/x86/kernel/traps.c:178
>   fixup_bug arch/x86/kernel/traps.c:247 [inline]
>   do_error_trap+0x2d7/0x3e0 arch/x86/kernel/traps.c:296
>   do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:315
>   invalid_op+0x58/0x80 arch/x86/entry/entry_64.S:957
> RIP: 0010:refcount_sub_and_test+0x167/0x1b0 lib/refcount.c:187
> RSP: 0018:ffff8801b164f6d8 EFLAGS: 00010286
> RAX: dffffc0000000008 RBX: 0000000000000000 RCX: ffffffff815ac30e
> RDX: 0000000000000000 RSI: 1ffff100362c9e8b RDI: 1ffff100362c9e60
> RBP: ffff8801b164f768 R08: 0000000000000000 R09: 0000000000000000
> R10: ffff8801b164f610 R11: 0000000000000000 R12: 1ffff100362c9edc
> R13: 00000000ffffffff R14: 0000000000000001 R15: ffff8801ae924044
>   refcount_dec_and_test+0x1a/0x20 lib/refcount.c:212
>   put_net include/net/net_namespace.h:220 [inline]
>   rpc_kill_sb+0x253/0x3c0 net/sunrpc/rpc_pipe.c:1473
>   deactivate_locked_super+0x88/0xd0 fs/super.c:312
>   sget_userns+0xbda/0xe40 fs/super.c:522
>   mount_ns+0x6d/0x190 fs/super.c:1029
>   rpc_mount+0x9e/0xd0 net/sunrpc/rpc_pipe.c:1451
>   mount_fs+0x66/0x2d0 fs/super.c:1222
>   vfs_kern_mount.part.26+0xc6/0x4a0 fs/namespace.c:1037
>   vfs_kern_mount fs/namespace.c:2509 [inline]
>   do_new_mount fs/namespace.c:2512 [inline]
>   do_mount+0xea4/0x2bb0 fs/namespace.c:2842
>   SYSC_mount fs/namespace.c:3058 [inline]
>   SyS_mount+0xab/0x120 fs/namespace.c:3035
>   do_syscall_64+0x280/0x940 arch/x86/entry/common.c:287
>   entry_SYSCALL_64_after_hwframe+0x42/0xb7
> RIP: 0033:0x4460f9
> RSP: 002b:00007fbcd76dcd78 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
> RAX: ffffffffffffffda RBX: 00000000006dcc3c RCX: 00000000004460f9
> RDX: 0000000020000080 RSI: 0000000020000040 RDI: 0000000020000000
> RBP: 00007fbcd76dcd80 R08: 00000000200000c0 R09: 0000000000003131
> R10: 0000000000000000 R11: 0000000000000246 R12: 00000000006dcc38
> R13: ffffffffffffffff R14: 0000000000000028 R15: 0030656c69662f2e
> Dumping ftrace buffer:
>     (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
> 
> 
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> 
> syzbot will keep track of this bug report.
> If you forgot to add the Reported-by tag, once the fix for this bug is  
> merged
> into any tree, please reply to this email with:
> #syz fix: exact-commit-title
> If you want to test a patch for this bug, please reply with:
> #syz test: git://repo/address.git branch
> and provide the patch inline or as an attachment.
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug  
> report.
> Note: all commands must start from beginning of the line in the email body.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
