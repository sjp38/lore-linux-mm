Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF336B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:46:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l81so3383089wmg.8
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 10:46:40 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id p64si1717421wmd.165.2017.06.29.10.46.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 10:46:39 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id 62so89390994wmw.1
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 10:46:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170627155035.GA20189@dhcp22.suse.cz>
References: <CAA25o9T1WmkWJn1LA-vS=W_Qu8pBw3rfMtTreLNu8fLuZjTDsw@mail.gmail.com>
 <20170627071104.GB28078@dhcp22.suse.cz> <CAA25o9T1q9gWzb0BeXY3mvLOth-ow=yjVuwD9ct5f1giBWo=XQ@mail.gmail.com>
 <CAA25o9TUkHd9w+DNBdH_4w6LTEEb+Q6QAycHcqx-z3mwh+G=kA@mail.gmail.com> <20170627155035.GA20189@dhcp22.suse.cz>
From: Luigi Semenzato <semenzato@google.com>
Date: Thu, 29 Jun 2017 10:46:37 -0700
Message-ID: <CAA25o9RL6ntbL9+ae11_AbGSZ7MNTNZv8yEW4jvZdMa-en+8ag@mail.gmail.com>
Subject: Re: OOM kills with lots of free swap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Well, my apologies, I haven't been able to reproduce the problem, so
there's nothing to go on here.

We had a bug (a local patch) which caused this, then I had a bug in my
test case, so I was confused.  I also have a recollection of this
happening in older kernels (3.8 I think), but I am not going to go
back that far since even if the problem exists, we have no evidence it
happens frequently.

Thanks!


On Tue, Jun 27, 2017 at 8:50 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 27-06-17 08:22:36, Luigi Semenzato wrote:
>> (sorry, I forgot to turn off HTML formatting)
>>
>> Thank you, I can try this on ToT, although I think that the problem is
>> not with the OOM killer itself but earlier---i.e. invoking the OOM
>> killer seems unnecessary and wrong.  Here's the question.
>>
>> The general strategy for page allocation seems to be (please correct
>> me as needed):
>>
>> 1. look in the free lists
>> 2. if that did not succeed, try to reclaim, then try again to allocate
>> 3. keep trying as long as progress is made (i.e. something was reclaimed)
>> 4. if no progress was made and no pages were found, invoke the OOM killer.
>
> Yes that is the case very broadly speaking. The hard question really is
> what "no progress" actually means. We use "no pages could be reclaimed"
> as the indicator. We cannot blow up at the first such instance of
> course because that could be too early (e.g. data under writeback
> and many other details). With 4.7+ kernels this is implemented in
> should_reclaim_retry. Prior to the rework we used to rely on
> zone_reclaimable which simply checked how many pages we have scanned
> since the last page has been freed and if that is 6 times the
> reclaimable memory then we simply give up. It had some issues described
> in 0a0337e0d1d1 ("mm, oom: rework oom detection").
>
>> I'd like to know if that "progress is made" notion is possibly buggy.
>> Specifically, does it mean "progress is made by this task"?  Is it
>> possible that resource contention creates a situation where most tasks
>> in most cases can reclaim and allocate, but one task randomly fails to
>> make progress?
>
> This can happen, alhtough it is quite unlikely. We are trying to
> throttle allocations but you can hardly fight a consistent badluck ;)
>
> In order to see what is going on in your particular case we need an oom
> report though.
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
