Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id A09606B00AE
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 12:14:49 -0400 (EDT)
Date: Wed, 7 Aug 2013 18:14:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 5/9] mm: compaction: don't require high order pages below
 min wmark
Message-ID: <20130807161437.GC4661@redhat.com>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-6-git-send-email-aarcange@redhat.com>
 <20130807154201.GS2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807154201.GS2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

Hi Mel,

On Wed, Aug 07, 2013 at 04:42:01PM +0100, Mel Gorman wrote:
> On Fri, Aug 02, 2013 at 06:06:32PM +0200, Andrea Arcangeli wrote:
> > The min wmark should be satisfied with just 1 hugepage.
> 
> This depends on the size of the machine and if THP is enabled or not
> (which adjusts min_free_kbytes).  I expect that it is generally true but
> wonder how often it is true on something like ARM which does high-order
> allocators for stack.

I exclude ARM is allocating stacks with GFP_ATOMIC, or how could it be
reliable? If it's not an atomic allocation, it should make no
difference as it wouldn't be allowed to eat from the reservation below
MIN anyway, just the area between LOW and MIN matters, no?

> It would be hard to hit but you may be able to trigger this warning if
> 
> process a			process b
> read min watermark
> 				increase min_free_kbytes
> __zone_watermark_ok
> 
> 
> 
> 
> if (min < 0)
> 	return false;
> 
> ?

Correct, this is why it's a WARN_ON and not a BUG_ON. It's signed so
nothing shall go wrong after the warn_on. I just wanted to be sure it
never triggers when people isn't altering the min_free_kbytes. If you
prefer to drop it, it's fine though (it never triggered as expected).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
