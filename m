Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 493CD6B0036
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 05:17:59 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so3874208wev.27
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 02:17:58 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id q7si11217963wif.25.2014.08.17.02.17.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 17 Aug 2014 02:17:57 -0700 (PDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so2493723wiv.4
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 02:17:57 -0700 (PDT)
Message-ID: <53F07342.30006@gmail.com>
Date: Sun, 17 Aug 2014 12:17:54 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 9/9] prd: Add support for page struct mapping
References: <53EB5536.8020702@gmail.com> <53EB5960.50200@plexistor.com> <1408134524.26567.38.camel@misato.fc.hp.com>
In-Reply-To: <1408134524.26567.38.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On 08/15/2014 11:28 PM, Toshi Kani wrote:
> On Wed, 2014-08-13 at 15:26 +0300, Boaz Harrosh wrote:
>> From: Yigal Korman <yigal@plexistor.com>
>>
<>
>>
>> All is actually needed for this is to allocate page-sections
>> and map them into kernel virtual memory. Note that these sections
>> are not associated with any zone, because that would add them to
>> the page_allocators.
> 
> Can we just use memory hotplug and call add_memory(), instead of
> directly calling sparse_add_one_section()?  Memory hotplug adds memory
> as off-line state, and sets all pages reserved.  So, I do not think the
> page allocators will mess with them (unless you put them online).  It
> can also maps the pages with large page size.
> 
> Thanks,
> -Toshi
> 

Thank you Toshi for your reply

I was thinking about that as well at first, but I was afraid, once I call
add_memory() what will prevent the user from enabling that memory through the sysfs
interface later, it looks to me that add_memory() will add all the necessary knobs
to do it.

It is very important to keep a clear distinction, pmem is *not* memory what-so-ever
it is however memory-mapped and needs these accesses enabled for it, hence the need
for page-struct so we can DMA it off the buss.

I am very afraid of any thing that will associate a "zone" with this memory.
Also the:
	firmware_map_add_hotplug(start, start + size, "System RAM");

"System RAM" it is not. And also I think that for DDR4 NvDIMMs we will fail with:
	ret = check_hotplug_memory_range(start, size);

Thanks
Boaz

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
