Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE9A6B0271
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:55:58 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m190so3903366pgm.4
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:55:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2-v6si13485675pli.539.2018.04.17.08.55.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:55:52 -0700 (PDT)
Date: Tue, 17 Apr 2018 17:55:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417155549.6lxmoiwnlwtwdgld@quack2.suse.cz>
References: <20180416113629.2474ae74@gandalf.local.home>
 <20180416160200.GY2341@sasha-vm>
 <20180416121224.2138b806@gandalf.local.home>
 <20180416161911.GA2341@sasha-vm>
 <20180416123019.4d235374@gandalf.local.home>
 <20180416163754.GD2341@sasha-vm>
 <20180416170604.GC11034@amd>
 <20180416172327.GK2341@sasha-vm>
 <20180417114144.ov27khlig5thqvyo@quack2.suse.cz>
 <20180417133149.GR2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417133149.GR2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Jan Kara <jack@suse.cz>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue 17-04-18 13:31:51, Sasha Levin wrote:
> On Tue, Apr 17, 2018 at 01:41:44PM +0200, Jan Kara wrote:
> >On Mon 16-04-18 17:23:30, Sasha Levin wrote:
> >> On Mon, Apr 16, 2018 at 07:06:04PM +0200, Pavel Machek wrote:
> >> >On Mon 2018-04-16 16:37:56, Sasha Levin wrote:
> >> >> On Mon, Apr 16, 2018 at 12:30:19PM -0400, Steven Rostedt wrote:
> >> >> >On Mon, 16 Apr 2018 16:19:14 +0000
> >> >> >Sasha Levin <Alexander.Levin@microsoft.com> wrote:
> >> >> >
> >> >> >> >Wait! What does that mean? What's the purpose of stable if it is as
> >> >> >> >broken as mainline?
> >> >> >>
> >> >> >> This just means that if there is a fix that went in mainline, and the
> >> >> >> fix is broken somehow, we'd rather take the broken fix than not.
> >> >> >>
> >> >> >> In this scenario, *something* will be broken, it's just a matter of
> >> >> >> what. We'd rather have the same thing broken between mainline and
> >> >> >> stable.
> >> >> >
> >> >> >Honestly, I think that removes all value of the stable series. I
> >> >> >remember when the stable series were first created. People were saying
> >> >> >that it wouldn't even get to more than 5 versions, because the bar for
> >> >> >backporting was suppose to be very high. Today it's just a fork of the
> >> >> >kernel at a given version. No more features, but we will be OK with
> >> >> >regressions. I'm struggling to see what the benefit of it is suppose to
> >> >> >be?
> >> >>
> >> >> It's not "OK with regressions".
> >> >>
> >> >> Let's look at a hypothetical example: You have a 4.15.1 kernel that has
> >> >> a broken printf() behaviour so that when you:
> >> >>
> >> >> 	pr_err("%d", 5)
> >> >>
> >> >> Would print:
> >> >>
> >> >> 	"Microsoft Rulez"
> >> >>
> >> >> Bad, right? So you went ahead and fixed it, and now it prints "5" as you
> >> >> might expect. But alas, with your patch, running:
> >> >>
> >> >> 	pr_err("%s", "hi!")
> >> >>
> >> >> Would show a cat picture for 5 seconds.
> >> >>
> >> >> Should we take your patch in -stable or not? If we don't, we're stuck
> >> >> with the original issue while the mainline kernel will behave
> >> >> differently, but if we do - we introduce a new regression.
> >> >
> >> >Of course not.
> >> >
> >> >- It must be obviously correct and tested.
> >> >
> >> >If it introduces new bug, it is not correct, and certainly not
> >> >obviously correct.
> >>
> >> As you might have noticed, we don't strictly follow the rules.
> >>
> >> Take a look at the whole PTI story as an example. It's way more than 100
> >> lines, it's not obviously corrent, it fixed more than 1 thing, and so
> >> on, and yet it went in -stable!
> >>
> >> Would you argue we shouldn't have backported PTI to -stable?
> >
> >So I agree with that being backported. But I think this nicely demostrates
> >a point some people are trying to make in this thread. We do take fixes
> >with high risk or regression if they fix serious enough issue. Also we do
> >take fixes to non-serious stuff (such as addition of device ID) if the
> >chances of regression are really low.
> >
> >So IMHO the metric for including the fix is not solely "how annoying to
> >user this can be" but rather something like:
> >
> >score = (how annoying the bug is) * ((1 / (chance of regression due to
> >	including this)) - 1)^3
> >
> >(constants are somewhat arbitrary subject to tuning ;). Now both 'annoying'
> >and 'regression chance' parts are subjective and sometimes difficult to
> >estimate so don't take the formula too seriously but it demonstrates the
> >point. I think we all agree we want to fix annoying stuff and we don't want
> >regressions. But you need to somehow weight this over your expected
> >userbase - and this is where your argument "but someone might be annoyed by
> >LEDs not working so let's include it" has problems - it should rather be
> >"is the annoyance of non-working leds over expected user base high enough
> >to risk a regression due to this patch for someone in the expected user
> >base"? The answer to this second question is not clear at all to a casual
> >reviewer and that's why we IMHO have CC stable tag as maintainer is
> >supposed to have at least a bit better clue.
> 
> We may be able to guesstimate the 'regression chance', but there's no
> way we can guess the 'annoyance' once. There are so many different use
> cases that we just can't even guess how many people would get "annoyed"
> by something.

