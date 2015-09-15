Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 367BC6B0253
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 05:20:33 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so19443510wic.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:20:32 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e14si24486200wjq.46.2015.09.15.02.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 02:20:31 -0700 (PDT)
Date: Tue, 15 Sep 2015 11:20:25 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150915092025.GA6812@cmpxchg.org>
References: <20150828220158.GD11089@htj.dyndns.org>
 <20150828220237.GE11089@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828220237.GE11089@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Fri, Aug 28, 2015 at 06:02:37PM -0400, Tejun Heo wrote:
> On the default hierarchy, all memory consumption will be accounted
> together and controlled by the same set of limits.  Enable kmemcg on
> the default hierarchy by default.  Boot parameter "disable_kmemcg" can
> be specified to turn it off.
> 
> v2: - v1 triggered oops on nested cgroup creations.  Moved enabling
>       mechanism to memcg_propagate_kmem().
>     - Bypass busy test on kmem activation as it's unnecessary and gets
>       confused by controller being enabled on a cgroup which already
>       has processes.
>     - "disable_kmemcg" boot param added.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

The old distinction between kernel and user memory really doesn't make
sense and should not be maintained. The dentry and inode caches are a
significant share of overall memory consumed in common workloads, and
that is memory unambiguously coupled to userspace activity. I'd go as
far as removing CONFIG_MEMCG_KMEM altogether because it strikes me as
a completely unreasonable choice to give to the user (outside of maybe
CONFIG_EXPERT).

What CONFIG_MEMCG should really capture is all memory that can grow
significantly in size and can be associated directly with userspace
behavior. If there are types of memory that turn out to be very costly
to account and track, we can still go back and conceive an interface
that lets the user select the types of memory he doesn't need tracked.

But the KMEMCG differentation is an arbitrary, and mostly historical
distinction that we shouldn't continue to present to users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
