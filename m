Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 805E46B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 23:33:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z20so3884358pfn.11
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 20:33:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d188sor1208197pgc.387.2018.04.19.20.33.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 20:33:42 -0700 (PDT)
Date: Thu, 19 Apr 2018 20:34:50 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: general protection fault in kernfs_kill_sb
Message-ID: <20180420033450.GC686@sol.localdomain>
References: <94eb2c0546040ebb4d0568cc6bdb@google.com>
 <821c80d2-0b55-287a-09aa-d004f4ac4215@I-love.SAKURA.ne.jp>
 <20180402143415.GC30522@ZenIV.linux.org.uk>
 <20180420024440.GB686@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420024440.GB686@sol.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+151de3f2be6b40ac8026@syzkaller.appspotmail.com>, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-fsdevel@vger.kernel.org

On Thu, Apr 19, 2018 at 07:44:40PM -0700, Eric Biggers wrote:
> On Mon, Apr 02, 2018 at 03:34:15PM +0100, Al Viro wrote:
> > On Mon, Apr 02, 2018 at 07:40:22PM +0900, Tetsuo Handa wrote:
> > 
> > > That commit assumes that calling kill_sb() from deactivate_locked_super(s)
> > > without corresponding fill_super() is safe. We have so far crashed with
> > > rpc_mount() and kernfs_mount_ns(). Is that really safe?
> > 
> > 	Consider the case when fill_super() returns an error immediately.
> > It is exactly the same situation.  And ->kill_sb() *is* called in cases
> > when fill_super() has failed.  Always had been - it's much less boilerplate
> > that way.
> > 
> > 	deactivate_locked_super() on that failure exit is the least painful
> > variant, unfortunately.
> > 
> > 	Filesystems with ->kill_sb() instances that rely upon something
> > done between sget() and the first failure exit after it need to be fixed.
> > And yes, that should've been spotted back then.  Sorry.
> > 
> > Fortunately, we don't have many of those - kill_{block,litter,anon}_super()
> > are safe and those are the majority.  Looking through the rest uncovers
> > some bugs; so far all I've seen were already there.  Note that normally
> > we have something like
> > static void affs_kill_sb(struct super_block *sb)
> > {
> >         struct affs_sb_info *sbi = AFFS_SB(sb);
> >         kill_block_super(sb);
> >         if (sbi) {
> >                 affs_free_bitmap(sb);
> >                 affs_brelse(sbi->s_root_bh);
> >                 kfree(sbi->s_prefix);
> >                 mutex_destroy(&sbi->s_bmlock);
> >                 kfree(sbi);
> >         }
> > }
> > which basically does one of the safe ones augmented with something that
> > takes care *not* to assume that e.g. ->s_fs_info has been allocated.
> > Not everyone does, though:
> > 
> > jffs2_fill_super():
> >         c = kzalloc(sizeof(*c), GFP_KERNEL);
> >         if (!c)
> >                 return -ENOMEM;
> > in the very beginning.  So we can return from it with NULL ->s_fs_info.
> > Now, consider
> >         struct jffs2_sb_info *c = JFFS2_SB_INFO(sb);
> >         if (!(sb->s_flags & MS_RDONLY))
> >                 jffs2_stop_garbage_collect_thread(c);
> > in jffs2_kill_sb() and
> > void jffs2_stop_garbage_collect_thread(struct jffs2_sb_info *c)
> > {
> >         int wait = 0;
> >         spin_lock(&c->erase_completion_lock);
> >         if (c->gc_task) {
> > 
> > IOW, fail that kzalloc() (or, indeed, an allocation in register_shrinker())
> > and eat an oops.  Always had been there, always hard to hit without
> > fault injectors and fortunately trivial to fix.
> > 
> > Similar in nfs_kill_super() calling nfs_free_server().
> > Similar in v9fs_kill_super() with v9fs_session_cancel()/v9fs_session_close() calls.
> > Similar in hypfs_kill_super(), afs_kill_super(), btrfs_kill_super(), cifs_kill_sb()
> > (all trivial to fix)
> > 
> > Aha... nfsd_umount() is a new regression.
> > 
> > orangefs: old, trivial to fix.
> > 
> > cgroup_kill_sb(): old, hopefully easy to fix.  Note that kernfs_root_from_sb()
> > can bloody well return NULL, making cgroup_root_from_kf() oops.  Always had been
> > there.
> > 
> > AFAICS, after discarding the instances that do the right thing we are left with:
> > hypfs_kill_super, rdt_kill_sb, v9fs_kill_super, afs_kill_super, btrfs_kill_super,
> > cifs_kill_sb, jffs2_kill_sb, nfs_kill_super, nfsd_umount, orangefs_kill_sb,
> > proc_kill_sb, sysfs_kill_sb, cgroup_kill_sb, rpc_kill_sb.
> > 
> > Out of those, nfsd_umount(), proc_kill_sb() and rpc_kill_sb() are regressions.
> > So are rdt_kill_sb() and sysfs_kill_sb() (victims of the issue you've spotted
> > in kernfs_kill_sb()).  The rest are old (and I wonder if syzbot had been
> > catching those - they are also dependent upon a specific allocation failing
> > at the right time).
> > 
> 
> Fix for the kernfs bug is now queued in vfs/for-linus:
> 
> #syz fix: kernfs: deal with early sget() failures
> 

But, there is still a related bug: when mounting sysfs, if register_shrinker()
fails in sget_userns(), then kernfs_kill_sb() gets called, which frees the
'struct kernfs_super_info'.  But, the 'struct kernfs_super_info' is also freed
in kernfs_mount_ns() by:

        sb = sget_userns(fs_type, kernfs_test_super, kernfs_set_super, flags,
                         &init_user_ns, info);
        if (IS_ERR(sb) || sb->s_fs_info != info)
                kfree(info);
        if (IS_ERR(sb))
                return ERR_CAST(sb);

I guess the problem is that sget_userns() shouldn't take ownership of the 'info'
if it returns an error -- but, it actually does if register_shrinker() fails,
resulting in a double free.

Here is a reproducer and the KASAN splat.  This is on Linus' tree (87ef12027b9b)
with vfs/for-linus merged in.

#define _GNU_SOURCE
#include <fcntl.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <unistd.h>

int main()
{
        int fd, i;
        char buf[16];

        unshare(CLONE_NEWNET);
        system("echo N > /sys/kernel/debug/failslab/ignore-gfp-wait");
        system("echo 0 | tee /sys/kernel/debug/fail*/verbose");
        fd = open("/proc/thread-self/fail-nth", O_WRONLY);
        for (i = 0; ; i++) {
                write(fd, buf, sprintf(buf, "%d", i));
                mount("sysfs", "mnt", "sysfs", 0, NULL);
                umount("mnt");
        }
}

==================================================================
BUG: KASAN: double-free or invalid-free in kernfs_mount_ns+0x5eb/0x7d0 fs/kernfs/mount.c:324

CPU: 12 PID: 268 Comm: syz_kernfs Not tainted 4.17.0-rc1-00038-gb25f027a33d42 #45
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-20171110_100015-anatol 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0x7c/0xbb lib/dump_stack.c:113
 print_address_description+0x73/0x290 mm/kasan/report.c:256
 kasan_report_invalid_free+0x60/0xa0 mm/kasan/report.c:336
 __kasan_slab_free+0x1d5/0x220 mm/kasan/kasan.c:501
 __cache_free mm/slab.c:3498 [inline]
 kfree+0x8a/0xd0 mm/slab.c:3813
 kernfs_mount_ns+0x5eb/0x7d0 fs/kernfs/mount.c:324
 sysfs_mount+0xa2/0x170 fs/sysfs/mount.c:36
 mount_fs+0x38/0x1b0 fs/super.c:1268
 vfs_kern_mount.part.10+0x53/0x3a0 fs/namespace.c:1037
 vfs_kern_mount fs/namespace.c:2514 [inline]
 do_new_mount fs/namespace.c:2517 [inline]
 do_mount+0x35c/0x2560 fs/namespace.c:2847
 ksys_mount+0x7b/0xd0 fs/namespace.c:3063
 __do_sys_mount fs/namespace.c:3077 [inline]
 __se_sys_mount fs/namespace.c:3074 [inline]
 __x64_sys_mount+0xb5/0x150 fs/namespace.c:3074
 do_syscall_64+0x90/0x3f0 arch/x86/entry/common.c:287
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x7febbf5877ea
RSP: 002b:00007ffee25976a8 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 0000560d99d26af4 RCX: 00007febbf5877ea
RDX: 0000560d99d26aee RSI: 0000560d99d26af4 RDI: 0000560d99d26aee
RBP: 0000560d99d26aee R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffee25976b0
R13: 0000560d99d26aeb R14: 0000000000000003 R15: 000000000000000c

Allocated by task 268:
 kmem_cache_alloc_trace include/linux/slab.h:415 [inline]
 kmalloc include/linux/slab.h:512 [inline]
 kzalloc include/linux/slab.h:701 [inline]
 kernfs_mount_ns+0x71/0x7d0 fs/kernfs/mount.c:313
 sysfs_mount+0xa2/0x170 fs/sysfs/mount.c:36
 mount_fs+0x38/0x1b0 fs/super.c:1268
 vfs_kern_mount.part.10+0x53/0x3a0 fs/namespace.c:1037
 vfs_kern_mount fs/namespace.c:2514 [inline]
 do_new_mount fs/namespace.c:2517 [inline]
 do_mount+0x35c/0x2560 fs/namespace.c:2847
 ksys_mount+0x7b/0xd0 fs/namespace.c:3063
 __do_sys_mount fs/namespace.c:3077 [inline]
 __se_sys_mount fs/namespace.c:3074 [inline]
 __x64_sys_mount+0xb5/0x150 fs/namespace.c:3074
 do_syscall_64+0x90/0x3f0 arch/x86/entry/common.c:287
 entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 268:
 __cache_free mm/slab.c:3498 [inline]
 kfree+0x8a/0xd0 mm/slab.c:3813
 sysfs_kill_sb+0x15/0x30 fs/sysfs/mount.c:50
 deactivate_locked_super+0x80/0xc0 fs/super.c:313
 sget_userns+0x90c/0xb50 fs/super.c:523
 kernfs_mount_ns+0x134/0x7d0 fs/kernfs/mount.c:321
 sysfs_mount+0xa2/0x170 fs/sysfs/mount.c:36
 mount_fs+0x38/0x1b0 fs/super.c:1268
 vfs_kern_mount.part.10+0x53/0x3a0 fs/namespace.c:1037
 vfs_kern_mount fs/namespace.c:2514 [inline]
 do_new_mount fs/namespace.c:2517 [inline]
 do_mount+0x35c/0x2560 fs/namespace.c:2847
 ksys_mount+0x7b/0xd0 fs/namespace.c:3063
 __do_sys_mount fs/namespace.c:3077 [inline]
 __se_sys_mount fs/namespace.c:3074 [inline]
 __x64_sys_mount+0xb5/0x150 fs/namespace.c:3074
 do_syscall_64+0x90/0x3f0 arch/x86/entry/common.c:287
 entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff88006a6e6480
 which belongs to the cache kmalloc-64 of size 64
The buggy address is located 0 bytes inside of
 64-byte region [ffff88006a6e6480, ffff88006a6e64c0)
The buggy address belongs to the page:
page:ffffea0001748250 count:1 mapcount:0 mapping:ffff88006a6e6000 index:0xffff88006a6e6f80
flags: 0x100000000000100(slab)
raw: 0100000000000100 ffff88006a6e6000 ffff88006a6e6f80 0000000100000010
raw: ffff88006d401338 ffff88006d401338 ffff88006d400200
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff88006a6e6380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88006a6e6400: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff88006a6e6480: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
                   ^
 ffff88006a6e6500: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
 ffff88006a6e6580: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
==================================================================
