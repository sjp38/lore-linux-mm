Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 456FA6B009D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 02:28:33 -0500 (EST)
Received: by yenq10 with SMTP id q10so273982yen.14
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 23:28:32 -0800 (PST)
Date: Tue, 6 Dec 2011 23:28:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
In-Reply-To: <1323234673.22361.372.camel@sli10-conroe>
Message-ID: <alpine.DEB.2.00.1112062319010.21785@chino.kir.corp.google.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com> <alpine.DEB.2.00.1112020842280.10975@router.home> <1323076965.16790.670.camel@debian> <alpine.DEB.2.00.1112061259210.28251@chino.kir.corp.google.com>
 <1323234673.22361.372.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: "Shi, Alex" <alex.shi@intel.com>, Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>

On Wed, 7 Dec 2011, Shaohua Li wrote:

> interesting. I did similar experiment before (try to sort the page
> according to free number), but it appears quite hard. The free number of
> a page is dynamic, eg more slabs can be freed when the page is in
> partial list. And in netperf test, the partial list could be very very
> long. Can you post your patch, I definitely what to look at it.

It was over a couple of years ago and the slub code has changed 
significantly since then, but you can see the general concept of the "slab 
thrashing" problem with netperf and my solution back then:

	http://marc.info/?l=linux-kernel&m=123839191416478
	http://marc.info/?l=linux-kernel&m=123839203016592
	http://marc.info/?l=linux-kernel&m=123839202916583

I also had a separate patchset that, instead of this approach, would just 
iterate through the partial list in get_partial_node() looking for 
anything where the number of free objects met a certain threshold, which 
still defaulted to 25% and instantly picked it.  The overhead was taking 
slab_lock() for each page, but that was nullified by the performance 
speedup of using the alloc fastpath a majority of the time for both 
kmalloc-256 and kmalloc-2k when in the past it had only been able to serve 
one or two allocs.  If no partial slab met the threshold, the slab_lock() 
is held of the partial slab with the most free objects and returned 
instead.

> What I have about the partial list is it wastes a lot of memory.

That's not going to be helped with the above approach since we typically 
try to fill a partial slab with many free objects, but it also won't be 
severely impacted because if the threshold is kept small enough, then we 
simply return the first partial slab that meets the criteria.  That allows 
the partial slabs at the end of the list to hopefully become mostly free.

And, for completeness, there's also a possibility that you have some 
completely free slabs on the partial list that coule be freed back to the 
buddy allocator by decreasing min_partial by way of 
/sys/kernel/slab/cache/min_partial at the risk of performance and then 
invoke /sys/kernel/slab/cache/shrink to free the unused slabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
