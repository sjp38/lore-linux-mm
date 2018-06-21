Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A046E6B0006
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 11:01:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p9-v6so2527868wrm.22
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 08:01:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y20-v6si2219645edm.267.2018.06.21.08.01.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 08:01:27 -0700 (PDT)
Date: Thu, 21 Jun 2018 17:01:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] slub: track number of slabs irrespective of
 CONFIG_SLUB_DEBUG
Message-ID: <20180621150122.GB13063@dhcp22.suse.cz>
References: <20180620224147.23777-1-shakeelb@google.com>
 <010001641fe92599-9006a895-d1ea-4881-a63c-f3749ff9b7b3-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001641fe92599-9006a895-d1ea-4881-a63c-f3749ff9b7b3-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Shakeel Butt <shakeelb@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu 21-06-18 01:15:30, Cristopher Lameter wrote:
> On Wed, 20 Jun 2018, Shakeel Butt wrote:
> 
> > For !CONFIG_SLUB_DEBUG, SLUB does not maintain the number of slabs
> > allocated per node for a kmem_cache. Thus, slabs_node() in
> > __kmem_cache_empty(), __kmem_cache_shrink() and __kmem_cache_destroy()
> > will always return 0 for such config. This is wrong and can cause issues
> > for all users of these functions.
> 
> 
> CONFIG_SLUB_DEBUG is set by default on almost all builds. The only case
> where CONFIG_SLUB_DEBUG is switched off is when we absolutely need to use
> the minimum amount of memory (embedded or some such thing).

I thought those would be using SLOB rather than SLUB.

> 
> > The right solution is to make slabs_node() work even for
> > !CONFIG_SLUB_DEBUG. The commit 0f389ec63077 ("slub: No need for per node
> > slab counters if !SLUB_DEBUG") had put the per node slab counter under
> > CONFIG_SLUB_DEBUG because it was only read through sysfs API and the
> > sysfs API was disabled on !CONFIG_SLUB_DEBUG. However the users of the
> > per node slab counter assumed that it will work in the absence of
> > CONFIG_SLUB_DEBUG. So, make the counter work for !CONFIG_SLUB_DEBUG.
> 
> Please do not do this. Find a way to avoid these checks. The
> objective of a !CONFIG_SLUB_DEBUG configuration is to not compile in
> debuggin checks etc etc in order to reduce the code/data footprint to the
> minimum necessary while sacrificing debuggability etc etc.
> 
> Maybe make it impossible to disable CONFIG_SLUB_DEBUG if CGROUPs are in
> use?

Why don't we simply remove the config option altogether and make it
enabled effectively.
-- 
Michal Hocko
SUSE Labs
