Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 554246B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 22:58:02 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id e89so6564553qgf.12
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 19:58:02 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id a10si1232716qab.8.2014.09.24.19.58.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 19:58:01 -0700 (PDT)
Received: by mail-qg0-f47.google.com with SMTP id z107so6976467qgd.6
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 19:58:01 -0700 (PDT)
Date: Wed, 24 Sep 2014 22:57:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch] mm: memcontrol: do not iterate uninitialized memcgs
Message-ID: <20140925025758.GA6903@mtj.dyndns.org>
References: <1411612278-4707-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411612278-4707-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Sep 24, 2014 at 10:31:18PM -0400, Johannes Weiner wrote:
..
> not meet the ordering requirements for memcg, and so we still may see
> partially initialized memcgs from the iterators.

It's mainly the other way around - a fully initialized css may not
show up in an iteration, but given that there's no memory ordering or
synchronization around the flag, anything can happen.

...
> +		if (next_css == &root->css ||
> +		    css_tryget_online(next_css)) {
> +			struct mem_cgroup *memcg;
> +
> +			memcg = mem_cgroup_from_css(next_css);
> +			if (memcg->initialized) {
> +				/*
> +				 * Make sure the caller's accesses to
> +				 * the memcg members are issued after
> +				 * we see this flag set.

I usually prefer if the comment points to the exact location that the
matching memory barriers live.  Sometimes it's difficult to locate the
partner barrier even w/ the functional explanation.

> +				 */
> +				smp_rmb();
> +				return memcg;

In an unlikely event this rmb becomes an issue, a self-pointing
pointer which is set/read using smp_store_release() and
smp_load_acquire() respectively can do with plain barrier() on the
reader side on archs which don't need data dependency barrier
(basically everything except alpha).  Not sure whether that'd be more
or less readable than this tho.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
