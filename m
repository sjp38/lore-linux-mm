Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0CF6B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:25:41 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id rd18so210798iec.41
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:25:41 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id xz8si2287786icb.102.2014.08.27.16.25.40
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 16:25:40 -0700 (PDT)
Message-ID: <53FE68E4.4090902@sgi.com>
Date: Wed, 27 Aug 2014 16:25:24 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] x86: Optimize resource lookups for ioremap
References: <20140827225927.364537333@asylum.americas.sgi.com>	<20140827225927.602319674@asylum.americas.sgi.com>	<20140827160515.c59f1c191fde5f788a7c42f6@linux-foundation.org>	<53FE6515.6050102@sgi.com> <20140827161854.0619a04653b336d3adc755f3@linux-foundation.org>
In-Reply-To: <20140827161854.0619a04653b336d3adc755f3@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>



On 8/27/2014 4:18 PM, Andrew Morton wrote:
> On Wed, 27 Aug 2014 16:09:09 -0700 Mike Travis <travis@sgi.com> wrote:
> 
>>
>>>>
>>>> ...
>>>>
>>>> --- linux.orig/kernel/resource.c
>>>> +++ linux/kernel/resource.c
>>>> @@ -494,6 +494,43 @@ int __weak page_is_ram(unsigned long pfn
>>>>  }
>>>>  EXPORT_SYMBOL_GPL(page_is_ram);
>>>>  
>>>> +/*
>>>> + * Search for a resouce entry that fully contains the specified region.
>>>> + * If found, return 1 if it is RAM, 0 if not.
>>>> + * If not found, or region is not fully contained, return -1
>>>> + *
>>>> + * Used by the ioremap functions to insure user not remapping RAM and is as
>>>> + * vast speed up over walking through the resource table page by page.
>>>> + */
>>>> +int __weak region_is_ram(resource_size_t start, unsigned long size)
>>>> +{
>>>> +	struct resource *p;
>>>> +	resource_size_t end = start + size - 1;
>>>> +	int flags = IORESOURCE_MEM | IORESOURCE_BUSY;
>>>> +	const char *name = "System RAM";
>>>> +	int ret = -1;
>>>> +
>>>> +	read_lock(&resource_lock);
>>>> +	for (p = iomem_resource.child; p ; p = p->sibling) {
>>>> +		if (end < p->start)
>>>> +			continue;
>>>> +
>>>> +		if (p->start <= start && end <= p->end) {
>>>> +			/* resource fully contains region */
>>>> +			if ((p->flags != flags) || strcmp(p->name, name))
>>>> +				ret = 0;
>>>> +			else
>>>> +				ret = 1;
>>>> +			break;
>>>> +		}
>>>> +		if (p->end < start)
>>>> +			break;	/* not found */
>>>> +	}
>>>> +	read_unlock(&resource_lock);
>>>> +	return ret;
>>>> +}
>>>> +EXPORT_SYMBOL_GPL(region_is_ram);
>>>
>>> Exporting a __weak symbol is strange.  I guess it works, but neither
>>> the __weak nor the export are actually needed?
>>>
>>
>> I mainly used 'weak' and export because that was what the page_is_ram
>> function was using.  Most likely this won't be used anywhere else but
>> I wasn't sure.  I can certainly remove the weak and export, at least
>> until it's actually needed?
> 
> Several architectures implement custom page_is_ram(), so they need the
> __weak.  region_is_ram() needs neither so yes, they should be removed.

Okay.
> 
> <looks at the code>
> 
> Doing strcmp("System RAM") is rather a hack.  Is there nothing in
> resource.flags which can be used?  Or added otherwise?

I agree except this mimics the page_is_ram function:

        while ((res.start < res.end) &&
                (find_next_iomem_res(&res, "System RAM", true) >= 0)) {

So it passes the same literal string which then find_next does the
same strcmp on it:

                if (p->flags != res->flags)
                        continue;
                if (name && strcmp(p->name, name))
                        continue;

I should add back in the check to insure name is not NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
