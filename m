Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 982F86B0055
	for <linux-mm@kvack.org>; Thu, 28 May 2009 06:04:31 -0400 (EDT)
Date: Thu, 28 May 2009 12:11:11 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090528101111.GE1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528095934.GA10678@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 05:59:34PM +0800, Wu Fengguang wrote:
> Dirty swap cache page is tricky to handle. The page could live both in page
> cache and swap cache(ie. page is freshly swapped in). So it could be referenced
> concurrently by 2 types of PTEs: one normal PTE and another swap PTE. We try to
> handle them consistently by calling try_to_unmap(TTU_IGNORE_HWPOISON) to convert
> the normal PTEs to swap PTEs, and then
>         - clear dirty bit to prevent IO
>         - remove from LRU
>         - but keep in the swap cache, so that when we return to it on
>           a later page fault, we know the application is accessing
>           corrupted data and shall be killed (we installed simple
>           interception code in do_swap_page to catch it).

That's a good description. I'll add it as a comment to the code.

> > You haven't waited on writeback here AFAIKS, and have you
> > *really* verified it is safe to call delete_from_swap_cache?
> 
> Good catch. I'll soon submit patches for handling the under
> read/write IO pages. In this patchset they are simply ignored.

Yes, we assume the IO device does something sensible with the poisoned
cache lines and aborts. Later we can likely abort IO requests in a early
stage on the Linux, but that's more advanced.

The question is if we need to wait on writeback for correctness? 

We still don't want to crash if we take a page away that is currently
writebacked.

My original assumption was that taking the page lock would take
care of that. Is that not true?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
