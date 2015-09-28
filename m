Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7206B0257
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:20 -0400 (EDT)
Received: by oiww128 with SMTP id w128so93005655oiw.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 09:18:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id cs4si8618817oeb.32.2015.09.28.09.18.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Sep 2015 09:18:19 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150922160608.GA2716@redhat.com>
	<20150923205923.GB19054@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
In-Reply-To: <201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
Message-Id: <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
Date: Tue, 29 Sep 2015 01:18:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Michal Hocko wrote:
> The point I've tried to made is that oom unmapper running in a detached
> context (e.g. kernel thread) vs. directly in the oom context doesn't
> make any difference wrt. lock because the holders of the lock would loop
> inside the allocator anyway because we do not fail small allocations.

We tried to allow small allocations to fail. It resulted in unstable system
with obscure bugs.

We tried to allow small !__GFP_FS allocations to fail. It failed to fail by
effectively __GFP_NOFAIL allocations.

We are now trying to allow zapping OOM victim's mm. Michal is already
skeptical about this approach due to lock dependency.

We already spent 9 months on this OOM livelock. No silver bullet yet.
Proposed approaches are too drastic to backport for existing users.
I think we are out of bullet.

Until we complete adding/testing __GFP_NORETRY (or __GFP_KILLABLE) to most
of callsites, timeout based workaround will be the only bullet we can use.

Michal's panic_on_oom_timeout and David's "global access to memory reserves"
will be acceptable for some users if these approaches are used as opt-in.
Likewise, my memdie_task_skip_secs / memdie_task_panic_secs will be
acceptable for those who want to retry a bit more rather than panic on
accidental livelock if this approach is used as opt-in.

Tetsuo Handa wrote:
> Excuse me, but thinking about CLONE_VM without CLONE_THREAD case...
> Isn't there possibility of hitting livelocks at
> 
>         /*
>          * If current has a pending SIGKILL or is exiting, then automatically
>          * select it.  The goal is to allow it to allocate so that it may
>          * quickly exit and free its memory.
>          *
>          * But don't select if current has already released its mm and cleared
>          * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
>          */
>         if (current->mm &&
>             (fatal_signal_pending(current) || task_will_free_mem(current))) {
>                 mark_oom_victim(current);
>                 return true;
>         }
> 
> if current thread receives SIGKILL just before reaching here, for we don't
> send SIGKILL to all threads sharing the mm?

Seems that CLONE_VM without CLONE_THREAD is irrelevant here.
We have sequences like

  Do a GFP_KENREL allocation.
  Hold a lock.
  Do a GFP_NOFS allocation.
  Release a lock.

where an example is seen in VFS operations which receive pathname from
user space using getname() and then call VFS functions and filesystem
code takes locks which can contend with other threads.

------------------------------------------------------------
diff --git a/fs/namei.c b/fs/namei.c
index d68c21f..d51c333 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4005,6 +4005,8 @@ int vfs_symlink(struct inode *dir, struct dentry *dentry, const char *oldname)
        if (error)
                return error;

+       if (fatal_signal_pending(current))
+               printk(KERN_INFO "Calling symlink with SIGKILL pending\n");
        error = dir->i_op->symlink(dir, dentry, oldname);
        if (!error)
                fsnotify_create(dir, dentry);
@@ -4021,6 +4023,10 @@ SYSCALL_DEFINE3(symlinkat, const char __user *, oldname,
        struct path path;
        unsigned int lookup_flags = 0;

+       if (!strcmp(current->comm, "a.out")) {
+               printk(KERN_INFO "Sending SIGKILL to current thread\n");
+               do_send_sig_info(SIGKILL, SEND_SIG_FORCED, current, true);
+       }
        from = getname(oldname);
        if (IS_ERR(from))
                return PTR_ERR(from);
diff --git a/fs/xfs/xfs_symlink.c b/fs/xfs/xfs_symlink.c
index 996481e..2b6faa5 100644
--- a/fs/xfs/xfs_symlink.c
+++ b/fs/xfs/xfs_symlink.c
@@ -240,6 +240,8 @@ xfs_symlink(
        if (error)
                goto out_trans_cancel;

+       if (fatal_signal_pending(current))
+               printk(KERN_INFO "Calling xfs_ilock() with SIGKILL pending\n");
        xfs_ilock(dp, XFS_IOLOCK_EXCL | XFS_ILOCK_EXCL |
                      XFS_IOLOCK_PARENT | XFS_ILOCK_PARENT);
        unlock_dp_on_error = true;
------------------------------------------------------------

[  119.534976] Sending SIGKILL to current thread
[  119.535898] Calling symlink with SIGKILL pending
[  119.536870] Calling xfs_ilock() with SIGKILL pending

Any program can potentially hit this silent livelock. We can't predict
what locks the OOM victim threads will depend on after TIF_MEMDIE was
set by the OOM killer. Therefore, I think that TIF_MEMDIE disables the
OOM killer indefinitely is one of possible causes regarding silent
hangup troubles.

Michal Hocko wrote:
> I really hate to do "easy" things now just to feel better about
> particular case which will kick us back little bit later. And from my
> own experience I can tell you that a more non-deterministic OOM behavior
> is thing people complain about.

I believe that not waiting for TIF_MEMDIE thread indefinitely is the first
choice we can propose people to try. From my own experience I can tell you
that some customers are really sensitive about bugs which halt their systems
(e.g. https://access.redhat.com/solutions/68466 ).
Opt-in version of TIF_MEMDIE timeout should be acceptable for people
who prefer avoiding silent hangup over non-deterministic OOM behavior if
they were explained about the truth of current memory allocator's behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
