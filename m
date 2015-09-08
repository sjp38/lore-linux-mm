Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5E16B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 14:50:53 -0400 (EDT)
Received: by ykdu9 with SMTP id u9so58112553ykd.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 11:50:53 -0700 (PDT)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id i81si2779999ywb.209.2015.09.08.11.50.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 11:50:52 -0700 (PDT)
Received: by ykcf206 with SMTP id f206so133546917ykc.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 11:50:52 -0700 (PDT)
Date: Tue, 8 Sep 2015 14:50:48 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150908185048.GK13749@mtj.duckdns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
 <20150828171438.GD21463@dhcp22.suse.cz>
 <20150828174140.GN26785@mtj.duckdns.org>
 <20150901124459.GC8810@dhcp22.suse.cz>
 <20150901185157.GD18956@htj.dyndns.org>
 <20150904133038.GC8220@dhcp22.suse.cz>
 <20150904161845.GB25329@mtj.duckdns.org>
 <20150907105437.GE6022@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150907105437.GE6022@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello, Michal.

On Mon, Sep 07, 2015 at 12:54:37PM +0200, Michal Hocko wrote:
> OK, I've quickly rerun my test on 32CPU machine with 64G of RAM
> Elapsed
> logs.kmem: min: 68.10 max: 69.27 avg: 68.53 std: 0.53 runs: 3
> logs.no.kmem: min: 64.08 [94.1%] max: 68.42 [98.8%] avg: 66.22 [96.6%] std: 1.77 runs: 3
> User
> logs.kmem: min: 867.68 max: 872.88 avg: 869.49 std: 2.40 runs: 3
> logs.no.kmem: min: 865.99 [99.8%] max: 884.94 [101.4%] avg: 874.08 [100.5%] std: 7.98 runs: 3
> System
> logs.kmem: min: 78.50 max: 78.85 avg: 78.63 std: 0.16 runs: 3
> logs.no.kmem: min: 75.36 [96.0%] max: 80.50 [102.1%] avg: 77.91 [99.1%] std: 2.10 runs: 3
> 
> The elapsed time is still ~3% worse in average while user and system are
> in noise. I haven't checked where he overhead is coming from.

Does the cgroup have memory limit configured?  Unless there are
measurement errors, the only way it'd take noticeably longer w/o
incurring more CPU time is spending time blocked on reclaim and
enabling kmem of course adds to memory pressure, which is the intended
behavior.

> > I don't think that's the right way to approach the problem.  Given
> > that the cost isn't prohibitive, no user only care about a certain
> > level of isolation willingly.
> 
> I haven't said it is prohibitive. It is simply non-zero and there is
> always cost/benefit that should be considered.

We do want to hunt down that 3% but locking into interface is an a lot
larger and longer-term commitment.  The cost sure is non-zero but I'd
be surprised if we can't get that down to something generally
acceptable over time given that the domain switching is a relatively
low-frequency event (scheduling) and it's an area where we can
actively make space to speed trade-off.

> > Distributing memory is what it's all about after all and memory is
> > memory, user or kernel.
> 
> True except that kmem accounting doesn't cover the whole kernel memory
> usage. It is an opt-in mechanism for a _better_ isolation. And the
> question really is whether that better isolation is needed/requested by
> default.

It isn't perfect but kmem and socket buffers do cover most of kernel
memory usage that is accountable to userland.  It isn't just a matter
of better or worse.  The goal of cgroup is providing a "reasonable"
isolation.  Sure, we can decide to ignore some but that should be
because the extra accuracy there doesn't matter in the scheme of
things and thus paying the overhead is pointless; however, users
shouldn't need to worry about the different levels of ambiguous
accuracies which can't even be quantified, at least not by default.

Let's please not get lost in perfectionism.  Sure, it can't be perfect
but that doesn't mean an attainable and clear goal doesn't exist here.

> > We have kmem
> > on/off situation for historical reasons and because the early
> > implementation wasn't good enough to be enabled by default.  I get
> > that there can be special cases, temporary or otherwise, where
> > disabling kmem is desirable but that gotta be the exception, not the
> > norm.
> 
> The default should be the cheapest one IMHO. And our overhead is really

That is a way too simplistic and greedy decision criterion.  I don't
think we want to make interface decisions on that.  Overhead
considerations definitely dictate what we can and can't do and that's
why I said that the cost wasn't prohibitive but there are a whole lot
of other things to consider too including where we wanna be
eventually years down the road.

> close to 0 if no memcg accounting is enabled thanks to Johannes'
> page_counters. Then we have a lightweight form of accounting (only user
> memory) which is nicely defined. And then we have an additional opt-in
> for a better isolation which involves some kernel memory as well. Why
> should we conflate the last two? I mean, if somebody wants an additional
> protection then sure, enable kmem and pay an additional overhead but why
> to force this on everybody who wants to use memcg?

Because it betrays the basic goal of reasonable resource isolation.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
