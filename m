Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id B86086B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:06:31 -0400 (EDT)
Received: by mail-qe0-f45.google.com with SMTP id q19so1480864qeb.32
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 16:06:30 -0700 (PDT)
Date: Wed, 5 Jun 2013 16:06:25 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 1/2] mm: memcontrol: fix lockless reclaim hierarchy
 iterator
Message-ID: <20130605230625.GN10693@mtj.dyndns.org>
References: <1370472826-29959-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370472826-29959-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jun 05, 2013 at 06:53:45PM -0400, Johannes Weiner wrote:
> The lockless reclaim hierarchy iterator currently has a misplaced
> barrier that can lead to use-after-free crashes.
> 
> The reclaim hierarchy iterator consist of a sequence count and a
> position pointer that are read and written locklessly, with memory
> barriers enforcing ordering.
> 
> The write side sets the position pointer first, then updates the
> sequence count to "publish" the new position.  Likewise, the read side
> must read the sequence count first, then the position.  If the
> sequence count is up to date, it's guaranteed that the position is up
> to date as well:
> 
>   writer:                         reader:
>   iter->position = position       if iter->sequence == expected:
>   smp_wmb()                           smp_rmb()
>   iter->sequence = sequence           position = iter->position
> 
> However, the read side barrier is currently misplaced, which can lead
> to dereferencing stale position pointers that no longer point to valid
> memory.  Fix this.
> 
> Reported-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: stable@kernel.org [3.10+]

Reviewed-by: Tejun Heo <tj@kernel.org>

Oops, right, the references were reversed too.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
