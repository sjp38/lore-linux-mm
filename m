Date: Fri, 4 Apr 2003 22:59:59 -0500 (EST)
From: Rik van Riel <riel@surriel.com>
Subject: Re: objrmap and vmtruncate
In-Reply-To: <20030405024414.GP16293@dualathlon.random>
Message-ID: <Pine.LNX.4.44.0304042255390.32336-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 5 Apr 2003, Andrea Arcangeli wrote:

> that's wasted memory IMHO, if you need nonlinear, you don't want to
> waste further metadata, you only want to pin pages in the pagetables,
> the 'window' over the pagecache (incidentally shm)

Agreed.

> > > - pte_chain setup and teardown CPU cost.
> > > 
> > >   objrmap does not seem to help.  Page clustering might, but is unlikely to
> > >   be enabled on the machines which actually care about the overhead.
> > 
> > eh? Not sure what you mean by that. It helped massively ...
> > diffprofile from kernbench showed:
> 
> Indeed. objrmap is the only way to avoid the big rmap waste. Infact I'm
> not even convinced about the hybrid approch, rmap should be avoided even
> for the anon pages. And the swap cpu doesn't matter, as far as we can
> reach pagteables in linear time that's fine, doesn't matter how many
> fixed cycles it takes. Only the complexity factor matters, and objrmap
> takes care of it just fine.

The only issues with objrmap seems to be mremap, which Hugh
seems to have taken care of, and the case of a large number
of processes mapping different parts of the same file multiple
times (1000 processes mapping each 1000 parts of the same file),
which would grow the complexity of the VMA search from linear
to quadratical.

That last case is also fixable, though, probably best done using
k-d trees.

Except for nonlinear VMAs I don't think there are any big obstacles
left that would keep us from switching to object rmap.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
