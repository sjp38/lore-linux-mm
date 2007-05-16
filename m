Date: Wed, 16 May 2007 19:38:16 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] optimise unlock_page
Message-ID: <20070516173816.GB5883@wotan.suse.de>
References: <1178659827.14928.85.camel@localhost.localdomain> <20070508224124.GD20174@wotan.suse.de> <20070508225012.GF20174@wotan.suse.de> <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com> <20070510033736.GA19196@wotan.suse.de> <Pine.LNX.4.64.0705101935590.18496@blonde.wat.veritas.com> <20070511085424.GA15352@wotan.suse.de> <Pine.LNX.4.64.0705111357120.3350@blonde.wat.veritas.com> <20070513033210.GA3667@wotan.suse.de> <Pine.LNX.4.64.0705161737140.7914@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705161737140.7914@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 16, 2007 at 06:21:09PM +0100, Hugh Dickins wrote:
> On Sun, 13 May 2007, Nick Piggin wrote:
> > On Fri, May 11, 2007 at 02:15:03PM +0100, Hugh Dickins wrote:
> > 
> > > But again I wonder just what the gain has been, once your double
> > > unmap_mapping_range is factored in.  When I suggested before that
> > > perhaps the double (well, treble including the one in truncate.c)
> > > unmap_mapping_range might solve the problem you set out to solve
> > > (I've lost sight of that!) without pagelock when faulting, you said:
> > > 
> > > > Well aside from being terribly ugly, it means we can still drop
> > > > the dirty bit where we'd otherwise rather not, so I don't think
> > > > we can do that.
> > > 
> > > but that didn't give me enough information to agree or disagree.
> > 
> > Oh, well invalidate wants to be able to skip dirty pages or have the
> > filesystem do something special with them first. Once you have taken
> > the page out of the pagecache but still mapped shared, then blowing
> > it away doesn't actually solve the data loss problem... only makes
> > the window of VM inconsistency smaller.
> 
> Right, I think I see what you mean now, thanks: userspace
> must not for a moment be allowed to write to orphaned pages.

Yep.


> Whereas it's not an issue for the privately COWed pages you added
> the second unmap_mapping_range for: because it's only truncation
> that has to worry about them, so they're heading for SIGBUS anyway.
> 
> Yes, and the page_mapped tests in mm/truncate.c are just racy
> heuristics without the page lock you now put into faulting.

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
