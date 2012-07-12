Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id B1D666B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 05:42:12 -0400 (EDT)
Date: Thu, 12 Jul 2012 11:42:03 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 01/10] mm: memcg: fix compaction/migration failing due to
 memcg limits
Message-ID: <20120712094202.GB1239@cmpxchg.org>
References: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
 <1342026142-7284-2-git-send-email-hannes@cmpxchg.org>
 <20120712085354.GA3181@kernel>
 <20120712091043.GB3181@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120712091043.GB3181@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jul 12, 2012 at 05:10:43PM +0800, Wanpeng Li wrote:
> On Thu, Jul 12, 2012 at 04:54:07PM +0800, Wanpeng Li wrote:
> >On Wed, Jul 11, 2012 at 07:02:13PM +0200, Johannes Weiner wrote:
> >>Compaction (and page migration in general) can currently be hindered
> >>through pages being owned by memory cgroups that are at their limits
> >>and unreclaimable.
> >>
> >>The reason is that the replacement page is being charged against the
> >>limit while the page being replaced is also still charged.  But this
> >>seems unnecessary, given that only one of the two pages will still be
> >>in use after migration finishes.
> >>
> >>This patch changes the memcg migration sequence so that the
> >>replacement page is not charged.  Whatever page is still in use after
> >>successful or failed migration gets to keep the charge of the page
> >>that was going to be replaced.
> >>
> >>The replacement page will still show up temporarily in the rss/cache
> >>statistics, this can be fixed in a later patch as it's less urgent.
> >>
> >
> >So I want to know after this patch be merged if mem_cgroup_wait_acct_move
> >still make sense, if the answer is no, I will send a patch to remove it.
> 
> And if this still make sense, I want to change check in
> mem_cgroup_do_charge:
> 
> if (mem_cgroup_wait_acct_move(mem_over_limit))
> 	return CHARGE_RETRY;
> 
> =>
> 
> if (mem_cgroup_wait_acct_move(mem_over_limit) && 
>                        mem_cgroup_margin(mem_over_limit) >= nr_pages)
> 	return CHARGE_RETRY;
> 
> Since mem_cgroup_relcaim can reclaim some pages, but in
> mem_cgroup_reclaim function there are some exit condition:
> 
> total += try_to_free_mem_cgroup_pages(memcg, gfp_mask, noswap);
> if(total && (flag & MEM_CGROUP_RECLAIM_SHRINK))
> 	break;
> 
> and 
> 
> if (mem_cgroup_margin(memcg))
> 	break;
> 
> So maybe mem_cgroup_reclaim not reclaim enough pages >= nr_pages, this
> time we should go to mem_cgroup_handle_oom instead of return
> CHARGE_RETRY.
> 
> Hopefully, you can verify if my idea make sense.

Sorry, but this is a waste of your time, my time, and that of
everybody else in this thread.

I will ignore any subsequent proposals from you unless they start with
a coherent description of an actual problem.  Something that has
impact on userspace, or significant impact on kernel development.

If there is a bug I don't see in your description above, than please
explain how it affects userspace.  If the code or comments are cryptic
and can be simplified or clarified, please explain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
