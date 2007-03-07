Date: Wed, 7 Mar 2007 08:08:53 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307070853.GB15877@wotan.suse.de>
References: <20070221023656.6306.246.sendpatchset@linux.site> <20070221023735.6306.83373.sendpatchset@linux.site> <20070306225101.f393632c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070306225101.f393632c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 06, 2007 at 10:51:01PM -0800, Andrew Morton wrote:
> On Wed, 21 Feb 2007 05:50:17 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:
> 
> > Nonlinear mappings are (AFAIKS) simply a virtual memory concept that
> > encodes the virtual address -> file offset differently from linear
> > mappings.
> > 
> > I can't see why the filesystem/pagecache code should need to know anything
> > about it, except for the fact that the ->nopage handler didn't quite pass
> > down enough information (ie. pgoff). But it is more logical to pass pgoff
> > rather than have the ->nopage function calculate it itself anyway. And
> > having the nopage handler install the pte itself is sort of nasty.
> > 
> > This patch introduces a new fault handler that replaces ->nopage and
> > ->populate and (later) ->nopfn. Most of the old mechanism is still in place
> > so there is a lot of duplication and nice cleanups that can be removed if
> > everyone switches over.
> > 
> > The rationale for doing this in the first place is that nonlinear mappings
> > are subject to the pagefault vs invalidate/truncate race too, and it seemed
> > stupid to duplicate the synchronisation logic rather than just consolidate
> > the two.
> > 
> 
> It's awkward to layer a largely do-nothing patch like this on top of a
> significant functional change.  Makes it harder to isolate the source of
> regressions, harder to revert the do-something patch.
> 
> > After this patch, MAP_NONBLOCK no longer sets up ptes for pages present in
> > pagecache. Seems like a fringe functionality anyway.
> 
> Does Ingo agree?

I cc'ed him when first posting it. He didn't disagree.

> > NOPAGE_REFAULT is removed. This should be implemented with ->fault, and
> > no users have hit mainline yet.
> 
> Did benh agree with that?

Yes.

> The patch unchangeloggedly adds a basic new structure to core mm
> (fault_data).  Would be nice to document its fields, especially `flags'.

OK. This is actually something that I would like more people to review.
Do we need any different fields? Should it be passed as arguments instead
of a structure?

> Please add less pointless blank lines.
> 
> 
> How well has this been tested?  The ocfs2 changes?  gfs2?  We should at
> least give those guys a heads-up.

Yes we should. Not all those filesystem changes have been tested.

> Does anybody really pass a NULL `type' arg into filemap_nopage()?

Dunno, it's exported. I remove that completely in a subsequent patch
anyway.

> This patch seems to churn things around an awful lot for minimal benefit.

Well it fixes the whole design of the nonlinear fault path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
