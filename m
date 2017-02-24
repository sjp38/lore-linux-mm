Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 71F7E6B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 07:19:50 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id l6so9060532lfb.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 04:19:50 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id g76si4180451lfg.248.2017.02.24.04.19.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 04:19:48 -0800 (PST)
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
References: <20170222120121.12601-1-mhocko@kernel.org>
 <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
 <CA+_MTtzj9z3JEH528iTjAuNivKo9tNzAx9dwpAJo6U5kgf636g@mail.gmail.com>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <855e929a-a891-a435-8f75-3674d8a3e96d@sonymobile.com>
Date: Fri, 24 Feb 2017 13:19:46 +0100
MIME-Version: 1.0
In-Reply-To: <CA+_MTtzj9z3JEH528iTjAuNivKo9tNzAx9dwpAJo6U5kgf636g@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martijn Coenen <maco@google.com>, John Stultz <john.stultz@linaro.org>
Cc: Michal Hocko <mhocko@kernel.org>, Greg KH <gregkh@linuxfoundation.org>, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Todd Kjos <tkjos@google.com>, Android Kernel Team <kernel-team@android.com>, Rom Lemarchand <romlem@google.com>, Tim Murray <timmurray@google.com>

On 02/23/2017 09:36 PM, Martijn Coenen wrote:
> On Thu, Feb 23, 2017 at 9:24 PM, John Stultz <john.stultz@linaro.org> wrote:
>> So, just for context, Android does have a userland LMK daemon (using
>> the mempressure notifiers) as you mentioned, but unfortunately I'm
>> unaware of any devices that ship with that implementation.
> I've previously worked on enabling userspace lmkd for a previous
> release, but ran into some issues there (see below).
>
>> This is reportedly because while the mempressure notifiers provide a
>> the signal to userspace, the work the deamon then has to do to look up
>> per process memory usage, in order to figure out who is best to kill
>> at that point was too costly and resulted in poor device performance.
> In particular, mempressure requires memory cgroups to function, and we
> saw performance regressions due to the accounting done in mem cgroups.
> At the time we didn't have enough time left to solve this before the
> release, and we reverted back to kernel lmkd.
>
>> So for shipping Android devices, the LMK is still needed. However, its
>> not critical for basic android development, as the system will
>> function without it.
> It will function, but it most likely will perform horribly (as the
> page cache will be trashed to such a level that the system will be
> unusable).
>
>> Additionally I believe most vendors heavily
>> customize the LMK in their vendor tree, so the value of having it in
>> staging might be relatively low.
>>
>> It would be great however to get a discussion going here on what the
>> ulmkd needs from the kernel in order to efficiently determine who best
>> to kill, and how we might best implement that.
> The two main issues I think we need to address are:
> 1) Getting the right granularity of events from the kernel; I once
> tried to submit a patch upstream to address this:
> https://lkml.org/lkml/2016/2/24/582
> 2) Find out where exactly the memory cgroup overhead is coming from,
> and how to reduce it or work around it to acceptable levels for
> Android. This was also on 3.10, and maybe this has long been fixed or
> improved in more recent kernel versions.
>
> I don't have cycles to work on this now, but I'm happy to talk to
> whoever picks this up on the Android side.
I sent some patches that is different approach. It still uses shrinkers
but it has a kernel part that do the kill part better than the old one
but it does it the android way. The future for this is get it triggered
with other path's than slab shrinker. But we will not continue unless
we get google-android to be part of it. Hocko objected heavy on
the patches but seems not to see that we need something to
do the job before we can disconnect from shrinker.

> Thanks,
> Martijn
>
>> thanks
>> -john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
