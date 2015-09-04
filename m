Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7106B0255
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 12:18:48 -0400 (EDT)
Received: by ykek143 with SMTP id k143so25700367yke.2
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 09:18:48 -0700 (PDT)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id i199si1780241ywc.101.2015.09.04.09.18.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 09:18:47 -0700 (PDT)
Received: by ykei199 with SMTP id i199so25683376yke.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 09:18:47 -0700 (PDT)
Date: Fri, 4 Sep 2015 12:18:45 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150904161845.GB25329@mtj.duckdns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
 <20150828171438.GD21463@dhcp22.suse.cz>
 <20150828174140.GN26785@mtj.duckdns.org>
 <20150901124459.GC8810@dhcp22.suse.cz>
 <20150901185157.GD18956@htj.dyndns.org>
 <20150904133038.GC8220@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150904133038.GC8220@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello, Michal.

On Fri, Sep 04, 2015 at 03:30:38PM +0200, Michal Hocko wrote:
> The overhead was around 4% for the basic kbuild test without ever
> triggering the [k]memcg limit last time I checked. This was quite some
> time ago and things might have changed since then. Even when this got
> better there will still be _some_ overhead because we have to track that
> memory and that is not free.

So, I just ran small scale tests and I don't see any meaningful
difference between kmemcg disabled and enabled for kbuild workload
(limit is never reached in both cases, memory is reclaimed from global
pressure).  The difference in kernel time usage.  I'm sure there's
*some* overhead buried in the noise but given the current
implementation, I can't see how enabling kmem would lead to 4%
overhead in kbuild tests.  It isn't that kernel intensive to begin
with.

> The question really is whether kmem accounting is so generally useful
> that the overhead is acceptable and it is should be enabled by
> default. From my POV it is a useful mitigation of untrusted users but
> many loads simply do not care because they only care about a certain
> level of isolation.

I don't think that's the right way to approach the problem.  Given
that the cost isn't prohibitive, no user only care about a certain
level of isolation willingly.  Distributing memory is what it's all
about after all and memory is memory, user or kernel.  We have kmem
on/off situation for historical reasons and because the early
implementation wasn't good enough to be enabled by default.  I get
that there can be special cases, temporary or otherwise, where
disabling kmem is desirable but that gotta be the exception, not the
norm.

> I might be wrong here of course but if the default should be switched it
> would deserve a better justification with some numbers so that people
> can see the possible drawbacks.
>
> I agree that the per-cgroup knob is better than the global one. We
> should also find consensus whether the legacy semantic of k < u limit
> should be preserved. It made sense to me at the time it was introduced
> but I recall that Vladimir found it not really helpful when we discussed
> that at LSF. I found it interesting e.g. for the rough task count
> limiting use case which people were asking for.

Let's please not hinge major design decisions on short-sighted hacks
and overhead considerations.  If task count is an actual resource
which needs to be regulated separatley, we should add a proper
controller for it and we did.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
