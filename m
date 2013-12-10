Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 078DA6B013B
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 20:02:41 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so3363917yha.21
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 17:02:41 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id m9si11755374yha.173.2013.12.09.17.02.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 17:02:41 -0800 (PST)
Message-ID: <52A66826.7060204@ti.com>
Date: Mon, 9 Dec 2013 20:02:30 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com> <529217C7.6030304@cogentembedded.com> <52935762.1080409@ti.com> <20131209165044.cf7de2edb8f4205d5ac02ab0@linux-foundation.org> <20131210005454.GX4360@n2100.arm.linux.org.uk>
In-Reply-To: <20131210005454.GX4360@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, linux-arm-kernel@lists.infradead.org

On Monday 09 December 2013 07:54 PM, Russell King - ARM Linux wrote:
> On Mon, Dec 09, 2013 at 04:50:44PM -0800, Andrew Morton wrote:
>> On Mon, 25 Nov 2013 08:57:54 -0500 Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:
>>
>>> On Sunday 24 November 2013 10:14 AM, Sergei Shtylyov wrote:
>>>> Hello.
>>>>
>>>> On 24-11-2013 3:28, Santosh Shilimkar wrote:
>>>>
>>>>> Building ARM with NO_BOOTMEM generates below warning. Using min_t
>>>>
>>>>    Where is that below? :-)
>>>>
>>> Damn.. Posted a wrong version of the patch ;-(
>>> Here is the one with warning message included.
>>>
>>> >From 571dfdf4cf8ac7dfd50bd9b7519717c42824f1c3 Mon Sep 17 00:00:00 2001
>>> From: Santosh Shilimkar <santosh.shilimkar@ti.com>
>>> Date: Sat, 23 Nov 2013 18:16:50 -0500
>>> Subject: [PATCH] mm: nobootmem: avoid type warning about alignment value
>>>
>>> Building ARM with NO_BOOTMEM generates below warning.
>>>
>>> mm/nobootmem.c: In function _____free_pages_memory___:
>>> mm/nobootmem.c:88:11: warning: comparison of distinct pointer types lacks a cast
>>>
>>> Using min_t to find the correct alignment avoids the warning.
>>>
>>> Cc: Tejun Heo <tj@kernel.org>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
>>> ---
>>>  mm/nobootmem.c |    2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
>>> index 2c254d3..8954e43 100644
>>> --- a/mm/nobootmem.c
>>> +++ b/mm/nobootmem.c
>>> @@ -85,7 +85,7 @@ static void __init __free_pages_memory(unsigned long start, unsigned long end)
>>>  	int order;
>>>  
>>>  	while (start < end) {
>>> -		order = min(MAX_ORDER - 1UL, __ffs(start));
>>> +		order = min_t(size_t, MAX_ORDER - 1UL, __ffs(start));
>>>  
>>
>> size_t makes no sense.  Neither `order', `MAX_ORDER', 1UL nor __ffs()
>> have that type.
>>
>> min() warnings often indicate that the chosen types are inappropriate,
>> and suppressing them with min_t() should be a last resort.
>>
>> MAX_ORDER-1UL has type `unsigned long' (yes?) and __ffs() should return
>> unsigned long (except arch/arc which decided to be different).
>>
>> Why does it warn?  What's the underlying reason?
> 
> The underlying reason is that - as I've already explained - ARM's __ffs()
> differs from other architectures in that it ends up being an int, whereas
> almost everyone else is unsigned long.
> 
> The fix is to fix ARMs __ffs() to conform to other architectures.
> 
I was just about to cross-post your reply here. Obviously I didn't think
this far when I made  $subject fix.

So lets ignore the $subject patch which is not correct. Sorry for noise

Regards,
Santosh




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
