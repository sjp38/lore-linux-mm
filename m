Date: Mon, 12 Aug 2002 13:58:17 -0400
Subject: Re: Broad questions about the current design
Content-Type: text/plain; charset=US-ASCII; format=flowed
Mime-Version: 1.0 (Apple Message framework v482)
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
In-Reply-To: <E17eBGG-0001nL-00@starship>
Message-Id: <147C8BD2-AE1D-11D6-8D07-000393829FA4@cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Monday, August 12, 2002, at 05:13 AM, Daniel Phillips wrote:

> On Friday 09 August 2002 17:12, Scott Kaplan wrote:
>> 1) What happened to page ages?  I found them in 2.4.0, but they're
>>     gone by 2.4.19, and remain gone in 2.5.30.
>
> The jury is still out as to whether aging or LRU is the better page
> replacement policy, and to date, no formal comparisons have been done.

Okay, so *that* explains when and how it happened.  Thank you.  As to 
``which is better'':  At the least, it's a very hard question to answer, 
not only because testing VM policies is difficult, but also because this 
policy is managing pages that are being put to very different uses.  From 
a VM perspective, LRU tends to be the better idea, and frequency 
information, while always tempting, is generally a bad idea with one 
notable exception -- In those cases where LRU performs poorly, frequency 
allows the replacement policy to deviate from LRU.  As it happens, just 
about *anything* that isn't LRU performs better in those cases, so there's 
nothing laudable about using frequency information in such situations, as 
other non-LRU approaches work, too.  Since page aging is only partly 
frequency based, it may be that its benefits are exactly these cases where 
just about anything that deviates from LRU will help.

For filesystem caching, the picture is less clear.  Some studies have 
shown frequency to be a genuinely good idea, as file access patterns 
exhibit strong regularities for which LRU performs poorly.  While I think 
that even those studies are oversimplifying the problem, frequency could 
be a decent approach.  Since the Linux MM system manages both VM pages and 
filesystem cache pages together, its hard to say how those pools compete, 
and which policy is a better choice.  I certainly think that something 
LRU-like is going to be more stable and predictable, failing in cases that 
people understand pretty well.

> This code implements the LRU on the active list:
>
> http://lxr.linux.no/source/mm/vmscan.c?v=2.5.28#L349:
>
> 349                 if (page->pte.chain && page_referenced(page)) {
> 350                         list_del(&page->lru);
> 351                         list_add(&page->lru, &active_list);
> 352                         pte_chain_unlock(page);
> 353                         continue;
> 354                 }
>
> Yes, it was supposed to be LRU but as you point out, it's merely a clock.
> It would be an LRU if the list deletion and reinsertion occured directly 
> in
> try_to_swap_out, but there the page referenced bit is merely set.  I asked
> Andrea why he did not do this and he wasn't sure, but he thought that 
> maybe
> the way he did it was more efficient.

I'm a bit confused by these comments, so maybe you can help me out a bit.  
While I agree that it would be possible to move pages to the front of the 
active list in try_to_swap_out() rather than setting their reference bits,
  I don't think that change would make this an LRU policy.  There are only 
two ways to achieve a true LRU ordering:

1) Trap into the kernel on every reference, moving the referenced page to 
the front immediately.  (Obviously, the overhead here would be absurd.)

2) Use hardware that timestamps each page frame with the time of each 
reference, allowing you to discover the order of last reference.  No chip 
does this, of course, since it's not worth the hardware or the cycles to 
examine the timestamps.

In other words, by the time try_to_swap_out() runs, it is possible to 
discover which pages have been used lately and move them to the front, but 
the order of last reference among those pages is already lost.  It's not a 
true LRU ordering.

Critically, true LRU orderings aren't worth much.  That the active list is 
managed via CLOCK is totally appropriate and desirable.  The entire 
purpose of CLOCK is that it is an approximation of LRU  -- and, in fact, a 
very good one -- that doesn't incur the overhead needed for true LRU.  I 
can't think of any reason to try to make the active list more LRU-like, as 
there's no real benefit to be gained.

