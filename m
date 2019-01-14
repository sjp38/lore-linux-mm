Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9AB8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:08:06 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id z25so1572641lfi.18
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:08:06 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id d7si673251lfi.57.2019.01.14.08.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 08:08:04 -0800 (PST)
Subject: Re: [PATCH] kasan: Remove use after scope bugs detection.
References: <20190111185842.13978-1-aryabinin@virtuozzo.com>
 <CACT4Y+YV+jjcXE1oa=Gf031KAgEy40Nq83x3_nj3TwQpw3b+Ug@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <296f2311-0a11-f4bd-b665-70c3ffad2124@virtuozzo.com>
Date: Mon, 14 Jan 2019 19:08:19 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+YV+jjcXE1oa=Gf031KAgEy40Nq83x3_nj3TwQpw3b+Ug@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Qian Cai <cai@lca.pw>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On 1/14/19 4:24 PM, Dmitry Vyukov wrote:
> On Fri, Jan 11, 2019 at 7:58 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>
>> Use after scope bugs detector seems to be almost entirely useless
>> for the linux kernel. It exists over two years, but I've seen only
>> one valid bug so far [1]. And the bug was fixed before it has been
>> reported. There were some other use-after-scope reports, but they
>> were false-positives due to different reasons like incompatibility
>> with structleak plugin.
>>
>> This feature significantly increases stack usage, especially with
>> GCC < 9 version, and causes a 32K stack overflow. It probably
>> adds performance penalty too.
>>
>> Given all that, let's remove use-after-scope detector entirely.
>>
>> While preparing this patch I've noticed that we mistakenly enable
>> use-after-scope detection for clang compiler regardless of
>> CONFIG_KASAN_EXTRA setting. This is also fixed now.
> 
> Hi Andrey,
> 
> I am on a fence. On one hand removing bug detection sucks and each
> case of a missed memory corruption leads to a splash of assorted bug
> reports by syzbot. On the other hand everything you said is true.
> Maybe support for CONFIG_VMAP_STACK will enable stacks larger then
> PAGE_ALLOC_COSTLY_ORDER?
> 

Yes, with vmap stacks higher order won't be a problem, since vmalloc() does only 0-order 
allocations. But even with vmap stacks use-after-scope won't become useful,
thus I don't see the point of re-enabling it with vmap stacks.
If feature doesn't detect bugs, but waste resources, than it's bad for detecting bugs.
We wasting our limited resources for useless checks, instead of using these resources
for doing more useful checks, running tests faster hence detecting more bugs per-time. 
