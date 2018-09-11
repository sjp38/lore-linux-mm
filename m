Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 770258E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 11:47:51 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b8-v6so32289932oib.4
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 08:47:51 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id z5-v6si12315532oib.40.2018.09.11.08.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 08:47:50 -0700 (PDT)
Date: Tue, 11 Sep 2018 08:47:35 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH RFC] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20180911154735.GC28828@tower.DHCP.thefacebook.com>
References: <20180910215622.4428-1-guro@fb.com>
 <20180911124303.GA19043@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180911124303.GA19043@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue, Sep 11, 2018 at 08:43:03AM -0400, Johannes Weiner wrote:
> On Mon, Sep 10, 2018 at 02:56:22PM -0700, Roman Gushchin wrote:
> > The memcg OOM killer is never invoked due to a failed high-order
> > allocation, however the MEMCG_OOM event can be easily raised.
> 
> Wasn't the same also true for kernel allocations until recently? We'd
> signal MEMCG_OOM and then return -ENOMEM.

Well, assuming that it's normal for a cgroup to have its memory usage
about the memory.max border, that sounds strange.

> 
> > Under some memory pressure it can happen easily because of a
> > concurrent allocation. Let's look at try_charge(). Even if we were
> > able to reclaim enough memory, this check can fail due to a race
> > with another allocation:
> > 
> >     if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
> >         goto retry;
> > 
> > For regular pages the following condition will save us from triggering
> > the OOM:
> > 
> >    if (nr_reclaimed && nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER))
> >        goto retry;
> > 
> > But for high-order allocation this condition will intentionally fail.
> > The reason behind is that we'll likely fall to regular pages anyway,
> > so it's ok and even preferred to return ENOMEM.
> 
> These seem to be more implementation details than anything else.
> 
> Personally, I'm confused by the difference between the "oom" and
> "oom_kill" events, and I don't understand when you would be interested
> in one and when in the other. The difference again seems to be mostly
> implementation details.
> 
> But the definition of "oom"/MEMCG_OOM in cgroup-v2.rst applies to the
> situation of failing higher-order allocations. I'm not per-se against
> changing the semantics here, as I don't think they are great. But can
> you please start out with rewriting the definition in a way that shows
> the practical difference for users?
> 
> The original idea behind MEMCG_OOM was to signal when reclaim had
> failed and we defer to the oom killer. The oom killer may or may not
> kill anything, which is the case for higher order allocations, but
> that doesn't change the out-of-memory situation that has occurred.
> 
> Konstantin added the OOM_KILL events to count actual kills. It seems
> to me that this has much more practical applications than the more
> theoretical OOM, since users care more about kills and not necessarily
> about "reclaim failed (but i might have been able to handle it with
> retries and fallback allocations, and so there isn't an actual issue".
> 
> Is there a good reason for keeping OOM now that we have OOM_KILL?

I totally agree that oom_kill is more useful, and I did propose to
convert existing oom counter into oom_kill semantics back to time when
Konstantin's patch was discussed. So, I'm not arguing here that having two
counter is really useful, I've expressed the opposite meaning from scratch.

However I'm not sure if it's not too late to remove the oom event.
But if it is too late, let's make it less confusing.

Definition of the oom event in docs is quite broad, so both current
behavior and proposed change will fit. So it's not a semantics change
at all, pure implementation details.

Let's agree that oom event should not indicate a "random" allocation
failure, but one caused by high memory pressure. Otherwise it's really
a alloc_failure counter, which has to be moved to memory.stat.

Thanks!
