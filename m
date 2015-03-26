Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 903896B006C
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:32:26 -0400 (EDT)
Received: by wgra20 with SMTP id a20so66197873wgr.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:32:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fh2si28442308wib.100.2015.03.26.07.32.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 07:32:24 -0700 (PDT)
Date: Thu, 26 Mar 2015 15:32:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 08/12] mm: page_alloc: wait for OOM killer progress
 before retrying
Message-ID: <20150326143223.GM15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-9-git-send-email-hannes@cmpxchg.org>
 <201503252315.FBJ09847.FSOtOJQFOMLFVH@I-love.SAKURA.ne.jp>
 <20150326112445.GC18560@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326112445.GC18560@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, ying.huang@intel.com, aarcange@redhat.com, david@fromorbit.com, tytso@mit.edu

On Thu 26-03-15 07:24:45, Johannes Weiner wrote:
> On Wed, Mar 25, 2015 at 11:15:48PM +0900, Tetsuo Handa wrote:
> > Johannes Weiner wrote:
[...]
> > >  	/*
> > > -	 * Acquire the oom lock.  If that fails, somebody else is
> > > -	 * making progress for us.
> > > +	 * This allocating task can become the OOM victim itself at
> > > +	 * any point before acquiring the lock.  In that case, exit
> > > +	 * quickly and don't block on the lock held by another task
> > > +	 * waiting for us to exit.
> > >  	 */
> > > -	if (!mutex_trylock(&oom_lock)) {
> > > -		*did_some_progress = 1;
> > > -		schedule_timeout_uninterruptible(1);
> > > -		return NULL;
> > > +	if (test_thread_flag(TIF_MEMDIE) || mutex_lock_killable(&oom_lock)) {
> > > +		alloc_flags |= ALLOC_NO_WATERMARKS;
> > > +		goto alloc;
> > >  	}
> > 
> > When a thread group has 1000 threads and most of them are doing memory allocation
> > request, all of them will get fatal_signal_pending() == true when one of them are
> > chosen by OOM killer.
> > This code will allow most of them to access memory reserves, won't it?
> 
> Ah, good point!  Only TIF_MEMDIE should get reserve access, not just
> any dying thread.  Thanks, I'll fix it in v2.

Do you plan to post this v2 here for review?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