As a maintainer, I hope I have reasonable idea what are common use cases
for my subsystem. Those I cater to when estimating 'annoyance'. Sure I don't
know all of the use cases so people doing unusual stuff hit more bugs and
have to report them to get fixes included in -stable. But for me this is a
preferable tradeoff over the risk of regression so this is the rule I use
when tagging for stable. Now I'm not a -stable maintainer and I fully agree
with "those who do the work decide" principle so pick whatever patches you
think are appropriate, I just wanted explain why I don't think more patches
in stable are necessarily good. 

> Even regression chance is tricky, look at the commits I've linked
> earlier in the thread. Even the most trivial looking commits that end up
> in stable have a chance for regression.

Sure, you can never be certain and I think people (including me)
underestimate the chance of regressions for "trivial" patches. But you just
estimate a chance, you may be lucky, you may not...

> >Another point I wanted to make is that if chance a patch causes a
> >regression is about 2% as you said somewhere else in a thread, then by
> >adding 20 patches that "may fix a bug that is annoying for someone" you've
> >just increased a chance there's a regression in the release by 34%. And
> 
> So I've said that the rejection rate is less than 2%. This includes
> all commits that I have proposed for -stable, but didn't end up being
> included in -stable.
> 
> This includes commits that the author/maintainers NACKed, commits that
> didn't do anything on older kernels, commits that were buggy but were
> caught before the kernel was released, commits that failed to build on
> an arch I didn't test it on originally and so on.
> 
> After thousands of merged AUTOSEL patches I can count the number of
> times a commit has caused a regression and had to be removed on one
> hand.
> 
> >this is not just a math game, this also roughly matches a real experience
> >with maintaining our enterprise kernels. Do 20 "maybe" fixes outweight such
> >regression chance? And I also note that for a regression to get reported so
> >that it gets included into your 2% estimate of a patch regression rate,
> >someone must be bothered enough by it to triage it and send an email
> >somewhere so that already falls into a category of "serious" stuff to me.
> 
> It is indeed a numbers game, but the regression rate isn't 2%, it's
> closer to 0.05%.

Honestly, I think 0.05% is too optimististic :) Quick grepping of 4.14
stable tree suggests some 13 commits were reverted from stable due to bugs.
That's some 0.4% and that doesn't count fixes that were applied to
fix other regressions.

But the actual numbers don't really matter that much, in principle the more
patches you add the higher is the chance of regression. You can't change
that so you better have a good reason to include a patch...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
