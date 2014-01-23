Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id C96B26B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 07:53:58 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id na10so342415bkb.0
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 04:53:58 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id ps5si10126816bkb.344.2014.01.23.04.53.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 04:53:57 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so1792587pbb.6
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 04:53:55 -0800 (PST)
Date: Thu, 23 Jan 2014 04:53:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH -mm 2/2] memcg: fix css reference leak and endless loop
 in mem_cgroup_iter
In-Reply-To: <20140123110920.GE4911@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1401230451490.1563@eggly.anvils>
References: <20140121083454.GA1894@dhcp22.suse.cz> <1390301143-9541-1-git-send-email-mhocko@suse.cz> <1390301143-9541-2-git-send-email-mhocko@suse.cz> <20140121114219.8c34256dfbe7c2470b36ced8@linux-foundation.org> <alpine.LSU.2.11.1401211218010.5688@eggly.anvils>
 <20140122082723.GB18154@dhcp22.suse.cz> <alpine.LSU.2.11.1401230203070.1132@eggly.anvils> <20140123110920.GE4911@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 23 Jan 2014, Michal Hocko wrote:
> On Thu 23-01-14 02:42:58, Hugh Dickins wrote:
> > > 
> > > Actually both patches are needed. If we had only 2/2 then we wouldn't
> > > endless loop inside mem_cgroup_iter but we could still return root to
> > > caller all the time because mem_cgroup_iter_load would return NULL on
> > > css_tryget failure on the cached root. Or am I missing something that
> > > would prevent that?
> > 
> > In theory I agree with you; and if you're missing something, I can't see
> > it either.  But in practice, all my earlier testing of 3.12 and 3.13 was
> > just with 2/2, and I've tried without your 1/2 since: whereas I have hung
> > on 3.12 and 3.13 a convincing number of times without 2/2, I have never
> > hung on them with 2/2 without 1/2.  In practice 1/2 appears essential
> > for 3.10 and 3.11, but irrelevant for 3.12 and 3.13.
> > 
> > That could be easy to explain if there were a difference at the calling
> > end, shrink_zone(), between those releases: but I don't see that.  Odd.
> > Either we're both missing something, or my testing is even less reliable
> > than I'd thought.  But since I certainly don't dispute 1/2, it is merely
> > academic.  Though still bothersome.
> 
> I would assume that it is (sc->nr_reclaimed >= sc->nr_to_reclaim) that
> helps us to back off. SWAP_CLUSTER_MAX shouldn't be that hard to get to
> before css_offline racing part reparents all the memory.

But wouldn't explain why I could see it on 3.10,11 but not on 3.12,13.

Perhaps the 2/2 problem is a lot easier to hit than the 1/2 problem,
and I mistakenly expected to see the 1/2 problem in the timescale that
I saw the 2/2 problem; but I don't really think either is the case.

> 
> Anyway, I would feel safer if this was pushed fixed although you haven't
> reporoduced it.

Absolutely.

> > Before Andrew sends these all off to Linus, I should admit that there's
> > probably a refinement still to come to the CSS_ONLINE one.  I'm ashamed
> > to admit that I overlooked a much earlier comment from Greg Thelen, who
> > suggested that a memory barrier might be required.
> 
> I was thinking about mem barrier while reviewing your patch but then I
> convinced myself that we should be safe also without using one when
> checking CSS_ONLINE.
> We have basically two situations.
> 	- online_css when we can miss it being set which is OK because
> 	  we would miss a new empty group.
> 	- offline_css when we could still see the flag being set but
> 	  then css_tryget would be already failing.
> 
> So while all this is subtle and relies on cgroup core heavily I think we
> should be safe wrt. memory barriers.
> 
> Or did you mean something else here?

Something else.  My CSS_OFFLINE patch claims to prevent the iterator
from returning an uninitialized struct mem_cgroup: if that is to be
relied upon, then it needs to make sure that the initialization of
the mem_cgroup is visible to the caller before the CSS_OFFLINE flag.

kernel/cgroup.c online_css() does nowadays have an smp_wmb() buried
in its rcu_assign_pointer(); but it's not in the right place to
make this particular guarantee.  And an smp_rmb() needed somewhere
too, if it doesn't already come for free somehow.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
