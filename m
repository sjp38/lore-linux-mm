Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3F16B0038
	for <linux-mm@kvack.org>; Thu, 28 May 2015 17:07:47 -0400 (EDT)
Received: by qgg60 with SMTP id 60so21961376qgg.2
        for <linux-mm@kvack.org>; Thu, 28 May 2015 14:07:47 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id f86si3696238qkh.19.2015.05.28.14.07.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 14:07:46 -0700 (PDT)
Received: by qkhg32 with SMTP id g32so34039418qkh.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 14:07:46 -0700 (PDT)
Date: Thu, 28 May 2015 17:07:42 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150528210742.GF27479@htj.duckdns.org>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526141011.GA11065@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150526141011.GA11065@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hello, Johannes, Michal.

On Tue, May 26, 2015 at 10:10:11AM -0400, Johannes Weiner wrote:
> On Tue, May 26, 2015 at 01:50:06PM +0200, Michal Hocko wrote:
> > Please note that this patch introduces a USER VISIBLE CHANGE OF BEHAVIOR.
> > Without mm->owner _all_ tasks associated with the mm_struct would
> > initiate memcg migration while previously only owner of the mm_struct
> > could do that. The original behavior was awkward though because the user
> > task didn't have any means to find out the current owner (esp. after
> > mm_update_next_owner) so the migration behavior was not well defined
> > in general.
> > New cgroup API (unified hierarchy) will discontinue tasks file which
> > means that migrating threads will no longer be possible. In such a case
> > having CLONE_VM without CLONE_THREAD could emulate the thread behavior
> > but this patch prevents from isolating memcg controllers from others.
> > Nevertheless I am not convinced such a use case would really deserve
> > complications on the memcg code side.
> 
> I think such a change is okay.  The memcg semantics of moving threads
> with the same mm into separate groups have always been arbitrary.  No
> reasonable behavior can be expected of this, so what sane real life
> usecase would rely on it?

I suppose that making mm always follow the threadgroup leader should
be fine, right?  While this wouldn't make any difference in the
unified hierarchy, I think this would make more sense for traditional
hierarchies.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
