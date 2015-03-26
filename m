Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5085F6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 09:31:16 -0400 (EDT)
Received: by wibg7 with SMTP id g7so148647008wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 06:31:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iy6si10702173wic.6.2015.03.26.06.31.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 06:31:13 -0700 (PDT)
Date: Thu, 26 Mar 2015 14:31:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 06/12] mm: oom_kill: simplify OOM killer locking
Message-ID: <20150326133111.GJ15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427264236-17249-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Wed 25-03-15 02:17:10, Johannes Weiner wrote:
> The zonelist locking and the oom_sem are two overlapping locks that
> are used to serialize global OOM killing against different things.
> 
> The historical zonelist locking serializes OOM kills from allocations
> with overlapping zonelists against each other to prevent killing more
> tasks than necessary in the same memory domain.  Only when neither
> tasklists nor zonelists from two concurrent OOM kills overlap (tasks
> in separate memcgs bound to separate nodes) are OOM kills allowed to
> execute in parallel.
> 
> The younger oom_sem is a read-write lock to serialize OOM killing
> against the PM code trying to disable the OOM killer altogether.
> 
> However, the OOM killer is a fairly cold error path, there is really
> no reason to optimize for highly performant and concurrent OOM kills.
> And the oom_sem is just flat-out redundant.
> 
> Replace both locking schemes with a single global mutex serializing
> OOM kills regardless of context.

OK, this is much simpler.

You have missed drivers/tty/sysrq.c which should take the lock as well.
ZONE_OOM_LOCKED can be removed as well. __out_of_memory in the kerneldoc
should be renamed.

[...]
> @@ -795,27 +728,21 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>   */
>  void pagefault_out_of_memory(void)
>  {
> -	struct zonelist *zonelist;
> -
> -	down_read(&oom_sem);
>  	if (mem_cgroup_oom_synchronize(true))
> -		goto unlock;
> +		return;

OK, so we are back to what David has asked previously. We do not need
the lock for memcg and oom_killer_disabled because we know that no tasks
(except for potential oom victim) are lurking around at the time
oom_killer_disable() is called. So I guess we want to stick a comment
into mem_cgroup_oom_synchronize before we check for oom_killer_disabled.

After those are fixed, feel free to add
Acked-by: Michal Hocko <mhocko@suse.cz>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
