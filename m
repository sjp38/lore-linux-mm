Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id DDA7A6B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 16:28:01 -0500 (EST)
Received: by pfdd184 with SMTP id d184so35977567pfd.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:28:01 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id qg7si15040581pac.163.2015.12.09.13.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 13:28:01 -0800 (PST)
Received: by pfu207 with SMTP id 207so36020237pfu.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:28:01 -0800 (PST)
Subject: Re: [PATCH v4 3/7] x86: mm/gup: add gup trace points
References: <1449682164-9933-1-git-send-email-yang.shi@linaro.org>
 <1449682164-9933-4-git-send-email-yang.shi@linaro.org>
 <20151209160749.250a2f56@gandalf.local.home>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <56689CDF.8060708@linaro.org>
Date: Wed, 9 Dec 2015 13:27:59 -0800
MIME-Version: 1.0
In-Reply-To: <20151209160749.250a2f56@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

On 12/9/2015 1:07 PM, Steven Rostedt wrote:
> On Wed,  9 Dec 2015 09:29:20 -0800
> Yang Shi <yang.shi@linaro.org> wrote:
>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: "H. Peter Anvin" <hpa@zytor.com>
>> Cc: x86@kernel.org
>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>> ---
>>   arch/x86/mm/gup.c | 7 +++++++
>>   1 file changed, 7 insertions(+)
>>
>> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
>> index ae9a37b..a96bcb7 100644
>> --- a/arch/x86/mm/gup.c
>> +++ b/arch/x86/mm/gup.c
>> @@ -12,6 +12,9 @@
>>
>>   #include <asm/pgtable.h>
>>
>> +#define CREATE_TRACE_POINTS
>> +#include <trace/events/gup.h>>
>
> First off, does the above even compile?
>
> Second, you already created the tracepoints in mm/gup.c, why are you
> creating them here again? CREATE_TRACE_POINTS must be defined only once
> per events/.h file.

Sorry for that. The typo was introduced by git amend without running 
test build. The multiple definition of trace points was not caught by my 
shaky test script.

Will fix them soon.

Thanks,
Yang

>
> -- Steve
>
>> +
>>   static inline pte_t gup_get_pte(pte_t *ptep)
>>   {
>>   #ifndef CONFIG_X86_PAE
>> @@ -270,6 +273,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>>   					(void __user *)start, len)))
>>   		return 0;
>>
>> +	trace_gup_get_user_pages_fast(start, nr_pages);
>> +
>>   	/*
>>   	 * XXX: batch / limit 'nr', to avoid large irq off latency
>>   	 * needs some instrumenting to determine the common sizes used by
>> @@ -373,6 +378,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>>   	} while (pgdp++, addr = next, addr != end);
>>   	local_irq_enable();
>>
>> +	trace_gup_get_user_pages_fast(start, nr_pages);
>> +
>>   	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
>>   	return nr;
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
