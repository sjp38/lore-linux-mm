Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D370E6B004D
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 12:14:03 -0500 (EST)
Date: Wed, 27 Jan 2010 18:13:16 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 01 of 31] define MADV_HUGEPAGE
Message-ID: <20100127171316.GC12736@random.random>
References: <patchbomb.1264513915@v2.random>
 <da09747e3b1d0368a0a6.1264513916@v2.random>
 <alpine.LSU.2.00.1001271600450.25739@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1001271600450.25739@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 27, 2010 at 04:37:57PM +0000, Hugh Dickins wrote:
> It embarrasses me to find the time to comment on so trivial a patch,
> and none more interesting; but I have to say that I don't think this
> patch can be right - in two ways.
> 
> You moved MADV_HUGEPAGE from 14 to 15 because someone noticed
> #define MADV_16K_PAGES 14 in arch/parisc/include/asm/mman.h?

Correct.

> Well, if we need to respect that, then we ought to respect its
> /* The range 12-64 is reserved for page size specification. */:
> 15 would be intended for 32K pages.

It would be probably better if those were defined with #define MADV_
instead of a comment that won't showup on my grep... I checked with
grep across all archs and nothing showed up.

> I don't know why parisc (even as far back as 2.4.0) wants those
> definitions: I guess to allow some peculiar-to-parisc program
> to build on Linux, yet fail with EINVAL when it runs?  I rather
> think they should never have been added (and perhaps could even
> be removed).
> 
> But, whether 14 or 15 or something else, I expect you're preventing
> mm/madvise.c from building on alpha, mips, parisc and xtensa.
> Those arches don't include asm-generic/mman-common.h, because of
> various divergencies, of which MADV_16K_PAGES would be just one.
> 
> So I think you should follow what we did with MADV_MERGEABLE:
> define it in asm-generic/mman-common.h and the four arches,
> use the expected number 14 wherever you can, and 67 for parisc.
> 
> Or if you feel there's virtue in using the same number on all
> arches (it would be less confusing, yes) and want to pave that way
> (as we'd have better done with MADV_MERGEABLE), add a comment into
> four of those files to point to parisc's peculiar group, and use
> the same number 67 on all (perhaps via an asm-generic/madv-common.h).
> 
> I'd take the lazy way out and follow what we did with MADV_MERGEABLE,
> unless Arnd (Mr Asm-Generic) would prefer something else.

I've no problem to do the not-lazy way of madv-common.h, and yes I
think it's less confusing to have one number for all archs...

Let's say, to me the important thing is we agree on one number, and
that MADV_HUGEPAGE is useful for embedded that may want to turn off
transparent hugepage feature except on a few mappings (to avoids
risking to lose minor memory during cows).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
