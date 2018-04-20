Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 542FC6B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 22:43:34 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id i8-v6so4105101plt.8
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 19:43:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4-v6sor1735305plr.128.2018.04.19.19.43.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 19:43:32 -0700 (PDT)
Date: Thu, 19 Apr 2018 19:44:40 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: general protection fault in kernfs_kill_sb
Message-ID: <20180420024440.GB686@sol.localdomain>
References: <94eb2c0546040ebb4d0568cc6bdb@google.com>
 <821c80d2-0b55-287a-09aa-d004f4ac4215@I-love.SAKURA.ne.jp>
 <20180402143415.GC30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180402143415.GC30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+151de3f2be6b40ac8026@syzkaller.appspotmail.com>, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-fsdevel@vger.kernel.org

On Mon, Apr 02, 2018 at 03:34:15PM +0100, Al Viro wrote:
> On Mon, Apr 02, 2018 at 07:40:22PM +0900, Tetsuo Handa wrote:
> 
> > That commit assumes that calling kill_sb() from deactivate_locked_super(s)
> > without corresponding fill_super() is safe. We have so far crashed with
> > rpc_mount() and kernfs_mount_ns(). Is that really safe?
> 
> 	Consider the case when fill_super() returns an error immediately.
> It is exactly the same situation.  And ->kill_sb() *is* called in cases
> when fill_super() has failed.  Always had been - it's much less boilerplate
> that way.
> 
> 	deactivate_locked_super() on that failure exit is the least painful
> variant, unfortunately.
> 
> 	Filesystems with ->kill_sb() instances that rely upon something
> done between sget() and the first failure exit after it need to be fixed.
> And yes, that should've been spotted back then.  Sorry.
> 
> Fortunately, we don't have many of those - kill_{block,litter,anon}_super()
> are safe and those are the majority.  Looking through the rest uncovers
> some bugs; so far all I've seen were already there.  Note that normally
> we have something like
> static void affs_kill_sb(struct super_block *sb)
> {
>         struct affs_sb_info *sbi = AFFS_SB(sb);
>         kill_block_super(sb);
>         if (sbi) {
>                 affs_free_bitmap(sb);
>                 affs_brelse(sbi->s_root_bh);
>                 kfree(sbi->s_prefix);
>                 mutex_destroy(&sbi->s_bmlock);
>                 kfree(sbi);
>         }
> }
> which basically does one of the safe ones augmented with something that
> takes care *not* to assume that e.g. ->s_fs_info has been allocated.
> Not everyone does, though:
> 
> jffs2_fill_super():
>         c = kzalloc(sizeof(*c), GFP_KERNEL);
>         if (!c)
>                 return -ENOMEM;
> in the very beginning.  So we can return from it with NULL ->s_fs_info.
> Now, consider
>         struct jffs2_sb_info *c = JFFS2_SB_INFO(sb);
>         if (!(sb->s_flags & MS_RDONLY))
>                 jffs2_stop_garbage_collect_thread(c);
> in jffs2_kill_sb() and
> void jffs2_stop_garbage_collect_thread(struct jffs2_sb_info *c)
> {
>         int wait = 0;
>         spin_lock(&c->erase_completion_lock);
>         if (c->gc_task) {
> 
> IOW, fail that kzalloc() (or, indeed, an allocation in register_shrinker())
> and eat an oops.  Always had been there, always hard to hit without
> fault injectors and fortunately trivial to fix.
> 
> Similar in nfs_kill_super() calling nfs_free_server().
> Similar in v9fs_kill_super() with v9fs_session_cancel()/v9fs_session_close() calls.
> Similar in hypfs_kill_super(), afs_kill_super(), btrfs_kill_super(), cifs_kill_sb()
> (all trivial to fix)
> 
> Aha... nfsd_umount() is a new regression.
> 
> orangefs: old, trivial to fix.
> 
> cgroup_kill_sb(): old, hopefully easy to fix.  Note that kernfs_root_from_sb()
> can bloody well return NULL, making cgroup_root_from_kf() oops.  Always had been
> there.
> 
> AFAICS, after discarding the instances that do the right thing we are left with:
> hypfs_kill_super, rdt_kill_sb, v9fs_kill_super, afs_kill_super, btrfs_kill_super,
> cifs_kill_sb, jffs2_kill_sb, nfs_kill_super, nfsd_umount, orangefs_kill_sb,
> proc_kill_sb, sysfs_kill_sb, cgroup_kill_sb, rpc_kill_sb.
> 
> Out of those, nfsd_umount(), proc_kill_sb() and rpc_kill_sb() are regressions.
> So are rdt_kill_sb() and sysfs_kill_sb() (victims of the issue you've spotted
> in kernfs_kill_sb()).  The rest are old (and I wonder if syzbot had been
> catching those - they are also dependent upon a specific allocation failing
> at the right time).
> 

Fix for the kernfs bug is now queued in vfs/for-linus:

#syz fix: kernfs: deal with early sget() failures

syzkaller just recently (3 weeks ago) gained the ability to mount filesystem
images, so that's the main reason for the increase in filesystem bug reports.
Each time syzkaller is updated to cover more code, bugs are found.

- Eric
