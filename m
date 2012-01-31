Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id B78DD6B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 13:56:20 -0500 (EST)
Message-ID: <4F283933.6070401@stericsson.com>
Date: Tue, 31 Jan 2012 19:55:47 +0100
From: Maxime Coquelin <maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Subject: Re: [RFCv1 3/6] PASR: mm: Integrate PASR in Buddy allocator
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com> <1327930436-10263-4-git-send-email-maxime.coquelin@stericsson.com> <20120130152237.GS25268@csn.ul.ie> <4F26CAD1.2000209@stericsson.com> <4F27DB7B.4010103@stericsson.com> <20120131140143.GW25268@csn.ul.ie>
In-Reply-To: <20120131140143.GW25268@csn.ul.ie>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus WALLEIJ <linus.walleij@stericsson.com>, Andrea GALLO <andrea.gallo@stericsson.com>, Vincent GUITTOT <vincent.guittot@stericsson.com>, Philippe LANGLAIS <philippe.langlais@stericsson.com>, Loic PALLARDY <loic.pallardy@stericsson.com>

On 01/31/2012 03:01 PM, Mel Gorman wrote:
> On Tue, Jan 31, 2012 at 01:15:55PM +0100, Maxime Coquelin wrote:
>> In current patch set, pasr_kget() is called when pages are removed
>> from the free lists, and pasr_kput() when pages are inserted in the
>> free lists.
>> So, pasr_get() is called in case of :
>>      - allocation of a max order page
>>      - split of a max order page into lower order pages to fulfill
>> allocation of pages smaller than max order
>> And pasr_put() is called in case of:
>>      - release of a max order page
>>      - coalescence of two "max order -1" pages when smaller pages are
>> released
>>
>> If we call the PASR framework in arch_alloc_page(), we have two
>> possibilities:
>>      1) using pasr_kget(): the PASR framework will only be notified
>> of max order allocations, so the coalesce/split of free pages case
>> will not be taken into account.
>>      2) using pasr_get(): the PASR framework will be called for every
>> orders of page allocation/release. The induced overhead is not
>> acceptable.
>>
>> To avoid calling pasr_kget/kput() directly in page_alloc.c, do you
>> think adding some arch specific hooks when a page is inserted or
>> removed from the free lists could be acceptable?
> It's not the name that is the problem, I'm strongly against any hook
> that can delay the page allocator for arbitrary lengths of time like
> this. I am open to being convinced otherwise but for me PASR would
> need to demonstrate large savings for a wide variety of machines and
> the alternatives would have to be considered and explained why they
> would be far inferior or unsuitable.
Ok Mel, I understand your point of view.

The goal of this RFC patch set was to collect comments, so I'm glad to 
get your opinion.
I propose to forget the patch in the Buddy allocator.

> For example - it seems like this could be also be done with a
> balloon driver instead of page allocator hooks. A governer would
> identify when the machine was under no memory pressure or triggered
> from userspace. To power down memory, it would use page reclaim and
> page migration to allocate large contiguous ranges of memory - CMA
> could potentially be adapted when it gets merged to save a lot of
> implementation work. The governer should register a slab shrinker
> so that under memory pressure it gets called so it can shrink the
> ballon, power the DIMMS back up and free the memory back to the
> buddy allocator. This would keep all the cost out of the allocator
> paths and move the cost to when the machine is either idle (in the
> case of powering down) or under memory pressure (where the cost of
> powering up will be small in comparison to the overall cost of the
> page reclaim operation).
>
This is very interesting.
I know Linaro plans to work on DDR power management topic.
One of the options they envisage is to use the Memory Hotplug feature.
However, the main problem with Memory Hotplug is to handle the memory 
pressure, i.e. when to re-plug the memory sections.
Your proposal address this issue. I don't know if such a driver could be 
done in the Linaro scope.

Anyway, even with a balloon driver, I think the PASR framework could be 
suitable to keep an "hardware" view of the memory layout (dies, banks, 
segments...).
Moreover, this framework is designed to also support some physically 
contiguous memory allocators (such as hwmem and pmem).

Best regards,
Maxime

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
