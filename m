Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A6703681034
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 09:12:52 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u143so50898856oif.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:12:52 -0800 (PST)
Received: from mail-ot0-x22c.google.com (mail-ot0-x22c.google.com. [2607:f8b0:4003:c0f::22c])
        by mx.google.com with ESMTPS id p84si4888854oig.259.2017.02.17.06.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 06:12:51 -0800 (PST)
Received: by mail-ot0-x22c.google.com with SMTP id 45so32017019otd.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:12:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CADZGycbxtoXXxCeg-nHjzGmHA72VnA=-td+hNaNqN67Vq2JuKg@mail.gmail.com>
References: <20170211021829.9646-1-richard.weiyang@gmail.com>
 <20170211021829.9646-2-richard.weiyang@gmail.com> <20170211022400.GA19050@mtj.duckdns.org>
 <CADZGycbxtoXXxCeg-nHjzGmHA72VnA=-td+hNaNqN67Vq2JuKg@mail.gmail.com>
From: Wei Yang <richard.weiyang@gmail.com>
Date: Fri, 17 Feb 2017 22:12:31 +0800
Message-ID: <CADZGycapTYxdxwHacFYiECZQ23uPDARQcahw_9zuKrNu-wG63g@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm/sparse: add last_section_nr in sparse_init()
 to reduce some iteration cycle
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 13, 2017 at 9:03 PM, Wei Yang <richard.weiyang@gmail.com> wrote:
> On Sat, Feb 11, 2017 at 10:24 AM, Tejun Heo <tj@kernel.org> wrote:
>>
>> Hello,
>>
>
> Hi, Tejun
>
> Sorry for the delay, my gmail client seems to facing some problem.
> I can't see latest mails. So I have to use the web client and reply.
>
>> On Sat, Feb 11, 2017 at 10:18:29AM +0800, Wei Yang wrote:
>> > During the sparse_init(), it iterate on each possible section. On x86_64,
>> > it would always be (2^19) even there is not much memory. For example, on a
>> > typical 4G machine, it has only (2^5) to (2^6) present sections. This
>> > benefits more on a system with smaller memory.
>> >
>> > This patch calculates the last section number from the highest pfn and use
>> > this as the boundary of iteration.
>>
>> * How much does this actually matter?  Can you measure the impact?
>>
>
> Hmm, I tried to print the "jiffies", while it is not ready at that moment. So
> I mimic the behavior in user space.
>
> I used following code for test.
>
> #include <stdio.h>
> #include <stdlib.h>
>
> int array[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
>
> int main()
> {
> unsigned long i;
> int val;
>
>     for (i = 0; i < (1UL << 5); i++)
>         val += array[i%10];
>     for (i = 0; i < (1UL << 5); i++)
>         val += array[i%10];
>     for (i = 0; i < (1UL << 5); i++)
>         val += array[i%10];
>
>     //printf("%lx %d\n", i, val);
>
>     return 0;
> }
>
> And compare the ruling with the iteration for the loop to be (1UL <<
> 5) and (1UL << 19).
> The runtime is 0.00s and 0.04s respectively. The absolute value is not much.
>

Hi, Tejun

What's your opinion on this change?

>> * Do we really need to add full reverse iterator to just get the
>>   highest section number?
>>
>
> You are right. After I sent out the mail, I realized just highest pfn
> is necessary.
>
>> Thanks.
>>
>> --
>> tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
