Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id C9A116B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 09:30:41 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so17804186wic.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 06:30:41 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id eo3si4426034wjd.92.2015.09.04.06.30.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 06:30:40 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so17803527wic.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 06:30:39 -0700 (PDT)
Date: Fri, 4 Sep 2015 15:30:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150904133038.GC8220@dhcp22.suse.cz>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
 <20150828171438.GD21463@dhcp22.suse.cz>
 <20150828174140.GN26785@mtj.duckdns.org>
 <20150901124459.GC8810@dhcp22.suse.cz>
 <20150901185157.GD18956@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150901185157.GD18956@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Tue 01-09-15 14:51:57, Tejun Heo wrote:
> Hello,
> 
> On Tue, Sep 01, 2015 at 02:44:59PM +0200, Michal Hocko wrote:
> > The runtime overhead is not negligible and I do not see why everybody
> > should be paying that price by default. I can definitely see the reason why
> > somebody would want to enable the kmem accounting but many users will
> > probably never care because the kernel footprint would be in the noise
> > wrt. user memory.
> 
> We said the same thing about hierarchy support.  Sure, it's not the
> same but I think it's wiser to keep the architectural decisions at a
> higher level.  I don't think kmem overhead is that high but if this
> actually is a problem we'd need a per-cgroup knob anyway.

The overhead was around 4% for the basic kbuild test without ever
triggering the [k]memcg limit last time I checked. This was quite some
time ago and things might have changed since then. Even when this got
better there will still be _some_ overhead because we have to track that
memory and that is not free.

The question really is whether kmem accounting is so generally useful
that the overhead is acceptable and it is should be enabled by
default. From my POV it is a useful mitigation of untrusted users but
many loads simply do not care because they only care about a certain
level of isolation.

I might be wrong here of course but if the default should be switched it
would deserve a better justification with some numbers so that people
can see the possible drawbacks.

I agree that the per-cgroup knob is better than the global one. We
should also find consensus whether the legacy semantic of k < u limit
should be preserved. It made sense to me at the time it was introduced
but I recall that Vladimir found it not really helpful when we discussed
that at LSF. I found it interesting e.g. for the rough task count
limiting use case which people were asking for.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
