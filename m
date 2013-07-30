Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 047046B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 20:41:36 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 29 Jul 2013 18:41:35 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 4FAA019D8048
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 18:41:21 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U0fWli167254
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 18:41:32 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U0fW45030697
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 18:41:32 -0600
Message-ID: <51F70BBA.7060607@linux.vnet.ibm.com>
Date: Mon, 29 Jul 2013 17:41:30 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: page_alloc: Add unlikely for MAX_ORDER check
References: <1375022906-1164-1-git-send-email-waydi1@gmail.com> <51F6F087.9060109@linux.intel.com> <51F70A9F.2000309@linux.vnet.ibm.com>
In-Reply-To: <51F70A9F.2000309@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: SeungHun Lee <waydi1@gmail.com>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, xinxing2zhou@gmail.com

On 07/29/2013 05:36 PM, Cody P Schafer wrote:
> On 07/29/2013 03:45 PM, Dave Hansen wrote:
>> On 07/28/2013 07:48 AM, SeungHun Lee wrote:
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index b8475ed..e644cf5 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -2408,7 +2408,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned
>>> int order,
>>>        * be using allocators in order of preference for an area that is
>>>        * too large.
>>>        */
>>> -    if (order >= MAX_ORDER) {
>>> +    if (unlikely(order >= MAX_ORDER)) {
>>>           WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
>>>           return NULL;
>>>       }
>>
>> What problem is this patch solving?  I can see doing this in hot paths,
>> or places where the compiler is known to be generating bad or suboptimal
>> code.  but, this costs me 512 bytes of text size:
>>
>>   898384 Jul 29 15:40 mm/page_alloc.o.nothing
>>   898896 Jul 29 15:40 mm/page_alloc.o.unlikely

[...]
>
> -rw-rw-r-- 1 cody cody 2942208 Jul 29 17:33 normal/arch/x86/boot/bzImage
> -rw-rw-r-- 1 cody cody 2942208 Jul 29 17:33 unlikely/arch/x86/boot/bzImage

So I screwed this last one up and didn't reapply/unapply the patch, so 
they probably are actually different sizes. I'll run a build and check 
tomorrow.

>> I really don't think we should be adding these without having _concrete_
>> reasons for it.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
