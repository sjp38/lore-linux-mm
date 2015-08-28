Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1D72E6B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 16:53:05 -0400 (EDT)
Received: by ykba134 with SMTP id a134so14681062ykb.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:53:04 -0700 (PDT)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id e185si3254049ywc.4.2015.08.28.13.53.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 13:53:04 -0700 (PDT)
Received: by ykdz80 with SMTP id z80so27643447ykd.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:53:04 -0700 (PDT)
Date: Fri, 28 Aug 2015 16:53:01 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828205301.GB11089@htj.dyndns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828171322.GC21463@dhcp22.suse.cz>
 <20150828204554.GM9610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828204554.GM9610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello, Vladmir.

On Fri, Aug 28, 2015 at 11:45:54PM +0300, Vladimir Davydov wrote:
> Actually, memory.high by itself *is* the protection against GFP_NOWAIT
> allocations, similarly to zone watermarks. W/o it we would have no other
> choice but fail a GFP_NOWAIT allocation on hitting memory.max. One
> should just set it so that
> 
>   memory.max - memory.high > [max sum size of !__GFP_WAIT allocations
>                               that can normally occur in a row]

While this would be true in many cases, I don't think this is the
intention of the two knobs and the space between high and max can be
filled up by anything which can't be reclaimed - e.g. too many dirty /
writeback pages on a slow device or memlocked pages.  If it were
really the buffer for GFP_NOWAIT, there's no reason to even make it a
separate knob and we *may* change how over-high reclaim behaves in the
future, so let's please not dig ourselves into something too specific.

> That being said, currently I don't see any point in making memory.high
> !__GFP_WAIT-safe.

Yeah, as long as the blow up can't be triggered consistently, it
should be fine.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
