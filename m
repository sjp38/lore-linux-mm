Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 51C7D6B7E03
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 07:10:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p51-v6so4576684eda.18
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 04:10:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p91-v6si1278370edd.11.2018.09.07.04.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 04:10:39 -0700 (PDT)
Date: Fri, 7 Sep 2018 13:10:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180907111038.GH19621@dhcp22.suse.cz>
References: <20180806205121.GM10003@dhcp22.suse.cz>
 <0aeb76e1-558f-e38e-4c66-77be3ce56b34@I-love.SAKURA.ne.jp>
 <20180906113553.GR14951@dhcp22.suse.cz>
 <87b76eea-9881-724a-442a-c6079cbf1016@i-love.sakura.ne.jp>
 <20180906120508.GT14951@dhcp22.suse.cz>
 <37b763c1-b83e-1632-3187-55fb360a914e@i-love.sakura.ne.jp>
 <20180906135615.GA14951@dhcp22.suse.cz>
 <8dd6bc67-3f35-fdc6-a86a-cf8426608c75@i-love.sakura.ne.jp>
 <20180906141632.GB14951@dhcp22.suse.cz>
 <55a3fb37-3246-73d7-0f45-5835a3f4831c@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55a3fb37-3246-73d7-0f45-5835a3f4831c@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Fri 07-09-18 06:13:13, Tetsuo Handa wrote:
> On 2018/09/06 23:16, Michal Hocko wrote:
> > On Thu 06-09-18 23:06:40, Tetsuo Handa wrote:
> >> On 2018/09/06 22:56, Michal Hocko wrote:
> >>> On Thu 06-09-18 22:40:24, Tetsuo Handa wrote:
> >>>> On 2018/09/06 21:05, Michal Hocko wrote:
> >>>>>> If you are too busy, please show "the point of no-blocking" using source code
> >>>>>> instead. If such "the point of no-blocking" really exists, it can be executed
> >>>>>> by allocating threads.
> >>>>>
> >>>>> I would have to study this much deeper but I _suspect_ that we are not
> >>>>> taking any blocking locks right after we return from unmap_vmas. In
> >>>>> other words the place we used to have synchronization with the
> >>>>> oom_reaper in the past.
> >>>>
> >>>> See commit 97b1255cb27c551d ("mm,oom_reaper: check for MMF_OOM_SKIP before
> >>>> complaining"). Since this dependency is inode-based (i.e. irrelevant with
> >>>> OOM victims), waiting for this lock can livelock.
> >>>>
> >>>> So, where is safe "the point of no-blocking" ?
> >>>
> >>> Ohh, right unlink_file_vma and its i_mmap_rwsem lock. As I've said I
> >>> have to think about that some more. Maybe we can split those into two parts.
> >>>
> >>
> >> Meanwhile, I'd really like to use timeout based back off. Like I wrote at
> >> http://lkml.kernel.org/r/201809060703.w8673Kbs076435@www262.sakura.ne.jp ,
> >> we need to wait for some period after all.
> >>
> >> We can replace timeout based back off after we got safe "the point of no-blocking" .
> > 
> > Why don't you invest your time in the long term solution rather than
> > playing with something that doesn't solve anything just papers over the
> > issue?
> > 
> 
> I am not a MM people. I am a secure programmer from security subsystem.

OK, so let me be completely honest with you. You have pretty strong
statements about the MM code while you are not considering yourself an
MM person. You are suggesting hacks which do not solve real underlying
problems and I will keep shooting those down.

> You are almost always introducing bugs (like you call dragons) rather
> than starting from safe changes. The OOM killer _is_ always racy. Even
> your what you think the long term solution _shall be_ racy. 

The reason why this area is so easy to to get wrong is basically a lack
of comprehensible design.  We have historical hacks here and there. I
really do not want to follow that direction and as long as my word has
some weigh (which is not my decision of course) I will keep fighting
for simplifications and an overall design refinements. If we are to add
heuristic they should be backed by well understood workloads we do care
about.

You might have your toy workload that hits different corner cases and
testing those is fine. But I absolutely disagree to base any non trivial
changes for that kind of workload unless they are a general improvement.

If you disagree then we have to agree to disagree and it doesn't make
much sense to continue in discussion.

> I can't waste my time in what you think the long term solution. Please
> don't refuse/ignore my (or David's) patches without your counter
> patches.

If you do not care about long term sanity of the code and if you do not
care about a larger picture then I am not interested in any patches from
you. MM code is far from trivial and no playground. This attitude of
yours is just dangerous.
-- 
Michal Hocko
SUSE Labs
