Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2AB6B006E
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 12:18:02 -0400 (EDT)
Received: by mail-yk0-f172.google.com with SMTP id 19so1289225ykq.31
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 09:18:02 -0700 (PDT)
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
        by mx.google.com with ESMTPS id o40si7336801yha.159.2014.10.02.09.18.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 09:18:01 -0700 (PDT)
Received: by mail-yk0-f171.google.com with SMTP id 79so1334165ykr.30
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 09:18:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141002121902.GA2342@redhat.com>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
	<1411740233-28038-2-git-send-email-steve.capper@linaro.org>
	<20141002121902.GA2342@redhat.com>
Date: Thu, 2 Oct 2014 23:18:00 +0700
Message-ID: <CAPvkgC3VkmctmD9dROqkAEwi-Njm9zQqVx1=Byttr5_n-J7wYw@mail.gmail.com>
Subject: Re: [PATCH V4 1/6] mm: Introduce a general RCU get_user_pages_fast.
From: Steve Capper <steve.capper@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Gary Robertson <gary.robertson@linaro.org>, Christoffer Dall <christoffer.dall@linaro.org>, Peter Zijlstra <peterz@infradead.org>, Anders Roxell <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Dann Frazier <dann.frazier@canonical.com>, Mark Rutland <mark.rutland@arm.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On 2 October 2014 19:19, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hi Steve,
>

Hi Andrea,

> On Fri, Sep 26, 2014 at 03:03:48PM +0100, Steve Capper wrote:
>> This patch provides a general RCU implementation of get_user_pages_fast
>> that can be used by architectures that perform hardware broadcast of
>> TLB invalidations.
>>
>> It is based heavily on the PowerPC implementation by Nick Piggin.
>
> It'd be nice if you could also at the same time apply it to sparc and
> powerpc in this same patchset to show the effectiveness of having a
> generic version. Because if it's not a trivial drop-in replacement,
> then this should go in arch/arm* instead of mm/gup.c...

I think it should be adapted (if need be) and adopted for sparc, power
and others, especially as it will result in a reduction in code size
and make future alterations to gup easier.
I would prefer to get this in iteratively; and have people who are
knowledgeable of those architectures and have a means of testing the
code thoroughly to help out. (it will be very hard for me to implement
this on my own, but likely trivial for people who know and can test
those architectures).

>
> Also I wonder if it wouldn't be better to add it to mm/util.c along
> with the __weak gup_fast but then this is ok too. I'm just saying
> because we never had sings of gup_fast code in mm/gup.c so far but
> then this isn't exactly a __weak version of it... so I don't mind
> either ways.

mm/gup.c was recently created?
It may even make sense to move the weak version in a future patch?

>
>> +             down_read(&mm->mmap_sem);
>> +             ret = get_user_pages(current, mm, start,
>> +                                  nr_pages - nr, write, 0, pages, NULL);
>> +             up_read(&mm->mmap_sem);
>
> This has a collision with a patchset I posted, but it's trivial to
> solve, the above three lines need to be replaced with:
>
> +               ret = get_user_pages_unlocked(current, mm, start,
> +                                    nr_pages - nr, write, 0, pages);
>
> And then arm gup_fast will also page fault with FOLL_FAULT_ALLOW_RETRY
> the first time to release the mmap_sem before I/O.
>

Ahh thanks.
I'm currently on holiday and have very limited access to email, I'd
appreciate it if someone can keep an eye out for this during the merge
window if this conflict arises?

> Thanks,
> Andrea

Cheers,
--
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
