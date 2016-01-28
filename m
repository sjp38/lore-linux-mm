Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id C49956B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 17:04:25 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p63so44385300wmp.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:04:25 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id y83si6747067wmc.67.2016.01.28.14.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 14:04:24 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id r129so44423927wmr.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:04:24 -0800 (PST)
Date: Thu, 28 Jan 2016 23:04:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] proposals for topics
Message-ID: <20160128220422.GG621@dhcp22.suse.cz>
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <20160125184559.GE29291@cmpxchg.org>
 <20160126095022.GC27563@dhcp22.suse.cz>
 <20160128205525.GO6033@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160128205525.GO6033@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri 29-01-16 07:55:25, Dave Chinner wrote:
> On Tue, Jan 26, 2016 at 10:50:23AM +0100, Michal Hocko wrote:
[...]
> > There have been patches posted during the year to fortify those places
> > which cannot cope with allocation failures for ext[34] and testing
> > has shown that ext* resp. xfs are quite ready to see NOFS allocation
> > failures.
> 
> The XFS situation is compeletely unchanged from last year, and the
> fact that you say it handles NOFS allocation failures just fine
> makes me seriously question your testing methodology.

I am certainly open to suggestions there. My testing managed to identify
some weaker points in ext[34] which led to RO remounts. __GFP_NOFAIL as
the current band aid worked for them. I wasn't able to hit this with
xfs.

> In XFS, *any* memory allocation failure during a transaction will
> either cause a panic through null point deference (because we don't
> check for allocation failure in most cases) or a filesystem
> shutdown (in the cases where we do check). If you haven't seen these
> behaviours, then you haven't been failing memory allocations during
> filesystem modifications.
> 
> We need to fundamentally change error handling in transactions in
> XFS to allow arbitrary memory allocation to fail. That is, we need
> to implement a full transaction rollback capability so we can back
> out changes made during the transaction before the error occurred.
> That's a major amount of work, and I'm probably not going to do
> anything on this in the next year as it's low priority because what
> we have now works.

I am quite confused now. I remember you were the one who complained
about the silent nofail behavior of the allocator because that means
you cannot implement an appropriate fallback strategy. Please also
note that I am talking solely about GFP_NOFS allocation here. The
allocator really cannot do much other than hoplessly retrying and
relying on somebody _else_ to make a forward progress.

That being said, I do understand that allowing GFP_NOFS allocation to
fail is not an easy task and nothing to be done tomorrow or in few
months, but I believe that a discussion with FS people about what
can/should be done in order to make this happen is valuable.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
