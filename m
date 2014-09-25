Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7796B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 09:07:21 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id q5so9388760wiv.16
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 06:07:20 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id q9si10447118wia.97.2014.09.25.06.07.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 06:07:19 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id u57so6079209wes.27
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 06:07:19 -0700 (PDT)
Date: Thu, 25 Sep 2014 15:07:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140925130716.GE12090@dhcp22.suse.cz>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
 <20140922144158.GC20398@esperanza>
 <20140922185736.GB6630@cmpxchg.org>
 <20140923110634.GH18526@esperanza>
 <20140923132801.GA14302@cmpxchg.org>
 <20140923152150.GL18526@esperanza>
 <20140923170525.GA28460@cmpxchg.org>
 <20140924141633.GB4558@dhcp22.suse.cz>
 <20140924170017.GB9968@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140924170017.GB9968@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 24-09-14 13:00:17, Johannes Weiner wrote:
> On Wed, Sep 24, 2014 at 04:16:33PM +0200, Michal Hocko wrote:
> > On Tue 23-09-14 13:05:25, Johannes Weiner wrote:
> > [...]
> > >  #include <trace/events/vmscan.h>
> > >  
> > > -int page_counter_sub(struct page_counter *counter, unsigned long nr_pages)
> > > +/**
> > > + * page_counter_cancel - take pages out of the local counter
> > > + * @counter: counter
> > > + * @nr_pages: number of pages to cancel
> > > + *
> > > + * Returns whether there are remaining pages in the counter.
> > > + */
> > > +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
> > >  {
> > >  	long new;
> > >  
> > >  	new = atomic_long_sub_return(nr_pages, &counter->count);
> > >  
> > > -	if (WARN_ON(unlikely(new < 0)))
> > > -		atomic_long_set(&counter->count, 0);
> > > +	if (WARN_ON_ONCE(unlikely(new < 0)))
> > > +		atomic_long_add(nr_pages, &counter->count);
> > >  
> > >  	return new > 0;
> > >  }
> > 
> > I am not sure I understand this correctly.
> > 
> > The original res_counter code has protection against < 0 because it used
> > unsigned longs and wanted to protect from really disturbing effects of
> > underflow I guess (this wasn't documented anywhere). But you are using
> > long so even underflow shouldn't be a big problem so why do we need a
> > fixup?
> 
> Immediate issues might be bogus numbers showing up in userspace or
> endless looping during reparenting.  Negative values are just not
> defined for that counter, so I want to mitigate exposing them.
> 
> It's not completely leak-free, as you can see, but I don't think it'd
> be worth weighing down the hot path any more than this just to
> mitigate the unlikely consequences of kernel bug.
> 
> > The only way how we can end up < 0 would be a cancel without pairing
> > charge AFAICS. A charge should always appear before uncharge
> > because both of them are using atomics which imply memory barriers
> > (atomic_*_return). So do I understand correctly that your motivation
> > is to fix up those cancel-without-charge automatically? This would
> > definitely ask for a fat comment. Or am I missing something?
> 
> This function is also used by the uncharge path, so any imbalance in
> accounting, not just from spurious cancels, is caught that way.
> 
> As you said, these are all atomics, so it has nothing to do with
> memory ordering.  It's simply catching logical underflows.

OK, I think we should document this in the changelog and/or in the
comment. These things are easy to forget...

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
