Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4378E6B0005
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 18:29:40 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id g73so140687958ioe.3
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 15:29:40 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id q102si484918ioi.196.2016.01.31.15.29.38
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 15:29:39 -0800 (PST)
Date: Mon, 1 Feb 2016 10:29:01 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [LSF/MM TOPIC] proposals for topics
Message-ID: <20160131232901.GO20456@dastard>
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <20160125184559.GE29291@cmpxchg.org>
 <20160126095022.GC27563@dhcp22.suse.cz>
 <20160128205525.GO6033@dastard>
 <20160128220422.GG621@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160128220422.GG621@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Jan 28, 2016 at 11:04:23PM +0100, Michal Hocko wrote:
> On Fri 29-01-16 07:55:25, Dave Chinner wrote:
> > On Tue, Jan 26, 2016 at 10:50:23AM +0100, Michal Hocko wrote:
> [...]
> > > There have been patches posted during the year to fortify those places
> > > which cannot cope with allocation failures for ext[34] and testing
> > > has shown that ext* resp. xfs are quite ready to see NOFS allocation
> > > failures.
> > 
> > The XFS situation is compeletely unchanged from last year, and the
> > fact that you say it handles NOFS allocation failures just fine
> > makes me seriously question your testing methodology.
> 
> I am certainly open to suggestions there. My testing managed to identify
> some weaker points in ext[34] which led to RO remounts. __GFP_NOFAIL as
> the current band aid worked for them. I wasn't able to hit this with
> xfs.

I'd suggest that you turn on error injection to fail memory
allocation. See Documentation/fault-injection/fault-injection.txt
and start failing random slab allocations whilst running a workload
that creates/unlinks lots of files.

> > We need to fundamentally change error handling in transactions in
> > XFS to allow arbitrary memory allocation to fail. That is, we need
> > to implement a full transaction rollback capability so we can back
> > out changes made during the transaction before the error occurred.
> > That's a major amount of work, and I'm probably not going to do
> > anything on this in the next year as it's low priority because what
> > we have now works.
> 
> I am quite confused now. I remember you were the one who complained
> about the silent nofail behavior of the allocator because that means
> you cannot implement an appropriate fallback strategy. 

I complained about the fact the allocator did not behave as
documented (or expected) in that it didn't fail allocations we
expected it to fail.

> Please also
> note that I am talking solely about GFP_NOFS allocation here. The
> allocator really cannot do much other than hoplessly retrying and
> relying on somebody _else_ to make a forward progress.

Well, yes, that's why XFS has, for many years, counted retry
attempts and emitted warnings when it is struggling to make
allocation progress (in any context). :)

> That being said, I do understand that allowing GFP_NOFS allocation to
> fail is not an easy task and nothing to be done tomorrow or in few
> months, but I believe that a discussion with FS people about what
> can/should be done in order to make this happen is valuable.

The discussion - from my perspective - is likely to be no different
to previous years. None of the proposals that FS people have come up
to address the "need memory allocation guarantees" issue have got
any traction on the mm side. Unless there's something fundamentally
new from the MM side that provides filesystems with a replacement
for __GFP_NOFAIL type behaviour, I don't think further discussion is
going to change the status quo.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
