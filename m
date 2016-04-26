Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3DDF6B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:00:20 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id u5so25074749igk.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:00:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p7si9835909oew.31.2016.04.26.07.00.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 07:00:19 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160420144758.GA7950@dhcp22.suse.cz>
	<201604212049.GFE34338.OQFOJSMOHFFLVt@I-love.SAKURA.ne.jp>
	<20160421130750.GA18427@dhcp22.suse.cz>
	<201604242319.GAF12996.tOJMOQFLFVOHSF@I-love.SAKURA.ne.jp>
	<20160425095508.GE23933@dhcp22.suse.cz>
In-Reply-To: <20160425095508.GE23933@dhcp22.suse.cz>
Message-Id: <201604262300.FDB82145.SHFFQLOOtMJFOV@I-love.SAKURA.ne.jp>
Date: Tue, 26 Apr 2016 23:00:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Michal Hocko wrote:
> On Sun 24-04-16 23:19:03, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > I have seen that patch. I didn't get to review it properly yet as I am
> > > still travelling. From a quick view I think it is conflating two things
> > > together. I could see arguments for the panic part but I do not consider
> > > the move-to-kill-another timeout as justified. I would have to see a
> > > clear indication this is actually useful for real life usecases.
> > 
> > You admit that it is possible that the TIF_MEMDIE thread is blocked at
> > unkillable wait (due to memory allocation requests by somebody else) but
> > the OOM reaper cannot reap the victim's memory (due to holding the mmap_sem
> > for write), don't you?
> 
> I have never said this to be impossible.
> 

OK. You might think it happens once per million OOM killer invocations.
I might think it happens once per thousand OOM killer invocations. But
someone might have a setup and applications which make it happen once
per ten OOM killer invocations. We need to be prepared for it anyway.

> > Then, I think this patch makes little sense unless accompanied with the
> > move-to-kill-another timeout. If the OOM reaper failed to reap the victim's
> > memory, the OOM reaper simply clears TIF_MEMDIE from the victim thread. But
> > since nothing has changed (i.e. the victim continues waiting, and the victim's
> > memory is not reclaimed, and the victim's oom_score_adj is not updated to
> > OOM_SCORE_ADJ_MIN), the OOM killer will select that same victim again.
> 
> Yes a patch to introduce a reliable panic-on-timeout would have to
> solved this and it is not really trivial to do so.
> 
> > This forms an infinite loop. You will want to call panic() as soon as the OOM
> > reaper failed to reap the victim's memory (than waiting for the panic timeout).
> > 
> > For both system operators at customer's companies and staffs at support center,
> > avoiding hangup (due to OOM livelock) and panic (due to the OOM panic timeout)
> > eliminates a lot of overhead. This is a practical benefit for them.
> > 
> > I also think that the purpose of killing only one task at a time than calling
> > panic() is to save as much work as possible.
> 
> If we are locked up then there is no room to try to save some work. We
> want the machine to recover rather than hope for anything.
> 

We might be locked up with the first OOM victim due to mmap_sem held for write.
But we are likely no longer locked up with the second/third OOM victims
(assuming that the OOM killer selects different mm users). I never want
the machine to panic/reboot without trying SysRq-f for several times (but
I'm not always sitting in front of the console in order to try SysRq-f).

> > Therefore, I can't understand why
> > you don't think that killing only another task via the move-to-kill-another
> > timeout is a useful real life usecase.
> 
> I feel like I have to repeat myself. The argument is really simple. If
> you have an unlikely possibility of a lockup then you you really want to
> a _reliable_ way to get out of this unfortunate state. Kill-another-task
> is a mere optimization which has to be evaluated for maintenance vs.
> feasibility aspects. So far I am not really convicend about the second
> while the first seems like a real concern because the oom code is
> complex enough already.
> 

Quite opposite. Panic on timeout is a mere optimization for those who don't
want to wait for too long. The basic direction for panic_on_oom == 0 is try
to loose minimum work while avoiding oom lockup. We added the OOM reaper
in order to assist that direction. We are talking about situations where
the OOM reaper failed to assist. You think "an unlikely possibility of a
lockup" but such assumption is not always true.

> You also have to consider that exporting sysctl knobs for one-off
> usecases which are very specific to the implementation at the time have
> proven bad. The implementation is moving on and there is no guarantee
> that the OOM killer will see changes where the single oom victim will
> make even sense - e.g. we might change the semantic to kill whole
> containers or that the killing logic would be under control of the admin
> (e.g. BPF filters or kernel modules or whatever).
> 

Yes, the OOM killer might change in the future. But that is not an excuse
to desert current users. You can deprecate and then remove such sysctl knobs
when you developed perfect model and mechanism. Until that moment, please
don't desert current and future users.

> No panic on timeout has a _clear_ semantic independent on the current
> oom implementation. While move-to-other victim is not so clear in that
> aspect.
> 
> > panic on timeout is a practical benefit for you, but giving several chances
> > on timeout is a practical benefit for someone you don't know.
> 
> Then I would like to hear about that "someone I don't know" with a
> clear usecase. So far you are only fuzzy about those and that is not
> sufficient to add another subtle code. Did I make myself clear?

I still cannot understand what you want to hear about the "usecase".

For CONFIG_MMU=n systems, the possibility is not small because the OOM
reaper is not available.

For large servers which take 10 minutes to reboot, trying to survive
for up to 60 seconds using move-to-other victim is helpful for several
administrators. (Of course, the period to retry is just an example.)

For desktop PCs running an Office application and a Web browser,
trying to save not-yet-saved Office documents when the Web browser
by chance triggered the OOM killer is helpful for several users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
