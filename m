Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id C24106B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:09:24 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so7135284igb.3
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:09:24 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id m4si2300719igx.47.2014.08.27.16.09.24
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 16:09:24 -0700 (PDT)
Message-ID: <53FE6515.6050102@sgi.com>
Date: Wed, 27 Aug 2014 16:09:09 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] x86: Optimize resource lookups for ioremap
References: <20140827225927.364537333@asylum.americas.sgi.com>	<20140827225927.602319674@asylum.americas.sgi.com> <20140827160515.c59f1c191fde5f788a7c42f6@linux-foundation.org>
In-Reply-To: <20140827160515.c59f1c191fde5f788a7c42f6@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>



On 8/27/2014 4:05 PM, Andrew Morton wrote:
> On Wed, 27 Aug 2014 17:59:28 -0500 Mike Travis <travis@sgi.com> wrote:
> 
>> Since the ioremap operation is verifying that the specified address range
>> is NOT RAM, it will search the entire ioresource list if the condition
>> is true.  To make matters worse, it does this one 4k page at a time.
>> For a 128M BAR region this is 32 passes to determine the entire region
>> does not contain any RAM addresses.
>>
>> This patch provides another resource lookup function, region_is_ram,
>> that searches for the entire region specified, verifying that it is
>> completely contained within the resource region.  If it is found, then
>> it is checked to be RAM or not, within a single pass.
>>
>> The return result reflects if it was found or not (-1), and whether it is
>> RAM (1) or not (0).  This allows the caller to fallback to the previous
>> page by page search if it was not found.
>>
>> ...
>>
>> --- linux.orig/kernel/resource.c
>> +++ linux/kernel/resource.c
>> @@ -494,6 +494,43 @@ int __weak page_is_ram(unsigned long pfn
>>  }
>>  EXPORT_SYMBOL_GPL(page_is_ram);
>>  
>> +/*
>> + * Search for a resouce entry that fully contains the specified region.
>> + * If found, return 1 if it is RAM, 0 if not.
>> + * If not found, or region is not fully contained, return -1
>> + *
>> + * Used by the ioremap functions to insure user not remapping RAM and is as
>> + * vast speed up over walking through the resource table page by page.
>> + */
>> +int __weak region_is_ram(resource_size_t start, unsigned long size)
>> +{
>> +	struct resource *p;
>> +	resource_size_t end = start + size - 1;
>> +	int flags = IORESOURCE_MEM | IORESOURCE_BUSY;
>> +	const char *name = "System RAM";
>> +	int ret = -1;
>> +
>> +	read_lock(&resource_lock);
>> +	for (p = iomem_resource.child; p ; p = p->sibling) {
>> +		if (end < p->start)
>> +			continue;
>> +
>> +		if (p->start <= start && end <= p->end) {
>> +			/* resource fully contains region */
>> +			if ((p->flags != flags) || strcmp(p->name, name))
>> +				ret = 0;
>> +			else
>> +				ret = 1;
>> +			break;
>> +		}
>> +		if (p->end < start)
>> +			break;	/* not found */
>> +	}
>> +	read_unlock(&resource_lock);
>> +	return ret;
>> +}
>> +EXPORT_SYMBOL_GPL(region_is_ram);
> 
> Exporting a __weak symbol is strange.  I guess it works, but neither
> the __weak nor the export are actually needed?
> 

I mainly used 'weak' and export because that was what the page_is_ram
function was using.  Most likely this won't be used anywhere else but
I wasn't sure.  I can certainly remove the weak and export, at least
until it's actually needed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
