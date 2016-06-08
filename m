Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7996B0260
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 10:55:39 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id q18so16683707igr.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:55:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a89si1085008otb.204.2016.06.08.07.55.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Jun 2016 07:55:38 -0700 (PDT)
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160606083651.GE11895@dhcp22.suse.cz>
	<201606072330.AHH81886.OOMVHFOFLtFSQJ@I-love.SAKURA.ne.jp>
	<20160607150534.GO12305@dhcp22.suse.cz>
	<201606080649.DGF51523.FLMOSHVtFFOJOQ@I-love.SAKURA.ne.jp>
	<20160608072741.GE22570@dhcp22.suse.cz>
In-Reply-To: <20160608072741.GE22570@dhcp22.suse.cz>
Message-Id: <201606082355.EIJ05259.OHQLFtFOJFOMSV@I-love.SAKURA.ne.jp>
Date: Wed, 8 Jun 2016 23:55:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 08-06-16 06:49:24, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > OK, so you are arming the timer for each mark_oom_victim regardless
> > > of the oom context. This means that you have replaced one potential
> > > lockup by other potential livelocks. Tasks from different oom domains
> > > might interfere here...
> > > 
> > > Also this code doesn't even seem easier. It is surely less lines of
> > > code but it is really hard to realize how would the timer behave for
> > > different oom contexts.
> > 
> > If you worry about interference, we can use per signal_struct timestamp.
> > I used per task_struct timestamp in my earlier versions (where per
> > task_struct TIF_MEMDIE check was used instead of per signal_struct
> > oom_victims).
> 
> This would allow pre-mature new victim selection for very large victims
> (note that exit_mmap can take a while depending on the mm size). It also
> pushed the timeout heuristic for everybody which will sooner or later
> open a question why is this $NUMBER rathen than $NUMBER+$FOO.

You are again worrying about wrong problem. You are ignoring distinction
between genuine lock up (real problem for you) and effectively locked up
(real problem for administrators).

Yes, it might be possible that exit_mmap() from __mmput() from mmput() from
exit_mm() from do_exit() takes 30 minutes. But how many administrators will
patiently wait for 30 minutes in order to avoid premature OOM victim selection?

If allocation task is blocked for 30 minutes because the OOM killer is waiting
for exit_mmap(), such system is already unusable. They will likely try SysRq-f
if they were sitting in front of console. They will likely depend on watchdog
mechanisms (e.g. /dev/watchdog) otherwise.

People are using various kind of timeout based watchdog (e.g. hard/soft lockup,
rcu lockup) because they do not want false negatives but they can tolerate
false positives. You are strongly rejecting false positives while I'm accepting
false positives.

Whether the OOM killer is making forward progress is important for you, but
whether their systems solve the OOM situation within their tolerable period
is important for users. You have proposed panic_on_oom_timeout, but many users
who use panic_on_oom = 0 want to try to survive for reasonable duration before
giving up by panic(). So, we lack intermediate mechanism.

$NUMBER will be sysctl tunable. I just used hardcoded constant for saving
lines.

> [...]
> > But expiring timeout by sleeping inside oom_kill_process() prevents other
> > threads which are OOM-killed from obtaining TIF_MEMDIE, for anybody needs
> > to wait for oom_lock in order to obtain TIF_MEMDIE.
> 
> True, but please note that this will happen only for the _unlikely_ case
> when the mm is shared with kthread or init. All other cases would rely
> on the oom_reaper which has a feedback mechanism to tell the oom killer
> to move on if something bad is going on.

My version (which always wakes up the OOM reaper even if it is known that
the memory is not reapable) tried to avoid what you call premature next OOM
victim selection. But you said you don't like waking up the OOM reaper when
the memory is not reapable. Then, I can't have reasons to honor feedback based
decision.

On the other hand, regarding this version, you said you don't like this timer
due to possible premature next OOM victim selection. That is conflicting
opinion.

If you realize the gap between your concern and people's concern, you won't
say possible premature next OOM victim selection is unacceptable. Real problem
for users is subjectively determined by users.

> 
> > Unless you set TIF_MEMDIE to all OOM-killed threads from
> > oom_kill_process() or allow the caller context to use
> > ALLOC_NO_WATERMARKS by checking whether current was already OOM-killed
> > rather than TIF_MEMDIE, attempt to expiring timeout by sleeping inside
> > oom_kill_process() is useless.
> 
> Well this is a rather strong statement for a highly unlikely corner
> case, don't you think? I do not mind fortifying this class of cases some
> more if we ever find out they are a real problem but I would rather make
> sure they cannot lockup at this stage rather than optimize for them.

Making sure unlikely corner cases will not lock up at this stage is
what you think a solution, but how many users will wait for 30 minutes
even if unlikely corner cases does not lock up?

> 
> To be honest I would rather explore ways to handle kthread case (which
> is the only real one IMHO from the two) gracefully and made them a
> nonissue - e.g. enforce EFAULT on a dead mm during the kthread page fault
> or something similar.

You are always living in a world with plenty resource. You tend to ignore
CONFIG_MMU=n kernels. For example, proposing changes like

	if (can_oom_reap) {
		wake_oom_reaper(victim);
	} else if (victim != current) {
		/*
		 * If we want to guarantee a forward progress we cannot keep
		 * the oom victim TIF_MEMDIE here. Sleep for a while and then
		 * drop the flag to make sure another victim can be selected.
		 */
		schedule_timeout_killable(HZ);
		exit_oom_victim(victim);
	}

is silly. can_oom_reap is likely true but wake_oom_reaper() is a no-op
if CONFIG_MMU=n. That is, you force CONFIG_MMU=n users to almost always
risk OOM livelock, and wait uselessly upon unlikely corner cases. Could
you please try to write changes evenly? For example, move above logic
to try_oom_reaper(), and start simple timer based unlocking method if
try_oom_reaper() did not wake up the OOM reaper.

Even if CONFIG_MMU=y, some people want to make their kernels as small as
possible. So, CONFIG_OOM_REAPER which is defaulted to y and depends on
CONFIG_MMU=y would be nice for them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