> For any page that is explicitly touched, e.g., by file IO, we use
> activate_page, which moves the page to the head of the active list 
> regardless of which list the page is currently on.  This is a classic LRU.

Okay, that sounds fine, although for the reasons I just mentioned, it's 
not clear that it's helping much to move the page to the front if it's 
already on the active list, which itself is a CLOCK that yields good 
LRU-like behavior.

> The inactive list is a fifo queue.  So you have a (sort-of) LRU feeding 
> pages from its cold end into the FIFO, and if the page stays on the FIFO 
> long enough to reach the code end it gets evicted, or at least it starts 
> on the process.

Wait, this doesn't make sense to me.  I assume that there is some code 
that examines pages on the inactive list and, if they've been referenced, 
moves them to the front of the active list.  That would make the inactive 
list another CLOCK-like queue, not a FIFO queue.  (It would be FIFO only 
if pages were pulled only from the cold end of the FIFO queue and either 
(a) evicted if they've not been used or (b) moved to the front of the 
active list if they have been.)

Making this list an LRU queue makes this whole structure a classic 
segmented queue (SEGQ) arrangement.  The first queue is a FIFO or CLOCK -- 
a kind of queue where references to pages are not detected immediately, 
but only when something from that queue needs replacement for an incoming 
page.  Pages evicted from the first queue are inserted into the second one.
   The purpose of the structure is that pages in the second queue are 
referenced far less often, and so incurring the overhead of detecting 
their references when they occur -- that is, protecting the pages so that 
the reference causes a trap into the kernel -- is a low cost way to order 
the pages near eviction.  While keeping the inactive queue as a CLOCK-like 
structure is fine, it could be a true LRU queue, and there's little 
advantage to making it a FIFO queue.  (Again, though, it doesn't sound to 
me as though it *is* a FIFO queue -- or am I misunderstanding your 
comments?)

> [...] and needing to find page referenced bits by virtual scanning.  The 
> latter means that the referenced information at the cold end of the LRU 
> and FIFO is unreliable.

The cold end of the CLOCK actually tends to be quite reliable.  I agree 
that the cold end of a FIFO queue is not, so why not do away with the 
scanning and simply mark pages in the inactive queue as not present 
(although they are, of course)?  If referenced, they are immediately moved 
to the front.  It's not likely to happen often, so the overhead is modest 
(and, for many workloads, far less than with the continual scanning).  
Leave the first queue as a CLOCK, make the second queue a true LRU.

> I haven't tried this, because I think it's more important to get the 
> reverse mapping work nailed down so that the page referenced information 
> is reliable.

Fair enough -- we can't solve all problems at once.  But, I do have a 
proposal, now that I've done all of this nit-picking:  For my own purposes,
  I want a simpler, non-scanning structure.  I want the CLOCK/LRU SEGQ 
structure that I described.  So I'll just go ahead and do that, as it will 
be the basis of some other experiments that I'm trying to do.  Once (if?) 
I've managed that, we can try some workloads to see what the overhead of 
scanning is vs. the overhead of minor (non-I/O) page faults for the 
inactive list references.  My prediction for the outcome is as follows:  
For workloads that are loop-like and require space near to the capacity of 
memory (that is, workloads that will hit the inactive list pages often), 
my approach will incur more overhead.  I think on other workloads, 
eliminating the scanning will be worthwhile, not only in the reduction of 
overhead, but in the elimination of one more factor to tune.  (Mind you, 
scanning will still be somewhat needed to batch together page-write 
operations for cleaning purposes, but that's yet another topic.)

Anyone think this is interesting?  Or am I just doing this for myself?  (I'
m happy to do it for myself, but if others want to know, I'll try to share 
the results.)  Also, does anyone think I'm nuts, and misunderstanding some 
of the issues?  (Always a possibility.)

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9V/c88eFdWQtoOmgRAsPUAJ9P8Qkag/wXeBibK01CjvgnjtnnwgCgkwYw
Zu1FbDBWZPYYV/tg13hifiA=
=sANG
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
