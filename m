Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0526B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 16:17:39 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c1-v6so762504qtj.6
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:17:39 -0700 (PDT)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id 14-v6si575553qkf.324.2018.06.19.13.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 13:17:38 -0700 (PDT)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id aa5bcfbd
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 20:11:43 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 734f4933 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 20:11:42 +0000 (UTC)
Received: by mail-ot0-f182.google.com with SMTP id 101-v6so1145982oth.4
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:17:37 -0700 (PDT)
MIME-Version: 1.0
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
 <46ca5661-4bd1-6733-0140-d6e6dea1ab33@virtuozzo.com>
In-Reply-To: <46ca5661-4bd1-6733-0140-d6e6dea1ab33@virtuozzo.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 19 Jun 2018 22:17:25 +0200
Message-ID: <CAHmME9qqsgz2faVP8FTbJvKTzX-5qQU1aHGbkzT6b05PZ4nkuw@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

Hi Andrey,

On Tue, Jun 19, 2018 at 7:33 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> What's the status of CONFIG_SLUB_DEBUG in your config?
>
> AFAICS __kmem_cache_empty() is broken for CONFIG_SLUB_DEBUG=n. We use slabs_node() there
> which is always 0 for CONFIG_SLUB_DEBUG=n.
>
> The problem seems not limited to __kmem_cache_empty(), __kmem_cache_shutdown() and __kmem_cache_shrink()
> are also rely on correctness of the slabs_node(). Presumably this might cause some problems while
> destroying memcg kmem caches.

CONFIG_SLUB_DEBUG is not set in the crash I sent.

Enabling it "fixes" the problem! This either means that KASAN+SLUB
should enable SLUB_DEBUG, or the extra overhead from SLUB_DEBUG is
just making the bug more rare but not actually eliminating it.

Jason
