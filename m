Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AEF3C6B016B
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 10:03:19 -0400 (EDT)
Date: Tue, 9 Aug 2011 16:03:12 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 1/2 v2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-ID: <20110809140312.GA2265@redhat.com>
References: <cover.1310732789.git.mhocko@suse.cz>
 <44ec61829ed8a83b55dc90a7aebffdd82fe0e102.1310732789.git.mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44ec61829ed8a83b55dc90a7aebffdd82fe0e102.1310732789.git.mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed, Jul 13, 2011 at 01:05:49PM +0200, Michal Hocko wrote:
> @@ -1803,37 +1806,83 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  /*
>   * Check OOM-Killer is already running under our hierarchy.
>   * If someone is running, return false.
> + * Has to be called with memcg_oom_mutex
>   */
>  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
>  {
> -	int x, lock_count = 0;
> -	struct mem_cgroup *iter;
> +	int lock_count = -1;
> +	struct mem_cgroup *iter, *failed = NULL;
> +	bool cond = true;
>  
> -	for_each_mem_cgroup_tree(iter, mem) {
> -		x = atomic_inc_return(&iter->oom_lock);
> -		lock_count = max(x, lock_count);
> +	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
> +		bool locked = iter->oom_lock;
> +
> +		iter->oom_lock = true;
> +		if (lock_count == -1)
> +			lock_count = iter->oom_lock;
> +		else if (lock_count != locked) {
> +			/*
> +			 * this subtree of our hierarchy is already locked
> +			 * so we cannot give a lock.
> +			 */
> +			lock_count = 0;
> +			failed = iter;
> +			cond = false;
> +		}

I noticed system-wide hangs during a parallel/hierarchical memcg test
and found that a single task with a central i_mutex held was sleeping
on the memcg oom waitqueue, stalling everyone else contending for that
same inode.

The problem is the above code, which never succeeds in hierarchies
with more than one member.  The first task going OOM tries to oom lock
the hierarchy, fails, goes to sleep on the OOM waitqueue with the
mutex held, without anybody actually OOM killing anything to make
progress.

Here is a patch that rectified things for me.

---
