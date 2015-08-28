Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id B658A6B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 16:44:36 -0400 (EDT)
Received: by ykba134 with SMTP id a134so14480759ykb.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:44:36 -0700 (PDT)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id r204si3502085ywb.149.2015.08.28.13.44.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 13:44:35 -0700 (PDT)
Received: by ykek5 with SMTP id k5so13593234yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:44:35 -0700 (PDT)
Date: Fri, 28 Aug 2015 16:44:32 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828204432.GA11089@htj.dyndns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828163611.GI9610@esperanza>
 <20150828164819.GL26785@mtj.duckdns.org>
 <20150828203231.GL9610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828203231.GL9610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

Hello,

On Fri, Aug 28, 2015 at 11:32:31PM +0300, Vladimir Davydov wrote:
> What kind of workload should it be then? `find` will constantly invoke
> d_alloc, which issues a GFP_KERNEL allocation and therefore is allowed
> to perform reclaim...
> 
> OK, I tried to reproduce the issue on the latest mainline kernel and ...
> succeeded - memory.current did occasionally jump up to ~55M although
> memory.high was set to 32M. Hmm, strange... Started to investigate.
> Printed stack traces and found that we don't invoke memcg reclaim on
> normal GFP_KERNEL allocations! How is that? The thing is there was a
> commit that made SLUB (not VFS or any other kmem user, but core SLUB)
> try to allocate high order slab pages w/o __GFP_WAIT for performance
> reasons. That broke kmemcg case. Here it goes:

Ah, cool, so it was a bug from slub.  Punting to return path still has
some niceties but if we can't consistently get rid of stack
consumption it's not that attractive.  Let's revisit it later together
with hard limit reclaim.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
