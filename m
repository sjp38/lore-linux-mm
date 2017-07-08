Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEC96B0292
	for <linux-mm@kvack.org>; Sat,  8 Jul 2017 01:00:11 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o202so71487709itc.14
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 22:00:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e135si5058322ioe.186.2017.07.07.22.00.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 22:00:10 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170601115936.GA9091@dhcp22.suse.cz>
	<201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
	<20170601132808.GD9091@dhcp22.suse.cz>
	<20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
	<20170602071818.GA29840@dhcp22.suse.cz>
In-Reply-To: <20170602071818.GA29840@dhcp22.suse.cz>
Message-Id: <201707081359.JCD39510.OSVOHMFOFtLFQJ@I-love.SAKURA.ne.jp>
Date: Sat, 8 Jul 2017 13:59:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

Michal Hocko wrote:
> On Thu 01-06-17 15:10:22, Andrew Morton wrote:
> > On Thu, 1 Jun 2017 15:28:08 +0200 Michal Hocko <mhocko@suse.com> wrote:
> > 
> > > On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> > > > > > Cong Wang has reported a lockup when running LTP memcg_stress test [1].
> > > > >
> > > > > This seems to be on an old and not pristine kernel. Does it happen also
> > > > > on the vanilla up-to-date kernel?
> > > > 
> > > > 4.9 is not an old kernel! It might be close to the kernel version which
> > > > enterprise distributions would choose for their next long term supported
> > > > version.
> > > > 
> > > > And please stop saying "can you reproduce your problem with latest
> > > > linux-next (or at least latest linux)?" Not everybody can use the vanilla
> > > > up-to-date kernel!
> > > 
> > > The changelog mentioned that the source of stalls is not clear so this
> > > might be out-of-tree patches doing something wrong and dump_stack
> > > showing up just because it is called often. This wouldn't be the first
> > > time I have seen something like that. I am not really keen on adding
> > > heavy lifting for something that is not clearly debugged and based on
> > > hand waving and speculations.
> > 
> > I'm thinking we should serialize warn_alloc anyway, to prevent the
> > output from concurrent calls getting all jumbled together?
> 
> dump_stack already serializes concurrent calls.
> 
> > I'm not sure I buy the "this isn't a mainline kernel" thing. 
> 
> The changelog doesn't really explain what is going on and only
> speculates that the excessive warn_alloc is the cause. The kernel is 
> 4.9.23.el7.twitter.x86_64 which I suspect contains a lot of stuff on top
> of 4.9. So I would really _like_ to see whether this is reproducible
> with the upstream kernel. Especially when this is a LTP test.
> 
> > warn_alloc() obviously isn't very robust, but we'd prefer that it be
> > robust to peculiar situations, wild-n-wacky kernel patches, etc.  It's
> > a low-level thing and it should Just Work.
> 
> Yes I would agree and if we have an evidence that warn_alloc is really
> the problem then I am all for fixing it. There is no such evidence yet.
> Note that dump_stack serialization might be unfair because there is no
> queuing. Is it possible that this is the problem? If yes we should
> rather fix that because that is arguably even more low-level routine than
> warn_alloc.
> 
> That being said. I strongly believe that this patch is not properly
> justified, issue fully understood and as such a disagree with adding a
> new lock on those grounds.
> 
> Until the above is resolved
> Nacked-by: Michal Hocko <mhocko@suse.com>

Apart from what happened to Cong Wang's case, I'm really bothered by jumbled
messages caused by concurrent warn_alloc() calls. My test case is using
linux-next without any out-of-tree patches. Thus, adding a new lock on those
grounds should be acceptable.

Quoting from http://lkml.kernel.org/r/20170705081956.GA14538@dhcp22.suse.cz :
Michal Hocko wrote:
> On Sat 01-07-17 20:43:56, Tetsuo Handa wrote:
> > You are rejecting serialization under OOM without giving a chance to test
> > side effects of serialization under OOM at linux-next.git. I call such attitude
> > "speculation" which you never accept.
> 
> No I am rejecting abusing the lock for purpose it is not aimed for.

Then, why adding a new lock (not oom_lock but warn_alloc_lock) is not acceptable?
Since warn_alloc_lock is aimed for avoiding messages by warn_alloc() getting
jumbled, there should be no reason you reject this lock.

If you don't like locks, can you instead accept below one?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 80e4adb..3ac382c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3900,9 +3900,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
+		static bool wait;
+
+		while (cmpxchg(&wait, false, true))
+			schedule_timeout_uninterruptible(1);
 		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
 			"page allocation stalls for %ums, order:%u",
 			jiffies_to_msecs(jiffies-alloc_start), order);
+		wait = false;
 		stall_timeout += 10 * HZ;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
