Message-ID: <458787FF.6080404@yahoo.com.au>
Date: Tue, 19 Dec 2006 17:34:39 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Fix area->nr_free-- went (-1) issue in buddy system
References: <6d6a94c50612181901m1bfd9d1bsc2d9496ab24eb3f8@mail.gmail.com>	 <458760B0.7090803@yahoo.com.au> <6d6a94c50612182216r15cd99a3p59bbe3d49cb482f0@mail.gmail.com>
In-Reply-To: <6d6a94c50612182216r15cd99a3p59bbe3d49cb482f0@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey <aubreylee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Aubery!

Aubrey wrote:
> Hi Nick,
> 
> Thanks for your reply again, ;-).
> 
> On 12/19/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>
>> This should not happen because the pages are checked to ensure they are
>> from the same zone before merging.
> 
> 
> How? page_is_buddy() only check if the buddy has the buddy flag and
> has the same order.
> Where can I find the same zone is checked?

Ah OK, you're using 2.6.16? Later kernels have a check for this. I
guess you could backport it?

> 
>>
>> What kind of system do you have? What is the dmesg and the .config?
> 
> 
> I'm using the blackfin uclinux. dmesg and .config is attached.
> 
>> It could be that the zones are not properly aligned and 
>> CONFIG_HOLES_IN_ZONE
>> is not set.
> 
> 
> I changed the code in paging_init(), see below:
> -----------------------------------------
> #if 0
>                zones_size[ZONE_DMA] = (end_mem - PAGE_OFFSET) >> 
> PAGE_SHIFT;
>                zones_size[ZONE_NORMAL] = 0;
> #else
>                zones_size[ZONE_DMA] = (end_mem/2 - PAGE_OFFSET) >> 
> PAGE_SHIFT;
>                zones_size[ZONE_NORMAL] = (end_mem/2 - PAGE_OFFSET) >>
> PAGE_SHIFT;
> #endif
> -----------------------------------------
> This is only what I did the change. I also suspect the zones are not
> properly aligned, But how to align it? I think our system doesn't need
> CONFIG_HOLES_IN_ZONE.

That's right. I guess you can either align your zone sizes (must be
aligned to MAX_ORDER size), or add the zone check in page_is_buddy.

Hope that works.

Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
