Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 81F5A6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:28:46 -0400 (EDT)
Received: by wgra20 with SMTP id a20so60420043wgr.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:28:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ey10si23826592wib.45.2015.03.26.04.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 04:28:45 -0700 (PDT)
Date: Thu, 26 Mar 2015 07:28:41 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 08/12] mm: page_alloc: wait for OOM killer progress
 before retrying
Message-ID: <20150326112841.GD18560@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-9-git-send-email-hannes@cmpxchg.org>
 <201503252315.FBJ09847.FSOtOJQFOMLFVH@I-love.SAKURA.ne.jp>
 <5512E9FC.7090105@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5512E9FC.7090105@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, ying.huang@intel.com, aarcange@redhat.com, david@fromorbit.com, mhocko@suse.cz, tytso@mit.edu

On Wed, Mar 25, 2015 at 06:01:48PM +0100, Vlastimil Babka wrote:
> On 03/25/2015 03:15 PM, Tetsuo Handa wrote:
> >Johannes Weiner wrote:
> >>diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> >>index 5cfda39b3268..e066ac7353a4 100644
> >>--- a/mm/oom_kill.c
> >>+++ b/mm/oom_kill.c
> >>@@ -711,12 +711,15 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >>  		killed = 1;
> >>  	}
> >>  out:
> >>+	if (test_thread_flag(TIF_MEMDIE))
> >>+		return true;
> >>  	/*
> >>-	 * Give the killed threads a good chance of exiting before trying to
> >>-	 * allocate memory again.
> >>+	 * Wait for any outstanding OOM victims to die.  In rare cases
> >>+	 * victims can get stuck behind the allocating tasks, so the
> >>+	 * wait needs to be bounded.  It's crude alright, but cheaper
> >>+	 * than keeping a global dependency tree between all tasks.
> >>  	 */
> >>-	if (killed)
> >>-		schedule_timeout_killable(1);
> >>+	wait_event_timeout(oom_victims_wait, !atomic_read(&oom_victims), HZ);
> >>
> >>  	return true;
> >>  }
> >
> >out_of_memory() returning true with bounded wait effectively means that
> >wait forever without choosing subsequent OOM victims when first OOM victim
> >failed to die. The system will lock up, won't it?
> 
> And after patch 12, does this mean that you may not be waiting long enough
> for the victim to die, before you fail the allocation, prematurely? I can
> imagine there would be situations where the victim is not deadlocked, but
> still take more than HZ to finish, no?

Arguably it should be reasonable to fail allocations once the OOM
victim is stuck for over a second and the OOM reserves have been
depleted.

On the other hand, we don't need to play it that tight, because that
timeout is only targetted for the victim-blocked-on-alloc situations
which aren't all that common.  Something like 5 seconds should still
be okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
