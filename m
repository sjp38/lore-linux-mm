Date: Sat, 22 Mar 2003 23:48:29 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.5.65-mm2 vs 2.5.65-mm3 (full objrmap)
In-Reply-To: <362150000.1048349169@[10.10.2.4]>
Message-ID: <Pine.LNX.4.44.0303222309050.1617-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 22 Mar 2003, Martin J. Bligh wrote:
> 
> I see very little impact either way. My initial analysis showed that 90%
> of the anonymous mappings were singletons, so the chain manipulation costs
> are probably very low. If there's a workload that has long anonymous chains,
> and manipulates them a lot, that might benefit. 

It would, yes - but like you I'm unable to name that workload
(aside from one of my own tests, not much use to the wide world).

> However, I thought there might be some benefit in the fork/exec cycle 
> (which presumably sets up a new chain instead of the direct mapping then
> tears it down again) ... but seemingly not.

I do see such benefit, but disappointingly little.  In kernel builds,
say 1% to 3% consistently (on a given machine with given jN) off the
system time; but the user time correspondingly up (eh? lock step tick
issue? cache oddity?), and elapsed time either same or slightly up.
oprofiles didn't enlighten me.

Your figures don't seem to show even that reduction in system time;
though I think you were comparing 2.5.65-mm2 against 2.5.65-mm3,
whereas I was comparing 2.5.65-mm3 with 2.5.65-mm3 minus anobjrmap.
It's conceivable there's something else in -mm3 affecting results.

> Did you keep the pte_direct
> optimisation? That seems worth keeping, with partial objrmap as well
> (I think that was removed in Dave's patch, but would presumably be easy
> to put back).

Dave didn't remove it at all, just went another way so that it became
irrelevant to obj rmaps (or you could say, every obj rmap direct,
apart from the sys_remap_file pages).  I did the same with anonymous,
they're almost all direct (since a given anon page is almost always
mapped at the same user virtual address in whatever mms it appears),
the exception needing chains coming from a perverse use of mremap.

The clearest advantage of anobjrmap so far is for your HIGHMEM64G
HIGHPTE configurations: which had a 64-bit direct pte_addr_t in
struct page, now just a 32-bit count like in the non-PAE configs.
(Though that saving could have been achieved in other ways.)

> Or maybe we just need some more tuning ;-)

Be nice if a magic wand would make it go faster, but it seems too
simple for tuning.  A lot of effort went into speeding up pte_chains,
looks like the effort paid off.  (It's particularly helpful that the
chains got collapsed back to direct lazily, by page_referenced, not
by page_remove_rmap - that means a repetitively forking process
was not perpetually convulsed in allocating and freeing chains).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
