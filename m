Date: Fri, 9 Feb 2007 02:31:16 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try 2)
Message-ID: <20070209013115.GA17334@wotan.suse.de>
References: <20070208111421.30513.77904.sendpatchset@linux.site> <Pine.LNX.4.64.0702090027580.29905@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702090027580.29905@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 09, 2007 at 12:41:51AM +0000, Hugh Dickins wrote:
> On Thu, 8 Feb 2007, Nick Piggin wrote:
> > Still no independent confirmation as to whether this is a problem or not.
> 
> I'm trying to convince myself none of your patch is necessary.  Probably
> shall fail.  But how come we've survived for years with such an issue?

Well I'm almost sure that the POWER guys hit this with anonymous pages
being zeroed out then added to process address space -- they would
occasionally see junk (via another thread, I presume).

If that were the case, then I think that a read-vs-read over a hole
(for example) should be buggy in the same way.

> > Updated some comments, added diffstats to patches, don't use
> > __SetPageUptodate as an internal page-flags.h private function.
> 
> Depressed by profusion of PageUptodate_UpperAndlowercasevariants.
> Those rmbs, you really only want them when it says "yes", don't you?

Yeah, any help with naming suggestions would be appreciated. I think
we can get rid of the SetPageUptodate_nowarn variant, by making
SetNewPageUptodate simply do an smp_wmb + __set_bit on all architectures?
This frees us from the extra atomic ops I'd added into the page fault
fastpaths as well.

Yes, we do only need the rmb if it is uptodate, that's a good point.

> > I would like to eventually get an ack from Hugh regarding the anon memory
> > and especially swap side of the equation,
> 
> Plea noted.  I'm pondering.  "Eventually" indeed.  OTOH I expect you're
> right to criticize anon/swap PageUptodate being set where it was needed
> to get by, rather than where it was natural to do so.

Well if I can get you to warm to that aspect of the patch... :) I expect
that using non-atomic bitops might help.

Should I make that change into its own patch?

> > and a glance from whoever put the
> > smp_wmb()s into the copy functions (Was it Ben H or Anton maybe?)
> 
> From: Linus Torvalds <torvalds@ppc970.osdl.org>
> Date: Thu, 14 Oct 2004 04:00:06 +0000 (-0700)
> Subject: Fix threaded user page write memory ordering
> X-Git-Tag: v2.6.9-final~3
> X-Git-Url: http://127.0.0.1:1234/?p=.git;a=commitdiff_plain;h=538ce05c0ef4055cf29a92a4abcdf139d180a0f9;hp=8c225dbc5a7b13801a8254aae0ccebab8e4bece7
> 
> Fix threaded user page write memory ordering

Thanks, I did see that, but I'm sure it must have been prompted by a
discussion or another proposed patch from IBM. Maybe I'm wrong
though.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
