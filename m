Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB27B6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 05:55:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so35823267wmw.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 02:55:11 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id w10si18478053wmw.27.2016.04.25.02.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 02:55:10 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id u206so118151754wme.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 02:55:10 -0700 (PDT)
Date: Mon, 25 Apr 2016 11:55:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
Message-ID: <20160425095508.GE23933@dhcp22.suse.cz>
References: <20160419200752.GA10437@dhcp22.suse.cz>
 <201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
 <20160420144758.GA7950@dhcp22.suse.cz>
 <201604212049.GFE34338.OQFOJSMOHFFLVt@I-love.SAKURA.ne.jp>
 <20160421130750.GA18427@dhcp22.suse.cz>
 <201604242319.GAF12996.tOJMOQFLFVOHSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604242319.GAF12996.tOJMOQFLFVOHSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Sun 24-04-16 23:19:03, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > I have seen that patch. I didn't get to review it properly yet as I am
> > still travelling. From a quick view I think it is conflating two things
> > together. I could see arguments for the panic part but I do not consider
> > the move-to-kill-another timeout as justified. I would have to see a
> > clear indication this is actually useful for real life usecases.
> 
> You admit that it is possible that the TIF_MEMDIE thread is blocked at
> unkillable wait (due to memory allocation requests by somebody else) but
> the OOM reaper cannot reap the victim's memory (due to holding the mmap_sem
> for write), don't you?

I have never said this to be impossible.

> Then, I think this patch makes little sense unless accompanied with the
> move-to-kill-another timeout. If the OOM reaper failed to reap the victim's
> memory, the OOM reaper simply clears TIF_MEMDIE from the victim thread. But
> since nothing has changed (i.e. the victim continues waiting, and the victim's
> memory is not reclaimed, and the victim's oom_score_adj is not updated to
> OOM_SCORE_ADJ_MIN), the OOM killer will select that same victim again.

Yes a patch to introduce a reliable panic-on-timeout would have to
solved this and it is not really trivial to do so.

> This forms an infinite loop. You will want to call panic() as soon as the OOM
> reaper failed to reap the victim's memory (than waiting for the panic timeout).
> 
> For both system operators at customer's companies and staffs at support center,
> avoiding hangup (due to OOM livelock) and panic (due to the OOM panic timeout)
> eliminates a lot of overhead. This is a practical benefit for them.
> 
> I also think that the purpose of killing only one task at a time than calling
> panic() is to save as much work as possible.

If we are locked up then there is no room to try to save some work. We
want the machine to recover rather than hope for anything.

> Therefore, I can't understand why
> you don't think that killing only another task via the move-to-kill-another
> timeout is a useful real life usecase.

I feel like I have to repeat myself. The argument is really simple. If
you have an unlikely possibility of a lockup then you you really want to
a _reliable_ way to get out of this unfortunate state. Kill-another-task
is a mere optimization which has to be evaluated for maintenance vs.
feasibility aspects. So far I am not really convicend about the second
while the first seems like a real concern because the oom code is
complex enough already.

You also have to consider that exporting sysctl knobs for one-off
usecases which are very specific to the implementation at the time have
proven bad. The implementation is moving on and there is no guarantee
that the OOM killer will see changes where the single oom victim will
make even sense - e.g. we might change the semantic to kill whole
containers or that the killing logic would be under control of the admin
(e.g. BPF filters or kernel modules or whatever).

No panic on timeout has a _clear_ semantic independent on the current
oom implementation. While move-to-other victim is not so clear in that
aspect.

> panic on timeout is a practical benefit for you, but giving several chances
> on timeout is a practical benefit for someone you don't know.

Then I would like to hear about that "someone I don't know" with a
clear usecase. So far you are only fuzzy about those and that is not
sufficient to add another subtle code. Did I make myself clear?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
