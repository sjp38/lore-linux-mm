Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 4DA426B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 06:44:14 -0500 (EST)
Date: Fri, 3 Feb 2012 11:44:10 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFCv1 3/6] PASR: mm: Integrate PASR in Buddy allocator
Message-ID: <20120203114410.GD5796@csn.ul.ie>
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
 <1327930436-10263-4-git-send-email-maxime.coquelin@stericsson.com>
 <20120130152237.GS25268@csn.ul.ie>
 <4F26CAD1.2000209@stericsson.com>
 <4F27DB7B.4010103@stericsson.com>
 <20120131140143.GW25268@csn.ul.ie>
 <4F283933.6070401@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F283933.6070401@stericsson.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Coquelin <maxime.coquelin@stericsson.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus WALLEIJ <linus.walleij@stericsson.com>, Andrea GALLO <andrea.gallo@stericsson.com>, Vincent GUITTOT <vincent.guittot@stericsson.com>, Philippe LANGLAIS <philippe.langlais@stericsson.com>, Loic PALLARDY <loic.pallardy@stericsson.com>

On Tue, Jan 31, 2012 at 07:55:47PM +0100, Maxime Coquelin wrote:
> >>To avoid calling pasr_kget/kput() directly in page_alloc.c, do you
> >>think adding some arch specific hooks when a page is inserted or
> >>removed from the free lists could be acceptable?
> >It's not the name that is the problem, I'm strongly against any hook
> >that can delay the page allocator for arbitrary lengths of time like
> >this. I am open to being convinced otherwise but for me PASR would
> >need to demonstrate large savings for a wide variety of machines and
> >the alternatives would have to be considered and explained why they
> >would be far inferior or unsuitable.
>
> Ok Mel, I understand your point of view.
> 
> The goal of this RFC patch set was to collect comments, so I'm glad
> to get your opinion.
> I propose to forget the patch in the Buddy allocator.
> 

Or at least tag it as "this should have an alternative"

> >For example - it seems like this could be also be done with a
> >balloon driver instead of page allocator hooks. A governer would
> >identify when the machine was under no memory pressure or triggered
> >from userspace. To power down memory, it would use page reclaim and
> >page migration to allocate large contiguous ranges of memory - CMA
> >could potentially be adapted when it gets merged to save a lot of
> >implementation work. The governer should register a slab shrinker
> >so that under memory pressure it gets called so it can shrink the
> >ballon, power the DIMMS back up and free the memory back to the
> >buddy allocator. This would keep all the cost out of the allocator
> >paths and move the cost to when the machine is either idle (in the
> >case of powering down) or under memory pressure (where the cost of
> >powering up will be small in comparison to the overall cost of the
> >page reclaim operation).
> >
>
> This is very interesting.
> I know Linaro plans to work on DDR power management topic.
> One of the options they envisage is to use the Memory Hotplug feature.
> However, the main problem with Memory Hotplug is to handle the
> memory pressure, i.e. when to re-plug the memory sections.

heh, I was originally going to suggest the Memory Hotplug feature until
I ran into the problem of how to bring the memory back. Technically,
it could *also* use a shrinker and keep track of the memory it
offlined. It would work on a similar principal to the balloon but I
was worried that the cost of offlining and onlining memory would be
too high for PASR. There was also the problem that it would require
SPARSEMEM and would also require that you grew/shrunk memory in ranges
of the section size which might be totally different to PASR.

> Your proposal address this issue. I don't know if such a driver
> could be done in the Linaro scope.
> 

Beats me.

> Anyway, even with a balloon driver, I think the PASR framework could
> be suitable to keep an "hardware" view of the memory layout (dies,
> banks, segments...).

Oh yes, the balloon driver would still need this information!

> Moreover, this framework is designed to also support some physically
> contiguous memory allocators (such as hwmem and pmem).
> 

Not being familiar with hwmem or pmem, I can't be 100% certain but
superficially, I would expect that the same balloon driver could be used
for hwmem and pmem. The main difference between this balloon driver and
others will be how it selects pages to add to the balloon.

There are existing balloon drivers that you may or may not be able to
leverage. There is some talk that KVM people want to be able to balloon
2M contiguous pages. If this was ever implemented, it's possible that
you could reuse it for PASR so keep an eye out for it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
