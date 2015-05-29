Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 093786B009C
	for <linux-mm@kvack.org>; Fri, 29 May 2015 08:08:41 -0400 (EDT)
Received: by wifw1 with SMTP id w1so21100713wif.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 05:08:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9si3215508wif.13.2015.05.29.05.08.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 05:08:39 -0700 (PDT)
Date: Fri, 29 May 2015 14:08:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150529120838.GC22728@dhcp22.suse.cz>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526141011.GA11065@cmpxchg.org>
 <20150528210742.GF27479@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150528210742.GF27479@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 28-05-15 17:07:42, Tejun Heo wrote:
> Hello, Johannes, Michal.
> 
> On Tue, May 26, 2015 at 10:10:11AM -0400, Johannes Weiner wrote:
> > On Tue, May 26, 2015 at 01:50:06PM +0200, Michal Hocko wrote:
> > > Please note that this patch introduces a USER VISIBLE CHANGE OF BEHAVIOR.
> > > Without mm->owner _all_ tasks associated with the mm_struct would
> > > initiate memcg migration while previously only owner of the mm_struct
> > > could do that. The original behavior was awkward though because the user
> > > task didn't have any means to find out the current owner (esp. after
> > > mm_update_next_owner) so the migration behavior was not well defined
> > > in general.
> > > New cgroup API (unified hierarchy) will discontinue tasks file which
> > > means that migrating threads will no longer be possible. In such a case
> > > having CLONE_VM without CLONE_THREAD could emulate the thread behavior
> > > but this patch prevents from isolating memcg controllers from others.
> > > Nevertheless I am not convinced such a use case would really deserve
> > > complications on the memcg code side.
> > 
> > I think such a change is okay.  The memcg semantics of moving threads
> > with the same mm into separate groups have always been arbitrary.  No
> > reasonable behavior can be expected of this, so what sane real life
> > usecase would rely on it?
> 
> I suppose that making mm always follow the threadgroup leader should
> be fine, right? 

That is the plan.

> While this wouldn't make any difference in the unified hierarchy,

Just to make sure I understand. "wouldn't make any difference" because
the API is not backward compatible right?

> I think this would make more sense for traditional hierarchies.

Yes I believe so.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
