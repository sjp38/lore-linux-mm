Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 24DDB6B0267
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:31:34 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xm6so20284622pab.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:31:34 -0700 (PDT)
Received: from mail-pf0-f196.google.com (mail-pf0-f196.google.com. [209.85.192.196])
        by mx.google.com with ESMTPS id ff4si3693046pad.48.2016.04.26.07.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 07:31:33 -0700 (PDT)
Received: by mail-pf0-f196.google.com with SMTP id 145so1720937pfz.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:31:33 -0700 (PDT)
Date: Tue, 26 Apr 2016 16:31:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: Re-enable OOM killer using timeout.
Message-ID: <20160426143129.GD20813@dhcp22.suse.cz>
References: <201604200006.FBG45192.SOHFQJFOOLFMtV@I-love.SAKURA.ne.jp>
 <20160419200752.GA10437@dhcp22.suse.cz>
 <201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
 <201604201937.AGB86467.MOFFOOQJVFHLtS@I-love.SAKURA.ne.jp>
 <20160425114733.GF23933@dhcp22.suse.cz>
 <201604262300.IFD43745.FMOLFJFQOVStHO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604262300.IFD43745.FMOLFJFQOVStHO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Tue 26-04-16 23:00:15, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Hmm, I guess we have already discussed that in the past but I might
> > misremember. The above relies on oom killer to be triggered after the
> > previous victim was selected. There is no guarantee this will happen.
> 
> Why there is no guarantee this will happen?

What happens if you even do not hit the out_of_memory path? E.g
GFP_FS allocation being stuck somewhere in shrinkers waiting for
somebody to make a forward progress which never happens. Because this is
essentially what would block the mmap_sem write holder as well and what
you are trying to workaround by the timeout based approach.

> This OOM livelock is caused by waiting for TIF_MEMDIE threads forever
> unconditionally. If oom_unkillable_task() is not called, it is not
> the OOM killer's problem.

It really doesn't matter whose problem is that because whoever it is
doesn't have a full picture to draw any conclusions.

[...]

> These OOM livelocks are caused by lack of mechanism for hearing administrator's
> policy. We are missing rescue mechanisms which are needed for recovering from
> situations your model did not expect.

I am not opposed against a rescue policy defined by the admin. All I
am saying is that the only save and reasonably maintainable one with
_predictable_ behavior I can see is to reboot/panic/killall-tasks after
a certain timeout. You consider this to be too harsh but do you at
least agree that the semantic of this is clear and an admin knows what
the behavior would be? As we are not able to find a consensus on
go-to-other-victim approach can we at least agree on the absolute last
resort first?

We will surely hear complains if this is too coarse and users really
need something more fine grained.
 
> I'm talking about corner cases where your deterministic approach fail. What we
> need is "stop waiting for something forever unconditionally" and "hear what the
> administrator wants to do". You can deprecate and then remove sysctl knobs for
> hearing what the administrator wants to do when you developed perfect model and
> mechanism.
> 
> > Why cannot we get back to the timer based solution at least for the
> > panic timeout?
> 
> Use of global timer can cause false positive panic() calls.

Race that would take in orders of tens of seconds which would be the
most probable chosen value doesn't matter that much IMHO.

> Timeout should be calculated for per task_struct or signal_struct basis.
> 
> Also, although a different problem, global timer based solution does not
> work for OOM livelock without any TIF_MEMDIE thread case (an example
> shown above).

which is a technical detail which can be solved.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
