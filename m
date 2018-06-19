Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5545E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:32:59 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o10-v6so378970qtm.7
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 10:32:59 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0125.outbound.protection.outlook.com. [104.47.1.125])
        by mx.google.com with ESMTPS id s124-v6si228385qkh.299.2018.06.19.10.32.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Jun 2018 10:32:58 -0700 (PDT)
Subject: Re: Possible regression in "slab, slub: skip unnecessary
 kasan_cache_shutdown()"
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <46ca5661-4bd1-6733-0140-d6e6dea1ab33@virtuozzo.com>
Date: Tue, 19 Jun 2018 20:34:22 +0300
MIME-Version: 1.0
In-Reply-To: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>



On 06/19/2018 05:51 AM, Jason A. Donenfeld wrote:
> Hello Shakeel,
> 
> It may be the case that f9e13c0a5a33d1eaec374d6d4dab53a4f72756a0 has
> introduced a regression. I've bisected a failing test to this commit,
> and after staring at the my code for a long time, I'm unable to find a
> bug that this commit might have unearthed. Rather, it looks like this
> commit introduces a performance optimization, rather than a
> correctness fix, so it seems that whatever test case is failing is
> likely an incorrect failure. Does that seem like an accurate
> possibility to you?
> 
> Below is a stack trace when things go south. Let me know if you'd like
> to run my test suite, and I can send additional information.
> 
> Regards,
> Jason
> 
> 

What's the status of CONFIG_SLUB_DEBUG in your config?

AFAICS __kmem_cache_empty() is broken for CONFIG_SLUB_DEBUG=n. We use slabs_node() there
which is always 0 for CONFIG_SLUB_DEBUG=n.

The problem seems not limited to __kmem_cache_empty(), __kmem_cache_shutdown() and __kmem_cache_shrink()
are also rely on correctness of the slabs_node(). Presumably this might cause some problems while
destroying memcg kmem caches.
