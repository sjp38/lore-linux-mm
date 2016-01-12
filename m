Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 085A94403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 05:17:33 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id vt7so22985760obb.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 02:17:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id rs11si5462948oec.15.2016.01.12.02.17.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jan 2016 02:17:31 -0800 (PST)
Subject: Re: What is oom_killer_disable() for?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1452337485-8273-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<201601100202.DHE57897.OVLJOMHFOtFFSQ@I-love.SAKURA.ne.jp>
	<20160111144924.GF27317@dhcp22.suse.cz>
In-Reply-To: <20160111144924.GF27317@dhcp22.suse.cz>
Message-Id: <201601121917.IEI30296.OVOFFtQSLFHJOM@I-love.SAKURA.ne.jp>
Date: Tue, 12 Jan 2016 19:17:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org, rjw@rjwysocki.net

Michal Hocko write:
> As only TIF_MEMDIE tasks are thawed we do not wait for all killed task.

Ah, I see.

I thought that TIF_MEMDIE && SIGKILL && PF_FROZEN tasks are woken by
try_to_wake_up(p, TASK_INTERRUPTIBLE | TASK_UNINTERRUPTIBLE, 0) via __thaw_task(p),
but SIGKILL tasks are anyway (i.e. regardless of TIF_MEMDIE and PF_FROZEN flags)
woken by try_to_wake_up(p, TASK_WAKEKILL | TASK_INTERRUPTIBLE, 0) via
do_send_sig_info(p).

----------
mark_oom_victim(struct task_struct *tsk) {
  __thaw_task(tsk) {
    if (frozen(p)) /* p->flags & PF_FROZEN */
      wake_up_process(p) {
        try_to_wake_up(p, TASK_NORMAL, 0) { /* TASK_NORMAL is TASK_INTERRUPTIBLE | TASK_UNINTERRUPTIBLE */
          if (!(p->state & state))
            goto out;
          success = 1; /* we're going to change ->state */
        }
      }
  }
}

do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true) {
  send_signal(sig, info, p, group) {
    __send_signal(sig, info, t, group, from_ancestor_ns) {
      if (info == SEND_SIG_FORCED) /* info is SEND_SIG_FORCED */
        goto out_set;
      out_set:
        complete_signal(sig, t, group) {
          signal_wake_up(t, sig == SIGKILL) {
            signal_wake_up_state(t, resume ? TASK_WAKEKILL : 0) { /* resume is 1 */
              wake_up_state(t, state | TASK_INTERRUPTIBLE) { /* state is TASK_WAKEKILL */
                try_to_wake_up(p, state, 0) { /* state is TASK_WAKEKILL | TASK_INTERRUPTIBLE */
                  if (!(p->state & state))
                    goto out;
                  success = 1; /* we're going to change ->state */
                }
              }
            }
          }
        }
    }
  }
}
----------

But frozen tasks are looping inside for(;;) { ... } at __refrigerator(),
and only TIF_MEMDIE tasks can escape this loop by

  if (test_thread_flag(TIF_MEMDIE))
    return false;

in freezing_slow_path().

Then, assuming that any task which is looping inside this loop has no
locks held, current oom_killer_disable() function which assumes that

  wait_event(oom_victims_wait, !atomic_read(&oom_victims));

is guaranteed to return shortly is unsafe if TIF_MEMDIE tasks are
waiting for locks held by not-yet-frozen kernel threads?



> >     Why don't we abort suspend operation by marking that
> >     re-enabling of the OOM killer might caused modification of on-memory
> >     data (like patch shown below)? We can make final decision after memory
> >     image snapshot is saved to disk, can't we?
>
> I am not sure I am following you here but how do you detect that the
> userspace has corrupted your image or accesses an already (half)
> suspended device or something similar?

Can't we determine whether the OOM killer might have corrupted our image
by checking whether oom_killer_disabled is kept true until the point of
final decision?

To me, satisfying allocation requests by kernel threads by invoking the
OOM killer and aborting suspend operation if the OOM killer was invoked
sounds cleaner than forcing !__GFP_NOFAIL allocation requests to fail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
