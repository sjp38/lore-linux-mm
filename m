Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id D4A686B00AF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 23:19:29 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id q108so11724681qgd.35
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 20:19:29 -0800 (PST)
Received: from mail-qc0-x22d.google.com (mail-qc0-x22d.google.com. [2607:f8b0:400d:c01::22d])
        by mx.google.com with ESMTPS id l9si4252572qae.53.2014.11.04.20.19.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 20:19:29 -0800 (PST)
Received: by mail-qc0-f173.google.com with SMTP id x3so12109031qcv.18
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 20:19:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <xa1tlhnq7ga7.fsf@mina86.com>
References: <CADtm3G7DtGkvPk36Fiunwen8grw-94V6=iv82iusGumfNJkn-g@mail.gmail.com>
 <xa1tlhnq7ga7.fsf@mina86.com>
From: Gregory Fong <gregory.0xf0@gmail.com>
Date: Tue, 4 Nov 2014 20:18:58 -0800
Message-ID: <CADtm3G7bU6Y2aKco5Vb81KSqsy=FH9zmdDJm=Tixjoep1YeJ7Q@mail.gmail.com>
Subject: Re: CMA alignment question
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-mm@kvack.org, Laura Abbott <lauraa@codeaurora.org>, iamjoonsoo.kim@lge.com, Marek Szyprowski <m.szyprowski@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>, Brian Norris <computersforpeace@gmail.com>

On Tue, Nov 4, 2014 at 2:27 PM, Michal Nazarewicz <mina86@mina86.com> wrote:
> On Tue, Nov 04 2014, Gregory Fong wrote:
>> The alignment in cma_alloc() is done w.r.t. the bitmap.  This is a
>> problem when, for example:
>>
>> - a device requires 16M (order 12) alignment
>> - the CMA region is not 16 M aligned
>>
>> In such a case, can result with the CMA region starting at, say,
>> 0x2f800000 but any allocation you make from there will be aligned from
>> there.  Requesting an allocation of 32 M with 16 M alignment, will
>> result in an allocation from 0x2f800000 to 0x31800000, which doesn't
>> work very well if your strange device requires 16M alignment.
>>
>> This doesn't have the behavior I would expect, which would be for the
>> allocation to be aligned w.r.t. the start of memory.  I realize that
>> aligning the CMA region is an option, but don't see why cma_alloc()
>> aligns to the start of the CMA region.  Is there a good reason for
>> having cma_alloc() alignment work this way?
>
> No, it's a bug.  The alignment should indicate alignment of physical
> address not position in CMA region.
>

Ah, now I see that Marek submitted this patch from you back in 2011
that would have allowed the bitmap lib to support an alignment offset:
http://thread.gmane.org/gmane.linux.kernel/1121103/focus=1121100

Any idea why this didn't make it into the later changesets?  If not,
I'll resubmit it and to use it to fix this bug.

Thanks,
Gregory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
