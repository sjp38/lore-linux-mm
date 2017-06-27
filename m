Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB3983296
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:22:39 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n124so5581607wmg.5
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:22:39 -0700 (PDT)
Received: from mail-wr0-x22f.google.com (mail-wr0-x22f.google.com. [2a00:1450:400c:c0c::22f])
        by mx.google.com with ESMTPS id 5si15208719wrz.303.2017.06.27.08.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 08:22:37 -0700 (PDT)
Received: by mail-wr0-x22f.google.com with SMTP id r103so161084451wrb.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:22:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9T1q9gWzb0BeXY3mvLOth-ow=yjVuwD9ct5f1giBWo=XQ@mail.gmail.com>
References: <CAA25o9T1WmkWJn1LA-vS=W_Qu8pBw3rfMtTreLNu8fLuZjTDsw@mail.gmail.com>
 <20170627071104.GB28078@dhcp22.suse.cz> <CAA25o9T1q9gWzb0BeXY3mvLOth-ow=yjVuwD9ct5f1giBWo=XQ@mail.gmail.com>
From: Luigi Semenzato <semenzato@google.com>
Date: Tue, 27 Jun 2017 08:22:36 -0700
Message-ID: <CAA25o9TUkHd9w+DNBdH_4w6LTEEb+Q6QAycHcqx-z3mwh+G=kA@mail.gmail.com>
Subject: Re: OOM kills with lots of free swap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

(sorry, I forgot to turn off HTML formatting)

Thank you, I can try this on ToT, although I think that the problem is
not with the OOM killer itself but earlier---i.e. invoking the OOM
killer seems unnecessary and wrong.  Here's the question.

The general strategy for page allocation seems to be (please correct
me as needed):

1. look in the free lists
2. if that did not succeed, try to reclaim, then try again to allocate
3. keep trying as long as progress is made (i.e. something was reclaimed)
4. if no progress was made and no pages were found, invoke the OOM killer.

I'd like to know if that "progress is made" notion is possibly buggy.
Specifically, does it mean "progress is made by this task"?  Is it
possible that resource contention creates a situation where most tasks
in most cases can reclaim and allocate, but one task randomly fails to
make progress?

On Tue, Jun 27, 2017 at 8:21 AM, Luigi Semenzato <semenzato@google.com> wrote:
> (copying Minchan because I just asked him the same question.)
>
> Thank you, I can try this on ToT, although I think that the problem is not
> with the OOM killer itself but earlier---i.e. invoking the OOM killer seems
> unnecessary and wrong.  Here's the question.
>
> The general strategy for page allocation seems to be (please correct me as
> needed):
>
> 1. look in the free lists
> 2. if that did not succeed, try to reclaim, then try again to allocate
> 3. keep trying as long as progress is made (i.e. something was reclaimed)
> 4. if no progress was made and no pages were found, invoke the OOM killer.
>
> I'd like to know if that "progress is made" notion is possibly buggy.
> Specifically, does it mean "progress is made by this task"?  Is it possible
> that resource contention creates a situation where most tasks in most cases
> can reclaim and allocate, but one task randomly fails to make progress?
>
>
> On Tue, Jun 27, 2017 at 12:11 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>
>> On Fri 23-06-17 16:29:39, Luigi Semenzato wrote:
>> > It is fairly easy to trigger OOM-kills with almost empty swap, by
>> > running several fast-allocating processes in parallel.  I can
>> > reproduce this on many 3.x kernels (I think I tried also on 4.4 but am
>> > not sure).  I am hoping this is a known problem.
>>
>> The oom detection code has been reworked considerably in 4.7 so I would
>> like to see whether your problem is still presenet with more up-to-date
>> kernels. Also an OOM report is really necessary to get any clue what
>> might have been going on.
>>
>> --
>> Michal Hocko
>> SUSE Labs
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
