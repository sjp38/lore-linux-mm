Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5514E6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 15:02:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b130so11809993wmc.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 12:02:58 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id o76si22434432wmg.82.2016.09.19.12.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 12:02:56 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id b130so78885209wmc.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 12:02:56 -0700 (PDT)
Date: Mon, 19 Sep 2016 21:02:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 0/4] mm, oom: get rid of TIF_MEMDIE
Message-ID: <20160919190254.GC25740@dhcp22.suse.cz>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
 <20160915144118.GB25519@cmpxchg.org>
 <20160916071517.GA29534@dhcp22.suse.cz>
 <20160919161837.GA29553@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160919161837.GA29553@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>

On Mon 19-09-16 12:18:37, Johannes Weiner wrote:
> On Fri, Sep 16, 2016 at 09:15:17AM +0200, Michal Hocko wrote:
[...]
> : For ages we have been relying on TIF_MEMDIE thread flag to mark OOM
> : victims and then, among other things, to give these threads full
> : access to memory reserves. There are few shortcomings of this
> : implementation, though.
> : 
> : First of all and the most serious one is that the full access to memory
> : reserves is quite dangerous because we leave no safety room for the
> : system to operate and potentially do last emergency steps to move on.
> 
> Do we encounter this in practice?

We rarely experience anything from this in practice. Even OOM is an
outstanding situation. Most of the lockups I am trying to solve are
close to non-existent. But this doesn't mean they are non-existent so as
far as the resulting code makes sense and doesn't make the situation
overly more complicated then I would go with enhancements.

> I think one of the clues is that you
> introduce the patch with "for ages we have been doing X", so I'd like
> to see a more practical explanation of how we did it was flawed.

OK, I will try harder to explain that. The core idea is that we couldn't
do anything better without the async oom killing because we were
strictly synchronous and only the victim could make some progress.

> : Secondly this flag is per task_struct while the OOM killer operates
> : on mm_struct granularity so all processes sharing the given mm are
> : killed. Giving the full access to all these task_structs could leave to
> : a quick memory reserves depletion. We have tried to reduce this risk by
> : giving TIF_MEMDIE only to the main thread and the currently allocating
> : task but that doesn't really solve this problem while it surely opens up
> : a room for corner cases - e.g. GFP_NO{FS,IO} requests might loop inside
> : the allocator without access to memory reserves because a particular
> : thread was not the group leader.
> 
> Same here I guess.
> 
> It *sounds* to me like there are two different things going on
> here. One being the access to emergency reserves, the other being the
> synchronization token to count OOM victims. Maybe it would be easier
> to separate those issues out in the line of argument?

Yes this is precisely the problem. The meaning of the flag is overloaded
for multiple purposes and it is not as easy to describe all of this and
get tangled in all the details. Over time we have reduced the locking
side of the flag but we still use it for oom_disable synchronization
and memory reserves access.

> For emergency reserves, you make the point that we now have the reaper
> and don't rely on the reserves as much anymore. However, we need to
> consider that the reaper relies on the mmap_sem and is thus not as
> robust as the concept of an emergency pool to guarantee fwd progress.

Yes it is not 100% but if we get stuck there then we will have a way to
go on to another victim so we will not lockup. On the other hand lockup
due to mmap_sem for write should be really rare because the lock is
mostly killable and taken outside of the oom victim context even more
rarely.

> For synchronization, I don't quite get the argument. The patch 4
> changelog uses term like "not optimal" and that we "should" be doing
> certain things, but doesn't explain the consequences of the "wrong"
> behavior, the impact is of frozen threads getting left behind etc.

Yes I will try harder. The primary point is a mismatch between oom
killer being per-mm operation and the flag being per-thread thing. For
the freezer context it means that only one thread is woken up while
other are still in the fridge. This wouldn't be a big deal for the pm
freezer but the cgroup freezer allows normal user to hide processes in
the fridge so users might hide processes there intentionally. The other
part of the puzzle is that not all resources are reclaimable by the
async oom killer. Say pipe/socket buffers can consume a lot of memory
while they are pinned by process not threads.

> That stuff would be useful to know, both in the cover letter (higher
> level user impact) and the changelogs (more detailed user impact).
> 
> I.e. sell the problem before selling the solution :-)

Sure, I see what you are saying. I just feel there are so many subtle
details that it is hard to squeeze all of them into the changelog and
still make some sense ;)

Anyway, I will definitely try to be more specific in the next post.
Thanks for the feedback!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
