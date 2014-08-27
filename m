Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 91FB46B0039
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:25:53 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id r2so115792igi.0
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:25:53 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id vd3si2375977icb.3.2014.08.27.16.25.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 16:25:53 -0700 (PDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so288014igb.17
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:25:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140827220955.GA26902@cerebellum.variantweb.net>
References: <CAA25o9T+byVZjO5U8krW-hQAnx3jNrvARANtur82b2KFzYpELQ@mail.gmail.com>
	<20140827220955.GA26902@cerebellum.variantweb.net>
Date: Wed, 27 Aug 2014 16:25:52 -0700
Message-ID: <CAA25o9RVZGqZTBM6+sPXBfMB_b5ZHCjPWwdWVy_cB0_whiiQrw@mail.gmail.com>
Subject: Re: compaction of zspages
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Slava Malyugin <slavamn@google.com>, Sonny Rao <sonnyrao@google.com>

Thank you Seth!

On Wed, Aug 27, 2014 at 3:09 PM, Seth Jennings <sjennings@variantweb.net> wrote:
> On Wed, Aug 27, 2014 at 02:42:52PM -0700, Luigi Semenzato wrote:
>> Hello Minchan and others,
>>
>> I just noticed that the data structures used by zsmalloc have the
>> potential to tie up memory unnecessarily.  I don't call it "leaking"
>> because that memory can be reused, but it's not necessarily returned
>> to the system upon freeing.
>
> Yes, this is a known condition in zsmalloc.
>
> Compaction is not a simple as it seems because zsmalloc returns a handle
> to the user that encodes the pfn.  In order the implement a compaction
> system, there would need to be some notification method to the alert the
> user that their allocation has moved and provide a new handle so the
> user can update its structures.  This is very non-trivial and I'm not
> sure that it can be done safely (i.e.  without races).

Since the handles are opaque, we can add a level of indirection
without affecting users.  Assuming that the overhead is tolerable, or
anyway less than what we're wasting now.  (For some definition of
"less".)

I agree that notification + update would be a huge pain, not really acceptable.

>
> I looked at it a while back and it would be a significant effort.
>
> And yes, if you could do such a thing, you would not want the compaction
> triggered by the shrinkers as the users of zsmalloc are only active
> under memory pressure.  Something like a periodic compaction kthread
> would be the best way (after two minutes of thinking about it).
>
> Seth
>
>
>>
>> I have no idea if this has any impact in practice, but I plan to run a
>> test in the near future.  Also, I am not sure that doing compaction in
>> the shrinkers (as planned according to a comment) is the best
>> approach, because the shrinkers won't be called unless there is
>> considerable pressure, but the compaction would be more effective when
>> there is less pressure.
>>
>> Some more detail here:
>>
>> https://code.google.com/p/chromium/issues/detail?id=408221
>>
>> Should I open a bug on some other tracker?
>>
>> Thank you very much!
>> Luigi
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
