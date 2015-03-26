Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id CD6716B006C
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 12:07:46 -0400 (EDT)
Received: by wibg7 with SMTP id g7so154257366wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 09:07:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r6si10660577wjx.75.2015.03.26.09.07.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 09:07:44 -0700 (PDT)
Date: Thu, 26 Mar 2015 17:07:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 06/12] mm: oom_kill: simplify OOM killer locking
Message-ID: <20150326160742.GR15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-7-git-send-email-hannes@cmpxchg.org>
 <20150326133111.GJ15257@dhcp22.suse.cz>
 <20150326151746.GC23973@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326151746.GC23973@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Thu 26-03-15 11:17:46, Johannes Weiner wrote:
> On Thu, Mar 26, 2015 at 02:31:11PM +0100, Michal Hocko wrote:
[...]
> > > @@ -795,27 +728,21 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> > >   */
> > >  void pagefault_out_of_memory(void)
> > >  {
> > > -	struct zonelist *zonelist;
> > > -
> > > -	down_read(&oom_sem);
> > >  	if (mem_cgroup_oom_synchronize(true))
> > > -		goto unlock;
> > > +		return;
> > 
> > OK, so we are back to what David has asked previously. We do not need
> > the lock for memcg and oom_killer_disabled because we know that no tasks
> > (except for potential oom victim) are lurking around at the time
> > oom_killer_disable() is called. So I guess we want to stick a comment
> > into mem_cgroup_oom_synchronize before we check for oom_killer_disabled.
> 
> I would prefer everybody that sets TIF_MEMDIE and kills a task to hold
> the lock, including memcg.  Simplicity is one thing, but also a global
> OOM kill might not even be necessary when it's racing with the memcg.

sure I am find with that.
 
> > After those are fixed, feel free to add
> > Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> Thanks.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
