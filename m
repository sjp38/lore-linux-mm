Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4F91D6B0254
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 11:50:06 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so189692514ykd.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 08:50:06 -0700 (PDT)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id c22si9401556ywb.41.2015.09.15.08.50.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 08:50:05 -0700 (PDT)
Received: by ykdu9 with SMTP id u9so190696883ykd.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 08:50:05 -0700 (PDT)
Date: Tue, 15 Sep 2015 11:50:02 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] memcg: ratify and consolidate over-charge handling
Message-ID: <20150915155002.GF2905@mtj.duckdns.org>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
 <20150914193225.GA26273@dhcp22.suse.cz>
 <20150914195608.GF25369@htj.duckdns.org>
 <20150915080110.GA14532@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915080110.GA14532@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

Hello, Michal.

On Tue, Sep 15, 2015 at 10:01:10AM +0200, Michal Hocko wrote:
> > > OK the code is easier in the end, although I would argue that try_charge
> > > could return ENOMEM for GFP_NOWAIT instead of overcharging (this would
> > > e.g. allow precharge to bail out earlier). Something for a separate patch I
> > > guess.
> > 
> > Hmm... GFP_NOWAIT is failed unless it also has __GFP_NOFAIL.
> 
> Yes I wasn't clear, sorry, it fails but TIF_MEMDIE or killed/exiting
> context would still overcharge GFP_NOWAIT requests rather than failing
> them. Something for a separate patch though.

Ah, I see.  I'm not sure that'd matter one way or the other tho.

> > I don't even think this is an implementation detail.
> 
> I really think this is an implementation detail because we can force
> the implementation to never overcharge. Just retry indefinitely for

But we actively choose not to and I think that's an architectural
decision.

> I am not sure I understand here. High and max are basically resembling
> watermarks for the global case. Sure max/high can be set independently
> which is not the case for the global case which calculates them from
> min_free_kbytes but why would that matter and make them different?

Yes, there are similarities but if we really wanted to emulate global
case, we'd just have the hardlimit and then have async reclaim to keep
certain level of reserves and so on.

I don't think it'd be meaningful to try to follow the limit strictly
under all circumstances.  It's not like we can track all memory
consumption to begin with.  There always is common consumption which
can't clearly be distributed to specific cgroups which makes literal
strictness rather pointless.  Also, I'm pretty sure there will always
be enough cases where it is saner to temporarily breach the limit in
small scale just because exhaustion of memory inside a cgroup doesn't
mean global exhaustion and that's an inherent characteristic of what
memcg does.

Anyways, I don't think this difference in viewpoints matters that
much.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
