Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DCDC6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 11:23:26 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g35so7686354ioi.5
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 08:23:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u21si8894670ite.182.2017.08.07.08.23.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 08:23:24 -0700 (PDT)
Subject: Re: [PATCH 0/2] mm, oom: fix oom_reaper fallouts
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170807113839.16695-1-mhocko@kernel.org>
	<201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp>
	<20170807140409.GJ32434@dhcp22.suse.cz>
In-Reply-To: <20170807140409.GJ32434@dhcp22.suse.cz>
Message-Id: <201708080023.DCG00506.HtJOQVFFMFLOOS@I-love.SAKURA.ne.jp>
Date: Tue, 8 Aug 2017 00:23:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Mon 07-08-17 22:28:27, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > Hi,
> > > there are two issues this patch series attempts to fix. First one is
> > > something that has been broken since MMF_UNSTABLE flag introduction
> > > and I guess we should backport it stable trees (patch 1). The other
> > > issue has been brought up by Wenwei Tao and Tetsuo Handa has created
> > > a test case to trigger it very reliably. I am not yet sure this is a
> > > stable material because the test case is rather artificial. If there is
> > > a demand for the stable backport I will prepare it, of course, though.
> > > 
> > > I hope I've done the second patch correctly but I would definitely
> > > appreciate some more eyes on it. Hence CCing Andrea and Kirill. My
> > > previous attempt with some more context was posted here
> > > http://lkml.kernel.org/r/20170803135902.31977-1-mhocko@kernel.org
> > > 
> > > My testing didn't show anything unusual with these two applied on top of
> > > the mmotm tree.
> > 
> > I really don't like your likely/unlikely speculation.
> 
> Have you seen any non artificial workload triggering this?

It will be 5 to 10 years away from now to know whether non artificial
workload triggers this. (I mean, customers start using RHEL8.)

>                                                            Look, I am
> not going to argue about how likely this is or not. I've said I am
> willing to do backports if there is a demand but please do realize that
> this is not a trivial change to backport pre 4.9 kernels would require
> MMF_UNSTABLE to be backported as well. This all can be discussed
> after the merge so can we focus on the review now rather than any
> distractions?

3f70dc38cec2 was not working as expected. Nobody tested that OOM situation.
Then, I think we can revert 3f70dc38cec2, and then make it possible to uniformly
apply MMF_UNSTABLE to all 4.6+ kernels.

> 
> Also please note that while writing zeros is certainly bad any integrity
> assumptions are basically off when an application gets killed
> unexpectedly while performing an IO.

I consider unexpectedly saving process image (instead of zeros) to a file
is similar to fs.suid_dumpable problem (i.e. could cause a security problem).
I do expect that this patch is backported to RHEL8 (I don't know which version
RHEL8 will choose, but I guess it will be between 4.6 and 4.13).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
