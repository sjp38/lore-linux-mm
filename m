Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB4E6B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 15:58:22 -0500 (EST)
Received: by pfdd184 with SMTP id d184so17697573pfd.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 12:58:22 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id kd8si7379124pab.66.2015.12.08.12.58.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 12:58:21 -0800 (PST)
Received: by pfbg73 with SMTP id g73so18125750pfb.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 12:58:21 -0800 (PST)
Subject: Re: [PATCH v3 2/7] mm/gup: add gup trace points
References: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
 <1449603595-718-3-git-send-email-yang.shi@linaro.org>
 <20151208152555.1c03ae54@gandalf.local.home>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <5667446B.30206@linaro.org>
Date: Tue, 8 Dec 2015 12:58:19 -0800
MIME-Version: 1.0
In-Reply-To: <20151208152555.1c03ae54@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 12/8/2015 12:25 PM, Steven Rostedt wrote:
> On Tue,  8 Dec 2015 11:39:50 -0800
> Yang Shi <yang.shi@linaro.org> wrote:
>
>> For slow version, just add trace point for raw __get_user_pages since all
>> slow variants call it to do the real work finally.
>>
>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>> ---
>>   mm/gup.c | 8 ++++++++
>>   1 file changed, 8 insertions(+)
>>
>> diff --git a/mm/gup.c b/mm/gup.c
>> index deafa2c..44f05c9 100644
>> --- a/mm/gup.c
>> +++ b/mm/gup.c
>> @@ -18,6 +18,9 @@
>>
>>   #include "internal.h"
>>
>> +#define CREATE_TRACE_POINTS
>> +#include <trace/events/gup.h>
>> +
>>   static struct page *no_page_table(struct vm_area_struct *vma,
>>   		unsigned int flags)
>>   {
>> @@ -462,6 +465,8 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>>   	if (!nr_pages)
>>   		return 0;
>>
>> +	trace_gup_get_user_pages(start, nr_pages);
>> +
>>   	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
>>
>>   	/*
>> @@ -599,6 +604,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>>   	if (!(vm_flags & vma->vm_flags))
>>   		return -EFAULT;
>>
>> +	trace_gup_fixup_user_fault(address);
>>   	ret = handle_mm_fault(mm, vma, address, fault_flags);
>>   	if (ret & VM_FAULT_ERROR) {
>>   		if (ret & VM_FAULT_OOM)
>> @@ -1340,6 +1346,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>>   					start, len)))
>>   		return 0;
>>
>> +	trace_gup_get_user_pages_fast(start, (unsigned long) nr_pages);
>
> typecast shouldn't be needed. But I'm wondering, it would save space in
> the ring buffer if we used unsigend int instead of long. Will nr_pages
> ever be bigger than 4 billion?

The "unsigned long" comes from get_user_pages() definition, I'm not 
quite sure why "unsigned long" is used. The fast version uses int (I 
guess unsigned int sounds better since it will not go negative).

"unsigned int" could cover 0xffffffff pages (almost 16TB), it sounds 
good enough in the most use case to me. In my test, just 1 page is 
passed to nr_pages in the most cases.

Thanks,
Yang

>
> -- Steve
>
>> +
>>   	/*
>>   	 * Disable interrupts.  We use the nested form as we can already have
>>   	 * interrupts disabled by get_futex_key.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
