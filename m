Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF4F6B0025
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 05:07:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 65so5581002wrn.7
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 02:07:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si6352984wrp.56.2018.03.23.02.07.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 02:07:07 -0700 (PDT)
Date: Fri, 23 Mar 2018 10:07:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, thp: do not invoke oom killer on thp charges
Message-ID: <20180323090704.GK23100@dhcp22.suse.cz>
References: <20180321205928.22240-1-mhocko@kernel.org>
 <alpine.DEB.2.20.1803211418170.107059@chino.kir.corp.google.com>
 <20180321214104.GT23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803220106010.175961@chino.kir.corp.google.com>
 <20180322085611.GY23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803221304160.3268@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803221304160.3268@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 22-03-18 13:29:37, David Rientjes wrote:
> On Thu, 22 Mar 2018, Michal Hocko wrote:
[...]
> > They simply cannot because kmalloc performs the change under the cover.
> > So you would have to use kmalloc(gfp|__GFP_NORETRY) to be absolutely
> > sure to not trigger _any_ oom killer. This is just wrong thing to do.
> > 
> 
> Examples of where this isn't already done?  It certainly wasn't a problem 
> before __GFP_NORETRY was dropped in commit 2516035499b9 but you suspect 
> it's a problem now.

It is not a problem _right now_ as I've already pointed out few
times. We do not trigger the OOM killer for anything but #PF path. But
this is an implementation detail which can change in future and there is
actually some demand for the change. Once we start triggering the oom
killer for all charges then we do not really want to have the disparity.

> > > You're diverging from it because the memcg charge path has never had this 
> > > heuristic.
> > 
> > Which is arguably a bug which just didn't matter because we do not
> > have costly order oom eligible charges in general and THP was subtly
> > different and turned out to be error prone.
> > 
> 
> It was inadvertently dropped from commit 2516035499b9.  There were no 
> high-order charge oom kill problems before this commit.  People know how 
> to use __GFP_NORETRY or leave it off, which you don't trust them to do 
> because you're hardcoding a heuristic in the charge path.

No. Just read what I wrote. I am worried that the current disparity
between the page allocator and the memcg charging will _force_ them to
do hacks and sometimes (e.g. kmalloc) they will not have any option but
using __GFP_NORETRY even when that is not really needed and it has a
different semantic than they would like.

Behavior on with and without memcgs should be as similar as possible
otherwise you will see different sets of bugs when running under the
memcg and without. I really fail to see what is so hard about this to
understand.

[...]

> > > Your change is broken and I wouldn't push it to Linus for rc7 if my life 
> > > depended on it.  What is the response when someone complains that they 
> > > start getting a ton of MEMCG_OOM notifications for every thp fallback?
> > > They will, because yours is a broken implementation.
> > 
> > I fail to see what is broken. Could you be more specific?
> >  
> 
> I said MEMCG_OOM notifications on thp fallback.  You modified 
> mem_cgroup_oom().  What is called before mem_cgroup_oom()?  
> mem_cgroup_event(mem_over_limit, MEMCG_OOM).  That increments the 
> MEMCG_OOM event and anybody waiting on the events file gets notified it 
> changed.  They read a MEMCG_OOM event.  It's thp fallback, it's not memcg 
> oom.

MEMCG_OOM doesn't count the number of oom killer invocations. That has
never been the case.

> Really, I can't continue to write 100 emails in this thread.

Then try to read and even try to understand concerns expressed in those
emails. Repeating the same set of arguments and ignoring the rest is not
really helpful.
-- 
Michal Hocko
SUSE Labs
