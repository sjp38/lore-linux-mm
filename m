Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BDC7C6B004D
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 11:38:21 -0500 (EST)
Date: Wed, 27 Jan 2010 16:37:57 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 01 of 31] define MADV_HUGEPAGE
In-Reply-To: <da09747e3b1d0368a0a6.1264513916@v2.random>
Message-ID: <alpine.LSU.2.00.1001271600450.25739@sister.anvils>
References: <patchbomb.1264513915@v2.random> <da09747e3b1d0368a0a6.1264513916@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 2010, Andrea Arcangeli wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Define MADV_HUGEPAGE.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
> --- a/include/asm-generic/mman-common.h
> +++ b/include/asm-generic/mman-common.h
> @@ -45,6 +45,8 @@
>  #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
>  #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
>  
> +#define MADV_HUGEPAGE	15		/* Worth backing with hugepages */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0

It embarrasses me to find the time to comment on so trivial a patch,
and none more interesting; but I have to say that I don't think this
patch can be right - in two ways.

You moved MADV_HUGEPAGE from 14 to 15 because someone noticed
#define MADV_16K_PAGES 14 in arch/parisc/include/asm/mman.h?

Well, if we need to respect that, then we ought to respect its
/* The range 12-64 is reserved for page size specification. */:
15 would be intended for 32K pages.

I don't know why parisc (even as far back as 2.4.0) wants those
definitions: I guess to allow some peculiar-to-parisc program
to build on Linux, yet fail with EINVAL when it runs?  I rather
think they should never have been added (and perhaps could even
be removed).

But, whether 14 or 15 or something else, I expect you're preventing
mm/madvise.c from building on alpha, mips, parisc and xtensa.
Those arches don't include asm-generic/mman-common.h, because of
various divergencies, of which MADV_16K_PAGES would be just one.

So I think you should follow what we did with MADV_MERGEABLE:
define it in asm-generic/mman-common.h and the four arches,
use the expected number 14 wherever you can, and 67 for parisc.

Or if you feel there's virtue in using the same number on all
arches (it would be less confusing, yes) and want to pave that way
(as we'd have better done with MADV_MERGEABLE), add a comment into
four of those files to point to parisc's peculiar group, and use
the same number 67 on all (perhaps via an asm-generic/madv-common.h).

I'd take the lazy way out and follow what we did with MADV_MERGEABLE,
unless Arnd (Mr Asm-Generic) would prefer something else.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
