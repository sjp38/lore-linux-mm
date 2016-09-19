Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE2C6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 12:18:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b130so8824007wmc.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 09:18:45 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f67si20428252wmg.128.2016.09.19.09.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 09:18:44 -0700 (PDT)
Date: Mon, 19 Sep 2016 12:18:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 0/4] mm, oom: get rid of TIF_MEMDIE
Message-ID: <20160919161837.GA29553@cmpxchg.org>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
 <20160915144118.GB25519@cmpxchg.org>
 <20160916071517.GA29534@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160916071517.GA29534@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>

On Fri, Sep 16, 2016 at 09:15:17AM +0200, Michal Hocko wrote:
> On Thu 15-09-16 10:41:18, Johannes Weiner wrote:
> > Hi Michal,
> > 
> > On Thu, Sep 01, 2016 at 11:51:00AM +0200, Michal Hocko wrote:
> > > Hi,
> > > this is an early RFC to see whether the approach I've taken is acceptable.
> > > The series is on top of the current mmotm tree (2016-08-31-16-06). I didn't
> > > get to test it so it might be completely broken.
> > > 
> > > The primary point of this series is to get rid of TIF_MEMDIE finally.
> > > Recent changes in the oom proper allows for that finally, I believe. Now
> > > that all the oom victims are reapable we are no longer depending on
> > > ALLOC_NO_WATERMARKS because the memory held by the victim is reclaimed
> > > asynchronously. A partial access to memory reserves should be sufficient
> > > just to guarantee that the oom victim is not starved due to other
> > > memory consumers. This also means that we do not have to pretend to be
> > > conservative and give access to memory reserves only to one thread from
> > > the process at the time. This is patch 1.
> > >
> > > Patch 2 is a simple cleanup which turns TIF_MEMDIE users to tsk_is_oom_victim
> > > which is process rather than thread centric. None of those callers really
> > > requires to be thread aware AFAICS.
> > > 
> > > The tricky part then is exit_oom_victim vs. oom_killer_disable because
> > > TIF_MEMDIE acted as a token there so we had a way to count threads from
> > > the process. It didn't work 100% reliably and had it own issues but we
> > > have to replace it with something which doesn't rely on counting threads
> > > but rather find a moment when all threads have reached steady state in
> > > do_exit. This is what patch 3 does and I would really appreciate if Oleg
> > > could double check my thinking there. I am also CCing Al on that one
> > > because I am moving exit_io_context up in do_exit right before exit_notify.
> > 
> > You're explaining the mechanical thing you are doing, but I'm having
> > trouble understanding why you want to get rid of TIF_MEMDIE. For one,
> > it's more code. And apparently, it's also more complicated than what
> > we have right now.
> > 
> > Can you please explain in the cover letter what's broken/undesirable?
> 
> Sure, I will extend the cover when submitting the series again. This RFC
> was mostly aimed at correctness so I focused more on technical details.
> Patch 1 should contain some reasoning. Do you find it sufficient or I
> should extend on top of that?

: For ages we have been relying on TIF_MEMDIE thread flag to mark OOM
: victims and then, among other things, to give these threads full
: access to memory reserves. There are few shortcomings of this
: implementation, though.
: 
: First of all and the most serious one is that the full access to memory
: reserves is quite dangerous because we leave no safety room for the
: system to operate and potentially do last emergency steps to move on.

Do we encounter this in practice? I think one of the clues is that you
introduce the patch with "for ages we have been doing X", so I'd like
to see a more practical explanation of how we did it was flawed.

: Secondly this flag is per task_struct while the OOM killer operates
: on mm_struct granularity so all processes sharing the given mm are
: killed. Giving the full access to all these task_structs could leave to
: a quick memory reserves depletion. We have tried to reduce this risk by
: giving TIF_MEMDIE only to the main thread and the currently allocating
: task but that doesn't really solve this problem while it surely opens up
: a room for corner cases - e.g. GFP_NO{FS,IO} requests might loop inside
: the allocator without access to memory reserves because a particular
: thread was not the group leader.

Same here I guess.

It *sounds* to me like there are two different things going on
here. One being the access to emergency reserves, the other being the
synchronization token to count OOM victims. Maybe it would be easier
to separate those issues out in the line of argument?

For emergency reserves, you make the point that we now have the reaper
and don't rely on the reserves as much anymore. However, we need to
consider that the reaper relies on the mmap_sem and is thus not as
robust as the concept of an emergency pool to guarantee fwd progress.

For synchronization, I don't quite get the argument. The patch 4
changelog uses term like "not optimal" and that we "should" be doing
certain things, but doesn't explain the consequences of the "wrong"
behavior, the impact is of frozen threads getting left behind etc.

That stuff would be useful to know, both in the cover letter (higher
level user impact) and the changelogs (more detailed user impact).

I.e. sell the problem before selling the solution :-)

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
