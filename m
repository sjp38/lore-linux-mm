Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2786B0387
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 15:36:02 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id q66so4167540oib.0
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 12:36:02 -0800 (PST)
Received: from mail-it0-x230.google.com (mail-it0-x230.google.com. [2607:f8b0:4001:c0b::230])
        by mx.google.com with ESMTPS id y16si5793111ioy.93.2017.02.23.12.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 12:36:01 -0800 (PST)
Received: by mail-it0-x230.google.com with SMTP id 203so14230853ith.0
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 12:36:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
References: <20170222120121.12601-1-mhocko@kernel.org> <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
From: Martijn Coenen <maco@google.com>
Date: Thu, 23 Feb 2017 21:36:00 +0100
Message-ID: <CA+_MTtzj9z3JEH528iTjAuNivKo9tNzAx9dwpAJo6U5kgf636g@mail.gmail.com>
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Michal Hocko <mhocko@kernel.org>, Greg KH <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Todd Kjos <tkjos@google.com>, Android Kernel Team <kernel-team@android.com>, Rom Lemarchand <romlem@google.com>, Tim Murray <timmurray@google.com>

On Thu, Feb 23, 2017 at 9:24 PM, John Stultz <john.stultz@linaro.org> wrote:
>
> So, just for context, Android does have a userland LMK daemon (using
> the mempressure notifiers) as you mentioned, but unfortunately I'm
> unaware of any devices that ship with that implementation.

I've previously worked on enabling userspace lmkd for a previous
release, but ran into some issues there (see below).

> This is reportedly because while the mempressure notifiers provide a
> the signal to userspace, the work the deamon then has to do to look up
> per process memory usage, in order to figure out who is best to kill
> at that point was too costly and resulted in poor device performance.

In particular, mempressure requires memory cgroups to function, and we
saw performance regressions due to the accounting done in mem cgroups.
At the time we didn't have enough time left to solve this before the
release, and we reverted back to kernel lmkd.

>
> So for shipping Android devices, the LMK is still needed. However, its
> not critical for basic android development, as the system will
> function without it.

It will function, but it most likely will perform horribly (as the
page cache will be trashed to such a level that the system will be
unusable).

>Additionally I believe most vendors heavily
> customize the LMK in their vendor tree, so the value of having it in
> staging might be relatively low.
>
> It would be great however to get a discussion going here on what the
> ulmkd needs from the kernel in order to efficiently determine who best
> to kill, and how we might best implement that.

The two main issues I think we need to address are:
1) Getting the right granularity of events from the kernel; I once
tried to submit a patch upstream to address this:
https://lkml.org/lkml/2016/2/24/582
2) Find out where exactly the memory cgroup overhead is coming from,
and how to reduce it or work around it to acceptable levels for
Android. This was also on 3.10, and maybe this has long been fixed or
improved in more recent kernel versions.

I don't have cycles to work on this now, but I'm happy to talk to
whoever picks this up on the Android side.

Thanks,
Martijn

>
> thanks
> -john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
