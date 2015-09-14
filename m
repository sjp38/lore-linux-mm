Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id CF2AF6B0259
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 15:56:12 -0400 (EDT)
Received: by qgx61 with SMTP id 61so124993921qgx.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:56:12 -0700 (PDT)
Received: from mail-qg0-x235.google.com (mail-qg0-x235.google.com. [2607:f8b0:400d:c04::235])
        by mx.google.com with ESMTPS id d81si13626949qkh.66.2015.09.14.12.56.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 12:56:12 -0700 (PDT)
Received: by qgx61 with SMTP id 61so124993551qgx.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:56:11 -0700 (PDT)
Date: Mon, 14 Sep 2015 15:56:08 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] memcg: ratify and consolidate over-charge handling
Message-ID: <20150914195608.GF25369@htj.duckdns.org>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
 <20150914193225.GA26273@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914193225.GA26273@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

Hello, Michal.

On Mon, Sep 14, 2015 at 09:32:25PM +0200, Michal Hocko wrote:
> >   mem_cgroup_try_charge() needs to switch
> >   the returned cgroup to the root one.
> > 
> > The reality is that in memcg there are cases where we are forced
> > and/or willing to go over the limit.  Each such case needs to be
> > scrutinized and justified but there definitely are situations where
> > that is the right thing to do.  We alredy do this but with a
> > superficial and inconsistent disguise which leads to unnecessary
> > complications.
> >
> > This patch updates try_charge() so that it over-charges and returns 0
> > when deemed necessary.  -EINTR return is removed along with all
> > special case handling in the callers.
> 
> OK the code is easier in the end, although I would argue that try_charge
> could return ENOMEM for GFP_NOWAIT instead of overcharging (this would
> e.g. allow precharge to bail out earlier). Something for a separate patch I
> guess.

Hmm... GFP_NOWAIT is failed unless it also has __GFP_NOFAIL.

> Anyway I still do not like usage > max/hard limit presented to userspace
> because it looks like a clear breaking of max/hard limit semantic. I
> realize that we cannot solve the underlying problem easily or it might
> be unfeasible but we should consider how to present this state to the
> userspace.
> We have basically 2 options AFAICS. We can either document that a
> _temporal_ breach of the max/hard limit is allowed or we can hide this
> fact and always present max(current,max).
> The first one might be better for an easier debugging and it is also
> more honest about the current state but the definition of the hard limit
> is a bit weird. It also exposes implementation details to the userspace.
> The other choice is clearly lying but users shouldn't care about the
> implementation details and if the state is really temporal then the
> userspace shouldn't even notice. There is also a risk that somebody is
> already depending on current < max which happened to work without kmem
> until now.
> This is something to be solved in a separate patch I guess but we
> should think about that. I am not entirely clear on that myself but I am
> more inclined to the first option and simply document the potential
> corner case and temporal breach.

I'm pretty sure we don't wanna lie.  Just document that temporal
small-scale breaches may happen.  I don't even think this is an
implementation detail.  The fact that we have separate high and max
limits is already admitting that this is inherently different from
global case and that memcg is consciously and actively making
trade-offs regarding handling of global and local memory pressure and
I think that's the right thing to do and something inherent to what
memcg is doing here.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
