From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16401.16474.881069.437933@laputa.namesys.com>
Date: Fri, 23 Jan 2004 18:40:10 +0300
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
In-Reply-To: <4011392D.1090600@cyberone.com.au>
References: <400F630F.80205@cyberone.com.au>
	<20040121223608.1ea30097.akpm@osdl.org>
	<16399.42863.159456.646624@laputa.namesys.com>
	<40105633.4000800@cyberone.com.au>
	<16400.63379.453282.283117@laputa.namesys.com>
	<4011392D.1090600@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin writes:
 > 
 > 
 > Nikita Danilov wrote:
 > 
 > >Nick Piggin writes:
 > > > 
 > >
 > >[...]
 > >
 > > > 
 > > > But those cold mapped pages are basically ignored until the
 > > > reclaim_mapped threshold, however they do continue to have their
 > > > referenced bits cleared - hence page_referenced check should
 > > > become a better estimation when reclaim_mapped is reached, right?
 > >
 > >Right.
 > >
 > 
 > 
 > I still am a bit skeptical that the LRU lists are actually LRU,
 > however I'm running out of other explainations for your patch's
 > improvements :)

They are not LRU, it is impossible (and useless) to have LRU in the VM.

The problem that we have, and that dont-rotate-active-list tries to
address, is that two different LRU _approximations_ are maintained
within the same page queues. This patch tries (lazily) to separate pages
handled differently so that they don't interfere with each other.

 > 
 > One ideas I had turns out to have little effect for kbuild, but
 > it might still be worth including?
 > 
 > When reclaim_mapped == 0 mapped referenced pages are treated
 > the same way as mapped unreferenced pages, and the referenced
 > info is thrown out. Fixed by not clearing referenced bits.

I think that purpose of having active/inactive lists in the first place
is to tell hot pages from cold one. Hotness of page is estimated on the
basis of how frequently it has been accessed _recently_: if page was
accessed while migrating through the active list---it is hot. When the
memory pressure increases, the active list is scanned more aggressively
and the time that the page spends on it (which is the time it has to get
a reference) decreases, thus adjusting VM's notion of the hotness.

By not clearing the referenced bit, one loses the ability to tell recent
accesses from the old ones. As a result, all mapped pages that were ever
accessed from the bootup would appear as hot when reclaim_mapped is
reached.

But,

"The practice is the criterion of the truth" :)

 > 
 >  linux-2.6-npiggin/mm/vmscan.c |   10 ++++++----
 >  1 files changed, 6 insertions(+), 4 deletions(-)
 > 
 > diff -puN mm/vmscan.c~vm-info mm/vmscan.c
 > --- linux-2.6/mm/vmscan.c~vm-info	2004-01-24 00:50:15.000000000 +1100

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
