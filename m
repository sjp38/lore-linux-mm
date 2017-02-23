Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF726B0387
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 15:25:00 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 203so8581540ith.3
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 12:25:00 -0800 (PST)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id g73si5733597ioi.199.2017.02.23.12.24.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 12:24:59 -0800 (PST)
Received: by mail-it0-x243.google.com with SMTP id 203so2065285ith.2
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 12:24:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170222120121.12601-1-mhocko@kernel.org>
References: <20170222120121.12601-1-mhocko@kernel.org>
From: John Stultz <john.stultz@linaro.org>
Date: Thu, 23 Feb 2017 12:24:57 -0800
Message-ID: <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Todd Kjos <tkjos@google.com>, Android Kernel Team <kernel-team@android.com>, Martijn Coenen <maco@google.com>, Rom Lemarchand <romlem@google.com>

On Wed, Feb 22, 2017 at 4:01 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> Lowmemory killer is sitting in the staging tree since 2008 without any
> serious interest for fixing issues brought up by the MM folks. The main
> objection is that the implementation is basically broken by design:
>         - it hooks into slab shrinker API which is not suitable for this
>           purpose. lowmem_count implementation just shows this nicely.
>           There is no scaling based on the memory pressure and no
>           feedback to the generic shrinker infrastructure.
>           Moreover lowmem_scan is called way too often for the heavy
>           work it performs.
>         - it is not reclaim context aware - no NUMA and/or memcg
>           awareness.
>
> As the code stands right now it just adds a maintenance overhead when
> core MM changes have to update lowmemorykiller.c as well. It also seems
> that the alternative LMK implementation will be solely in the userspace
> so this code has no perspective it seems. The staging tree is supposed
> to be for a code which needs to be put in shape before it can be merged
> which is not the case here obviously.

So, just for context, Android does have a userland LMK daemon (using
the mempressure notifiers) as you mentioned, but unfortunately I'm
unaware of any devices that ship with that implementation.

This is reportedly because while the mempressure notifiers provide a
the signal to userspace, the work the deamon then has to do to look up
per process memory usage, in order to figure out who is best to kill
at that point was too costly and resulted in poor device performance.

So for shipping Android devices, the LMK is still needed. However, its
not critical for basic android development, as the system will
function without it. Additionally I believe most vendors heavily
customize the LMK in their vendor tree, so the value of having it in
staging might be relatively low.

It would be great however to get a discussion going here on what the
ulmkd needs from the kernel in order to efficiently determine who best
to kill, and how we might best implement that.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
