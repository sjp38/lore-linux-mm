Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id D321D6B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 08:04:02 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id j49so141148021otb.7
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:04:02 -0800 (PST)
Received: from mail-ot0-x241.google.com (mail-ot0-x241.google.com. [2607:f8b0:4003:c0f::241])
        by mx.google.com with ESMTPS id c68si4627121oih.308.2017.02.13.05.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 05:04:02 -0800 (PST)
Received: by mail-ot0-x241.google.com with SMTP id f9so11199823otd.0
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:04:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170211022400.GA19050@mtj.duckdns.org>
References: <20170211021829.9646-1-richard.weiyang@gmail.com>
 <20170211021829.9646-2-richard.weiyang@gmail.com> <20170211022400.GA19050@mtj.duckdns.org>
From: Wei Yang <richard.weiyang@gmail.com>
Date: Mon, 13 Feb 2017 21:03:41 +0800
Message-ID: <CADZGycbxtoXXxCeg-nHjzGmHA72VnA=-td+hNaNqN67Vq2JuKg@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm/sparse: add last_section_nr in sparse_init()
 to reduce some iteration cycle
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Feb 11, 2017 at 10:24 AM, Tejun Heo <tj@kernel.org> wrote:
>
> Hello,
>

Hi, Tejun

Sorry for the delay, my gmail client seems to facing some problem.
I can't see latest mails. So I have to use the web client and reply.

> On Sat, Feb 11, 2017 at 10:18:29AM +0800, Wei Yang wrote:
> > During the sparse_init(), it iterate on each possible section. On x86_64,
> > it would always be (2^19) even there is not much memory. For example, on a
> > typical 4G machine, it has only (2^5) to (2^6) present sections. This
> > benefits more on a system with smaller memory.
> >
> > This patch calculates the last section number from the highest pfn and use
> > this as the boundary of iteration.
>
> * How much does this actually matter?  Can you measure the impact?
>

Hmm, I tried to print the "jiffies", while it is not ready at that moment. So
I mimic the behavior in user space.

I used following code for test.

#include <stdio.h>
#include <stdlib.h>

int array[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

int main()
{
unsigned long i;
int val;

    for (i = 0; i < (1UL << 5); i++)
        val += array[i%10];
    for (i = 0; i < (1UL << 5); i++)
        val += array[i%10];
    for (i = 0; i < (1UL << 5); i++)
        val += array[i%10];

    //printf("%lx %d\n", i, val);

    return 0;
}

And compare the ruling with the iteration for the loop to be (1UL <<
5) and (1UL << 19).
The runtime is 0.00s and 0.04s respectively. The absolute value is not much.

> * Do we really need to add full reverse iterator to just get the
>   highest section number?
>

You are right. After I sent out the mail, I realized just highest pfn
is necessary.

> Thanks.
>
> --
> tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
