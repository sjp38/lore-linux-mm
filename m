Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5B006B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:06:59 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 75so104742712pgf.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 16:06:59 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 137si23024135pfa.58.2017.01.16.16.06.58
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 16:06:58 -0800 (PST)
Date: Tue, 17 Jan 2017 09:12:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCHSET v2] slab: make memcg slab destruction scalable
Message-ID: <20170117001256.GB25218@js1304-P5Q-DELUXE>
References: <20170114184834.8658-1-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114184834.8658-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 01:48:26PM -0500, Tejun Heo wrote:
> This is v2.  Changes from the last version[L] are
> 
> * 0002-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch was
>   incorrect and dropped.
> 
> * 0006-slab-don-t-put-memcg-caches-on-slab_caches-list.patch
>   incorrectly converted places which needed to walk all caches.
>   Replaced with 0005-slab-implement-slab_root_caches-list.patch which
>   adds root-only list instead of converting slab_caches list to list
>   only root caches.
> 
> * Misc fixes.
> 
> With kmem cgroup support enabled, kmem_caches can be created and
> destroyed frequently and a great number of near empty kmem_caches can
> accumulate if there are a lot of transient cgroups and the system is
> not under memory pressure.  When memory reclaim starts under such
> conditions, it can lead to consecutive deactivation and destruction of
> many kmem_caches, easily hundreds of thousands on moderately large
> systems, exposing scalability issues in the current slab management
> code.
> 
> I've seen machines which end up with hundred thousands of caches and
> many millions of kernfs_nodes.  The current code is O(N^2) on the
> total number of caches and has synchronous rcu_barrier() and
> synchronize_sched() in cgroup offline / release path which is executed
> while holding cgroup_mutex.  Combined, this leads to very expensive
> and slow cache destruction operations which can easily keep running
> for half a day.
> 
> This also messes up /proc/slabinfo along with other cache iterating
> operations.  seq_file operates on 4k chunks and on each 4k boundary
> tries to seek to the last position in the list.  With a huge number of
> caches on the list, this becomes very slow and very prone to the list
> content changing underneath it leading to a lot of missing and/or
> duplicate entries.
> 
> This patchset addresses the scalability problem.
> 
> * Add root and per-memcg lists.  Update each user to use the
>   appropriate list.
> 
> * Replace rcu_barrier() and synchronize_rcu() with call_rcu() and
>   call_rcu_sched().
> 
> * For dying empty slub caches, remove the sysfs files after
>   deactivation so that we don't end up with millions of sysfs files
>   without any useful information on them.

Could you confirm that your series solves the problem that is reported
by Doug? It would be great if the result is mentioned to the patch
description.

https://bugzilla.kernel.org/show_bug.cgi?id=172991

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
