Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A1E236B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 08:15:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w79so16806539wme.7
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 05:15:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j35si21954791eda.11.2017.06.02.05.15.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 05:15:37 -0700 (PDT)
Date: Fri, 2 Jun 2017 14:15:33 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170602121533.GH29840@dhcp22.suse.cz>
References: <20170601115936.GA9091@dhcp22.suse.cz>
 <201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
 <20170601132808.GD9091@dhcp22.suse.cz>
 <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
 <20170602071818.GA29840@dhcp22.suse.cz>
 <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

On Fri 02-06-17 20:13:32, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
> >> Michal Hocko wrote:
> >>> On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> >>>> Cong Wang has reported a lockup when running LTP memcg_stress test [1].
> >>>
> >>> This seems to be on an old and not pristine kernel. Does it happen also
> >>> on the vanilla up-to-date kernel?
> >>
> >> 4.9 is not an old kernel! It might be close to the kernel version which
> >> enterprise distributions would choose for their next long term supported
> >> version.
> >>
> >> And please stop saying "can you reproduce your problem with latest
> >> linux-next (or at least latest linux)?" Not everybody can use the vanilla
> >> up-to-date kernel!
> >
> > The changelog mentioned that the source of stalls is not clear so this
> > might be out-of-tree patches doing something wrong and dump_stack
> > showing up just because it is called often. This wouldn't be the first
> > time I have seen something like that. I am not really keen on adding
> > heavy lifting for something that is not clearly debugged and based on
> > hand waving and speculations.
> 
> You are asking users to prove that the problem is indeed in the MM subsystem,
> but you are thinking that kmallocwd which helps users to check whether the
> problem is indeed in the MM subsystem is not worth merging into mainline.
> As a result, we have to try things based on what you think handwaving and
> speculations. This is a catch-22. If you don't want handwaving/speculations,
> please please do provide a mechanism for checking (a) and (b) shown later.

configure watchdog to bug on soft lockup, take a crash dump, see what
is going on there and you can draw a better picture of what is going on
here. Seriously I am fed up with all the "let's do the async thing
because it would tell much more" side discussions. You are trying to fix
a soft lockup which alone is not a deadly condition. If the system is
overwhelmed it can happen and if that is the case then we should care
whether it gets resolved or it is a permanent livelock situation. If yes
then we need to isolate which path is not preempting and why and place
the cond_resched there. The page allocator contains preemption points,
if we are lacking some for some pathological paths let's add them. For
some reason you seem to be focused only on the warn_alloc path, though,
while the real issue might be somewhere completely else.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
