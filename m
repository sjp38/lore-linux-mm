Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 082026B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 09:01:46 -0500 (EST)
Date: Tue, 31 Jan 2012 14:01:43 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFCv1 3/6] PASR: mm: Integrate PASR in Buddy allocator
Message-ID: <20120131140143.GW25268@csn.ul.ie>
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
 <1327930436-10263-4-git-send-email-maxime.coquelin@stericsson.com>
 <20120130152237.GS25268@csn.ul.ie>
 <4F26CAD1.2000209@stericsson.com>
 <4F27DB7B.4010103@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F27DB7B.4010103@stericsson.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Coquelin <maxime.coquelin@stericsson.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus WALLEIJ <linus.walleij@stericsson.com>, Andrea GALLO <andrea.gallo@stericsson.com>, Vincent GUITTOT <vincent.guittot@stericsson.com>, Philippe LANGLAIS <philippe.langlais@stericsson.com>, Loic PALLARDY <loic.pallardy@stericsson.com>

On Tue, Jan 31, 2012 at 01:15:55PM +0100, Maxime Coquelin wrote:
> Hello Mel,
> On 01/30/2012 05:52 PM, Maxime Coquelin wrote:
> >
> >On 01/30/2012 04:22 PM, Mel Gorman wrote:
> >
> >>You may be able to use the existing arch_alloc_page() hook and
> >>call PASR on architectures that support it if and only if PASR is
> >>present and enabled by the administrator but even this is likely to be
> >>unpopular as it'll have a measurable performance impact on platforms
> >>with PASR (not to mention the PASR lock will be even heavier as it'll
> >>now be also used for per-cpu page allocations). To get the hook you
> >>want, you'd need to show significant benefit before they were happy with
> >>the hook.
> >Your proposal sounds good.
> >AFAIK, per-cpu allocation maximum size is 32KB. Please correct me
> >if I'm wrong.
> >Since pasr_kget/kput() calls the PASR framework only on MAX_ORDER
> >allocations, we wouldn't add any locking risks nor contention
> >compared to current patch.
> >I will update the patch set using  arch_alloc/free_page().
> >
> I just had a deeper look at when arch_alloc_page() is called. I
> think it does not fit with PASR framework needs.
> pasr_kget() calls pasr_get() only for max order pages (same for
> pasr_kput()) to avoid overhead.
> 

I see. My bad.

> In current patch set, pasr_kget() is called when pages are removed
> from the free lists, and pasr_kput() when pages are inserted in the
> free lists.
> So, pasr_get() is called in case of :
>     - allocation of a max order page
>     - split of a max order page into lower order pages to fulfill
> allocation of pages smaller than max order
> And pasr_put() is called in case of:
>     - release of a max order page
>     - coalescence of two "max order -1" pages when smaller pages are
> released
> 
> If we call the PASR framework in arch_alloc_page(), we have two
> possibilities:
>     1) using pasr_kget(): the PASR framework will only be notified
> of max order allocations, so the coalesce/split of free pages case
> will not be taken into account.
>     2) using pasr_get(): the PASR framework will be called for every
> orders of page allocation/release. The induced overhead is not
> acceptable.
> 
> To avoid calling pasr_kget/kput() directly in page_alloc.c, do you
> think adding some arch specific hooks when a page is inserted or
> removed from the free lists could be acceptable?

It's not the name that is the problem, I'm strongly against any hook
that can delay the page allocator for arbitrary lengths of time like
this. I am open to being convinced otherwise but for me PASR would
need to demonstrate large savings for a wide variety of machines and
the alternatives would have to be considered and explained why they
would be far inferior or unsuitable.

For example - it seems like this could be also be done with a
balloon driver instead of page allocator hooks. A governer would
identify when the machine was under no memory pressure or triggered
from userspace. To power down memory, it would use page reclaim and
page migration to allocate large contiguous ranges of memory - CMA
could potentially be adapted when it gets merged to save a lot of
implementation work. The governer should register a slab shrinker
so that under memory pressure it gets called so it can shrink the
ballon, power the DIMMS back up and free the memory back to the
buddy allocator. This would keep all the cost out of the allocator
paths and move the cost to when the machine is either idle (in the
case of powering down) or under memory pressure (where the cost of
powering up will be small in comparison to the overall cost of the
page reclaim operation).

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
