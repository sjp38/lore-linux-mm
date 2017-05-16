Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D09F6B0038
	for <linux-mm@kvack.org>; Tue, 16 May 2017 00:48:10 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id c90so49457336uac.15
        for <linux-mm@kvack.org>; Mon, 15 May 2017 21:48:10 -0700 (PDT)
Received: from mail-ua0-x232.google.com (mail-ua0-x232.google.com. [2607:f8b0:400c:c08::232])
        by mx.google.com with ESMTPS id h20si5580106uac.229.2017.05.15.21.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 21:48:09 -0700 (PDT)
Received: by mail-ua0-x232.google.com with SMTP id e28so92664081uah.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 21:48:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com> <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 15 May 2017 21:47:48 -0700
Message-ID: <CACT4Y+aJ+0a=7x5+jZSve3_JT=HMAvx7K_U51mwoUiOY9Cz5ow@mail.gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, May 15, 2017 at 9:34 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Mon, May 15, 2017 at 6:16 PM,  <js1304@gmail.com> wrote:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> Hello, all.
>>
>> This is an attempt to recude memory consumption of KASAN. Please see
>> following description to get the more information.
>>
>> 1. What is per-page shadow memory
>
> Hi Joonsoo,
>
> First I need to say that this is great work. I wanted KASAN to consume
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


Just in case, I've uploaded a squashed version of this to codereview
site, if somebody will find it useful:
https://codereview.appspot.com/325780043
(side-by-side diffs is what you want)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
