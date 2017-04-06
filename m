Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id F11476B0434
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 10:49:37 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u18so6509884wrc.17
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 07:49:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u127si3294414wmf.107.2017.04.06.07.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 07:49:36 -0700 (PDT)
Date: Thu, 6 Apr 2017 10:49:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmscan: fix IO/refault regression in cache
 workingset transition
Message-ID: <20170406144922.GA32364@cmpxchg.org>
References: <20170404220052.27593-1-hannes@cmpxchg.org>
 <1491430264.16856.43.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1491430264.16856.43.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Apr 05, 2017 at 06:11:04PM -0400, Rik van Riel wrote:
> On Tue, 2017-04-04 at 18:00 -0400, Johannes Weiner wrote:
> 
> > +
> > +	/*
> > +	 * When refaults are being observed, it means a new
> > workingset
> > +	 * is being established. Disable active list protection to
> > get
> > +	 * rid of the stale workingset quickly.
> > +	 */
> 
> This looks a little aggressive. What is this
> expected to do when you have multiple workloads
> sharing the same LRU, and one of the workloads
> is doing refaults, while the other workload is
> continuing to use the same working set as before?

It is aggressive, but it seems to be a trade-off between three things:
maximizing workingset protection during stable periods; minimizing
repeat refaults during workingset transitions; both of those when the
LRU is shared.

The data point we would need to balance optimally between these cases
is whether the active list is hot or stale, but we only have that once
we disable active list protection and challenge those pages.

The more conservative we go about this, the more IO cost to establish
the incoming workingset pages.

I actually did experiment with this. Instead of disabling active list
protection entirely, I reverted to the more conservative 50/50 ratio
during refaults. The 50/50 split addressed the regression, but the
aggressive behavior fared measurably better across three different
services I tested this on (one of them *is* multi-workingset, but the
jobs are cgrouped so they don't *really* share LRUs).

That win was intriguing, but it would be bad if it came out of the
budget of truly shared LRUs (for which I have no quantification).

Since this is a regression fix, it would be fair to be conservative
and use the 50/50 split for transitions here; keep the more adaptive
behavior for a future optimization.

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
