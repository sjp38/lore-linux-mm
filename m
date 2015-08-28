Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id DE7B26B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 17:07:22 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so73818793pac.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 14:07:22 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pt9si6101306pdb.54.2015.08.28.14.07.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 14:07:22 -0700 (PDT)
Date: Sat, 29 Aug 2015 00:07:04 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828210704.GN9610@esperanza>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828171322.GC21463@dhcp22.suse.cz>
 <20150828204554.GM9610@esperanza>
 <20150828205301.GB11089@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150828205301.GB11089@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, Aug 28, 2015 at 04:53:01PM -0400, Tejun Heo wrote:
> On Fri, Aug 28, 2015 at 11:45:54PM +0300, Vladimir Davydov wrote:
> > Actually, memory.high by itself *is* the protection against GFP_NOWAIT
> > allocations, similarly to zone watermarks. W/o it we would have no other
> > choice but fail a GFP_NOWAIT allocation on hitting memory.max. One
> > should just set it so that
> > 
> >   memory.max - memory.high > [max sum size of !__GFP_WAIT allocations
> >                               that can normally occur in a row]
> 
> While this would be true in many cases, I don't think this is the
> intention of the two knobs and the space between high and max can be
> filled up by anything which can't be reclaimed - e.g. too many dirty /
> writeback pages on a slow device or memlocked pages.  If it were
> really the buffer for GFP_NOWAIT, there's no reason to even make it a
> separate knob and we *may* change how over-high reclaim behaves in the
> future, so let's please not dig ourselves into something too specific.

Yep, come to think of it, you're right. One might want to use the
memory.high knob as the protection, because currently it is the only way
to protect kmemcg against GFP_NOWAIT failures, but it looks more like
abusing it :-/

We should probably think about introducing some kind of watermarks that
would trigger memcg reclaim, asynchronous or direct, on exceeding
them.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
