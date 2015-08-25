Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 79CA76B0254
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 06:36:33 -0400 (EDT)
Received: by ykbi184 with SMTP id i184so150968246ykb.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 03:36:33 -0700 (PDT)
Received: from ns.horizon.com (ns.horizon.com. [71.41.210.147])
        by mx.google.com with SMTP id o20si7476286yke.178.2015.08.25.03.36.32
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 03:36:32 -0700 (PDT)
Date: 25 Aug 2015 06:36:30 -0400
Message-ID: <20150825103630.26398.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 3/3 v6] mm/vmalloc: Cache the vmalloc memory info
In-Reply-To: <20150825095638.GA24750@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, mingo@kernel.org
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

>> Second, and this is up to you, I'd be inclined to go fully non-blocking
>> and only spin_trylock().  If that fails, just skip the cache update.

> So I'm not sure about this one: we have no guarantee of the order every
> updater reaches the spinlock, and we want the 'freshest' updater to do
> the update. The trylock might cause us to drop the 'freshest' update
> erroneously - so this change would introduce a 'stale data' bug I think.

Er, no it wouldn't.  If someone leaves the cache stale, they'll leave
vmap_info_cache_gen != vmap_info_gen and the next reader to come along
will see the cache is stale and refresh it.

If there's lock contention, there's a risk of more work, because the
callers fall back to calc_vmalloc_info rather than waiting.

But it's not a big risk.  With the blocking code, if two readers
arrive simultaneously and see a stale cache, they'll both call
calc_vmalloc_info() and then line up to update the cache.

The second will get the lock but then *not* update the cache.

With trylock(), the second will just skip the update faster.
Same number of calc_vmalloc_info() calls.

The only inefficient case is if two readers arrive far enough apart that
vmap_info_gen is updated between them, yet close enough together than
the second arrives at the lock while the first is updating the cache.

In that case, the second reader will not update the cache and (assuming
no more changes to vmap_info_gen) some future third reader will have to
duplicate the effort of calling calc_vmalloc_info().

But that's such a tiny window I give preference to my fondness
for non-blocking code.

> I added your Reviewed-by optimistically, saving a v7 submission hopefully ;-)

You did right.  As I said, the non-blocking part is your preference.

I've done so much nasty stuff in interrupt handlers ($DAY_JOB more than
kernel) that I go for the non-blocking algorithm whenever possible.

Reviewed-by: George Spelvin <linux@horizon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
