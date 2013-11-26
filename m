Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1BB6B00AF
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:31:22 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id v16so2850093bkz.41
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 14:31:21 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ql8si9444605bkb.274.2013.11.26.14.31.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 14:31:21 -0800 (PST)
Date: Tue, 26 Nov 2013 17:30:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/9] mm: thrash detection-based file cache sizing v6
Message-ID: <20131126223046.GI22729@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <20131125165729.3ad409506fb6db058d88c258@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131125165729.3ad409506fb6db058d88c258@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 25, 2013 at 04:57:29PM -0800, Andrew Morton wrote:
> On Sun, 24 Nov 2013 18:38:19 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > This series solves the problem by maintaining a history of pages
> > evicted from the inactive list, enabling the VM to detect frequently
> > used pages regardless of inactive list size and facilitate working set
> > transitions.
> 
> It's a very readable patchset - thanks for taking the time to do that.

Thanks.

> > 31 files changed, 1253 insertions(+), 401 deletions(-)
> 
> It's also a *ton* of stuff.  More code complexity, larger kernel data
> structures.  All to address a quite narrow class of workloads on a
> relatively small window of machine sizes.  How on earth do we decide
> whether it's worth doing?

The fileserver-type workload is not that unusual and not really
restricted to certain machine sizes.

But more importantly, these are reasonable workloads for which our
cache management fails completely, and we have no alternative solution
to offer.  What do we tell the people running these loads?

> Also, what's the memcg angle?  This is presently a global thing - do
> you think we're likely to want to make it per-memcg in the future?

Yes, it seemed easier to get the global case working first, but the
whole thing is designed with memcg in mind.  We can encode the unique
cgroup ID in the shadow entries as well and make the inactive_age per
lruvec instead of per-zone.

If space gets tight in the shadow entry (on 32 bit e.g.), instead of
counting every single eviction, we can group evictions into
generations of bigger chunks - the more memory, the less accurate the
refault distance has to be anyway - and can then get away with fewer
bits for the eviction timestamp.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
