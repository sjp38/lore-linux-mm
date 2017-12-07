Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEBE56B0261
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 20:27:21 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v69so2681673wmd.2
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 17:27:21 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v196sor1343207wmf.71.2017.12.06.17.27.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Dec 2017 17:27:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171206152621.2c263569ea623dd1e0119848@linux-foundation.org>
References: <20171206192026.25133-1-surenb@google.com> <20171206152621.2c263569ea623dd1e0119848@linux-foundation.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Wed, 6 Dec 2017 17:27:19 -0800
Message-ID: <CAJuCfpHKMamMfw2SW0QnJv_bu4CYLgbHuL0nJ2kwPc8D+44K3w@mail.gmail.com>
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, Johannes Weiner <hannes@cmpxchg.org>, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>, Todd Kjos <tkjos@google.com>

>
> Some quantification of "quite time consuming" and "delay" would be
> interesting, please.
>

Unfortunately that depends on the implementation of the shrinkers
registered in the system including the ones from drivers. I've
captured traces showing delays of up to 100ms where the process with
pending SIGKILL is in direct memory reclaim and signal handling is
delayed because of that. I realize that it's not the fault of
shrink_slab_lmk() that some shrinkers take long time to shrink their
slabs (sometimes because of justifiable reasons and sometimes because
of a bug which has to be fixed) but this can be a safeguard against
such cases.
Couple shrinker examples that I found most time consuming are (most of
that 100ms delay is the result of the first two ones):

https://patchwork.kernel.org/patch/10096641/
The patch fixes dm-bufio shrinker which in certain conditions reclaims
only one buffer per scan making the shrinking process very
inefficient.

https://android.googlesource.com/kernel/msm/+/android-7.1.0_r0.2/drivers/gpu/msm/kgsl_pool.c#420
This example is from a driver where shrinker returns 0 instead of
SHRINK_STOP when it's unable to reclaim anymore. As a result when
total_scan in do_shrink_slab() is large this will cause multiple
scan_objects() calls with no memory being reclaimed. Patch for this
one is under review by the owners.

Shrinker that seems to be justifiably heavy is super_cache_scan()
inside fs/super.c. I have traces where it takes up to 4ms to complete.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
