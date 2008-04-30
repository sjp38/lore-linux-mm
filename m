Date: Wed, 30 Apr 2008 08:53:44 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] data race in page table setup/walking?
In-Reply-To: <20080430060340.GE27652@wotan.suse.de>
Message-ID: <alpine.LFD.1.10.0804300848390.2997@woody.linux-foundation.org>
References: <20080429050054.GC21795@wotan.suse.de> <Pine.LNX.4.64.0804291333540.22025@blonde.site> <20080430060340.GE27652@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>


On Wed, 30 Apr 2008, Nick Piggin wrote:
> 
> Actually, aside, all those smp_wmb() things in pgtable-3level.h can
> probably go away if we cared: because we could be sneaky and leverage
> the assumption that top and bottom will always be in the same cacheline
> and thus should be shielded from memory consistency problems :)

Umm.

Why would we care, since smp_wmb() is a no-op? (Yea, it's a compiler 
barrier, big deal, it's not going to cost us anything).

Also, write barriers are not about cacheline access order, they tend to be 
more about the write *buffer*, ie before the write even hits the cache 
line. And a write coudl easily pass another write in the write buffer if 
there is (for example) a dependency on the address.

So even if they are in the same cacheline, if the first write needs an 
offset addition, and the second one does not, it could easily be that the 
second one hits the write buffer first (together with some alias 
detection that re-does the things if they alias).

Of course, on x86, the write ordering is strictly defined, and even if the 
CPU reorders writes they are guaranteed to never show up re-ordered, so 
this is not an issue. But I wanted to point out that memory ordering is 
*not* just about cachelines, and being in the same cacheline is no 
guarantee of anything, even if it can have *some* effects.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
