Date: Fri, 13 Apr 2007 14:13:47 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] rename page_count for lockless pagecache
Message-ID: <20070413121347.GC966@wotan.suse.de>
References: <20070412103151.5564.16127.sendpatchset@linux.site> <20070412103340.5564.23286.sendpatchset@linux.site> <Pine.LNX.4.64.0704131229510.19073@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704131229510.19073@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 13, 2007 at 12:53:05PM +0100, Hugh Dickins wrote:
> On Thu, 12 Apr 2007, Nick Piggin wrote:
> > In order to force an audit of page_count users (which I have already done
> > for in-tree users), and to ensure people think about page_count correctly
> > in future, I propose this (incomplete, RFC) patch to rename page_count.
> 
> I see your point, it's a concern worth raising; but it grieves me that
> we first lost page->count, and now you propose we lose page_count().
> 
> I don't care for the patch (especially page_count_lessequal).
> I rather think it will cause more noise and nuisance than anything
> else.  All the arches would need to be updated too.  Out of tree
> people, won't they just #define anew without comprehending?

Yeah you may have a point. (lessequal is silly I agree, because it
doesn't convey the fact that the count is still unstable even with
nonewrefs).

On the other hand, I think it probably would get people to think a
little bit more.


> Might it be more profitable for a DEBUG mode to inject random
> variations into page_count?

I think that's a very fine idea, and much more suitable for an
everyday kernel than my test threads. Doesn't help if they use the
field somehow without the accessors, but we must discourage that.
Thanks, I'll add such a debug mode.


> What did your audit show?  Was anything in the tree actually using
> page_count() in a manner safe before but unsafe after your changes?
> What you found outside of /mm should be a fair guide to what might
> be there out of tree.

A couple of things... a network driver was using it as a non-atomic
field IIRC (or at least in an unsafe manner), and x86-64 kernel tlb
flushing was using it unsafely. I think that might have been all,
but that was a while ago... So yeah, basically, not much wsa wrong.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
