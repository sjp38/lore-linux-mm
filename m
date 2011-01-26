Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 50F376B00E8
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 12:07:26 -0500 (EST)
Date: Wed, 26 Jan 2011 18:07:13 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] oom: handle overflow in mem_cgroup_out_of_memory()
Message-ID: <20110126170713.GA2401@cmpxchg.org>
References: <1296030555-3594-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296030555-3594-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 26, 2011 at 12:29:15AM -0800, Greg Thelen wrote:
> mem_cgroup_get_limit() returns a byte limit as a unsigned 64 bit value,
> which is converted to a page count by mem_cgroup_out_of_memory().  Prior
> to this patch the conversion could overflow on 32 bit platforms
> yielding a limit of zero.

Balbir: It can truncate, because the conversion shrinks the required
bits of this 64-bit number by only PAGE_SHIFT (12).  Trying to store
the resulting up to 52 significant bits in a 32-bit integer will cut
up to 20 significant bits off.

> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
>  mm/oom_kill.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 7dcca55..3fcac51 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -538,7 +538,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  	struct task_struct *p;
>  
>  	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
> -	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
> +	limit = min(mem_cgroup_get_limit(mem) >> PAGE_SHIFT, (u64)ULONG_MAX);

I would much prefer using min_t(u64, ...).  To make it really, really
explicit that this is 64-bit arithmetic.  But that is just me, no
correctness issue.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
