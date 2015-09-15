Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 21A1D6B0253
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:47:31 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so15745223wic.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:47:30 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ir10si23950499wjb.206.2015.09.15.00.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 00:47:29 -0700 (PDT)
Date: Tue, 15 Sep 2015 09:47:24 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 2/2] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150915074724.GE2858@cmpxchg.org>
References: <20150913185940.GA25369@htj.duckdns.org>
 <20150913190008.GB25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150913190008.GB25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Sun, Sep 13, 2015 at 03:00:08PM -0400, Tejun Heo wrote:
> Currently, try_charge() tries to reclaim memory synchronously when the
> high limit is breached; however, if the allocation doesn't have
> __GFP_WAIT, synchronous reclaim is skipped.  If a process performs
> only speculative allocations, it can blow way past the high limit.
> This is actually easily reproducible by simply doing "find /".
> slab/slub allocator tries speculative allocations first, so as long as
> there's memory which can be consumed without blocking, it can keep
> allocating memory regardless of the high limit.
> 
> This patch makes try_charge() always punt the over-high reclaim to the
> return-to-userland path.  If try_charge() detects that high limit is
> breached, it adds the overage to current->memcg_nr_pages_over_high and
> schedules execution of mem_cgroup_handle_over_high() which performs
> synchronous reclaim from the return-to-userland path.

Why can't we simply fail NOWAIT allocations when the high limit is
breached? We do the same for the max limit.

As I see it, NOWAIT allocations are speculative attempts on available
memory. We should be able to just fail them and have somebody that is
allowed to reclaim try again, just like with the max limit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
