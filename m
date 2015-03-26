Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id ED1F96B006E
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 09:01:09 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so21399126wia.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 06:01:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si9776460wjy.173.2015.03.26.06.01.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 06:01:08 -0700 (PDT)
Date: Thu, 26 Mar 2015 14:01:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 04/12] mm: oom_kill: remove unnecessary locking in
 exit_oom_victim()
Message-ID: <20150326130106.GG15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-5-git-send-email-hannes@cmpxchg.org>
 <20150326125348.GF15257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326125348.GF15257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Thu 26-03-15 13:53:48, Michal Hocko wrote:
> On Wed 25-03-15 02:17:08, Johannes Weiner wrote:
> > Disabling the OOM killer needs to exclude allocators from entering,
> > not existing victims from exiting.
> 
> The idea was that exit_oom_victim doesn't miss a waiter.
> 
> exit_oom_victim is doing
> 	atomic_dec_return(&oom_victims) && oom_killer_disabled)
> 
> so there is a full (implicit) memory barrier befor oom_killer_disabled
> check. The other part is trickier. oom_killer_disable does:
> 	oom_killer_disabled = true;
>         up_write(&oom_sem);
> 
>         wait_event(oom_victims_wait, !atomic_read(&oom_victims));
> 
> up_write doesn't guarantee a full memory barrier AFAICS in
> Documentation/memory-barriers.txt (although the generic and x86
> implementations seem to implement it as a full barrier) but wait_event
> implies the full memory barrier (prepare_to_wait_event does spin
> lock&unlock) before checking the condition in the slow path. This should
> be sufficient and docummented...
> 
> 	/*
> 	 * We do not need to hold oom_sem here because oom_killer_disable
> 	 * guarantees that oom_killer_disabled chage is visible before
> 	 * the waiter is put into sleep (prepare_to_wait_event) so
> 	 * we cannot miss a wake up.
> 	 */
> 
> in unmark_oom_victim()

OK, I can see that the next patch removes oom_killer_disabled
completely. The dependency won't be there and so the concerns about the
memory barriers.

Is there any reason why the ordering is done this way? It would sound
more logical to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
