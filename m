Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6853D6B0038
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 12:51:22 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id p50so13435191qtc.9
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 09:51:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x38si1852395qtx.134.2017.04.06.09.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 09:51:21 -0700 (PDT)
Message-ID: <1491497476.8850.156.camel@redhat.com>
Subject: Re: [PATCH] mm: vmscan: fix IO/refault regression in cache
 workingset transition
From: Rik van Riel <riel@redhat.com>
Date: Thu, 06 Apr 2017 12:51:16 -0400
In-Reply-To: <20170406144922.GA32364@cmpxchg.org>
References: <20170404220052.27593-1-hannes@cmpxchg.org>
	 <1491430264.16856.43.camel@redhat.com> <20170406144922.GA32364@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, 2017-04-06 at 10:49 -0400, Johannes Weiner wrote:
> On Wed, Apr 05, 2017 at 06:11:04PM -0400, Rik van Riel wrote:
> > On Tue, 2017-04-04 at 18:00 -0400, Johannes Weiner wrote:
> > 
> > > +
> > > +	/*
> > > +	A * When refaults are being observed, it means a new
> > > workingset
> > > +	A * is being established. Disable active list protection
> > > to
> > > get
> > > +	A * rid of the stale workingset quickly.
> > > +	A */
> > 
> > This looks a little aggressive. What is this
> > expected to do when you have multiple workloads
> > sharing the same LRU, and one of the workloads
> > is doing refaults, while the other workload is
> > continuing to use the same working set as before?
> 
> That win was intriguing, but it would be bad if it came out of the
> budget of truly shared LRUs (for which I have no quantification).
> 
> Since this is a regression fix, it would be fair to be conservative
> and use the 50/50 split for transitions here; keep the more adaptive
> behavior for a future optimization.
> 
> What do you think?

Lets try your patch, and see what happens.
After all, it only affects the file cache,
and does not lead to anonymous pages being
swapped out and causing major pain.

A fast workload transition seems like it
could be in everybody's best interest.

If this approach leads to trouble, we can
always try to soften it later.

One potential way of softening would be to
look at the number of refaults, vs the
number of working set re-confirmations, and
determine a target based on that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
