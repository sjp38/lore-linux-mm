Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 485076B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 13:38:46 -0500 (EST)
Date: Mon, 14 Nov 2011 19:38:12 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-ID: <20111114183812.GC4414@redhat.com>
References: <20111114140421.GA27150@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111114140421.GA27150@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Colin Cross <ccross@android.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Nov 14, 2011 at 02:04:21PM +0000, Mel Gorman wrote:
> In his fix, he avoided retrying the allocation if reclaim made no
> progress and __GFP_FS was not set. The problem is that this would
> result in GFP_NOIO allocations failing that previously succeeded
> which would be very unfortunate.

GFP_NOFS are made by filesystems/buffers to avoid locking up on fs/vfs
locking. Those also should be able to handle failure gracefully but
userland is more likely to get a -ENOMEM from these (for example
during direct-io) if those fs allocs fails. So clearly it sounds risky
to apply the modification quoted above and risk having any GFP_NOFS
fail. Said that I'm afraid we're not deadlock safe with current code
that cannot fail but there's no easy solution and no way to fix it in
the short term, and it's only a theoretical concern.

For !__GFP_FS allocations, __GFP_NOFAIL is the default for order <=
PAGE_ALLOC_COSTLY_ORDER and __GFP_NORETRY is the default for order >
PAGE_ALLOC_COSTLY_ORDER. This inconsistency is not so clean in my
view. Also for GFP_KERNEL/USER/__GFP_FS regular allocations the
__GFP_NOFAIL looks more like a __GFP_MAY_OOM.  But if we fix that and
we drop __GFP_NORETRY, and we set __GFP_NOFAIL within the
GFP_NOFS/NOIO #defines (to remove the magic PAGE_ALLOC_COSTLY_ORDER
check in should_alloc_retry) we may loop forever if somebody allocates
several mbytes of huge contiguous RAM with GFP_NOIO. So at least
there's a practical explanation for the current code.

Patch looks good to me (and safer) even if I don't like keeping
infinite loops from a purely theoretical standpoint.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
