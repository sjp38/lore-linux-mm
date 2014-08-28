Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id BCF616B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 20:27:11 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q107so54273qgd.33
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 17:27:11 -0700 (PDT)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id u4si3315722qcb.38.2014.08.27.17.27.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 17:27:11 -0700 (PDT)
Received: by mail-qc0-f180.google.com with SMTP id c9so53792qcz.25
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 17:27:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140828001719.GA14679@bbox>
References: <CAA25o9T+byVZjO5U8krW-hQAnx3jNrvARANtur82b2KFzYpELQ@mail.gmail.com>
	<20140827220955.GA26902@cerebellum.variantweb.net>
	<CAA25o9RVZGqZTBM6+sPXBfMB_b5ZHCjPWwdWVy_cB0_whiiQrw@mail.gmail.com>
	<20140828001719.GA14679@bbox>
Date: Wed, 27 Aug 2014 17:27:10 -0700
Message-ID: <CAA25o9Thamkp5HewMYepPTj+MqnkDUKArGE=QfXt0m2KAUVv9Q@mail.gmail.com>
Subject: Re: compaction of zspages
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, Slava Malyugin <slavamn@google.com>, Sonny Rao <sonnyrao@google.com>

On Wed, Aug 27, 2014 at 5:17 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hey Luigi,
>
> On Wed, Aug 27, 2014 at 04:25:52PM -0700, Luigi Semenzato wrote:
>> Thank you Seth!
>>
>> On Wed, Aug 27, 2014 at 3:09 PM, Seth Jennings <sjennings@variantweb.net> wrote:
>> > On Wed, Aug 27, 2014 at 02:42:52PM -0700, Luigi Semenzato wrote:
>> >> Hello Minchan and others,
>> >>
>> >> I just noticed that the data structures used by zsmalloc have the
>> >> potential to tie up memory unnecessarily.  I don't call it "leaking"
>> >> because that memory can be reused, but it's not necessarily returned
>> >> to the system upon freeing.
>> >
>> > Yes, this is a known condition in zsmalloc.
>
> Yeb, I discussed it with Seth and Dan two years ago but I didn't have
> a number how it's significat problem for real practice and no time to
> look at it.
>
>> >
>> > Compaction is not a simple as it seems because zsmalloc returns a handle
>> > to the user that encodes the pfn.  In order the implement a compaction
>> > system, there would need to be some notification method to the alert the
>> > user that their allocation has moved and provide a new handle so the
>> > user can update its structures.  This is very non-trivial and I'm not
>> > sure that it can be done safely (i.e.  without races).
>>
>> Since the handles are opaque, we can add a level of indirection
>> without affecting users.  Assuming that the overhead is tolerable, or
>> anyway less than what we're wasting now.  (For some definition of
>> "less".)
>
> Yeb, my idea was same.
> We could add indirection layer and it wouldn't be hard to implement.
> It would add a bit overhead for memory footprint and performance
> but I think it's is worth to try and see the result.

Well I don't even know if this is really a problem, so I'll try to
determine that first.

> I hope I'd really like to implement it.

I am not sure you mean what you wrote, but I hope so too! :-)

>>
>> I agree that notification + update would be a huge pain, not really acceptable.
>>
>> >
>> > I looked at it a while back and it would be a significant effort.
>> >
>> > And yes, if you could do such a thing, you would not want the compaction
>> > triggered by the shrinkers as the users of zsmalloc are only active
>> > under memory pressure.  Something like a periodic compaction kthread
>> > would be the best way (after two minutes of thinking about it).
>> >
>> > Seth
>> >
>> >
>> >>
>> >> I have no idea if this has any impact in practice, but I plan to run a
>> >> test in the near future.  Also, I am not sure that doing compaction in
>> >> the shrinkers (as planned according to a comment) is the best
>> >> approach, because the shrinkers won't be called unless there is
>> >> considerable pressure, but the compaction would be more effective when
>> >> there is less pressure.
>
> If we add the feature, basically, I'd like to open the interface(ex, zs_compact)
> to user because when we need to compact depends on user's usecase and then
> we could add up more smart things (ex, zs_set_auto_compaction(frag_ratio))
> based on it.

OK.

>> >>
>> >> Some more detail here:
>> >>
>> >> https://code.google.com/p/chromium/issues/detail?id=408221
>> >>
>> >> Should I open a bug on some other tracker?
>
> I don't think it's a bug, every allocator have a same problem(fragmentation).

Right, I don't think so either---we tend to use the term "bug" too
loosely,  Our bug tracker is really an issue tracker, including
feature requests, investigations, etc.

So, the ball is on my side.  I'll instrument the allocator and try to
get some numbers out of it, then I will let you know.  Thanks!

> Thanks for the report!
>
>> >>
>> >> Thank you very much!
>> >> Luigi
>> >>
>> >> --
>> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> >> the body to majordomo@kvack.org.  For more info on Linux MM,
>> >> see: http://www.linux-mm.org/ .
>> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
