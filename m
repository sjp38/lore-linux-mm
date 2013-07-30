Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 67A816B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 21:20:28 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 29 Jul 2013 19:20:27 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 216863E40044
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 19:20:01 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U1KNUG295084
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 19:20:23 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U1KM18022005
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 19:20:23 -0600
Message-ID: <51F714D4.9070005@linux.vnet.ibm.com>
Date: Mon, 29 Jul 2013 18:20:20 -0700
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
>
> I took a look at this on my system.
>
> With gcc version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5):
>
> -rw-rw-r-- 1 cody cody 841160 Jul 29 16:47 unlikely/mm/page_alloc.o
> -rw-rw-r-- 1 cody cody 840584 Jul 29 16:59 normal/mm/page_alloc.o
>
>     text       data        bss        dec        hex    filename
>    33799       1414        184      35397       8a45
> unlikely/mm/page_alloc.o
>    33799       1414        184      35397       8a45
> normal/mm/page_alloc.o
>
> Well, where are are those extra bytes coming from, then?
>
> Using readelf -S + `git diff --no-index --word-diff` shows:
> .debug_info      shrinks from 1e991 to 1e98f
> .rela.debug_info shrinks from 33a80 to 33a68
> .debug_loc         grows from 15e1d to 15ecb
> .rela.debug_loc    grows from 26f40 to 270f0
> .debug_line        grows from 038eb to 038ed
> .debug_str       shrinks from 0adb6 to 0adb2
>
> The sizes of all other sections are unchanged.
>
> Also: comparing vmlinux sizes:
> -rwxrwxr-x 1 cody cody 94121230 Jul 29 17:00 normal/vmlinux
> -rwxrwxr-x 1 cody cody 94121294 Jul 29 16:51 unlikely/vmlinux
>
> And the bzImage sizes:
> -rw-rw-r-- 1 cody cody 2942240 Jul 29 16:51 unlikely/arch/x86/boot/bzImage
> -rw-rw-r-- 1 cody cody 2942208 Jul 29 17:00 normal/arch/x86/boot/bzImage
>
> I build this kernel with debug info built in though, what happens when
> it is removed?
>
> -rwxrwxr-x 1 cody cody 16392454 Jul 29 17:33 normal/vmlinux
> -rwxrwxr-x 1 cody cody 16392454 Jul 29 17:33 unlikely/vmlinux
>
> -rw-rw-r-- 1 cody cody 2942208 Jul 29 17:33 normal/arch/x86/boot/bzImage
> -rw-rw-r-- 1 cody cody 2942208 Jul 29 17:33 unlikely/arch/x86/boot/bzImage

Corrected size for bzImage and vmlinux with patch applied:
-rwxrwxr-x 1 cody cody 16392454 Jul 29 18:15 unlikely/vmlinux
-rw-rw-r-- 1 cody cody 2942240 Jul 29 18:15 unlikely/arch/x86/boot/bzImage

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
