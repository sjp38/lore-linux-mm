Subject: Re: Zoned CART
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.62.0508161318420.7906@schroedinger.engr.sgi.com>
References: <1123857429.14899.59.camel@twins>
	 <1124024312.30836.26.camel@twins> <1124141492.15180.22.camel@twins>
	 <43024435.90503@andrew.cmu.edu>
	 <Pine.LNX.4.62.0508161318420.7906@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 26 Aug 2005 00:39:15 +0200
Message-Id: <1125009555.20161.33.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Rahul Iyer <rni@andrew.cmu.edu>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-08-16 at 13:49 -0700, Christoph Lameter wrote:
> Hmm. I am a bit concerned about the proliferation of counters in CART 
> because these may lead to bouncing cachelines.
> 
> The paper mentions some relationships between the different values. 
> 
> If we had a counter for the number of pages resident (nr_rpages) 
> (|T1|+|T2|) then that counter would gradually approach c and then no 
> longer change.
> 
> Then
> 
> |T2| = nr_rpages - |T1|
> 
> Similarly if we had a counter for the number of pages on the evicted 
> list (nr_evicted) then that counter would also gradually approach c and 
> then stay constant. nr_evicted would only increase if nr_rpages has 
> already reached c which is another good thing to avoid bouncing 
> cachelines.
> 
> Then also
> 
> |B2| = nr_evicted - |B1|
> 
> Thus we could reduce the frequency of counter increments on a fully 
> loaded system (where nr_rpages = c and nr_eviced = c) by 
> calculating some variables:
> 
> #define nr_inactive (nr_rpages - nr_active)
> #define nr_evicted_longterm (nr_evicted - nr_evicted_shortterm)
> 
> There is also a relationship between |S| and |L| since these attributes 
> are only used on resident pages.
> 
> |L| = nr_rpages - |S|
>
> So
> 
> #define nr_longterm (nr_rpages - nr_shortterm)

I tried to do this, however I have some problems getting nr_rpages.

#define cart_c(zone)	((zone)->present_pages - (zone)->free_pages - (zone)->nr_inactive)
/* |T2| = c - |T1| */
#define active_longterm(zone) (cart_c(zone) - (zone)->nr_active)
/* |B2| = c - |B1| */
#define evicted_longterm(zone) (cart_c(zone) - (zone)->nr_evicted_active)
/* nl = c - ns */
#define longterm(zone) (cart_c(zone) - (zone)->nr_shortterm)

This is with a rahul's 3 list approach:
  active_list <-> T1, 
  active_longterm <-> T2
  inactive_list - used for batch replace; although i'm contemplating
getting rid of the thing.


My trouble is with the definition of cart_c; I seem to over guess c.
(and miscount some, esp. shortterm, but I'm looking into that).

struct zone values:
  zone->nr_active: 1645
  zone->nr_inactive: 1141
  zone->nr_evicted_active: 0
  zone->nr_shortterm: 30526
  zone->cart_p: 0
  zone->cart_q: 88
  zone->present_pages: 16384
  zone->free_pages: 10546
  zone->pages_min: 256
  zone->pages_low: 320
  zone->pages_high: 384

implicit values:
  zone->nr_active_longterm: 3052
  zone->nr_evicted_longterm: 4697
  zone->nr_longterm: 4294941467
  zone->cart_c: 4697

counted values:
  zone->nr_active: 1549
  zone->nr_shortterm: 1545
  zone->nr_longterm: 4
  zone->nr_active_longterm: 0
  zone->nr_inactive: 1141


here nr_rpages should be:
 nr_active + nr_active_longterm = 
  1549 + 0 = 1549

but my cart_c marco gives me:
 present_pages - free_pages - nr_inactive = 
  16384 - 10546 - 1141 = 4697

where are those 4697 - 1549 = 3148 pages?


-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
