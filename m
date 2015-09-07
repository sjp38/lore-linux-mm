Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 86A596B0256
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 06:54:40 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so84418363wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 03:54:40 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id ll9si20555962wic.3.2015.09.07.03.54.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 03:54:39 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so79473278wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 03:54:39 -0700 (PDT)
Date: Mon, 7 Sep 2015 12:54:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150907105437.GE6022@dhcp22.suse.cz>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
 <20150828171438.GD21463@dhcp22.suse.cz>
 <20150828174140.GN26785@mtj.duckdns.org>
 <20150901124459.GC8810@dhcp22.suse.cz>
 <20150901185157.GD18956@htj.dyndns.org>
 <20150904133038.GC8220@dhcp22.suse.cz>
 <20150904161845.GB25329@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150904161845.GB25329@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri 04-09-15 12:18:45, Tejun Heo wrote:
> Hello, Michal.
> 
> On Fri, Sep 04, 2015 at 03:30:38PM +0200, Michal Hocko wrote:
> > The overhead was around 4% for the basic kbuild test without ever
> > triggering the [k]memcg limit last time I checked. This was quite some
> > time ago and things might have changed since then. Even when this got
> > better there will still be _some_ overhead because we have to track that
> > memory and that is not free.
> 
> So, I just ran small scale tests and I don't see any meaningful
> difference between kmemcg disabled and enabled for kbuild workload
> (limit is never reached in both cases, memory is reclaimed from global
> pressure).  The difference in kernel time usage.  I'm sure there's
> *some* overhead buried in the noise but given the current
> implementation, I can't see how enabling kmem would lead to 4%
> overhead in kbuild tests.  It isn't that kernel intensive to begin
> with.

OK, I've quickly rerun my test on 32CPU machine with 64G of RAM
Elapsed
logs.kmem: min: 68.10 max: 69.27 avg: 68.53 std: 0.53 runs: 3
logs.no.kmem: min: 64.08 [94.1%] max: 68.42 [98.8%] avg: 66.22 [96.6%] std: 1.77 runs: 3
User
logs.kmem: min: 867.68 max: 872.88 avg: 869.49 std: 2.40 runs: 3
logs.no.kmem: min: 865.99 [99.8%] max: 884.94 [101.4%] avg: 874.08 [100.5%] std: 7.98 runs: 3
System
logs.kmem: min: 78.50 max: 78.85 avg: 78.63 std: 0.16 runs: 3
logs.no.kmem: min: 75.36 [96.0%] max: 80.50 [102.1%] avg: 77.91 [99.1%] std: 2.10 runs: 3

The elapsed time is still ~3% worse in average while user and system are
in noise. I haven't checked where he overhead is coming from.
 
> > The question really is whether kmem accounting is so generally useful
> > that the overhead is acceptable and it is should be enabled by
> > default. From my POV it is a useful mitigation of untrusted users but
> > many loads simply do not care because they only care about a certain
> > level of isolation.
> 
> I don't think that's the right way to approach the problem.  Given
> that the cost isn't prohibitive, no user only care about a certain
> level of isolation willingly.

I haven't said it is prohibitive. It is simply non-zero and there is
always cost/benefit that should be considered.

> Distributing memory is what it's all about after all and memory is
> memory, user or kernel.

True except that kmem accounting doesn't cover the whole kernel memory
usage. It is an opt-in mechanism for a _better_ isolation. And the
question really is whether that better isolation is needed/requested by
default.

> We have kmem
> on/off situation for historical reasons and because the early
> implementation wasn't good enough to be enabled by default.  I get
> that there can be special cases, temporary or otherwise, where
> disabling kmem is desirable but that gotta be the exception, not the
> norm.

The default should be the cheapest one IMHO. And our overhead is really
close to 0 if no memcg accounting is enabled thanks to Johannes'
page_counters. Then we have a lightweight form of accounting (only user
memory) which is nicely defined. And then we have an additional opt-in
for a better isolation which involves some kernel memory as well. Why
should we conflate the last two? I mean, if somebody wants an additional
protection then sure, enable kmem and pay an additional overhead but why
to force this on everybody who wants to use memcg?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
