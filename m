Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C47D6B0038
	for <linux-mm@kvack.org>; Tue, 16 May 2017 02:23:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e8so118539460pfl.4
        for <linux-mm@kvack.org>; Mon, 15 May 2017 23:23:29 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id v1si13383691pge.1.2017.05.15.23.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 23:23:28 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id f27so8408519pfe.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 23:23:28 -0700 (PDT)
Date: Tue, 16 May 2017 15:23:21 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Message-ID: <20170516062318.GC16015@js1304-desktop>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Mon, May 15, 2017 at 09:34:17PM -0700, Dmitry Vyukov wrote:
> On Mon, May 15, 2017 at 6:16 PM,  <js1304@gmail.com> wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > Hello, all.
> >
> > This is an attempt to recude memory consumption of KASAN. Please see
> > following description to get the more information.
> >
> > 1. What is per-page shadow memory
> 
> Hi Joonsoo,

Hello, Dmitry.

> 
> First I need to say that this is great work. I wanted KASAN to consume

Thanks!

> 1/8-th of _kernel_ memory rather than total physical memory for a long
> time.
> 
> However, this implementation does not work inline instrumentation. And
> the inline instrumentation is the main mode for KASAN. Outline
> instrumentation is merely a rudiment to support gcc 4.9, and it needs
> to be removed as soon as we stop caring about gcc 4.9 (do we at all?
> is it the current compiler in any distro? Ubuntu 12 has 4.8, Ubuntu 14
> already has 5.4. And if you build gcc yourself or get a fresher
> compiler from somewhere else, you hopefully get something better than
> 4.9).

Hmm... I don't think that outline instrumentation is something to be
removed. In embedded world, there is a fixed partition table and
enlarging the kernel binary would cause the problem. Changing that
table is possible but is really uncomfortable thing for debugging
something. So, I think that outline instrumentation has it's own merit.

Anyway, I have missed inline instrumentation completely.

I will attach the fix in the bottom. It doesn't look beautiful
since it breaks layer design (some check will be done at report
function). However, I think that it's a good trade-off.

> 
> Here is an example boot+scp log with inline instrumentation:
> https://gist.githubusercontent.com/dvyukov/dfdc8b6972ddd260b201a85d5d5cdb5d/raw/2a032cd5be371c7ad6cad8f14c0a0610e6fa772e/gistfile1.txt
> 
> Joonsoo, can you think of a way to take advantages of your approach,
> but make it work with inline instrumentation?
> 
> Will it work if we map a single zero page for whole shadow initially,
> and then lazily map real shadow pages only for kernel memory, and then
> remap it again to zero pages when the whole KASAN_SHADOW_SCALE_SHIFT
> range of pages becomes unused (similarly to what you do in
> kasan_unmap_shadow())?

Mapping zero page to non-kernel memory could cause true-negative
problem since we cannot flush the TLB in all cpus. We will read zero
shadow value value in this case even if actual shadow value is not
zero. This is one of the reason that black page is introduced in this
patchset.

Thanks.

-------------------->8------------------
