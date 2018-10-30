Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99A5A6B028E
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 09:57:59 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id o8-v6so11032108iom.6
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 06:57:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p5-v6si13933763iog.26.2018.10.30.06.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 06:57:58 -0700 (PDT)
Subject: Re: [RFC PATCH v2 3/3] mm, oom: hand over MMF_OOM_SKIP to exit path
 if it is guranteed to finish
References: <20181025082403.3806-1-mhocko@kernel.org>
 <20181025082403.3806-4-mhocko@kernel.org>
 <201810300445.w9U4jMhu076672@www262.sakura.ne.jp>
 <20181030063136.GU32673@dhcp22.suse.cz>
 <95cb93ec-2421-3c5d-fd1e-91d9696b0f5a@I-love.SAKURA.ne.jp>
 <20181030113915.GB32673@dhcp22.suse.cz>
 <ca390ac1-2f10-b734-fff7-56767253e8c5@i-love.sakura.ne.jp>
 <20181030121012.GC32673@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0b1a8c3b-8346-ba7d-da7b-3c79354e11d7@i-love.sakura.ne.jp>
Date: Tue, 30 Oct 2018 22:57:37 +0900
MIME-Version: 1.0
In-Reply-To: <20181030121012.GC32673@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/10/30 21:10, Michal Hocko wrote:
> I misunderstood your concern. oom_reaper would back off without
> MMF_OOF_SKIP as well. You are right we cannot assume anything about
> close callbacks so MMF_OOM_SKIP has to come before that. I will move it
> behind the pagetable freeing.
> 

And at that point, your patch can at best wait for only __free_pgtables(),
at the cost/risk of complicating exit_mmap() and arch specific code. Also,
you are asking for comments to wrong audiences. It is arch maintainers who
need to precisely understand the OOM behavior / possibility of OOM lockup,
and you must persuade them about restricting/complicating future changes in
their arch code due to your wish to allow handover. Without "up-to-dated
big fat comments to all relevant functions affected by your change" and
"acks from all arch maintainers", I'm sure that people keep making
errors/mistakes/overlooks.

My patch can wait for completion of (not only exit_mmap() but also) __mmput(),
by using simple polling approach. My patch can allow NOMMU kernels to avoid
possibility of OOM lockup by setting MMF_OOM_SKIP at __mmput() (and future
patch will implement timeout based back off for NOMMU kernels), and allows you
to get rid of TIF_MEMDIE (which you recently added to your TODO list) by getting
rid of conditional handling of oom_reserves_allowed() and ALLOC_OOM.

Your "refusing timeout based next OOM victim selection" keeps everyone unable
to safely make forward progress. OOM handling is too much complicated, and
nobody can become free from errors/mistakes/overlooks. Look at the reality!
