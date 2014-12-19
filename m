Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E51EE6B0071
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 07:22:55 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so1124488pde.12
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 04:22:55 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y11si14256999pas.38.2014.12.19.04.22.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 04:22:54 -0800 (PST)
Subject: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141216124714.GF22914@dhcp22.suse.cz>
	<201412172054.CFJ78687.HFFLtVMOOJSQFO@I-love.SAKURA.ne.jp>
	<20141217130807.GB24704@dhcp22.suse.cz>
	<201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
	<20141218153341.GB832@dhcp22.suse.cz>
In-Reply-To: <20141218153341.GB832@dhcp22.suse.cz>
Message-Id: <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
Date: Fri, 19 Dec 2014 21:22:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, dchinner@redhat.com
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

(Renamed thread's title and invited Dave Chinner. A memory stressing program
at http://marc.info/?l=linux-mm&m=141890469424353&w=2 can trigger stalls on
a system with 4 CPUs/2048MB of RAM/no swap. I want to hear your opinion.)

Michal Hocko wrote:
> > My question is quite simple. How can we avoid memory allocation stalls when
> >
> >   System has 2048MB of RAM and no swap.
> >   Memcg1 for task1 has quota 512MB and 400MB in use.
> >   Memcg2 for task2 has quota 512MB and 400MB in use.
> >   Memcg3 for task3 has quota 512MB and 400MB in use.
> >   Memcg4 for task4 has quota 512MB and 400MB in use.
> >   Memcg5 for task5 has quota 512MB and 1MB in use.
> >
> > and task5 launches below memory consumption program which would trigger
> > the global OOM killer before triggering the memcg OOM killer?
> >
> [...]
> > The global OOM killer will try to kill this program because this program
> > will be using 400MB+ of RAM by the time the global OOM killer is triggered.
> > But sometimes this program cannot be terminated by the global OOM killer
> > due to XFS lock dependency.
> >
> > You can see what is happening from OOM traces after uptime > 320 seconds of
> > http://I-love.SAKURA.ne.jp/tmp/serial-20141213.txt.xz though memcg is not
> > configured on this program.
>
> This is clearly a separate issue. It is a lock dependency and that alone
> _cannot_ be handled from OOM killer as it doesn't understand lock
> dependencies. This should be addressed from the xfs point of view IMHO
> but I am not familiar with this filesystem to tell you how or whether it
> is possible.
>
Then, let's ask Dave Chinner whether he can address it. My opinion is that
everybody is doing __GFP_WAIT memory allocation without understanding the
entire dependencies. Everybody is only prepared for allocation failures
because everybody is expecting that the OOM killer shall somehow solve the
OOM condition (except that some are expecting that memory stress that will
trigger the OOM killer must not be given). I am neither familiar with XFS,
but I don't think this issue can be addressed from the XFS point of view.

For example, https://lkml.org/lkml/2014/7/2/249 stalls at blk_rq_map_kern()
which I'm suspecting it as one of causes of the stall due to happening
inside disk I/O event of XFS partition. If XFS were responsible for
avoiding stall at blk_rq_map_kern() (on the assumption that XFS triggered
that disk I/O event), XFS (filesystem layer) somehow needs to drop
__GFP_WAIT flag from scsi_execute() (SCSI layer). We will end up with
passing gfp flags to every function which might do memory allocation.
Is everybody happy with such code complication/bloat?

----------
int scsi_execute(struct scsi_device *sdev, const unsigned char *cmd,
                 int data_direction, void *buffer, unsigned bufflen,
                 unsigned char *sense, int timeout, int retries, u64 flags,
                 int *resid)
{
        struct request *req;
        int write = (data_direction == DMA_TO_DEVICE);
        int ret = DRIVER_ERROR << 24;

        req = blk_get_request(sdev->request_queue, write, __GFP_WAIT);
        if (IS_ERR(req))
                return ret;
        blk_rq_set_block_pc(req);

        if (bufflen &&  blk_rq_map_kern(sdev->request_queue, req,
                                        buffer, bufflen, __GFP_WAIT))
                goto out;

        req->cmd_len = COMMAND_SIZE(cmd[0]);
        memcpy(req->cmd, cmd, req->cmd_len);
        req->sense = sense;
        req->sense_len = 0;
        req->retries = retries;
        req->timeout = timeout;
        req->cmd_flags |= flags | REQ_QUIET | REQ_PREEMPT;

        /*
         * head injection *required* here otherwise quiesce won't work
         */
        blk_execute_rq(req->q, NULL, req, 1);

        /*
         * Some devices (USB mass-storage in particular) may transfer
         * garbage data together with a residue indicating that the data
         * is invalid.  Prevent the garbage from being misinterpreted
         * and prevent security leaks by zeroing out the excess data.
         */
        if (unlikely(req->resid_len > 0 && req->resid_len <= bufflen))
                memset(buffer + (bufflen - req->resid_len), 0, req->resid_len);

        if (resid)
                *resid = req->resid_len;
        ret = req->errors;
 out:
        blk_put_request(req);

        return ret;
}
----------

