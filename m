Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CC5A0828E5
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 15:44:09 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so149151260wme.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 12:44:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bf2si44496095wjb.6.2016.02.08.12.44.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 12:44:08 -0800 (PST)
Date: Mon, 8 Feb 2016 15:43:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/5] mm: workingset: make shadow node shrinker memcg aware
Message-ID: <20160208204311.GA23389@cmpxchg.org>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
 <934ce4e1cfe42b57e8114c72a447656fe5a01267.1454864628.git.vdavydov@virtuozzo.com>
 <20160208062353.GE22202@cmpxchg.org>
 <20160208142835.GB13379@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160208142835.GB13379@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 08, 2016 at 05:28:35PM +0300, Vladimir Davydov wrote:
> On Mon, Feb 08, 2016 at 01:23:53AM -0500, Johannes Weiner wrote:
> > It's true that both the shrinking of the active list and subsequent
> > activations to regrow it will reduce the number of actionable
> > refaults, and so it wouldn't be unreasonable to also shrink shadow
> > nodes when the active list shrinks.
> > 
> > However, I think these are too many assumptions to encode in the
> > shrinker, because it is only meant to prevent a worst-case explosion
> > of radix tree nodes. I'd prefer it to be dumb and conservative.
> > 
> > Could we instead go with the current usage of the memcg? Whether
> > reclaim happens globally or due to the memory limit, the usage at the
> > time of reclaim gives a good idea of the memory is available to the
> > group. But it's making less assumptions about the internal composition
> > of the memcg's memory, and the consequences associated with that.
> 
> But that would likely result in wasting a considerable chunk of memory
> for stale shadow nodes in case file caches constitute only a small part
> of memcg memory consumption, which isn't good IMHO.

Hm, that's probably true. But I think it's a separate patch at this
point - going from total memory to the cache portion for overhead
reasons - that shouldn't be conflated with the memcg awareness patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
