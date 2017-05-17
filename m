Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2257A6B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 03:26:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e131so3242370pfh.7
        for <linux-mm@kvack.org>; Wed, 17 May 2017 00:26:02 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id o1si1326037pgf.14.2017.05.17.00.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 00:26:01 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id w69so739270pfk.1
        for <linux-mm@kvack.org>; Wed, 17 May 2017 00:26:01 -0700 (PDT)
Date: Wed, 17 May 2017 16:25:54 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Message-ID: <20170517072552.GB18406@js1304-desktop>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
 <20170516062318.GC16015@js1304-desktop>
 <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
 <20170517072315.GA18406@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170517072315.GA18406@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Wed, May 17, 2017 at 04:23:17PM +0900, Joonsoo Kim wrote:
> > However, I see some very significant slowdowns with inline
> > instrumentation. I did 3 tests:
> > 1. Boot speed, I measured time for a particular message to appear on
> > console. Before:
> > [    2.504652] random: crng init done
> > [    2.435861] random: crng init done
> > [    2.537135] random: crng init done
> > After:
> > [    7.263402] random: crng init done
> > [    7.263402] random: crng init done
> > [    7.174395] random: crng init done
> > 
> > That's ~3x slowdown.
> > 
> > 2. I've run bench_readv benchmark:
> > https://raw.githubusercontent.com/google/sanitizers/master/address-sanitizer/kernel_buildbot/slave/bench_readv.c
> > as:
> > while true; do time ./bench_readv bench_readv 300000 1; done
> > 
> > Before:
> > sys 0m7.299s
> > sys 0m7.218s
> > sys 0m6.973s
> > sys 0m6.892s
> > sys 0m7.035s
> > sys 0m6.982s
> > sys 0m6.921s
> > sys 0m6.940s
> > sys 0m6.905s
> > sys 0m7.006s
> > 
> > After:
> > sys 0m8.141s
> > sys 0m8.077s
> > sys 0m8.067s
> > sys 0m8.116s
> > sys 0m8.128s
> > sys 0m8.115s
> > sys 0m8.108s
> > sys 0m8.326s
> > sys 0m8.529s
> > sys 0m8.164s
> > sys 0m8.380s
> > 
> > This is ~19% slowdown.
> > 
> > 3. I've run bench_pipes benchmark:
> > https://raw.githubusercontent.com/google/sanitizers/master/address-sanitizer/kernel_buildbot/slave/bench_pipes.c
> > as:
> > while true; do time ./bench_pipes 10 10000 1; done
> > 
> > Before:
> > sys 0m5.393s
> > sys 0m6.178s
> > sys 0m5.909s
> > sys 0m6.024s
> > sys 0m5.874s
> > sys 0m5.737s
> > sys 0m5.826s
> > sys 0m5.664s
> > sys 0m5.758s
> > sys 0m5.421s
> > sys 0m5.444s
> > sys 0m5.479s
> > sys 0m5.461s
> > sys 0m5.417s
> > 
> > After:
> > sys 0m8.718s
> > sys 0m8.281s
> > sys 0m8.268s
> > sys 0m8.334s
> > sys 0m8.246s
> > sys 0m8.267s
> > sys 0m8.265s
> > sys 0m8.437s
> > sys 0m8.228s
> > sys 0m8.312s
> > sys 0m8.556s
> > sys 0m8.680s
> > 
> > This is ~52% slowdown.
> > 
> > 
> > This does not look acceptable to me. I would ready to pay for this,
> > say, 10% of performance. But it seems that this can have up to 2-4x
> > slowdown for some workloads.
> 
> I found the reasons of above regression. There are two reasons.
> 
> 1. In my implementation, original shadow to the memory allocated from
> memblock is black shadow so it causes to call kasan_report(). It will
> pass the check since per page shadow would be zero shadow but it
> causes some overhead.
> 
> 2. Memory used by stackdepot is in a similar situation with #1. It
> allocates page and divide it to many objects. Then, use it like as
> object. Although there is "KASAN_SANITIZE_stackdepot.o := n" which try
> to disable sanitizer, there is a function call (memcmp() in
> find_stack()) to other file and sanitizer work for it.
> 
> #1 problem can be fixed but more investigation is needed. I will
> respin the series after fixing it.
> 
> #2 problem also can be fixed. There are two options here. First, uses
> private memcmp() for stackdepot and disable sanitizer for it. I think
> that this is a right approach since it slowdown the performance in all
> KASAN build cases. And, we don't want to sanitize KASAN itself.
> Second, I can provide a function to map the actual shadow manually. It
> will reduce the case calling kasan_report().
> 
> See the attached patch. It implements later approach on #2 problem.
> It would reduce performance regression. I have tested your bench_pipes
> test with it and found that performance is restored. However, there is
> still remaining problem, #1, so I'm not sure that it completely
> restore your regression. Could you check that if possible?
> 
Oops... I missed to attach the patch.

Thanks.

--------------------->8-------------------
