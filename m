Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB5476B0069
	for <linux-mm@kvack.org>; Sat, 10 Sep 2016 07:25:50 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so223713675pab.1
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 04:25:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j12si9331750pat.285.2016.09.10.04.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Sep 2016 04:25:49 -0700 (PDT)
Date: Sat, 10 Sep 2016 13:25:53 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] android: binder: Disable preemption while holding the
 global binder lock
Message-ID: <20160910112553.GA27714@kroah.com>
References: <1473434264-18479-1-git-send-email-tkjos@google.com>
 <20160909154423.GB24649@kroah.com>
 <CAD0t5oO9ZGPS3hKS3ZW-DzG21xz4zXH8050fK2G9R6CVPb0n6w@mail.gmail.com>
 <20160910111847.GC26685@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160910111847.GC26685@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Todd Kjos <tkjos@android.com>
Cc: arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Sep 10, 2016 at 01:18:47PM +0200, Greg KH wrote:
> On Fri, Sep 09, 2016 at 10:39:32AM -0700, Todd Kjos wrote:
> > On Fri, Sep 9, 2016 at 8:44 AM, Greg KH <gregkh@linuxfoundation.org> wrote:
> > > On Fri, Sep 09, 2016 at 08:17:44AM -0700, Todd Kjos wrote:
> > >> From: Todd Kjos <tkjos@android.com>
> > >>
> > >> In Android systems, the display pipeline relies on low
> > >> latency binder transactions and is therefore sensitive to
> > >> delays caused by contention for the global binder lock.
> > >> Jank is significantly reduced by disabling preemption
> > >> while the global binder lock is held.
> > >
> > > What is the technical definition of "Jank"?  :)
> > 
> > I'll rephrase in the next version to "dropped or delayed frames".
> 
> Heh, thanks :)
> 
> Also in the next version can you fix the errors found by the 0-day build
> bot?
> 
> > >> This patch was originated by Riley Andrews <riandrews@android.com>
> > >> with tweaks and forward-porting by me.
> > >>
> > >> Originally-from: Riley Andrews <riandrews@android.com>
> > >> Signed-off-by: Todd Kjos <tkjos@android.com>
> > >> ---
> > >>  drivers/android/binder.c | 194 +++++++++++++++++++++++++++++++++++------------
> > >>  1 file changed, 146 insertions(+), 48 deletions(-)
> > >>
> > >> diff --git a/drivers/android/binder.c b/drivers/android/binder.c
> > >> index 16288e7..c36e420 100644
> > >> --- a/drivers/android/binder.c
> > >> +++ b/drivers/android/binder.c
> > >> @@ -379,6 +379,7 @@ static int task_get_unused_fd_flags(struct binder_proc *proc, int flags)
> > >>       struct files_struct *files = proc->files;
> > >>       unsigned long rlim_cur;
> > >>       unsigned long irqs;
> > >> +     int ret;
> > >>
> > >>       if (files == NULL)
> > >>               return -ESRCH;
> > >> @@ -389,7 +390,11 @@ static int task_get_unused_fd_flags(struct binder_proc *proc, int flags)
> > >>       rlim_cur = task_rlimit(proc->tsk, RLIMIT_NOFILE);
> > >>       unlock_task_sighand(proc->tsk, &irqs);
> > >>
> > >> -     return __alloc_fd(files, 0, rlim_cur, flags);
> > >> +     preempt_enable_no_resched();
> > >> +     ret = __alloc_fd(files, 0, rlim_cur, flags);
> > >> +     preempt_disable();
> > >> +
> > >> +     return ret;
> > >>  }
> > >>
> > >>  /*
> > >> @@ -398,8 +403,11 @@ static int task_get_unused_fd_flags(struct binder_proc *proc, int flags)
> > >>  static void task_fd_install(
> > >>       struct binder_proc *proc, unsigned int fd, struct file *file)
> > >>  {
> > >> -     if (proc->files)
> > >> +     if (proc->files) {
> > >> +             preempt_enable_no_resched();
> > >>               __fd_install(proc->files, fd, file);
> > >> +             preempt_disable();
> > >> +     }
> > >>  }
> > >>
> > >>  /*
> > >> @@ -427,6 +435,7 @@ static inline void binder_lock(const char *tag)
> > >>  {
> > >>       trace_binder_lock(tag);
> > >>       mutex_lock(&binder_main_lock);
> > >> +     preempt_disable();
> > >>       trace_binder_locked(tag);
> > >>  }
> > >>
> > >> @@ -434,8 +443,65 @@ static inline void binder_unlock(const char *tag)
> > >>  {
> > >>       trace_binder_unlock(tag);
> > >>       mutex_unlock(&binder_main_lock);
> > >> +     preempt_enable();
> > >> +}
> > >> +
> > >> +static inline void *kzalloc_nopreempt(size_t size)
> > >> +{
> > >> +     void *ptr;
> > >> +
> > >> +     ptr = kzalloc(size, GFP_NOWAIT);
> > >> +     if (ptr)
> > >> +             return ptr;
> > >> +
> > >> +     preempt_enable_no_resched();
> > >> +     ptr = kzalloc(size, GFP_KERNEL);
> > >> +     preempt_disable();
> > >
> > > Doesn't the allocator retry if the first one fails anyway?  Why not
> > > GFP_NOIO or GFP_ATOMIC?  Have you really hit the second GFP_KERNEL
> > > usage?
> > 
> > I suspect we have hit the second, since we do get into cases where
> > direct reclaim is needed. I can't confirm since I haven't instrumented
> > this case. As you say, if we use GFP_ATOMIC instead, maybe we
> > wouldn't, but even then I'd be concerned that we could deplete the
> > memory reserved for atomic. The general idea of trying for a fast,
> > nowait allocation and then enabling preempt for the rare potentially
> > blocking allocation seems reasonable, doesn't it?
> 
> Yes it is, so much so that I think there's a generic kernel function for
> it already.  Adding in the linux-mm mailing list to be told that I'm
> wrong about this :)

Ok, adding the correct linux-mm list address this time...

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
