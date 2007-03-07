Date: Wed, 7 Mar 2007 01:39:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
 nonlinear)
Message-Id: <20070307013942.5c0fadff.akpm@linux-foundation.org>
In-Reply-To: <20070307092903.GJ18774@holomorphy.com>
References: <20070221023656.6306.246.sendpatchset@linux.site>
	<20070221023735.6306.83373.sendpatchset@linux.site>
	<20070306225101.f393632c.akpm@linux-foundation.org>
	<20070307070853.GB15877@wotan.suse.de>
	<20070307081948.GA9563@wotan.suse.de>
	<20070307082755.GA25733@elte.hu>
	<20070307003520.08b1a082.akpm@linux-foundation.org>
	<20070307092903.GJ18774@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Irwin <bill.irwin@oracle.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Mar 2007 01:29:03 -0800 Bill Irwin <bill.irwin@oracle.com> wrote:

> On Wed, 7 Mar 2007 09:27:55 +0100 Ingo Molnar <mingo@elte.hu> wrote:
> >> btw., if we decide that nonlinear isnt worth the continuing maintainance 
> >> pain, we could internally implement/emulate sys_remap_file_pages() via a 
> >> call to mremap() and essentially deprecate it, without breaking the ABI 
> >> - and remove all the nonlinear code. (This would split fremap areas into 
> >> separate vmas)
> 
> On Wed, Mar 07, 2007 at 12:35:20AM -0800, Andrew Morton wrote:
> > I'm rather regretting having merged it - I don't think it has been used for
> > much.
> > Paolo's UML speedup patches might use nonlinear though.
> 
> Guess what major real-life application not only uses nonlinear daily
> but would even be very happy to see it extended with non-vma-creating
> protections and more?

uh-oh.  SQL server?

> It's not terribly typical for things to be
> truncated while remap_file_pages() is doing its work, though it's been
> proposed as a method of dynamism. It won't stress remap_file_pages() vs.
> truncate() in any meaningful way, though, as userspace will be rather
> diligent about clearing in-use data out of the file offset range to be
> truncated away anyway, and all that via O_DIRECT.

The problem here isn't related to truncate or direct-IO.  It's just
plain-old MAP_SHARED.  nonlinear VMAs are now using the old-style
dirty-memory management.  msync() is basically a no-op and the code is
wildly tricky and pretty much untested.  The chances that we broke it are
considerable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
