Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9F196B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 08:02:22 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 73so101966pfz.11
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 05:02:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o185si73989pga.27.2017.12.05.05.02.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 05:02:18 -0800 (PST)
Date: Tue, 5 Dec 2017 14:02:15 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/3] mm,oom: Move last second allocation to inside the
 OOM killer.
Message-ID: <20171205130215.bxkgzbzo25sljmgd@dhcp22.suse.cz>
References: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171201143317.GC8097@cmpxchg.org>
 <20171201144634.sc4cn6hyyt6zawms@dhcp22.suse.cz>
 <20171201145638.GA10280@cmpxchg.org>
 <20171201151715.yiep5wkmxmp77nxn@dhcp22.suse.cz>
 <20171201155711.GA11057@cmpxchg.org>
 <20171201163830.on5mykdtet2wa5is@dhcp22.suse.cz>
 <20171205104601.GA1898@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205104601.GA1898@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Tue 05-12-17 10:46:01, Johannes Weiner wrote:
> On Fri, Dec 01, 2017 at 05:38:30PM +0100, Michal Hocko wrote:
[...]
> > So are you saying that the existing last allocation attempt is more
> > reasonable? I've tried to remove it [1] and you were against that.
> > 
> > All I'am trying to tell is that _if_ we want to have something like
> > the last moment allocation after reclaim gave up then it should happen
> > closer to the killing the actual disruptive operation. The current
> > attempt in __alloc_pages_may_oom makes only very little sense to me.
> 
> Yes, you claim that, but you're not making a convincing case to me.
> 
> That last attempt serializes OOM conditions. It doesn't matter where
> it is before the OOM kill as long as it's inside the OOM lock, because
> these are the outcomes from the locked section:
> 
> 	1. It's the first invocation, nothing is on the freelist, no
> 	task has TIF_MEMDIE set. Choose a victim and kill.
> 
> 	2. It's the second invocation, the first invocation is still
> 	active. The trylock fails and we retry.
> 
> 	3. It's the second invocation, a victim has been dispatched
> 	but nothing has been freed. TIF_MEMDIE is found, we retry.
> 
> 	4. It's the second invocation, a victim has died (or been
> 	reaped) and freed memory. The allocation succeeds.
> 
> That's how the OOM state machine works in the presence of multiple
> allocating threads, and the code as is makes perfect sense to me.
> 
> Your argument for moving the allocation attempt closer to the kill is
> because the OOM kill is destructive and we don't want it to happen
> when something unrelated happens to free memory during the victim
> selection. I do understand that.
> 
> My argument against doing that is that the OOM kill is destructive and
> we want it tied to memory pressure as determined by reclaim, not
> random events we don't have control over, so that users can test the
> safety of the memory pressure created by their applications before
> putting them into production environments.
> 
> We'd give up a certain amount of determinism and reproducibility, and
> introduce unexpected implementation-defined semantics (currently the
> sampling window for pressure is reclaim time, afterwards it would
> include OOM victim selection time), in an attempt to probabilistically
> reduce OOM kills under severe memory pressure by an unknown factor.
> 
> This might sound intriguing when you only focus on the split second
> between the last reclaim attempt and when we issue the kill - "hey,
> look, here is one individual instance of a kill I could have avoided
> by exploiting a race condition."
> 
> But it's bad system behavior. For most users OOM kills are extremely
> disruptive. Literally the only way to make them any worse is by making
> them unpredictable and less reproducible.

Thanks for the extended clarification. I understand your concern much
more now. I do not fully agree, though.

OOM killer has always had that "try to prevent killing a victim"
approach in it and on some cases it is a good thing. Basically anytime
when there are reasonable changes of a forward progress then a saved
kill might save a workload and user data. That is something we really
care about much more than a determinism which is quite limited by the
fact that the memory reclaim itself cannot be deterministic because
there way too many parties to interact together on a highly complex
system.

On the other hand we used to have some back-off heuristics which were
promissing a forward progress yet they had some rough edges and were too
livelock happy. So this is definitely a tricky area.

> I do understand the upsides you're advocating for - although you
> haven't quantified them. They're just not worth the downsides.

OK, fair enough. Let's drop the patch then. There is no _strong_
justification for it and what I've seen as "nice to have" is indeed
really hard to quantify and not really worth merging without a full
consensus.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
