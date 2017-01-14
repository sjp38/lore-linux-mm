Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6918A6B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 05:10:58 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id j82so130902343oih.6
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 02:10:58 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h20si6148601oib.88.2017.01.14.02.10.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 02:10:56 -0800 (PST)
Subject: Re: [PATCH] mm: Ignore __GFP_NOWARN when reporting stalls
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1484132120-35288-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170111161228.GE16365@dhcp22.suse.cz>
	<201701132000.HJB81754.VOQtFMSJOFFHLO@I-love.SAKURA.ne.jp>
	<20170114090613.GD9962@dhcp22.suse.cz>
In-Reply-To: <20170114090613.GD9962@dhcp22.suse.cz>
Message-Id: <201701141910.ACF73418.OJHFVFStQOOMFL@I-love.SAKURA.ne.jp>
Date: Sat, 14 Jan 2017 19:10:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 13-01-17 20:00:11, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > So rather than repeating why you think that warn_alloc is worse than a
> > > different solution which you are trying to push through you should in
> > > fact explain why we should handle stall and allocation failure warnings
> > > differently and how are we going to handle potential future users who
> > > would like to disable warning for both. Because once you change the
> > > semantic we will have problems to change it like for other gfp flags.
> > 
> > Oh, thank you very much for positive (or at least neutral) response to
> > asynchronous watchdog. I don't mean to change the semantic of GFP flags
> > if we can go with asynchronous watchdog. I'm posting this patch because
> > there is no progress with asynchronous watchdog.
> > 
> > I'm not sure what "why we should handle stall and allocation failure
> > warnings differently" means. Which one did you mean?
> > 
> >   (a) "why we should handle stall warning by synchronous watchdog
> >       (e.g. warn_alloc()) and allocation failure warnings differently"
> > 
> >   (b) "why we should handle stall warning by asynchronous watchdog
> >       (e.g. kmallocwd) and allocation failure warnings differently"
> > 
> > If you meant (a), it is because allocation livelock is a problem which
> > current GFP flags semantics cannot handle. We had been considering only
> > allocation failures. We have never considered allocation livelock which
> > is observed as allocation stalls. (The allocation livelock after the OOM
> > killer is invoked was solved by the OOM reaper. But I'm talking about
> > allocation livelock before the OOM killer is invoked,
> 
> I am not going to allow defining a weird __GFP_NOWARN semantic which
> allows warnings but only sometimes. At least not without having a proper
> way to silence both failures _and_ stalls or just stalls. I do not
> really thing this is worth the additional gfp flag.
> 
> > and I don't think
> > this problem can be solved within a few years because this problem is
> > caused by optimistic direct reclaim.
> 
> And again your are trying to define a weird semantic just because the
> original problem seems too hard. This is a really wrong way to do
> the development. And again the oom repear should serve you as an example
> that things can be done _properly_ rather than tweaked around with
> "sometimes works but not always" solutions.
> 
> I plan to address the too_many_isolated problem. In fact I already have
> some preliminary work done which I plan to post next week. An unbound
> loop inside the reclaim is certainly something to get rid of and AFAIK
> this is the only problem which can prevent reasonable return to the page
> allocator.

Sigh. You are again looking at only bugs which are reported. If I care only
too_many_isolated() case, I don't need to propose asynchronous watchdog.
Since I believe that there are bugs which averaged administrator cannot
afford reporting, I'm proposing asynchronous watchdog for automatic reporting.

Tetsuo Handa wrote at http://lkml.kernel.org/r/201612282042.GDB17129.tOHFOFSQOFLVJM@I-love.SAKURA.ne.jp :
> > There has never been a disagreement here. The point we seem to be
> > disagreeing is how much those issues you are seeing matter. I do not
> > consider them top priority because they are not happening in real life
> > enough.
> 
> There is no evidence to prove "they are not happening in real life enough", for
> there is no catch-all reporting mechanism. I consider that offering a mean to
> find and report problems is top priority as a troubleshooting staff.

I repeat: "AFAIK this is the only problem" is not acceptable.

Andrew, what do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
