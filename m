Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id CE6266B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:02:25 -0500 (EST)
Date: Mon, 6 Feb 2012 09:02:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [rfc PATCH]slub: per cpu partial statistics change
In-Reply-To: <4F2C824E.8080501@intel.com>
Message-ID: <alpine.DEB.2.00.1202060858510.393@router.home>
References: <1328256695.12669.24.camel@debian> <alpine.DEB.2.00.1202030920060.2420@router.home> <4F2C824E.8080501@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, 4 Feb 2012, Alex Shi wrote:

> On 02/03/2012 11:27 PM, Christoph Lameter wrote:
>
> > On Fri, 3 Feb 2012, Alex,Shi wrote:
> >
> >> This patch split the cpu_partial_free into 2 parts: cpu_partial_node, PCP refilling
> >> times from node partial; and same name cpu_partial_free, PCP refilling times in
> >> slab_free slow path. A new statistic 'release_cpu_partial' is added to get PCP
> >> release times. These info are useful when do PCP tunning.
> >
> > Releasing? The code where you inserted the new statistics counts the pages
> > put on the cpu partial list when refilling from the node partial list.
>
>
> Ops, are we talking the same base kernel: Linus' tree?  :)
> Here the Releasing code only be called in slow free path and the PCP is
> full at the same time, not in PCP refilling from node partial.

Well the term releasing is unfortunate. per cpu partial pages can migrate
to and from the per node partial list and become per cpu slabs under
allocation.

> >> @@ -2465,9 +2466,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
> >>  		 * If we just froze the page then put it onto the
> >>  		 * per cpu partial list.
> >>  		 */
> >> -		if (new.frozen && !was_frozen)
> >> +		if (new.frozen && !was_frozen) {
> >>  			put_cpu_partial(s, page, 1);
> >> -
> >> +			stat(s, CPU_PARTIAL_FREE);
> >
> > cpu partial list filled with a partial page created from a fully allocated
> > slab (which therefore was not on any list before).
>
>
> Yes, but the counting is not new here. It just moved out of
> put_cpu_partial().

Ok but then you also added different accounting in put_cpu_partial.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
