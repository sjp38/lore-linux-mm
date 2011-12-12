Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 1469D6B00A9
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 21:30:58 -0500 (EST)
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <alpine.DEB.2.00.1112062319010.21785@chino.kir.corp.google.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
	 <alpine.DEB.2.00.1112020842280.10975@router.home>
	 <1323076965.16790.670.camel@debian>
	 <alpine.DEB.2.00.1112061259210.28251@chino.kir.corp.google.com>
	 <1323234673.22361.372.camel@sli10-conroe>
	 <alpine.DEB.2.00.1112062319010.21785@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 12 Dec 2011 10:43:13 +0800
Message-ID: <1323657793.22361.383.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Shi, Alex" <alex.shi@intel.com>, Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>

On Wed, 2011-12-07 at 15:28 +0800, David Rientjes wrote:
> On Wed, 7 Dec 2011, Shaohua Li wrote:
> 
> > interesting. I did similar experiment before (try to sort the page
> > according to free number), but it appears quite hard. The free number of
> > a page is dynamic, eg more slabs can be freed when the page is in
> > partial list. And in netperf test, the partial list could be very very
> > long. Can you post your patch, I definitely what to look at it.
> 
> It was over a couple of years ago and the slub code has changed 
> significantly since then, but you can see the general concept of the "slab 
> thrashing" problem with netperf and my solution back then:
> 
> 	http://marc.info/?l=linux-kernel&m=123839191416478
> 	http://marc.info/?l=linux-kernel&m=123839203016592
> 	http://marc.info/?l=linux-kernel&m=123839202916583
> 
> I also had a separate patchset that, instead of this approach, would just 
> iterate through the partial list in get_partial_node() looking for 
> anything where the number of free objects met a certain threshold, which 
> still defaulted to 25% and instantly picked it.  The overhead was taking 
> slab_lock() for each page, but that was nullified by the performance 
> speedup of using the alloc fastpath a majority of the time for both 
> kmalloc-256 and kmalloc-2k when in the past it had only been able to serve 
> one or two allocs.  If no partial slab met the threshold, the slab_lock() 
> is held of the partial slab with the most free objects and returned 
> instead.
With the per-cpu partial list, I didn't see any workload which is still
suffering from the list lock, so I suppose both the trashing approach
and pick 25% used slab approach don't help. The per-cpu partial list
flushes the whole per-cpu partial list after s->cpu_partial objects are
freed, this is a little aggressive, because the per-cpu partial list
need refilled again soon after an allocation. I had experiment to have
separate per-cpu alloc/free partial list, which can avoid this. but
again, I didn't see any workload still suffering list lock issue even
with netperf which stress slub much. did you see such workload?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
