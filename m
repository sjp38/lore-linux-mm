Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CFAE831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 04:01:19 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 196so7391053wmk.9
        for <linux-mm@kvack.org>; Thu, 18 May 2017 01:01:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31si4718782edf.271.2017.05.18.01.01.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 01:01:18 -0700 (PDT)
Date: Thu, 18 May 2017 10:01:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: fix oom invocation issues
Message-ID: <20170518080114.GA25462@dhcp22.suse.cz>
References: <1495034780-9520-1-git-send-email-guro@fb.com>
 <20170517161446.GB20660@dhcp22.suse.cz>
 <20170517194316.GA30517@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170517194316.GA30517@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-05-17 20:43:16, Roman Gushchin wrote:
> On Wed, May 17, 2017 at 06:14:46PM +0200, Michal Hocko wrote:
> > On Wed 17-05-17 16:26:20, Roman Gushchin wrote:
[...]
> > > After some investigations I've found some issues:
> > > 
> > > 1) Prior to commit 1af8bb432695 ("mm, oom: fortify task_will_free_mem()"),
> > >    if a process with a pending SIGKILL was calling out_of_memory(),
> > >    it was always immediately selected as a victim.
> > 
> > Yes but this had its own issues. Mainly picking the same victim again
> > without making a further progress.
> 
> That is why I've added this check into the pagefault_out_of_memory(),
> rather than out_of_memory(), where it was earlier.

As I've said in my previous email, this alone makes some sense but I do
not think it is a bug fix but rather a short cut that should be safe to
do because we should check fatal signals on the way out of the #PF.

> > >    But now, after some changes, it's not always a case.
> > >    If a process has been reaped at the moment, MMF_SKIP_FLAG is set,
> > >    task_will_free_mem() will return false, and a new
> > >    victim selection logic will be started.
> > 
> > right. The point is that it doesn't make any sense to consider such a
> > task because it either cannot be reaped or it has been reaped and there
> > is not much left to consider. It would be interesting to see what
> > happened in your case.
> > 
> > >    This actually happens if a userspace pagefault causing an OOM.
> > >    pagefault_out_of_memory() is called in a context of a faulting
> > >    process after it has been selected as OOM victim (assuming, it
> > >    has), and killed. With some probability (there is a race with
> > >    oom_reaper thread) this process will be passed to the oom reaper
> > >    again, or an innocent victim will be selected and killed.
> > > 
> > > 2) We clear up the task->oom_reaper_list before setting
> > >    the MMF_OOM_SKIP flag, so there is a race.
> > 
> > I am not sure what you mean here. Why would a race matter?
> 
> oom_reaper_list pointer is zeroed before MMF_OOM_SKIP flag is set.
> Inbetween this process can be selected again and added to the
> oom reaper queue. It's not a big issue, still.

I still do not see why it would matter. Even if we queue this task again
then oom_lock would prevent from parallel reaping and even if we do not
race then it is not so harmfull to crawl over all mappings just to find
out that nothing is left to be reaped.

[...]
> > > 2) Set the MMF_OOM_SKIP bit in wake_oom_reaper() before adding a
> > >    process to the oom_reaper list. If it's already set, do nothing.
> > >    Do not rely on tsk->oom_reaper_list value.
> > 
> > This is wrong. The sole purpose of MMF_OOM_SKIP is to let the oom
> > selection logic know that this task is not interesting anymore. Setting
> > it in wake_oom_reaper means it would be set _before_ the oom_reaper had
> > any chance to free any memory from the task. So we would
> 
> But if have selected a task once, it has no way back.
> Anyway it will be reaped or will quit by itself soon. Right?

yes and we have to wait for one or the other...

> So, under no circumstances we should consider choosing them
> as an OOM victim again.

and that is exactly what we do right now. We just postpone a new task
selection. Put simply we just wait while there is a pending oom victim
and MMF_OOM_SKIP is a way to skip such a pending victim if we believe
there is no much hope to release some memory anymore.

> There are no reasons to calculate it's badness again, etc.

Yes that is true but oom_badness has to consider MMF_OOM_SKIP anyway
(mainly because it is called from more places).
 
> > > 3) Check the MMF_OOM_SKIP even if OOM is triggered by a sysrq.
> > 
> > The code is a bit messy here but we do check MMF_OOM_SKIP in that case.
> > We just do it in oom_badness(). So this is not needed, strictly
> > speaking.
> > 
> > That being said I would like to here more about the cause of the OOM and
> > the full dmesg would be interesting. The proposed setting of
> > MMF_OOM_SKIP before the task is reaped is a nogo, though.
> 
> If so, how you will prevent putting a process again into the reaper list,
> if it's already reaped?

We simply do not care all that much as already said.
 
> > 1) would be
> > acceptable I think but I would have to think about it some more.
> 
> Actually, the first problem is much more serious, as it leads
> to a killing of second process.

That sounds like a bug to me. I will investigate further.
 
> The second one can lead only to a unnecessary wake up of
> the oom reaper thread, which is not great, but acceptable.

yes.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
