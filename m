Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 6789F6B0036
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 10:32:13 -0400 (EDT)
Date: Fri, 14 Jun 2013 14:32:11 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slub: Avoid direct compaction if possible
In-Reply-To: <51BB1802.8050108@yandex-team.ru>
Message-ID: <0000013f4319cb46-a5a3de58-1207-4037-ae39-574b58135ea2-000000@email.amazonses.com>
References: <51BB1802.8050108@yandex-team.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, glommer@parallels.com, hannes@cmpxchg.org, minchan@kernel.org, jiang.liu@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 14 Jun 2013, Roman Gushchin wrote:

> Slub tries to allocate contiguous pages even if memory is fragmented and
> there are no free contiguous pages. In this case it calls direct compaction
> to allocate contiguous page. Compaction requires the taking of some heavily
> contended locks (e.g. zone locks). So, running compaction (direct and using
> kswapd) simultaneously on several processors can cause serious performance
> issues.

The main thing that this patch does is to add a nocompact flag to the page
allocator. That needs to be a separate patch. Also fix the description.
Slub does not invoke compaction. The page allocator initiates compaction
under certain conditions.

> It's possible to avoid such problems (or at least to make them less probable)
> by avoiding direct compaction. If it's not possible to allocate a contiguous
> page without compaction, slub will fall back to order 0 page(s). In this case
> kswapd will be woken to perform asynchronous compaction. So, slub can return
> to default order allocations as soon as memory will be de-fragmented.

Sounds like a good idea. Do you have some numbers to show the effect of
this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
