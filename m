Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id C511C828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 03:39:10 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id gc3so55273443obb.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 00:39:10 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id f202si7806432oig.14.2016.02.18.00.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 00:39:10 -0800 (PST)
Received: by mail-ob0-x235.google.com with SMTP id xk3so56263297obc.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 00:39:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
References: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
Date: Thu, 18 Feb 2016 17:39:10 +0900
Message-ID: <CAAmzW4MQYtWtCwhPF9VSQdK=rcy0t1-hThNNu9fBduS395J6iA@mail.gmail.com>
Subject: Re: [PATCHv2 0/4] Improve performance for SLAB_POISON
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

2016-02-16 3:44 GMT+09:00 Laura Abbott <labbott@fedoraproject.org>:
> Hi,
>
> This is a follow up to my previous series
> (http://lkml.kernel.org/g/<1453770913-32287-1-git-send-email-labbott@fedoraproject.org>)
> This series takes the suggestion of Christoph Lameter and only focuses on
> optimizing the slow path where the debug processing runs. The two main
> optimizations in this series are letting the consistency checks be skipped and
> relaxing the cmpxchg restrictions when we are not doing consistency checks.
> With hackbench -g 20 -l 1000 averaged over 100 runs:
>
> Before slub_debug=P
> mean 15.607
> variance .086
> stdev .294
>
> After slub_debug=P
> mean 10.836
> variance .155
> stdev .394
>
> This still isn't as fast as what is in grsecurity unfortunately so there's still
> work to be done. Profiling ___slab_alloc shows that 25-50% of time is spent in
> deactivate_slab. I haven't looked too closely to see if this is something that
> can be optimized.

There is something to be optimized. deactivate_slab() deactivate objects of
freelist one by one and it's useless. And, it deactivates freelist
with two phases.
Deactivating objects except last one and then deactivating last object with
node lock. It would be also optimized although I didn't think deeply.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
