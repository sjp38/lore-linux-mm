Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id B34976B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 04:30:09 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so16999439wic.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 01:30:09 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id gk9si43989621wjb.122.2015.10.07.01.30.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 01:30:08 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so201893804wic.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 01:30:06 -0700 (PDT)
Date: Wed, 7 Oct 2015 10:30:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: convert threshold to bytes
Message-ID: <20151007083004.GB17444@dhcp22.suse.cz>
References: <fc100a5a381d1961c3b917489eb82b098d9e0840.1444081366.git.shli@fb.com>
 <20151006170122.GB2752@dhcp22.suse.cz>
 <20151006122225.8a499b42f49d8484b61632a8@linux-foundation.org>
 <20151007073002.GA17444@dhcp22.suse.cz>
 <20151007005820.54a0b2da.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151007005820.54a0b2da.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Wed 07-10-15 00:58:20, Andrew Morton wrote:
> On Wed, 7 Oct 2015 09:30:02 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Tue 06-10-15 12:22:25, Andrew Morton wrote:
> > > On Tue, 6 Oct 2015 19:01:23 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > > 
> > > > On Mon 05-10-15 14:44:22, Shaohua Li wrote:
> > > > > The page_counter_memparse() returns pages for the threshold, while
> > > > > mem_cgroup_usage() returns bytes for memory usage. Convert the threshold
> > > > > to bytes.
> > > > > 
> > > > > Looks a regression introduced by 3e32cb2e0a12b69150
> > > > 
> > > > Yes. This suggests
> > > > Cc: stable # 3.19+
> > > 
> > > But it's been this way for 2 years and nobody noticed it.  How come?
> > 
> > Maybe we do not have that many users of this API with newer kernels.
> 
> Either it's zero or all the users have worked around this bug.
> 
> > > Or at least, nobody reported it.  Maybe people *have* noticed it, and
> > > adjusted their userspace appropriately.  In which case this patch will
> > > cause breakage.
> > 
> > I dunno, I would rather have it fixed than keep bug to bug compatibility
> > because they would eventually move to a newer kernel one day when they
> > see the "breakage" anyway.
> 
> They'd only see breakage if we fixed this in the newer kernel.
> 
> We could just change the docs and leave it as-is.  That it is called
> "usage_in_bytes" makes that a bit awkward.

The whole API is bytes based. Having one which is silently page size
based is definitely wrong.
 
> A bit of googling indicates that people are using usage_in_bytes.  A
> few.  All the discussions I found clearly predate this bug.
>
> 
> So did people just stop using this?

To be honest I haven't seen any real users from my enterprise
distribution experience and I also consider the API quite unusable
because most loads simply fill up their limit with the page case so
something like a vmpressure is a much better indicator of the memory
usage.

This has been introduced before my time. Kirill has introduced it back
in 2009.

> Is there some alternative way of getting the same info?

I am not aware of any alternative nor am I aware of any strong usecases
for such a small granularity API. The consensus so far has been that any
new controller knob for the new cgrroup API has to be backed by a strong
usecase.

I am pretty sure that we want some form of memory pressure notification,
though.

> Why does memcg_write_event_control() says "DO NOT USE IN NEW FILES"
> and "DO NOT ADD NEW FILES"?

Because eventfd notification mechanism is considered a wrong API to
convey notifications. New cgroup API is supposed to use a new mechanism.
The current one will have to live with the old/legacy cgroup API though.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
