Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9D96B0012
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:53:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g22so2659065pgv.16
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:53:47 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id i131si2955364pgc.347.2018.03.21.09.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 09:53:46 -0700 (PDT)
Subject: Re: [RFC PATCH 7/8] x86: mpx: pass atomic parameter to do_munmap()
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-8-git-send-email-yang.shi@linux.alibaba.com>
 <alpine.DEB.2.21.1803202307330.1714@nanos.tec.linutronix.de>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <8d2b26b6-b40a-cef8-9d67-afb8c12ad359@linux.alibaba.com>
Date: Wed, 21 Mar 2018 09:53:36 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1803202307330.1714@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>, x86@kernel.org



On 3/20/18 3:35 PM, Thomas Gleixner wrote:
> On Wed, 21 Mar 2018, Yang Shi wrote:
>
> Please CC everyone involved on the full patch set next time. I had to dig
> the rest out from my lkml archive to get the context.

Sorry for the inconvenience. Will pay attention to it next time.

>
>> Pass "true" to do_munmap() to not do unlock/relock to mmap_sem when
>> manipulating mpx map.
>> This is API change only.
> This is wrong. You cannot change the function in one patch and then clean
> up the users. That breaks bisectability.
>
> Depending on the number of callers this wants to be a single patch changing
> both the function and the callers or you need to create a new function
> which has the extra argument and switch all users over to it and then
> remove the old function.
>
>> @@ -780,7 +780,7 @@ static int unmap_entire_bt(struct mm_struct *mm,
>>   	 * avoid recursion, do_munmap() will check whether it comes
>>   	 * from one bounds table through VM_MPX flag.
>>   	 */
>> -	return do_munmap(mm, bt_addr, mpx_bt_size_bytes(mm), NULL);
>> +	return do_munmap(mm, bt_addr, mpx_bt_size_bytes(mm), NULL, true);
> But looking at the full context this is the wrong approach.
>
> First of all the name of that parameter 'atomic' is completely
> misleading. It suggests that this happens in fully atomic context, which is
> not the case.
>
> Secondly, conditional locking is frowned upon in general and rightfully so.
>
> So the right thing to do is to leave do_munmap() alone and add a new
> function do_munmap_huge() or whatever sensible name you come up with. Then
> convert the places which are considered to be safe one by one with a proper
> changelog which explains WHY this is safe.
>
> That way you avoid the chasing game of all existing do_munmap() callers and
> just use the new 'free in chunks' approach where it is appropriate and
> safe. No suprises, no bisectability issues....
>
> While at it please add proper kernel doc documentation to both do_munmap()
> and the new function which explains the intricacies.

Thanks a lot for the suggestion. Absolutely agree. Will fix the problems 
in newer version.

Yang

>
> Thanks,
>
> 	tglx
