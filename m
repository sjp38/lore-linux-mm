Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 50EBB6B0009
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 21:14:01 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id b17so1415869otf.2
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 18:14:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w18sor4432123oti.36.2018.02.26.18.14.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 18:14:00 -0800 (PST)
Subject: Re: [PATCH] mm: Provide consistent declaration for num_poisoned_pages
References: <1519686565-8224-1-git-send-email-linux@roeck-us.net>
 <alpine.DEB.2.20.1802261556420.236524@chino.kir.corp.google.com>
From: Guenter Roeck <linux@roeck-us.net>
Message-ID: <262450c2-778a-fb12-1af3-aa52d03121c8@roeck-us.net>
Date: Mon, 26 Feb 2018 18:13:57 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1802261556420.236524@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>

On 02/26/2018 03:57 PM, David Rientjes wrote:
> On Mon, 26 Feb 2018, Guenter Roeck wrote:
> 
>> clang reports the following compile warning.
>>
>> In file included from mm/vmscan.c:56:
>> ./include/linux/swapops.h:327:22: warning:
>> 	section attribute is specified on redeclared variable [-Wsection]
>> extern atomic_long_t num_poisoned_pages __read_mostly;
>>                       ^
>> ./include/linux/mm.h:2585:22: note: previous declaration is here
>> extern atomic_long_t num_poisoned_pages;
>>                       ^
>>
>> Let's use __read_mostly everywhere.
>>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>> Cc: Matthias Kaehlcke <mka@chromium.org>
>> ---
>>   include/linux/mm.h | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index ad06d42adb1a..bd4bd59f02c1 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2582,7 +2582,7 @@ extern int get_hwpoison_page(struct page *page);
>>   extern int sysctl_memory_failure_early_kill;
>>   extern int sysctl_memory_failure_recovery;
>>   extern void shake_page(struct page *p, int access);
>> -extern atomic_long_t num_poisoned_pages;
>> +extern atomic_long_t num_poisoned_pages __read_mostly;
>>   extern int soft_offline_page(struct page *page, int flags);
>>   
>>   
> 
> No objection to the patch, of course, but I'm wondering if it's (1) the
> only such clang compile warning for mm/, and (2) if the re-declaration in

It is the only one I recall seeing in mm/ while testing the clang/retpoline
changes with ToT clang 7.0.0, but then I didn't pay too close attention.

> mm.h could be avoided by including swapops.h?
> 

Another alternative would be to remove the extern fom swapops.h and have
swapops.h include mm.h instead. I chose the least invasive change since
I didn't want to risk breaking some other build (after all, maybe there
was a reason for declaring num_poisoned_pages in two include files).

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
