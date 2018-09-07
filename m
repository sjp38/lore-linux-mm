Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE5A26B7E32
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 07:51:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x24-v6so4778504edm.13
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 04:51:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x51-v6si2860473edm.270.2018.09.07.04.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 04:51:33 -0700 (PDT)
Date: Fri, 7 Sep 2018 13:51:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180907115132.GJ19621@dhcp22.suse.cz>
References: <20180906113553.GR14951@dhcp22.suse.cz>
 <87b76eea-9881-724a-442a-c6079cbf1016@i-love.sakura.ne.jp>
 <20180906120508.GT14951@dhcp22.suse.cz>
 <37b763c1-b83e-1632-3187-55fb360a914e@i-love.sakura.ne.jp>
 <20180906135615.GA14951@dhcp22.suse.cz>
 <8dd6bc67-3f35-fdc6-a86a-cf8426608c75@i-love.sakura.ne.jp>
 <20180906141632.GB14951@dhcp22.suse.cz>
 <55a3fb37-3246-73d7-0f45-5835a3f4831c@i-love.sakura.ne.jp>
 <20180907111038.GH19621@dhcp22.suse.cz>
 <4e1bcda7-ab40-3a79-f566-454e1f24c0ff@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4e1bcda7-ab40-3a79-f566-454e1f24c0ff@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Fri 07-09-18 20:36:31, Tetsuo Handa wrote:
> On 2018/09/07 20:10, Michal Hocko wrote:
> >> I can't waste my time in what you think the long term solution. Please
> >> don't refuse/ignore my (or David's) patches without your counter
> >> patches.
> > 
> > If you do not care about long term sanity of the code and if you do not
> > care about a larger picture then I am not interested in any patches from
> > you. MM code is far from trivial and no playground. This attitude of
> > yours is just dangerous.
> > 
> 
> Then, please explain how we guarantee that enough CPU resource is spent
> between "exit_mmap() set MMF_OOM_SKIP" and "the OOM killer finds MMF_OOM_SKIP
> was already set" so that last second allocation with high watermark can't fail
> when 50% of available memory was already reclaimed.

There is no guarantee. Full stop! This is an inherently racy land. We
can strive to work reasonably well but this will never be perfect. And
no, no timeout is going to solve it either. We have to live with the
fact that sometimes we hit the race and kill an additional task. As long
as there are no reasonable workloads which hit this race then we are
good enough.

The only guarantee we can talk about is the forward progress guarantee.
If we know that exit_mmap is past the blocking point then we can hand
over MMF_OOM_SKIP setting to the exit path rather than oom_reaper. Last
moment (minute, milisecond, nanosecond for that matter) allocation is in
no way related or solveable without a strong locking and we have learned
this is not a good idea in the past.

This is nothing new though. This discussion is not moving forward. It
just burns time so this is my last email in this thread.
-- 
Michal Hocko
SUSE Labs