By the way, if __GFP_WAIT requests had higher priority (lower or ignore
the watermark?) than GFP_NOIO or GFP_NOFS or GFP_KERNEL requests, could
blk_rq_map_kern() avoid the stall and allow XFS to proceed (and release
XFS lock and terminate the OOM victim)?

> > Somebody may set
> > TIF_MEMDIE at oom_kill_process() even if we avoided setting TIF_MEMDIE at
> > out_of_memory(). There will be more locations where TIF_MEMDIE is set; even
> > out-of-tree modules might set TIF_MEMDIE.
>
> TIF_MEMDIE should be set only when we _know_ the task will free _some_
> memory and when we are killing the OOM victim. The only place I can see
> that would break the first condition is out_of_memory for the current
> which passed exit_mm(). That is the point why I've suggested you this
> patch and it would be much more easier if we could simply finished that
> one without pulling other things in.

I agree that TIF_MEMDIE should be set only when we know the task will free
some memory, but currently setting TIF_MEMDIE on the OOM victim is causing
stalls which I want to analyze/debug via patchset posted at
http://marc.info/?l=linux-mm&m=141671817211121&w=2 because we forever wait
until the OOM victim terminates. In serial-20141213.txt.xz, TIF_MEMDIE was
set on the OOM victim which is even unkillable by SysRq-f.

> > Nonetheless, I don't think
> >
> >     if (!task->mm && test_tsk_thread_flag(task, TIF_MEMDIE))
> >         return true;
> >
> > check is perfect because we anyway need to prepare for both mm-less and
> > with-mm cases.
> >
> > My concern is not "whether TIF_MEMDIE flag should be set or not". My concern
> > is not "whether task->mm is NULL or not". My concern is "whether threads with
> > TIF_MEMDIE flag retard other process' memory allocation or not".
> > Above-mentioned program is an example of with-mm threads retarding
> > other process' memory allocation.
>
> There is no way you can guarantee something like that. OOM is the _last_
> resort. Things are in a pretty bad state already when it hits. It is the
> last attempt to reclaim some memory. System might be in an arbitrary
> state at this time.
> I really hate to repeat myself but you are trying to "fix" your problem
> at a wrong level.

I think that the OOM killer is responsible for killing the OOM condition or
triggering kernel panic. I don't like that the OOM killer is failing to kill
the OOM condition as it claims to be.

>
> > I know you don't like timeout approach, but adding
> >
> >     if (sysctl_memdie_timeout_secs && test_tsk_thread_flag(task, TIF_MEMDIE) &&
> >         time_after(jiffies, task->memdie_start + sysctl_memdie_timeout_secs * HZ))
> >         return true;
> >
> > check to oom_unkillable_task() will take care of both mm-less and with-mm
> > cases because everyone can safely skip the TIF_MEMDIE victim threads who
> > cannot be terminated immediately for some reason.
>
> It will not take care of anything. It will start shooting to more
> processes after some timeout, which is hard to get right, and there
> wouldn't be any guaratee multiple victims will help because they might
> end up blocking on the very same or other lock on the way out.

If you don't like skip on timeout approach, I'm OK with triggering kernel
panic on timeout approach. Analyzing vmcore will give us some hints about
what was happening.

>                                                                Jeez are
> you even reading feedback you are getting?

Of course, I'm reading your feedback.

The "[RFC PATCH 0/5] mm: Patches for mitigating memory allocation stalls."
will become unnecessary after all bugs are identified and fixed. I agree
that bugs should be identified and fixed, but XFS stall is nothing but an
example which I can reproduce on my desktop. My role is to analyze and
respond to kernel troubles such as unexpected stalls, panics, reboots
occurred on customer's servers which I don't have access. I will encounter
various different troubles which I can't predict how to obtain information.
Therefore, I want some unattended built-in assistance for understanding
what was happening in chronological order and identifying/fixing the bugs.
Existing built-in debugging hooks which requires administrator's operation
might help after understanding what was happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
