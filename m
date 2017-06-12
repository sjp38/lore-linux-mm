Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE2166B02C3
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 06:48:21 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 193so29816036itr.10
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 03:48:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f87si8128843iod.231.2017.06.12.03.48.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 03:48:20 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the #PF
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170609140853.GA14760@cmpxchg.org>
	<20170609144642.GH21764@dhcp22.suse.cz>
	<20170610084901.GB12347@dhcp22.suse.cz>
	<201706102057.GGG13003.OtFMJSQOVLFOHF@I-love.SAKURA.ne.jp>
	<20170612073922.GA7476@dhcp22.suse.cz>
In-Reply-To: <20170612073922.GA7476@dhcp22.suse.cz>
Message-Id: <201706121948.CEC81794.OFMLFSJOtHOQFV@I-love.SAKURA.ne.jp>
Date: Mon, 12 Jun 2017 19:48:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, guro@fb.com, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sat 10-06-17 20:57:46, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > And just to clarify a bit. The OOM killer should be invoked whenever
> > > appropriate from the allocation context. If we decide to fail the
> > > allocation in the PF path then we can safely roll back and retry the
> > > whole PF. This has an advantage that any locks held while doing the
> > > allocation will be released and that alone can help to make a further
> > > progress. Moreover we can relax retry-for-ever _inside_ the allocator
> > > semantic for the PF path and fail allocations when we cannot make
> > > further progress even after we hit the OOM condition or we do stall for
> > > too long.
> > 
> > What!? Are you saying that leave the allocator loop rather than invoke
> > the OOM killer if it is from page fault event without __GFP_FS set?
> > With below patch applied (i.e. ignore __GFP_FS for emulation purpose),
> > I can trivially observe systemwide lockup where the OOM killer is
> > never called.
> 
> Because you have ruled the OOM out of the game completely from the PF
> path AFICS.

Yes, I know.

>             So that is clearly _not_ what I meant (read the second
> sentence). What I meant was that page fault allocations _could_ fail
> _after_ we have used _all_ the reclaim opportunities.

I used this patch for demonstrating what will happen if page fault
allocations failed but the OOM killer does not trigger.

>                                                       Without this patch
> this would be impossible.

What I wanted to say is that, with this patch, you are introducing possibility
of lockup. "Retrying the whole page fault path when page fault allocations
failed but the OOM killer does not trigger" helps nothing. It will just spin
wasting CPU time until somebody else invokes the OOM killer.

>                           Note that I am not proposing that change now
> because that would require a deeper audit but it sounds like a viable
> way to go long term.

I don't think introducing possibility of "page fault allocations failed
but the OOM killer does not trigger" makes sense. Thus, this patch does not
make sense unless we invoke the OOM killer before returning VM_FAULT_OOM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
