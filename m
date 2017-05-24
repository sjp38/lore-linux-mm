Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD1866B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 03:34:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w79so36015881wme.7
        for <linux-mm@kvack.org>; Wed, 24 May 2017 00:34:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x40si23395194edb.133.2017.05.24.00.34.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 00:34:07 -0700 (PDT)
Date: Wed, 24 May 2017 09:34:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/4 v2] mm: give __GFP_REPEAT a better semantic
Message-ID: <20170524073403.GA14733@dhcp22.suse.cz>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170516091022.GD2481@dhcp22.suse.cz>
 <77fdc6db-5cc1-297f-e049-0d6f824e688c@suse.cz>
 <87shjvhxmr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87shjvhxmr.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, NeilBrown <neilb@suse.de>, Jonathan Corbet <corbet@lwn.net>, Paolo Bonzini <pbonzini@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On Wed 24-05-17 11:06:04, NeilBrown wrote:
> On Tue, May 23 2017, Vlastimil Babka wrote:
> 
> > On 05/16/2017 11:10 AM, Michal Hocko wrote:
> >> So, is there some interest in this? I am not going to push this if there
> >> is a general consensus that we do not need to do anything about the
> >> current situation or need a different approach.
> >
> > After the recent LWN article [1] I think that we should really support
> > marking allocations as failable, without making them too easily failable
> > via __GFP_NORETRY. The __GFP_RETRY_MAY_FAIL flag sounds like a good way
> > to do that without introducing a new __GFP_MAYFAIL. We could also
> > introduce a wrapper such as GFP_KERNEL_MAYFAIL.
> >
> > [1] https://lwn.net/Articles/723317/
> 
> Yes please!!!
> 
> I particularly like:
> 
> > - GFP_KERNEL | __GFP_NORETRY - overrides the default allocator behavior and
> >   all allocation requests fail early rather than cause disruptive
> >   reclaim (one round of reclaim in this implementation). The OOM killer
> >   is not invoked.
> > - GFP_KERNEL | __GFP_RETRY_MAYFAIL - overrides the default allocator behavior
> >   and all allocation requests try really hard. The request will fail if the
> >   reclaim cannot make any progress. The OOM killer won't be triggered.
> > - GFP_KERNEL | __GFP_NOFAIL - overrides the default allocator behavior
> >   and all allocation requests will loop endlessly until they
> >   succeed. This might be really dangerous especially for larger orders.
> 
> There seems to be a good range here, and the two end points are good
> choices.
> I like that only __GFP_NOFAIL triggers the OOM.
> I would like the middle option to be the default.  I think that is what
> many people thought the default was.  I appreciate that making the
> transition might be awkward.

Yeah, turning GFP_KERNEL int GFP_KERNEL | __GFP_RETRY_MAYFAIL would be
hard if possible at all. One of the problems with the current code is
that error paths are checked but there is rarely a sane error handling
strategy implemented on top. So we mostly check for the failure and
return -ENOMEM up the call chain without having a great clue what will
happen up there. And the result might be really unexpected. Say that
some allocation fails on the sys_close() path and returns to the
userspace. a) this syscall is not supposed to return -ENOMEM b) there is
no _transaction_ rollback to have the fd in a sane state to retry later.

Therefore I assume that __GFP_RETRY_MAYFAIL will be slowly added to
those places where the error path strategy is clear.

> Maybe create GFP_DEFAULT which matches the middle option and encourage
> that in new code??
> 
> We would probably want guidelines on when __GFP_NOFAIL is acceptable.
> I assume:
>   - no locks held

This is of course preferable but hard to demand in general. I think that
requiring "no locks which can block oom victim exit" would be more
appropriate, albeit much more fuzzy. But in general locks should be much
smaller problem these days with the async OOM reclaim (oom_reaper) and
with __GFP_NOFAIL gaining access to a part of memory reserves when
hitting the OOM path.

>   - small allocations OK, large allocation need clear justification.

yes

>   - error would be exposed to systemcall

Not only. There are some FS transaction code paths where failure
basically means RO remount and such. This would be acceptable as well.
> ???
> 
> I think it is important to give kernel developers clear options and make
> it easy for them to choose the best option.  This helps to do that.

Yes, I completely agree here. Does the updated documentation in the
patch helps or would you suggest som improvements? 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
