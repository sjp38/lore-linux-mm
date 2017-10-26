Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB6A16B025F
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 03:50:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y83so1395270wmc.8
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 00:50:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g12si3206784edm.471.2017.10.26.00.49.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 00:49:59 -0700 (PDT)
Date: Thu, 26 Oct 2017 09:49:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171026074958.tmtxkyymmsqtgr7w@dhcp22.suse.cz>
References: <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org>
 <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org>
 <20171025172924.i7du5wnkeihx2fgl@dhcp22.suse.cz>
 <20171025181106.GA14967@cmpxchg.org>
 <20171025190057.mqmnprhce7kvsfz7@dhcp22.suse.cz>
 <20171025211359.GA17899@cmpxchg.org>
 <xr931slqdery.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr931slqdery.fsf@gthelen.svl.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed 25-10-17 15:49:21, Greg Thelen wrote:
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Wed, Oct 25, 2017 at 09:00:57PM +0200, Michal Hocko wrote:
[...]
> >> So just to make it clear you would be OK with the retry on successful
> >> OOM killer invocation and force charge on oom failure, right?
> >
> > Yeah, that sounds reasonable to me.
> 
> Assuming we're talking about retrying within try_charge(), then there's
> a detail to iron out...
> 
> If there is a pending oom victim blocked on a lock held by try_charge() caller
> (the "#2 Locks" case), then I think repeated calls to out_of_memory() will
> return true until the victim either gets MMF_OOM_SKIP or disappears.

true. And oom_reaper guarantees that MMF_OOM_SKIP gets set in the finit
amount of time.

> So a force
> charge fallback might be a needed even with oom killer successful invocations.
> Or we'll need to teach out_of_memory() to return three values (e.g. NO_VICTIM,
> NEW_VICTIM, PENDING_VICTIM) and try_charge() can loop on NEW_VICTIM.

No we, really want to wait for the oom victim to do its job. The only
thing we should be worried about is when out_of_memory doesn't invoke
the reaper. There is only one case like that AFAIK - GFP_NOFS request. I
have to think about this case some more. We currently fail in that case
the request.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
