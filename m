Message-ID: <4011C537.8040104@cyberone.com.au>
Date: Sat, 24 Jan 2004 12:07:03 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
References: <400F630F.80205@cyberone.com.au>	<20040121223608.1ea30097.akpm@osdl.org>	<16399.42863.159456.646624@laputa.namesys.com>	<40105633.4000800@cyberone.com.au>	<16400.63379.453282.283117@laputa.namesys.com>	<4011392D.1090600@cyberone.com.au> <16401.16474.881069.437933@laputa.namesys.com>
In-Reply-To: <16401.16474.881069.437933@laputa.namesys.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Nikita Danilov wrote:

>Nick Piggin writes:
> > 
> > 
> > Nikita Danilov wrote:
> > 
> > >Nick Piggin writes:
> > > > 
> > >
> > >[...]
> > >
> > > > 
> > > > But those cold mapped pages are basically ignored until the
> > > > reclaim_mapped threshold, however they do continue to have their
> > > > referenced bits cleared - hence page_referenced check should
> > > > become a better estimation when reclaim_mapped is reached, right?
> > >
> > >Right.
> > >
> > 
> > 
> > I still am a bit skeptical that the LRU lists are actually LRU,
> > however I'm running out of other explainations for your patch's
> > improvements :)
>
>They are not LRU, it is impossible (and useless) to have LRU in the VM.
>
>The problem that we have, and that dont-rotate-active-list tries to
>address, is that two different LRU _approximations_ are maintained
>within the same page queues. This patch tries (lazily) to separate pages
>handled differently so that they don't interfere with each other.
>

Yes, but why doesn't my small patch have the same effect?
It doesn't do it by nicely seperating mapped and non mapped
pages like yours, but it should do something similar: ignore
all mapped pages until the reclaim_mapped threshold.

>
>
> > 
> > One ideas I had turns out to have little effect for kbuild, but
> > it might still be worth including?
> > 
> > When reclaim_mapped == 0 mapped referenced pages are treated
> > the same way as mapped unreferenced pages, and the referenced
> > info is thrown out. Fixed by not clearing referenced bits.
>
>I think that purpose of having active/inactive lists in the first place
>is to tell hot pages from cold one. Hotness of page is estimated on the
>basis of how frequently it has been accessed _recently_: if page was
>accessed while migrating through the active list---it is hot. When the
>memory pressure increases, the active list is scanned more aggressively
>and the time that the page spends on it (which is the time it has to get
>a reference) decreases, thus adjusting VM's notion of the hotness.
>
>By not clearing the referenced bit, one loses the ability to tell recent
>accesses from the old ones. As a result, all mapped pages that were ever
>accessed from the bootup would appear as hot when reclaim_mapped is
>reached.
>

But by clearing the referenced bit when below the reclaim_mapped
threshold, you're throwing this information away.

Say you have 16 mapped pages on the active list, 8 referenced, 8 not.
You do a !reclaim_mapped scan. Your 16 pages are now in the same
order and none are referenced. You now do a reclaim_mapped scan and
reclaim 8 pages. 4 of them were the referenced ones, 4 were not.

With my change, you would reclaim all 8 non referenced pages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
